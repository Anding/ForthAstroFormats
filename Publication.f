\ Preview, histogram, metadata projection and manifest publication.

NEED ForthAstroFormats
NEED ForthAtomicFile

: open-publication-file { filepath-buffer | fileid -- fileid }
\ Create the selected publication file and any missing parent directories.
    filepath-buffer create-imageDirectory
    filepath-buffer buffer-to-string w/o
        create-file abort" Cannot create publication file" -> fileid
    fileid
;

: write-manifest-line { fileid key-addr key-u value-addr value-u -- }
\ Write one quoted key/value manifest record.
    key-addr key-u fileid write-file abort" Cannot write manifest"
    s\" : \"" fileid write-file abort" Cannot write manifest"
    value-addr value-u fileid write-file abort" Cannot write manifest"
    s\" \"\r\n" fileid write-file abort" Cannot write manifest"
;

: write-manifest-path { filepath-buffer fileid -- }
\ Write a Windows pathname as a JSON-style string value.
    filepath-buffer buffer-to-string bounds ?do
        i c@ '\' = if
            s" \\" fileid write-file abort" Cannot write manifest"
        else
            i 1 fileid write-file abort" Cannot write manifest"
        then
    loop
;

: write-path-manifest-line { fileid key-addr key-u filepath-buffer -- }
\ Write one manifest record containing an authoritative generated filepath.
    key-addr key-u fileid write-file abort" Cannot write manifest"
    s\" : \"" fileid write-file abort" Cannot write manifest"
    filepath-buffer fileid write-manifest-path
    s\" \"\r\n" fileid write-file abort" Cannot write manifest"
;

: replace-file-atomically
    { source-buffer destination-buffer | replaced? -- }
\ Replace a visible publication only after its temporary file is complete.
    0 source-buffer echo-buffer abort" Publication source path buffer full"
    0 destination-buffer echo-buffer abort" Publication destination path buffer full"
    10 0 do
        source-buffer buffer-to-string drop
        destination-buffer buffer-to-string drop
        ReplaceFileAtomic 0= if -1 -> replaced? leave then
        100 ms
    loop
    source-buffer backspace-buffer abort" Cannot restore publication source path"
    destination-buffer backspace-buffer abort" Cannot restore publication destination path"
    replaced? 0= abort" Cannot replace publication manifest"
;

: save-binary-file-to
    { data-addr data-u filepath-buffer | fileid -- }
\ Save one binary artifact to an explicitly prepared pathname.
    filepath-buffer create-imageDirectory
    filepath-buffer buffer-to-string w/o
        create-file abort" Cannot create binary publication" -> fileid
    data-addr data-u fileid write-file abort" Cannot write binary publication"
    fileid close-file abort" Cannot close binary publication"
;

: no-preview-manifest-extension ( fileid -- )
\ Default extension action: append no additional manifest records.
    drop
;

\ Optional ( fileid -- ) action; append records without closing the manifest.
DEFER write-preview-manifest-extension ( fileid -- )
ASSIGN no-preview-manifest-extension TO-DO write-preview-manifest-extension

: publish-preview-manifest { preview? histogram? | fileid -- }
\ Atomically publish selected artifacts which exist for the current frame.
\ Resolve every selected path afresh; shared buffers may refer to an older frame.
    preview? if
        image s" .bmp" preview-BMPfilepath write-filepath-bmp
        image s" .bmp" stretched-BMPfilepath write-filepath-stretched-bmp
        preview-BMPfilepath buffer-to-string FileExists?
        stretched-BMPfilepath buffer-to-string FileExists? and -> preview?
    then
    histogram? if
        image s" .bin" histogram-filepath write-filepath-histogram
        histogram-filepath buffer-to-string FileExists? -> histogram?
    then
    image s" .dat" preview-manifest-filepath
        write-filepath-preview-manifest
    image s" .tmp" preview-manifest-tmp-filepath
        write-filepath-preview-manifest
    preview-manifest-tmp-filepath open-publication-file -> fileid
    preview? if
        fileid s" image filepath" preview-BMPfilepath
            write-path-manifest-line
        fileid s" stretched image filepath" stretched-BMPfilepath
            write-path-manifest-line
    then
    histogram? if
        fileid s" histogram filepath" histogram-filepath
            write-path-manifest-line
    then
    fileid s" image name" s" UUID" image FRAME_METADATA @ map@
        write-manifest-line
    fileid s" time-stamp" s" DATE-END" image FRAME_METADATA @ map@
        write-manifest-line
    fileid write-preview-manifest-extension
    fileid close-file abort" Cannot close manifest"
    preview-manifest-tmp-filepath preview-manifest-filepath
        replace-file-atomically
;

: publish-metadata-manifest { | fileid -- }
\ Atomically publish the current FITS-key projection path.
    image s" .dat" metadata-manifest-filepath
        write-filepath-metadata-manifest
    image s" .tmp" metadata-manifest-tmp-filepath
        write-filepath-metadata-manifest
    metadata-manifest-tmp-filepath open-publication-file -> fileid
    fileid s" fits keys filepath" FITSprojection-filepath
        write-path-manifest-line
    fileid s" image name" s" UUID" image FRAME_METADATA @ map@
        write-manifest-line
    fileid s" time-stamp" s" DATE-END" image FRAME_METADATA @ map@
        write-manifest-line
    fileid close-file abort" Cannot close manifest"
    metadata-manifest-tmp-filepath metadata-manifest-filepath
        replace-file-atomically
;

16384 constant FITS_PROJECTION_SIZE \ Maximum allocated FITS projection bytes.

: XISF.mapIterProjection { buf key-addr key-u value-addr value-u -- buf }
\ Append one tab-separated map entry to the retained projection buffer.
    key-addr key-u buf write-buffer abort" FITS projection buffer full"
    9 buf echo-buffer abort" FITS projection buffer full"
    value-addr value-u buf write-buffer abort" FITS projection buffer full"
    13 buf echo-buffer abort" FITS projection buffer full"
    10 buf echo-buffer abort" FITS projection buffer full"
    buf
;

: FITS.projection-item-size { total key-addr key-u value-addr value-u -- total' }
\ Add one entry's key/value lengths and separators to the running byte count.
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

: save-stretched-BMPimage { | bitmap ior -- }
\ Apply the display function, save the high-byte BMP and publish available artifacts.
    image frame-size allocate abort" Cannot allocate stretched bitmap"
        -> bitmap
    image bitmap apply-displayFunction-to
    image s" .bmp" stretched-BMPfilepath write-filepath-stretched-bmp
    image bitmap stretched-BMPfilepath ['] save-BMPimage-to catch -> ior
    bitmap free abort" Cannot free stretched bitmap"
    ior ?dup if throw then
    -1 -1 publish-preview-manifest
;

: save-Histogram ( -- )
\ Save 65,536 four-byte bins and independently publish available preview artifacts.
    image s" .bin" histogram-filepath write-filepath-histogram
    image FRAME_STATISTICS @ HISTOGRAM 0x40000 histogram-filepath
        save-binary-file-to
    -1 -1 publish-preview-manifest
;
