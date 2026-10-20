\ FITS loading into a format-neutral FRAME.

256 buffer: XISF.FITSloadline
\ The loader accepts this project's 16-bit, two-axis primary images. It reuses
\ the shared FITS header buffer and is therefore synchronous/non-reentrant.

: xisf.open-FITSfile ( caddr u -- fileid 0 | ior )
    r/o open-file dup if ." Cannot open FITS file" then
;

: xisf.scanFITS-for-metadata { frame | map -- }
    frame FRAME_METADATA @ -> map
    fits.header-buffer buffer-to-string
    begin
        over 80 FITS.read-line >R
        R@ 0= if map map! then
    R> 1 <> while
        80 /string
        dup 0= if ." Unexpected EOF" 2drop exit then
    repeat
    2drop
;

: XISF.scan-FITSgeometry { fileid | NAXIS1 NAXIS2 depth -- width height depth }
\ FRAME depth is a plane count; the supported FITS NAXIS=2 image maps to one
\ greyscale plane. Higher-dimensional FITS images are outside this codec.
    begin
        XISF.FITSloadline dup 80 fileid read-line drop
        0= if ." Unexpected EOF" 2drop 0 0 0 exit then
        FITS.read-line >R
        R@ 0= if
            hash$ case
                [ s" NAXIS" hash$ ] literal of toInteger 2/ -> depth endof
                [ s" NAXIS1" hash$ ] literal of toInteger -> NAXIS1 endof
                [ s" NAXIS2" hash$ ] literal of toInteger -> NAXIS2 endof
                nip nip
            endcase
        then
    R> 1 = until
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

: XISF.read-FITSfile { fileid frame -- }
\ Re-read the fixed header into fits.header-buffer, then read exactly the
\ logical frame bytes; FITS block padding is deliberately ignored.
    0 0 fileid reposition-file drop
    fits.header-buffer reset-buffer
    fits.header-buffer FITS_HEADER_SIZE fileid buffer-read-file 2drop
    frame FRAME_BITMAP frame frame-size fileid read-file 2drop
    frame FRAME_BITMAP frame frame-size reverseConvertDataFITS
    fileid close-file drop
;

: xisf.load-FITSfile { caddr u | fileid frame -- frame 0 | ior }
    caddr u xisf.open-FITSfile if abort" failed to open FITS file" then -> fileid
    fileid XISF.scan-FITSgeometry ?dup if
        allocate-frame -> frame
        fileid frame XISF.read-FITSfile
        frame xisf.scanFITS-for-metadata
        frame 0
    else
        2drop
        fileid close-file drop
        -1
    then
;
