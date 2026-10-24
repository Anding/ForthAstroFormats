\ FITS and XISF serializers consume ordered key/value pairs, including empties.
NEED ForthXISF
NEED simple-tester

allocate-map constant metadata.test-map
1024 allocate-buffer constant metadata.test-buffer
1024 allocate-buffer constant metadata.test-expected

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
metadata.test-buffer reset-buffer
metadata.test-map metadata.test-buffer FITS.write-map
T{ metadata.test-buffer BUFFER_ADDR 80 + 8 s" DATE-OBS" compare }T 0 ==
T{ metadata.test-buffer BUFFER_ADDR 160 + 8 s" DATE-END" compare }T 0 ==
T{ metadata.test-buffer BUFFER_ADDR 170 + 2 s" ''" compare }T 0 ==
metadata.test-map add-observationEndFITS
metadata.test-buffer reset-buffer
metadata.test-map metadata.test-buffer FITS.write-map
T{ metadata.test-buffer BUFFER_ADDR 160 + 8 s" DATE-END" compare }T 0 ==
T{ s" DATE-END" metadata.test-map map@ nip 0> }T true ==
Tend

metadata.test-map free-map
metadata.test-buffer free-buffer
metadata.test-expected free-buffer
