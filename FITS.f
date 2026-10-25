\ FITS codec for format-neutral FRAME values.

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

11520 constant FITS_HEADER_SIZE
FITS_HEADER_SIZE allocate-buffer constant fits.header-buffer
16 2880 * constant FITS_TRANSFER_SIZE
create fits.pixel-buffer FITS_TRANSFER_SIZE allot
\ Header and transfer storage are shared synchronous scratch buffers. The
\ codec is intentionally non-reentrant; the imaging pipeline serializes saves.

: FITS.map-iterate { buf key-addr key-u value-addr value-u -- buf }
    key-u 8 > if buf exit then
    key-addr key-u buf write-buffer drop
    8 key-u ?do bl buf echo-buffer drop loop
    s" = " buf write-buffer drop
    value-addr value-u 68 min StrToFITSStr
    2dup buf write-buffer drop
    70 swap ?do bl buf echo-buffer drop loop
    drop buf
;

: FITS.write-map ( map buf -- )
    ['] FITS.map-iterate rot map-for-each drop
;

CODE convertDataFITS ( src dst n -- )
\ Convert unsigned little-endian camera words to FITS signed big-endian words.
\ BZERO=32768 in the header reconstructs the original unsigned sample values.
    mov     edx, 4 [ebp]
    mov     ecx, 0 [ebp]
    test    ebx, ebx
    jz      L$2
L$1:
    cmp     ebx, 2
    jb      L$2
    movzx   ax, word 0 [edx]
    sub     ax, 32768
    xchg    al, ah
    mov     word 0 [ecx], ax
    add     edx, 2
    add     ecx, 2
    sub     ebx, 2
    jmp     L$1
L$2:
    mov ebx, 08 [ebp]
    lea ebp, 12 [ebp]
    NEXT,
END-CODE

: FITS.encode-header { frame header-buffer -- ior }
\ FITS cards retain ordered-map insertion order. Unused fixed-header cards are
\ blank-filled before END so pixel data always starts at FITS_HEADER_SIZE.
    header-buffer reset-buffer
    s" SIMPLE  = T                                                                     " header-buffer write-buffer drop
    frame FRAME_METADATA @ header-buffer FITS.write-map
    header-buffer buffer_space 80 < if cr ." FITS header buffer full" cr -1 exit then
    header-buffer buffer_space 80 / 1- 0 ?do
        s"                                                                                 " header-buffer write-buffer drop
    loop
    s" END                                                                             " header-buffer write-buffer drop
    0
;

: FITS.write-pixels { frame fileid | source remaining chunk padding -- ior }
\ Convert bounded chunks directly to the FITS byte order and unsigned offset.
    frame FRAME_BITMAP -> source
    frame frame-size -> remaining
    begin
        remaining
    while
        remaining FITS_TRANSFER_SIZE min -> chunk
        source fits.pixel-buffer chunk convertDataFITS
        fits.pixel-buffer chunk fileid write-file
            ?dup if exit then
        source chunk + -> source
        remaining chunk - -> remaining
    repeat
    frame frame-size 2880 mod dup if 2880 swap - then -> padding
    padding if
        fits.pixel-buffer padding erase
        fits.pixel-buffer padding fileid write-file exit
    then
    0
;

: save-FITSimage-to { frame filepath-buffer | fileid -- }
\ Save a FITS frame to an explicitly prepared pathname.
    filepath-buffer buffer_used 0= if exit then
    frame fits.header-buffer FITS.encode-header if filepath-buffer reset-buffer exit then
    filepath-buffer open-publication-file -> fileid
    fileid 0= if exit then
    fileid
    fits.header-buffer BUFFER_ADDR FITS_HEADER_SIZE fileid write-file
    frame fileid FITS.write-pixels or filepath-buffer finish-image-file
;

: save-FITSframe-to { frame filepath-buffer -- }
\ Save a selected frame through the configured FITS writer.
    frame s" .fits" filepath-buffer write-filepath-fits
    frame filepath-buffer save-FITSimage-to
;

: save-FITSimage ( frame -- )
\ Save the supplied frame and retain its resulting FITS pathname.
    FITSfilepath save-FITSframe-to
;
