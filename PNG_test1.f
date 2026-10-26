\ PNG export with an explicit destination buffer.

NEED simple-tester
NEED ForthAstroFormats
include "%idir%\ForthAstroFormats_test_support.f"

FILEPATH_SIZE allocate-buffer constant png.test.path
test.make-frame constant png.test.frame
s" frame.png" png.test.path test.prepare-path drop
png.test.frame png.test.path save-PNGimage-to

Tstart
T{ png.test.path buffer-to-string FileExists? }T -1 ==
Tend

png.test.frame free-frame
bye
