\ Shared plate-solver contract and solver-independent metadata operations.

NEED ForthAstroFormats
NEED AstroCalc

256 buffer: solver.wcs-line
s" " $value solver.alignment-command

: no-solver { img -- failed? }
    s" FAILED" img FRAME_METADATA @ =>" SOLVSTAT"
    -1
;

DEFER solve-image ( img -- failed? )
ASSIGN no-solver TO-DO solve-image

: solver.import-WCS { caddr u img | metadata fileid -- }
\ Merge ordinary WCS FITS cards into the frame's ordered metadata.
    img FRAME_METADATA @ -> metadata
    caddr u r/o open-file abort" Cannot open solver WCS file" -> fileid
    begin
        solver.wcs-line 255 fileid read-line
            abort" Cannot read solver WCS file"
    while
        solver.wcs-line swap FITS.read-line
        dup 0= if
            drop metadata map!
        else
            drop
        then
    repeat
    drop
    fileid close-file abort" Cannot close solver WCS file"
;

: solver.~Dec$ ( deg-min-sec -- caddr u )
    ':' ':' -1 ~custom$
;

: solver.~RA$ ( hr-min-sec -- caddr u )
    ':' ':' 0 ~custom$
    s" HH:MM:SS.0" drop dup >R
    swap move R> 10
;

: solver.alignment-part { caddr u separator | low high rest remaining -- rest u' n }
\ Parse a required integer component and consume its separator.
    0 0 caddr u >number -> remaining -> rest -> high -> low
    remaining u = remaining 0= or high 0<> or
        abort" Invalid alignment component"
    rest c@ separator <> abort" Invalid alignment separator"
    rest 1+ remaining 1- low
;

: solver.alignment-number~ { caddr u separator | sign x y -- n }
\ Validate all three fields before constructing a finite fraction.
    u 0= abort" Missing alignment input"
    caddr u check-sign -> sign -> u -> caddr
    caddr u separator solver.alignment-part -> x
    separator solver.alignment-part -> y
    -white dup 0= abort" Missing alignment component"
    >float 0= abort" Invalid alignment component"
    f>s x y rot ~ sign *
;

: solver.alignment-night~ { caddr u | sign result low high rest remaining -- n }
\ Numeric dates retain the legacy finite-fraction encoding without reading
\ beyond the input when fewer than three components are present.
    caddr u >float 0= if
        caddr u '-' solver.alignment-number~ exit
    then
    fdrop
    caddr u check-sign -> sign -> u -> caddr
    0 -> result
    3 0 do
        result ffBasis * -> result
        u if
            0 0 caddr u >number -> remaining -> rest -> high -> low
            remaining u = high 0<> or abort" Invalid alignment date"
            result low + -> result
            remaining if
                rest 1+ -> caddr
                remaining 1- -> u
            else
                0 -> u
            then
        then
    loop
    result sign *
;

: solver.alignment-FITS { metadata |
    reported-ra reported-dec sidereal night-of
    solved-ra solved-dec pierside-addr pierside-u -- }
\ Derive the 10Micron alignment command once from the completed solve context.
    s" OBJCTRA" metadata map@ ':' solver.alignment-number~ -> reported-ra
    s" OBJCTDEC" metadata map@ ':' solver.alignment-number~ -> reported-dec
    s" SIDEREAL" metadata map@ ':' solver.alignment-number~ -> sidereal
    s" NIGHTOF" metadata map@ -white dup 0= abort" Missing alignment NIGHTOF"
        solver.alignment-night~ -> night-of
    s" PIERSIDE" metadata map@ -> pierside-u -> pierside-addr
    pierside-addr pierside-u s" EAST" compare 0<>
    pierside-addr pierside-u s" WEST" compare 0<> and
        abort" Invalid alignment pierside"
    s" CRVAL1" metadata map@ -white dup 0= abort" Missing alignment CRVAL1"
        >float 0= abort" Invalid alignment CRVAL1"
        1.5E1 f/ fp~ -> solved-ra
    s" CRVAL2" metadata map@ -white dup 0= abort" Missing alignment CRVAL2"
        >float 0= abort" Invalid alignment CRVAL2"
        fp~ -> solved-dec

    s\" s\" " $-> solver.alignment-command
    reported-ra reported-dec night-of JNOW swap
    solver.~RA$ $+> solver.alignment-command
    s" ," $+> solver.alignment-command
    solver.~Dec$ $+> solver.alignment-command
    s" ," $+> solver.alignment-command
    pierside-addr pierside-u 0> if 1 else 0 then
        $+> solver.alignment-command
    s" ," $+> solver.alignment-command
    solved-ra solved-dec night-of JNOW swap
    solver.~RA$ $+> solver.alignment-command
    s" ," $+> solver.alignment-command
    solver.~Dec$ $+> solver.alignment-command
    s" ," $+> solver.alignment-command
    sidereal solver.~RA$ $+> solver.alignment-command
    s\" \" add-alignment-point" $+> solver.alignment-command
    solver.alignment-command metadata =>" 10UALPT"
;
