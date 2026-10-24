\ FITS and XISF serializers consume ordered key/value pairs, including empties.
NEED ForthXISF
NEED simple-tester

allocate-map constant metadata.test-map
4096 allocate-buffer constant metadata.test-buffer
4096 allocate-buffer constant metadata.test-expected

: metadata.test-key { buffer key-addr key-u value-addr value-u -- buffer }
\ Collect insertion-order keys, including section headings and empty values.
    key-addr key-u buffer write-buffer drop
    bl buffer echo-buffer drop
    buffer
;

s" original" metadata.test-map =>" FIRST"
s" 0" metadata.test-map =>" SECOND"
0 0 metadata.test-map =>" EMPTY"
s" skipped by FITS" metadata.test-map =>" TOOLONGKEY"
s" first" metadata.test-map =>" FIRST"

Tstart
T{ [defined] >string [defined] => [defined] simple-iterate-map }T 0 0 0 ==
T{ metadata.test-map metadata.test-buffer FITS.write-map
   metadata.test-buffer buffer_used }T 240 ==
T{ metadata.test-buffer BUFFER_ADDR 5 s" FIRST" compare }T 0 ==
T{ metadata.test-buffer BUFFER_ADDR 10 + 7 s" 'first'" compare }T 0 ==
T{ metadata.test-buffer BUFFER_ADDR 80 + 6 s" SECOND" compare }T 0 ==
T{ metadata.test-buffer BUFFER_ADDR 90 + 1 s" 0" compare }T 0 ==
T{ metadata.test-buffer BUFFER_ADDR 170 + 2 s" ''" compare }T 0 ==

metadata.test-buffer reset-buffer
s\" <FITSKeyword name=\"FIRST\" value=\"'first'\" />\r\n<FITSKeyword name=\"SECOND\" value=\"0\" />\r\n"
    metadata.test-expected write-buffer drop
s\" <FITSKeyword name=\"EMPTY\" value=\"''\" />\r\n<FITSKeyword name=\"TOOLONGKEY\" value=\"'skipped by FITS'\" />\r\n"
    metadata.test-expected write-buffer drop
T{ metadata.test-map metadata.test-buffer XISF.write-map-XISF
   metadata.test-buffer buffer-to-string hashS
}T metadata.test-expected buffer-to-string hashS ==
T{ 0 0 FITSstrToStr }T 0 0 ==

metadata.test-map erase-map
metadata.test-map add-startFITS
metadata.test-map add-observationFITS
metadata.test-expected reset-buffer
s" BITPIX NAXIS NAXIS1 NAXIS2 XORGSUBF YORGSUBF BZERO BSCALE XBINNING YBINNING PEDESTAL EXPTIME EXPOINUS EXPOINMS #IDENTITY DATE-OBS DATE-END LOCAL-DT NIGHTOF UUID IMAGETYP TARGET OBJECT OBSERVER "
    metadata.test-expected write-buffer drop
metadata.test-buffer reset-buffer
metadata.test-buffer ' metadata.test-key metadata.test-map map-for-each drop
T{ metadata.test-buffer buffer-to-string
   metadata.test-expected buffer-to-string compare }T 0 ==
T{ s" DATE-END" metadata.test-map map@ }T 0 0 ==
s" 16" metadata.test-map =>" BITPIX"
s" 1000" metadata.test-map =>" EXPOINMS"
metadata.test-map add-observationEndFITS
metadata.test-buffer reset-buffer
metadata.test-buffer ' metadata.test-key metadata.test-map map-for-each drop
T{ metadata.test-buffer buffer-to-string
   metadata.test-expected buffer-to-string compare }T 0 ==
metadata.test-buffer reset-buffer
metadata.test-map metadata.test-buffer FITS.write-map
T{ metadata.test-buffer BUFFER_ADDR 8 s" BITPIX  " compare }T 0 ==
T{ metadata.test-buffer BUFFER_ADDR 1040 + 8 s" EXPOINMS" compare }T 0 ==
T{ metadata.test-buffer BUFFER_ADDR 1120 + 8 s" DATE-OBS" compare }T 0 ==
T{ metadata.test-buffer BUFFER_ADDR 1200 + 8 s" DATE-END" compare }T 0 ==
T{ s" DATE-END" metadata.test-map map@ nip 0> }T true ==

\ Import a small WCS without an external solver or equipment.
4 3 1 allocate-frame constant metadata.test-frame
FILEPATH_SIZE allocate-buffer constant metadata.test-path
s" E:\images\tests\" metadata.test-path write-buffer drop
metadata.test-path buffer-punctuate-filepath
s" metadata-order.wcs" metadata.test-path write-buffer drop
metadata.test-path create-imageDirectory
metadata.test-path buffer-to-string w/o create-file throw constant metadata.test-file
s\" CTYPE1  = 'RA---TAN'\r\nCRVAL1  = 1.0\r\n"
    metadata.test-file write-file throw
metadata.test-file close-file throw
metadata.test-path buffer-to-string metadata.test-frame solver.import-WCS
s" alignment" metadata.test-frame FRAME_METADATA @ =>" 10UALPT"
metadata.test-buffer reset-buffer
metadata.test-buffer ' metadata.test-key
    metadata.test-frame FRAME_METADATA @ map-for-each drop
T{ metadata.test-buffer buffer-to-string
   s" #ASTROMETRY CTYPE1 CRVAL1 10UALPT " compare }T 0 ==
metadata.test-path buffer-to-string delete-file throw
metadata.test-frame free-frame
metadata.test-path free-buffer
Tend

metadata.test-map free-map
metadata.test-buffer free-buffer
metadata.test-expected free-buffer
