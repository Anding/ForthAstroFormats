\ Save a 16-bit greyscale frame as a raw binary file at an explicit destination.

: SaveBitmapAsBinary { bitmap width height caddr | fileid bitdepth t -- IOR }
\ AIMG is a deliberately small native interchange format: magic, width,
\ height, bit depth, reserved cell, then host-endian 16-bit pixels.
    caddr zcount w/o create-file dup if nip exit then drop -> fileid
    s" AIMG" fileid write-file
    ADDR width 4 fileid write-file or
    ADDR height 4 fileid write-file or
    16 -> bitdepth
    ADDR bitdepth 4 fileid write-file or
    0 -> t
    ADDR t 4 fileid write-file or
    bitmap width height * 2* fileid write-file or
    fileid close-file or dup if caddr zcount delete-file drop then
;

: save-RAWimage-to { frame filepath-buffer | filename -- }
    filepath-buffer native-image-filepath -> filename
    filename 0= if exit then
    frame FRAME_BITMAP
    frame FRAME_WIDTH @
    frame FRAME_HEIGHT @
    filename SaveBitmapAsBinary dup .throw if filepath-buffer discard-image-file then
;