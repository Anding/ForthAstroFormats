\ Save 16-bit greyscale data as an 8-bit BMP using each sample's high byte.

: save-BMPimage-to { frame bitmap filepath-buffer | filename temporary-buffer -- }
\ Replace only a completed bitmap at the fixed preview pathname.
    filepath-buffer image-temporary-filepath -> temporary-buffer
    temporary-buffer native-image-filepath -> filename
    filename if
        bitmap frame FRAME_WIDTH @ frame FRAME_HEIGHT @
        filename SaveBitmapAsBMP dup .throw if temporary-buffer discard-image-file then
    then
    temporary-buffer buffer_used if
        temporary-buffer filepath-buffer replace-file-atomically
    else
        filepath-buffer reset-buffer
    then
    temporary-buffer free-buffer
;

: save-BMPimage { frame -- }
\ Save the supplied frame through the normal preview BMP writer.
    frame s" .bmp" preview-BMPfilepath write-filepath-bmp
    frame frame FRAME_BITMAP preview-BMPfilepath save-BMPimage-to
;
