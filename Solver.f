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
    astro.root filepath-buffer write-buffer ?dup if exit then
    s" working" filepath-buffer append-path
    filepath-buffer buffer_used 0= if -1 exit then
    '\' filepath-buffer echo-buffer
    s" UUID" img FRAME_METADATA @ map@ filepath-buffer write-buffer or
    '\' filepath-buffer echo-buffer or
    filepath-buffer buffer-punctuate-filepath
    s" solve" filepath-buffer write-buffer or
    suffix-addr suffix-u filepath-buffer write-buffer or
;

: solver.save-temp-FITS { img filepath-buffer path-action -- }
\ Explicit private paths need not alter the science writer's action.
    img s" .fits" filepath-buffer path-action execute
    img filepath-buffer save-FITSimage-to
;

: solver.import-WCS { caddr u img | metadata fileid -- ior }
\ Merge ordinary WCS FITS cards into the frame's ordered metadata.
    img FRAME_METADATA @ -> metadata
    caddr u r/o open-file dup .throw ?dup if nip exit then -> fileid
    s"  " metadata =>" #ASTROMETRY"
    begin
        solver.wcs-line 255 fileid read-line dup .throw
        ?dup if >R 2drop fileid close-file .throw R> exit then
    while
        solver.wcs-line swap FITS.read-line
        dup 0= if
            drop metadata map!
        else
            drop
        then
    repeat
    drop fileid close-file dup .throw
;
