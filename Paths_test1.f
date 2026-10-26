NEED ForthAstroFormats
NEED simple-tester

FILEPATH_SIZE allocate-buffer constant paths.test.filepath
1 1 1 allocate-frame constant paths.test.frame

Tstart
T{ paths.test.frame s" .fits" paths.test.filepath write-filepath-fits }T ==
T{ paths.test.frame s" .bmp" paths.test.filepath write-filepath-bmp }T ==
T{ paths.test.filepath buffer_used }T 0 ==
Tend

paths.test.frame free-frame
paths.test.filepath free-buffer
