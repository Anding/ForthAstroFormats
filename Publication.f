\ Generic manifest mechanics for replaceable publications.

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
    drop
;

DEFER write-preview-manifest-extension ( fileid -- )
ASSIGN no-preview-manifest-extension TO-DO write-preview-manifest-extension

: publish-preview-manifest { preview? histogram? | fileid -- }
\ Atomically publish the paths of the selected preview artifacts.
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
    fileid s" image name" s" UUID" image FRAME_METADATA @ >string
        write-manifest-line
    fileid s" time-stamp" s" DATE-END" image FRAME_METADATA @ >string
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
    fileid s" image name" s" UUID" image FRAME_METADATA @ >string
        write-manifest-line
    fileid s" time-stamp" s" DATE-END" image FRAME_METADATA @ >string
        write-manifest-line
    fileid close-file abort" Cannot close manifest"
    metadata-manifest-tmp-filepath metadata-manifest-filepath
        replace-file-atomically
;
