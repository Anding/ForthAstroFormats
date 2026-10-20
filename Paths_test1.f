NEED ForthAstroPaths
NEED simple-tester

FILEPATH_SIZE allocate-buffer constant paths.test.filepath

Tstart

T{ astro.root hashS }T s" E:\images" hashS ==

s" E:\test-images" $-> astro.root

T{ astro.root hashS }T s" E:\test-images" hashS ==

1 1 1 allocate-frame constant paths.test.frame
s" 11111111-2222-3333-4444-555555555555"
    paths.test.frame FRAME_METADATA @ =>" UUID"
s" 2026-10-09" paths.test.frame FRAME_METADATA @ =>" NIGHTOF"
s" Dark" paths.test.frame FRAME_METADATA @ =>" IMAGETYP"
s" LUM" paths.test.frame FRAME_METADATA @ =>" FILTER"
s" 5" paths.test.frame FRAME_METADATA @ =>" EXPTIME"
s" 5100" paths.test.frame FRAME_METADATA @ =>" FOCUSPOS"

T{ paths.test.frame s" .bmp" paths.test.filepath write-filepath-bmp
   paths.test.filepath buffer-to-string hashS
}T s" E:\test-images\working\preview\11111111-2222-3333-4444-555555555555\image.bmp" hashS ==

T{ paths.test.frame s" .bmp" paths.test.filepath
   write-filepath-stretched-bmp
   paths.test.filepath buffer-to-string hashS
}T s" E:\test-images\working\preview\11111111-2222-3333-4444-555555555555\stretched.bmp" hashS ==

T{ paths.test.frame s" .bin" paths.test.filepath
   write-filepath-histogram
   paths.test.filepath buffer-to-string hashS
}T s" E:\test-images\working\preview\11111111-2222-3333-4444-555555555555\histogram.bin" hashS ==

T{ paths.test.frame s" .dat" paths.test.filepath
   write-filepath-preview-manifest paths.test.filepath buffer-to-string hashS
}T s" E:\test-images\working\preview\latest.dat" hashS ==

T{ paths.test.frame s" .dat" paths.test.filepath
   write-filepath-fits-projection
   paths.test.filepath buffer-to-string hashS
}T s" E:\test-images\working\metadata\11111111-2222-3333-4444-555555555555\fits.dat" hashS ==

T{ paths.test.frame s" .tmp" paths.test.filepath
   write-filepath-metadata-manifest
   paths.test.filepath buffer-to-string hashS
}T s" E:\test-images\working\metadata\latest.tmp" hashS ==

T{ paths.test.frame s" .fits" paths.test.filepath write-filepath-fits
   paths.test.filepath buffer-to-string hashS
}T s" E:\test-images\2026-10-09\Dark\LUM-E5-F5100-555555555555.fits" hashS ==

0 0 paths.test.frame FRAME_METADATA @ =>" UUID"
T{ paths.test.frame s" .fits" paths.test.filepath write-filepath-fits
   paths.test.filepath buffer-to-string hashS
}T s" E:\test-images\2026-10-09\Dark\LUM-E5-F5100.fits" hashS ==

s" 11111111-2222-3333-4444-55555555555"
    paths.test.frame FRAME_METADATA @ =>" UUID"
T{ paths.test.frame s" .xisf" paths.test.filepath write-filepath-xisf
   paths.test.filepath buffer-to-string hashS
}T s" E:\test-images\2026-10-09\Dark\LUM-E5-F5100.xisf" hashS ==

paths.test.frame reset-frame-metadata
T{ paths.test.frame s" .wcs" paths.test.filepath write-filepath-wcs
   paths.test.filepath buffer-to-string hashS
}T s" E:\test-images\\\-E-F.wcs" hashS ==

paths.test.frame free-frame
paths.test.filepath free-buffer

Tend
