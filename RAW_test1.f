\ RAW export with an explicit destination buffer.

NEED simple-tester
NEED ForthImageExport
include "%idir%\ForthAstroFormats_test_support.f"

FILEPATH_SIZE allocate-buffer constant raw.test.path
test.make-frame constant raw.test.frame
s" frame.raw" raw.test.path test.prepare-path drop
raw.test.frame raw.test.path save-RAWimage-to

Tstart
T{ raw.test.path buffer-to-string FileExists? }T -1 ==
Tend

raw.test.frame free-frame
raw.test.path buffer-to-string delete-file .throw
raw.test.path free-buffer
