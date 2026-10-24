\ Format-neutral in-memory astronomy frame.

NEED ForthBase
NEED FiniteFractions
NEED buffers
NEED ordered-maps
NEED Shared

0 shared value image

\ Native double-aligned StarRecord; keep offsets aligned with image_analysis.h.
BEGIN-STRUCTURE StarRecord
    4 +FIELD star.positive-pixel-count \ Zero terminates the list.
    4 +FIELD star.saturated-pixel-count
    8 +FIELD star.x
    8 +FIELD star.y
    8 +FIELD star.flux
    8 +FIELD star.hfd
    8 +FIELD star.qxx
    8 +FIELD star.qyy
    8 +FIELD star.qxy
    8 +FIELD star.max-pixel \ uint16_t followed by six alignment bytes; use W@.
END-STRUCTURE

256 constant maximum-stars
maximum-stars 1+ StarRecord * constant star-buffer-bytes

BEGIN-STRUCTURE FRAME
                4   +FIELD FRAME_WIDTH
                4   +FIELD FRAME_HEIGHT
                4   +FIELD FRAME_DEPTH
                4   +FIELD FRAME_SIZE_BYTES
                4   +FIELD FRAME_CAPACITY_BYTES
                4   +FIELD FRAME_METADATA
                4   +FIELD FRAME_STATISTICS
                4   +FIELD FRAME_PIPELINE
                4   +FIELD FRAME_STARS
                0   +FIELD FRAME_BITMAP
END-STRUCTURE

FRAME constant FRAME_DESCRIPTOR
\ The descriptor and 16-bit pixel planes occupy one allocation. Metadata is a
\ separately owned ordered map; statistics is either zero or an owned analysis
\ allocation. Pipeline state is optional. Every frame owns storage for 256
\ star measurements plus a terminator, initially an empty list.

: allocate-frame { width height depth | bytes frame -- frame }
\ depth is the number of 16-bit planes. FRAME_BITMAP begins immediately after
\ the descriptor so native camera and codec words can receive a plain address.
    width height depth 2* * * -> bytes
    bytes FRAME_DESCRIPTOR + allocate abort" unable to allocate frame" -> frame
    bytes frame FRAME_SIZE_BYTES !
    bytes frame FRAME_CAPACITY_BYTES !
    depth frame FRAME_DEPTH !
    height frame FRAME_HEIGHT !
    width frame FRAME_WIDTH !
    frame FRAME_BITMAP bytes erase
    allocate-map frame FRAME_METADATA !
    0 frame FRAME_STATISTICS !
    0 frame FRAME_PIPELINE !
    star-buffer-bytes allocate abort" unable to allocate star list"
    dup star-buffer-bytes erase frame FRAME_STARS !
    frame
;

: free-frame ( frame -- )
    dup FRAME_METADATA @ ?dup if free-map then
    dup FRAME_STATISTICS @ ?dup if free drop then
    dup FRAME_PIPELINE @ ?dup if free throw then
    dup FRAME_STARS @ free throw
    free drop
;

: reset-frame-metadata ( frame -- )
    FRAME_METADATA @ erase-map
;

: frame-size ( frame -- size-in-bytes )
    FRAME_SIZE_BYTES @
;

: frame-capacity ( frame -- size-in-bytes )
\ Return the immutable allocation capacity, distinct from the active ROI size.
    FRAME_CAPACITY_BYTES @
;

: initialize-frame { frame | map x y -- }
\ Camera download geometry may be smaller than the original full-frame
\ allocation after subframing. This updates logical dimensions only.
    frame FRAME_METADATA @ -> map
    s" NAXIS1" map map@ toInteger -> x
    s" NAXIS2" map map@ toInteger -> y
    x frame FRAME_WIDTH !
    y frame FRAME_HEIGHT !
    x y * 2 * frame FRAME_SIZE_BYTES !
;
