\ Generic filepath mechanics and replaceable writer interfaces.

NEED ForthBase

256 constant FILEPATH_SIZE
s" " $value astro.root

: valid-filepath-folder? { filepath-buffer | folder-u -- flag }
\ Require a drive prefix and a recorded folder wholly inside the used buffer.
    filepath-buffer BUFFER_LEN_DIR @ -> folder-u
    folder-u 3 >=
    folder-u filepath-buffer buffer_used <= and
;

: create-imageDirectory ( filepath-buffer -- )
    dup valid-filepath-folder? 0= abort" Filepath folder not punctuated"
    >R
    R@ buffer-drive-to-string R> buffer-dir-to-string makeDirLevels abort" cannot create image directory"
;

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

: append-UUID-suffix { uuid-addr uuid-u filepath-buffer -- }
\ Missing and short UUIDs contribute neither separator nor suffix.
    uuid-u 36 < if exit then
    '-' filepath-buffer echo-buffer abort" Science filepath buffer full"
    uuid-addr 24 + 12 filepath-buffer write-buffer
        abort" Science filepath buffer full"
;

: no-image-filepath ( frame caddr u filepath-buffer -- )
    2drop 2drop
    true abort" Image filepath policy is not configured"
;

DEFER write-filepath-bmp ( frame caddr u filepath-buffer -- )
DEFER write-filepath-stretched-bmp ( frame caddr u filepath-buffer -- )
DEFER write-filepath-histogram ( frame caddr u filepath-buffer -- )
DEFER write-filepath-preview-manifest ( frame caddr u filepath-buffer -- )
DEFER write-filepath-fits-projection ( frame caddr u filepath-buffer -- )
DEFER write-filepath-metadata-manifest ( frame caddr u filepath-buffer -- )
DEFER write-filepath-xisf ( frame caddr u filepath-buffer -- )
DEFER write-filepath-fits ( frame caddr u filepath-buffer -- )
DEFER write-filepath-wcs ( frame caddr u filepath-buffer -- )

ASSIGN no-image-filepath TO-DO write-filepath-bmp
ASSIGN no-image-filepath TO-DO write-filepath-stretched-bmp
ASSIGN no-image-filepath TO-DO write-filepath-histogram
ASSIGN no-image-filepath TO-DO write-filepath-preview-manifest
ASSIGN no-image-filepath TO-DO write-filepath-fits-projection
ASSIGN no-image-filepath TO-DO write-filepath-metadata-manifest
ASSIGN no-image-filepath TO-DO write-filepath-xisf
ASSIGN no-image-filepath TO-DO write-filepath-fits
ASSIGN no-image-filepath TO-DO write-filepath-wcs
