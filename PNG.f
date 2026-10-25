\ Save a 16-bit greyscale frame as an 8-bit PNG at an explicit destination.

: save-PNGimage-to { frame filepath-buffer | filename -- }
    filepath-buffer native-image-filepath -> filename
    filename 0= if exit then
    frame FRAME_BITMAP
    frame FRAME_WIDTH @
    frame FRAME_HEIGHT @
    filename SaveBitmapAsPNG dup .throw if filepath-buffer discard-image-file then
;