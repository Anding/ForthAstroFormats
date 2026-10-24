\ Shared plate-solver contract and solver-independent metadata operations.

NEED ForthAstroFormats

256 buffer: solver.wcs-line

: no-solver { img -- failed? }
    s" FAILED" img FRAME_METADATA @ =>" SOLVSTAT"
    -1
;

DEFER solve-image ( img -- failed? )
ASSIGN no-solver TO-DO solve-image

DEFER solver.solved-metadata ( metadata -- )
\ Add application metadata after a successful solve has imported its WCS.
ASSIGN drop TO-DO solver.solved-metadata

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
