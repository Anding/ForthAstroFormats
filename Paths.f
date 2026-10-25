\ Generic filepath mechanics and replaceable writer interfaces.

NEED ForthBase

256 constant FILEPATH_SIZE
s" " $value astro.root

: create-imageDirectory ( filepath-buffer -- )
    dup buffer_used 0= if drop exit then
    >R
    R@ buffer-drive-to-string R@ buffer-dir-to-string makeDirLevels
    dup .throw if R@ reset-buffer then
    R> drop
;

: discard-image-file ( filepath-buffer -- )
\ A failed write must not leave an artifact or an authoritative pathname.
    dup buffer-to-string delete-file drop reset-buffer
;

: open-publication-file { filepath-buffer -- fileid|0 }
    filepath-buffer create-imageDirectory
    filepath-buffer buffer_used 0= if 0 exit then
    filepath-buffer buffer-to-string w/o create-file dup .throw if
        drop filepath-buffer reset-buffer 0
    then
;

: finish-image-file { fileid ior filepath-buffer -- }
    fileid close-file ior or dup .throw if filepath-buffer discard-image-file then
;

: native-image-filepath { filepath-buffer -- caddr|0 }
    filepath-buffer create-imageDirectory
    filepath-buffer buffer_used 0= if 0 exit then
    0 filepath-buffer echo-buffer dup .throw if filepath-buffer reset-buffer 0 exit then
    filepath-buffer backspace-buffer drop
    filepath-buffer BUFFER_ADDR
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
    filepath-buffer buffer_used 0= if exit then
    '\' filepath-buffer echo-buffer
    caddr u filepath-buffer write-buffer or dup .throw if filepath-buffer reset-buffer then
;

: append-UUID-suffix { uuid-addr uuid-u filepath-buffer -- }
\ Missing and short UUIDs contribute neither separator nor suffix.
    uuid-u 36 < if exit then
    filepath-buffer buffer_used 0= if exit then
    '-' filepath-buffer echo-buffer
    uuid-addr 24 + 12 filepath-buffer write-buffer or dup .throw
    if filepath-buffer reset-buffer then
;

: no-image-filepath ( frame caddr u filepath-buffer -- )
    reset-buffer 2drop drop
    cr ." Image filepath policy is not configured" cr
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
