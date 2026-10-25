\ Save 16-bit greyscale data as an 8-bit BMP using each sample's high byte.

: save-BMPimage-to { frame bitmap filepath-buffer | filename -- }
\ Save supplied pixels to an explicitly prepared pathname.
    filepath-buffer native-image-filepath -> filename
    filename 0= if exit then
    bitmap
    frame FRAME_WIDTH @
    frame FRAME_HEIGHT @
    filename SaveBitmapAsBMP dup .throw if filepath-buffer discard-image-file then
;

: save-BMPimage { frame -- }
\ Save the supplied frame through the normal preview BMP writer.
    frame s" .bmp" preview-BMPfilepath write-filepath-bmp
    frame frame FRAME_BITMAP preview-BMPfilepath save-BMPimage-to
;
