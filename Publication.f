\ Preview, histogram, metadata projection and manifest publication.

: write-manifest-line { fileid key-addr key-u value-addr value-u -- ior }
\ Write one quoted key/value manifest record.
    key-addr key-u fileid write-file ?dup if exit then
    s\" : \"" fileid write-file ?dup if exit then
    value-addr value-u fileid write-file ?dup if exit then
    s\" \"\r\n" fileid write-file
;

: write-manifest-path { filepath-buffer fileid -- ior }
\ Write a Windows pathname as a JSON-style string value.
    0
    filepath-buffer buffer-to-string bounds ?do
        i c@ '\' = if
            s" \\" fileid write-file
        else
            i 1 fileid write-file
        then
        or
    loop
;

: write-path-manifest-line { fileid key-addr key-u filepath-buffer -- ior }
\ Write one manifest record containing an authoritative generated filepath.
    key-addr key-u fileid write-file ?dup if exit then
    s\" : \"" fileid write-file ?dup if exit then
    filepath-buffer fileid write-manifest-path ?dup if exit then
    s\" \"\r\n" fileid write-file
;

: save-binary-file-to
    { data-addr data-u filepath-buffer | fileid -- }
\ Save one binary artifact to an explicitly prepared pathname.
    filepath-buffer open-publication-file -> fileid
    fileid if fileid data-addr data-u fileid write-file filepath-buffer finish-image-file then
;

: no-preview-manifest-extension ( fileid -- ior )
\ Default extension action: append no additional manifest records.
    drop 0
;

\ Optional ( fileid -- ior ) action; append records without closing the manifest.
DEFER write-preview-manifest-extension ( fileid -- ior )
ASSIGN no-preview-manifest-extension TO-DO write-preview-manifest-extension

: write-frame-manifest-lines { frame fileid -- ior }
    fileid s" image name" s" UUID" frame FRAME_METADATA @ map@ write-manifest-line
    fileid s" time-stamp" s" DATE-END" frame FRAME_METADATA @ map@ write-manifest-line or
;

: publish-preview-manifest { frame preview? histogram? | fileid -- }
\ Atomically publish selected artifacts which exist for the supplied frame.
\ Resolve every selected path afresh; shared buffers may refer to an older frame.
    preview? preview-BMPfilepath buffer_used 0<> and
        stretched-BMPfilepath buffer_used 0<> and -> preview?
    histogram? histogram-filepath buffer_used 0<> and -> histogram?
    preview? if
        frame s" .bmp" preview-BMPfilepath write-filepath-bmp
        frame s" .bmp" stretched-BMPfilepath write-filepath-stretched-bmp
        preview-BMPfilepath buffer-to-string FileExists?
        stretched-BMPfilepath buffer-to-string FileExists? and -> preview?
    then
    histogram? if
        frame s" .bin" histogram-filepath write-filepath-histogram
        histogram-filepath buffer-to-string FileExists? -> histogram?
    then
    frame s" .dat" preview-manifest-filepath
        write-filepath-preview-manifest
    frame s" .tmp" preview-manifest-tmp-filepath
        write-filepath-preview-manifest
    preview-manifest-tmp-filepath open-publication-file -> fileid
    fileid 0= if preview-manifest-filepath reset-buffer exit then
    0
    preview? if
        fileid s" image filepath" preview-BMPfilepath
            write-path-manifest-line or
        fileid s" stretched image filepath" stretched-BMPfilepath
            write-path-manifest-line or
    then
    histogram? if
        fileid s" histogram filepath" histogram-filepath
            write-path-manifest-line or
    then
    frame fileid write-frame-manifest-lines or
    fileid s" filter" s" FILTER" frame FRAME_METADATA @ map@ write-manifest-line or
    fileid s" focuser position" s" FOCUSPOS" frame FRAME_METADATA @ map@ write-manifest-line or
    fileid s" exposure seconds" s" EXPTIME" frame FRAME_METADATA @ map@ write-manifest-line or
    fileid write-preview-manifest-extension or
    fileid swap preview-manifest-tmp-filepath finish-image-file
    preview-manifest-tmp-filepath buffer_used 0= if preview-manifest-filepath reset-buffer exit then
    preview-manifest-tmp-filepath preview-manifest-filepath
        replace-file-atomically
;

: publish-metadata-manifest { frame | fileid -- }
\ Atomically publish the supplied frame's FITS-key projection path.
    frame s" .dat" metadata-manifest-filepath
        write-filepath-metadata-manifest
    frame s" .tmp" metadata-manifest-tmp-filepath
        write-filepath-metadata-manifest
    FITSprojection-filepath buffer_used 0= if exit then
    metadata-manifest-tmp-filepath open-publication-file -> fileid
    fileid 0= if metadata-manifest-filepath reset-buffer exit then
    fileid s" fits keys filepath" FITSprojection-filepath
        write-path-manifest-line
    frame fileid write-frame-manifest-lines or
    fileid swap metadata-manifest-tmp-filepath finish-image-file
    metadata-manifest-tmp-filepath buffer_used 0= if metadata-manifest-filepath reset-buffer exit then
    metadata-manifest-tmp-filepath metadata-manifest-filepath
        replace-file-atomically
;

16384 constant FITS_PROJECTION_SIZE \ Maximum allocated FITS projection bytes.

: XISF.mapIterProjection { buf key-addr key-u value-addr value-u -- buf }
\ Append one tab-separated map entry to the retained projection buffer.
    key-addr key-u buf write-buffer drop
    9 buf echo-buffer drop
    value-addr value-u buf write-buffer drop
    13 buf echo-buffer drop
    10 buf echo-buffer drop
    buf
;

: FITS.projection-item-size { total key-addr key-u value-addr value-u -- total' }
\ Add one entry's key/value lengths and separators to the running byte count.
    total key-u + value-u + 3 +
;

: save-FITSprojection-to { img filepath-buffer | projection-buffer map -- }
\ Projection files are small transient publications, so one bounded buffer is
\ allocated per write and released before returning.
    img FRAME_METADATA @ -> map
    filepath-buffer buffer_used 0= if exit then
    0 ['] FITS.projection-item-size map map-for-each FITS_PROJECTION_SIZE > if
        cr ." FITS projection buffer full" cr filepath-buffer reset-buffer exit
    then
    FITS_PROJECTION_SIZE allocate-buffer -> projection-buffer
    projection-buffer ['] XISF.mapIterProjection map map-for-each drop
    projection-buffer buffer-to-string filepath-buffer save-binary-file-to
    projection-buffer free-buffer
;

: save-FITSprojection { frame -- }
\ Save the supplied frame's viewer projection through its dedicated writer.
    frame s" .wcs" FITSprojection-filepath write-filepath-fits-projection
    frame FITSprojection-filepath save-FITSprojection-to
;

: save-WCSprojection { frame -- }
\ Save the supplied frame's WCS sidecar through its dedicated writer.
    frame s" .wcs" WCSfilepath write-filepath-wcs
    frame WCSfilepath save-FITSprojection-to
;

: save-Histogram-file { frame -- }
\ Save 65,536 four-byte bins without publishing a partially completed preview.
    frame s" .bin" histogram-filepath write-filepath-histogram
    frame FRAME_STATISTICS @ HISTOGRAM 0x40000 histogram-filepath
        save-binary-file-to
;

: save-Histogram { frame -- }
\ Save and independently publish available preview artifacts for direct callers.
    frame save-Histogram-file
    histogram-filepath buffer_used 0= if exit then
    frame -1 -1 publish-preview-manifest
;
