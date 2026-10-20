\ Format-neutral in-memory astronomy frame.

NEED ForthBase
NEED FiniteFractions
NEED buffers
NEED ordered-maps
NEED Shared

0 shared value image

256 constant FILEPATH_SIZE

BEGIN-STRUCTURE FRAME
                4   +FIELD FRAME_WIDTH
                4   +FIELD FRAME_HEIGHT
                4   +FIELD FRAME_DEPTH
                4   +FIELD FRAME_SIZE_BYTES
                4   +FIELD FRAME_CAPACITY_BYTES
                4   +FIELD FRAME_METADATA
                4   +FIELD FRAME_STATISTICS
                0   +FIELD FRAME_BITMAP
END-STRUCTURE

FRAME constant FRAME_DESCRIPTOR
\ The descriptor and 16-bit pixel planes occupy one allocation. Metadata is a
\ separately owned ordered map; statistics is either zero or an owned analysis
\ allocation. free-frame releases all three ownership layers.

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
    frame
;

: free-frame ( frame -- )
    dup FRAME_METADATA @ ?dup if free-map then
    dup FRAME_STATISTICS @ ?dup if free drop then
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

: IsFITSnumchar? ( c -- flag )
    >R 0
    R@ '+' = OR
    R@ '-' = OR
    R@ '.' = OR
    R@ 'E' = OR
    R@ 'e' = OR
    R> '0' '9' within? OR
;

s" " $value FITSstringBuf

: StrToFITSStr ( caddr u -- caddr u )
    dup 0= if 2drop s" ''" exit then
    2dup -1 -rot over + swap do i c@ IsFITSnumchar? and dup 0= if leave then loop
    0= if
        s" '" $-> FITSstringBuf $+> FITSstringBuf s" '" $+> FITSstringBuf FITSstringBuf
    then
;

: FITSstrToStr ( caddr u -- caddr u )
    dup if over c@ ''' = if 2 - swap 1 + swap then then
;

: valid-filepath-folder? { filepath-buffer | folder-u -- flag }
\ Require a drive prefix and a recorded folder wholly inside the used buffer.
    filepath-buffer BUFFER_LEN_DIR @ -> folder-u
    folder-u 3 >=
    folder-u filepath-buffer buffer_used <= and
;

: create-imageDirectory ( filepath-buffer -- )
    dup valid-filepath-folder? 0= abort" Filepath folder not punctuated"
    >R
    R@ buffer-drive-to-string R> buffer-dir-to-string makeDirLevels abort" cannot create image directory"
;
