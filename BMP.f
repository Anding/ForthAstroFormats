\ Save 16-bit greyscale data as an 8-bit BMP using each sample's high byte.

: save-BMPimage-to { frame bitmap filepath-buffer | ior -- }
\ Save supplied pixels to an explicitly prepared pathname.
    filepath-buffer create-imageDirectory
    0 filepath-buffer echo-buffer abort" BMP filepath buffer full"
    bitmap
    frame FRAME_WIDTH @
    frame FRAME_HEIGHT @
    filepath-buffer buffer-to-string drop
    SaveBitmapAsBMP -> ior
    filepath-buffer backspace-buffer abort" Cannot restore BMP filepath"
    ior abort" Error writing BMP file"
;

: save-BMPimage { frame -- }
\ Save the supplied frame through the normal preview BMP writer.
    frame s" .bmp" preview-BMPfilepath write-filepath-bmp
    frame frame FRAME_BITMAP preview-BMPfilepath save-BMPimage-to
;
