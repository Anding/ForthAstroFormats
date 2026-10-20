\ Replaceable output-stream pathname policy.

NEED ForthBase

s" E:\images" $value astro.root

\ Writer-owned paths retain the most recently published artifacts.
FILEPATH_SIZE allocate-buffer constant preview-BMPfilepath
FILEPATH_SIZE allocate-buffer constant stretched-BMPfilepath
FILEPATH_SIZE allocate-buffer constant histogram-filepath
FILEPATH_SIZE allocate-buffer constant preview-manifest-filepath
FILEPATH_SIZE allocate-buffer constant preview-manifest-tmp-filepath
FILEPATH_SIZE allocate-buffer constant FITSprojection-filepath
FILEPATH_SIZE allocate-buffer constant metadata-manifest-filepath
FILEPATH_SIZE allocate-buffer constant metadata-manifest-tmp-filepath
FILEPATH_SIZE allocate-buffer constant WCSfilepath
FILEPATH_SIZE allocate-buffer constant XISFfilepath
FILEPATH_SIZE allocate-buffer constant FITSfilepath

: append-path { caddr u filepath-buffer -- }
\ Append one backslash-separated component to a prepared pathname.
    '\' filepath-buffer echo-buffer abort" Filepath buffer full"
    caddr u filepath-buffer write-buffer abort" Filepath buffer full"
;

: default-write-generation-filepath
    { frame stream-addr stream-u filename-addr filename-u
      suffix-addr suffix-u filepath-buffer -- }
\ Build one complete UUID-versioned working filepath.
    filepath-buffer reset-buffer
    astro.root filepath-buffer write-buffer drop
    s" working" filepath-buffer append-path
    stream-addr stream-u filepath-buffer append-path
    s" UUID" frame FRAME_METADATA @ map@ filepath-buffer append-path
    filepath-buffer buffer-punctuate-filepath
    filename-addr filename-u filepath-buffer append-path
    suffix-addr suffix-u filepath-buffer write-buffer
        abort" Filepath buffer full"
;

: default-write-manifest-filepath
    { frame stream-addr stream-u filename-addr filename-u
      suffix-addr suffix-u filepath-buffer -- }
\ Build one complete working-stream manifest filepath.
    frame drop
    filepath-buffer reset-buffer
    astro.root filepath-buffer write-buffer drop
    s" working" filepath-buffer append-path
    stream-addr stream-u filepath-buffer append-path
    filepath-buffer buffer-punctuate-filepath
    filename-addr filename-u filepath-buffer append-path
    suffix-addr suffix-u filepath-buffer write-buffer
        abort" Filepath buffer full"
;

: default-write-preview-image-filepath
    { frame suffix-addr suffix-u filepath-buffer -- }
\ Build the raw-preview pathname with the writer's suffix.
    frame s" preview" s" image" suffix-addr suffix-u filepath-buffer
        default-write-generation-filepath
;

DEFER write-filepath-bmp ( frame caddr u filepath-buffer -- )
ASSIGN default-write-preview-image-filepath
    TO-DO write-filepath-bmp

: default-write-preview-stretched-filepath
    { frame suffix-addr suffix-u filepath-buffer -- }
\ Build the stretched-preview pathname with the writer's suffix.
    frame s" preview" s" stretched" suffix-addr suffix-u filepath-buffer
        default-write-generation-filepath
;

DEFER write-filepath-stretched-bmp ( frame caddr u filepath-buffer -- )
ASSIGN default-write-preview-stretched-filepath
    TO-DO write-filepath-stretched-bmp

: default-write-preview-histogram-filepath
    { frame suffix-addr suffix-u filepath-buffer -- }
\ Build the preview-histogram pathname with the writer's suffix.
    frame s" preview" s" histogram" suffix-addr suffix-u filepath-buffer
        default-write-generation-filepath
;

DEFER write-filepath-histogram ( frame caddr u filepath-buffer -- )
ASSIGN default-write-preview-histogram-filepath
    TO-DO write-filepath-histogram

: default-write-preview-manifest-filepath
    { frame suffix-addr suffix-u filepath-buffer -- }
\ Build the preview-manifest filepath with the requested publication suffix.
    frame s" preview" s" latest" suffix-addr suffix-u filepath-buffer
        default-write-manifest-filepath
;

DEFER write-filepath-preview-manifest ( frame caddr u filepath-buffer -- )
ASSIGN default-write-preview-manifest-filepath
    TO-DO write-filepath-preview-manifest

: default-write-metadata-filepath
    { frame suffix-addr suffix-u filepath-buffer -- }
\ Build the FITS-key projection pathname with the writer's suffix.
    frame s" metadata" s" fits" suffix-addr suffix-u filepath-buffer
        default-write-generation-filepath
;

DEFER write-filepath-fits-projection ( frame caddr u filepath-buffer -- )
ASSIGN default-write-metadata-filepath TO-DO write-filepath-fits-projection

: default-write-metadata-manifest-filepath
    { frame suffix-addr suffix-u filepath-buffer -- }
\ Build the metadata-manifest filepath with the requested publication suffix.
    frame s" metadata" s" latest" suffix-addr suffix-u filepath-buffer
        default-write-manifest-filepath
;

DEFER write-filepath-metadata-manifest ( frame caddr u filepath-buffer -- )
ASSIGN default-write-metadata-manifest-filepath
    TO-DO write-filepath-metadata-manifest

: append-UUID-suffix { uuid-addr uuid-u filepath-buffer -- }
\ Missing and short UUIDs contribute neither separator nor suffix.
    uuid-u 36 < if exit then
    '-' filepath-buffer echo-buffer abort" Science filepath buffer full"
    uuid-addr 24 + 12 filepath-buffer write-buffer
        abort" Science filepath buffer full"
;

: default-write-science-filepath
    { frame suffix-addr suffix-u filepath-buffer | map -- }
\ Build one complete science filepath with the requested format suffix.
    frame FRAME_METADATA @ -> map
    filepath-buffer reset-buffer
    astro.root filepath-buffer write-buffer drop
    s" NIGHTOF" map map@ filepath-buffer append-path
    s" IMAGETYP" map map@ filepath-buffer append-path
    '\' filepath-buffer echo-buffer drop
    filepath-buffer buffer-punctuate-filepath
    s" FILTER" map map@ filepath-buffer write-buffer drop
    '-' filepath-buffer echo-buffer drop
    'E' filepath-buffer echo-buffer drop
    s" EXPTIME" map map@ filepath-buffer write-buffer drop
    '-' filepath-buffer echo-buffer drop
    'F' filepath-buffer echo-buffer drop
    s" FOCUSPOS" map map@ filepath-buffer write-buffer drop
    s" UUID" map map@ filepath-buffer append-UUID-suffix
    suffix-addr suffix-u filepath-buffer write-buffer
        abort" Science filepath buffer full"
;

DEFER write-filepath-xisf ( frame caddr u filepath-buffer -- )
ASSIGN default-write-science-filepath TO-DO write-filepath-xisf

DEFER write-filepath-fits ( frame caddr u filepath-buffer -- )
ASSIGN default-write-science-filepath TO-DO write-filepath-fits

DEFER write-filepath-wcs ( frame caddr u filepath-buffer -- )
ASSIGN default-write-science-filepath TO-DO write-filepath-wcs
