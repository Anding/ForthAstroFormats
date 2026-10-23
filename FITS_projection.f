\ Ordered UTF-8 projection of a FITS map for metadata viewers and WCS sidecars.

NEED ForthAstroFormats
NEED ForthPublication

16384 constant FITS_PROJECTION_SIZE

: XISF.mapIterProjection { buf key-addr key-u value-addr value-u -- buf }
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
    filepath-buffer buffer-to-string w/o
        create-file abort" Cannot create FITS projection" -> fileid
    FITS_PROJECTION_SIZE allocate-buffer -> projection-buffer
    projection-buffer ['] XISF.mapIterProjection map map-for-each drop
    projection-buffer fileid buffer-to-file
    projection-buffer free-buffer
    fileid close-file abort" Cannot close FITS projection"
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
