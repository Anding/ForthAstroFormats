NEED ForthAstroPaths
NEED simple-tester

FILEPATH_SIZE allocate-buffer constant paths.test.filepath
1 1 1 allocate-frame constant paths.test.frame

: paths.test-unconfigured-FITS ( -- )
    paths.test.frame s" .fits" paths.test.filepath write-filepath-fits
;

: paths.test-unconfigured-preview ( -- )
    paths.test.frame s" .bmp" paths.test.filepath write-filepath-bmp
;

Tstart
T{ ' paths.test-unconfigured-FITS catch }T -2 ==
T{ ' paths.test-unconfigured-preview catch }T -2 ==
T{ paths.test.filepath buffer_used }T 0 ==
Tend

paths.test.frame free-frame
paths.test.filepath free-buffer
