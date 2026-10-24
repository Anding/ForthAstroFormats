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

: solver.mark-solved { solver-addr solver-u metadata -- }
\ Record engine identity and success before the application's solved hook.
    solver-addr solver-u metadata =>" SOLVER"
    s" SOLVED" metadata =>" SOLVSTAT"
    metadata solver.solved-metadata
;

: solver.temp-FITSfilepath { img suffix-addr suffix-u filepath-buffer -- full? }
\ Compose the common private solver path, leaving the final buffer-full flag.
    filepath-buffer reset-buffer
    astro.root filepath-buffer write-buffer drop
    s" working" filepath-buffer append-path
    '\' filepath-buffer echo-buffer drop
    s" UUID" img FRAME_METADATA @ map@ filepath-buffer write-buffer drop
    '\' filepath-buffer echo-buffer drop
    filepath-buffer buffer-punctuate-filepath
    s" solve" filepath-buffer write-buffer drop
    suffix-addr suffix-u filepath-buffer write-buffer
;

: solver.save-temp-FITS { img filepath-buffer path-action | saved-path ior -- }
\ Write through a temporary pathname action and restore it even on failure.
    ACTION-OF write-filepath-fits -> saved-path
    path-action TO-DO write-filepath-fits
    img filepath-buffer ['] save-FITSframe-to catch -> ior
    saved-path TO-DO write-filepath-fits
    ior ?dup if throw then
;

: solver.import-WCS { caddr u img | metadata fileid -- }
\ Merge ordinary WCS FITS cards into the frame's ordered metadata.
    img FRAME_METADATA @ -> metadata
    caddr u r/o open-file abort" Cannot open solver WCS file" -> fileid
    s"  " metadata =>" #ASTROMETRY"
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
