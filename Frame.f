\ Format-neutral in-memory astronomy frame.

NEED ForthBase
NEED FiniteFractions
NEED buffers
NEED ordered-maps
NEED Shared

0 shared value image


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
\ allocation. Pipeline state and star measurements are optional owned blocks;
\ their layouts belong to the imaging and analysis vocabularies.

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
    0 frame FRAME_STARS !
    frame
;

: free-frame ( frame -- )
    dup FRAME_METADATA @ ?dup if free-map then
    dup FRAME_STATISTICS @ ?dup if free drop then
    dup FRAME_PIPELINE @ ?dup if free throw then
    dup FRAME_STARS @ ?dup if free throw then
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
