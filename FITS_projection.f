\ Ordered UTF-8 projection of a FITS map for metadata viewers and WCS sidecars.

NEED ForthAstroFormats
NEED ForthPublication
NEED ForthVT100

16384 constant FITS_PROJECTION_SIZE

0 value FITS.projection-debug
1024 allocate-buffer constant FITS.projection-log-buffer

: FITS.projection-log ( caddr u -- )
    FITS.projection-debug if
        s" fits-projection" 2swap log-line
    else
        2drop
    then
;

: FITS.projection-log-item { key-addr key-u value-addr value-u | buf -- }
    FITS.projection-debug LOG and 0= if exit then
    FITS.projection-log-buffer -> buf
    buf reset-buffer
    key-addr key-u buf write-buffer abort" Projection log buffer full"
    s"  length=" buf write-buffer abort" Projection log buffer full"
    value-u (.) buf write-buffer abort" Projection log buffer full"
    s"  bytes=" buf write-buffer abort" Projection log buffer full"
    value-u 0 ?do
        value-addr i + c@ 16 /mod
        s" 0123456789ABCDEF" drop + c@
        buf echo-buffer abort" Projection log buffer full"
        s" 0123456789ABCDEF" drop + c@
        buf echo-buffer abort" Projection log buffer full"
    loop
    buf buffer-to-string FITS.projection-log
;

: XISF.mapIterProjection { buf key-addr key-u value-addr value-u -- buf }
    key-addr key-u FITS.projection-log
    key-addr key-u value-addr value-u FITS.projection-log-item
    key-addr key-u buf write-buffer abort" FITS projection buffer full"
    9 buf echo-buffer abort" FITS projection buffer full"
    value-addr value-u buf write-buffer abort" FITS projection buffer full"
    13 buf echo-buffer abort" FITS projection buffer full"
    10 buf echo-buffer abort" FITS projection buffer full"
    buf
;

: FITS.projection-item-size { total key-addr key-u value-addr value-u -- total' }
    total key-u + value-u + 3 +
;

: FITS.projection-size ( map -- size )
\ Account for key, tab, value, CR, and LF before allocating publication state.
    0 ['] FITS.projection-item-size rot map-for-each
;

: save-FITSprojection-to { img filepath-buffer | fileid projection-buffer map -- }
\ Projection files are small transient publications, so one bounded buffer is
\ allocated per write and released before returning.
    img FRAME_METADATA @ -> map
    map FITS.projection-size FITS_PROJECTION_SIZE >
        abort" FITS projection buffer full"
    filepath-buffer create-imageDirectory
    s" create-file start" FITS.projection-log
    filepath-buffer buffer-to-string w/o
        create-file abort" Cannot create FITS projection" -> fileid
    s" allocate start" FITS.projection-log
    FITS_PROJECTION_SIZE allocate-buffer -> projection-buffer
    s" iteration start" FITS.projection-log
    projection-buffer ['] XISF.mapIterProjection map map-for-each drop
    s" write start" FITS.projection-log
    projection-buffer fileid buffer-to-file
    s" free start" FITS.projection-log
    projection-buffer free-buffer
    s" close start" FITS.projection-log
    fileid close-file abort" Cannot close FITS projection"
    s" projection complete" FITS.projection-log
;

: save-FITSprojection ( -- )
\ Save the current frame's viewer projection through its dedicated writer.
    image s" .dat" FITSprojection-filepath write-filepath-fits-projection
    image FITSprojection-filepath save-FITSprojection-to
;

: save-WCSprojection ( -- )
\ Save the current frame's WCS sidecar through its dedicated writer.
    image s" .wcs" WCSfilepath write-filepath-wcs
    image WCSfilepath save-FITSprojection-to
;
