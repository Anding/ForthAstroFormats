\ FITS loading into a format-neutral FRAME.

\ The loader accepts this project's 16-bit, two-axis primary images. It reuses
\ the shared FITS header buffer and is therefore synchronous/non-reentrant.

: xisf.open-FITSfile ( caddr u -- fileid 0 | ior )
    r/o open-file dup if nip cr ." Cannot open FITS file" cr then
;

: xisf.scanFITS-for-metadata { frame | map -- }
    frame FRAME_METADATA @ -> map
    fits.header-buffer buffer-to-string bounds ?do
        i 80 FITS.read-line dup 0= if drop map map! else 1 = if leave then then
    80 +loop
;

: XISF.scan-FITSgeometry { fileid | NAXIS1 NAXIS2 depth -- width height depth }
\ FRAME depth is a plane count; the supported FITS NAXIS=2 image maps to one
\ greyscale plane. Higher-dimensional FITS images are outside this codec.
    0 -> NAXIS1 0 -> NAXIS2 0 -> depth
    fits.header-buffer reset-buffer
    fits.header-buffer FITS_HEADER_SIZE fileid buffer-read-file
    swap FITS_HEADER_SIZE <> or if cr ." Cannot read FITS header" cr 0 0 0 exit then
    fits.header-buffer buffer-to-string bounds ?do
        i 80 FITS.read-line >R
        R@ 0= if
            hash$ case
                [ s" NAXIS" hash$ ] literal of toInteger 2/ -> depth endof
                [ s" NAXIS1" hash$ ] literal of toInteger -> NAXIS1 endof
                [ s" NAXIS2" hash$ ] literal of toInteger -> NAXIS2 endof
                nip nip
            endcase
        then
        R> 1 = if
            i fits.header-buffer BUFFER_ADDR - 80 + 2879 + 2880 / 2880 *
            0 fileid reposition-file dup .throw if 0 -> depth then
            leave
        then
    80 +loop
    NAXIS1 NAXIS2 depth
;

CODE reverseConvertDataFITS ( src n -- )
\ In-place inverse of convertDataFITS after reading the FITS pixel attachment.
    mov     edx, 0 [ebp]
    test    ebx, ebx
    jz      L$2
L$1:
    cmp     ebx, 2
    jb      L$2
    movzx   ax, word 0 [edx]
    xchg    al, ah
    add     ax, 32768
    mov     word 0 [edx], ax
    add     edx, 2
    sub     ebx, 2
    jmp     L$1
L$2:
    mov ebx, 04 [ebp]
    lea ebp, 08 [ebp]
    NEXT,
END-CODE

: xisf.load-FITSfile { caddr u | fileid frame -- frame 0 | ior }
    caddr u xisf.open-FITSfile ?dup if exit then -> fileid
    fileid XISF.scan-FITSgeometry ?dup if
        allocate-frame -> frame
        frame FRAME_BITMAP frame frame-size fileid read-file swap frame frame-size <> or
        fileid close-file or dup .throw ?dup if frame free-frame exit then
        frame FRAME_BITMAP frame frame-size reverseConvertDataFITS
        frame xisf.scanFITS-for-metadata
        frame 0
    else
        2drop
        fileid close-file drop
        -1
    then
;
