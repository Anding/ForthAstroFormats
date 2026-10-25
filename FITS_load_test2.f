\ FITS write/load round-trip with explicit codec destinations.

NEED simple-tester
include "%idir%\ForthAstroFormats_test_support.f"

FILEPATH_SIZE allocate-buffer constant fits.roundtrip.path
FILEPATH_SIZE allocate-buffer constant fits.clone.path
0 value fits.source
0 value fits.clone

Tstart
test.make-frame -> fits.source
0 0 fits.source FRAME_METADATA @ =>" EMPTY"
s" roundtrip.fits" fits.roundtrip.path test.prepare-path drop
fits.source fits.roundtrip.path save-FITSimage-to
fits.roundtrip.path buffer-to-string xisf.load-FITSfile
T{ dup }T 0 == drop -> fits.clone
s" roundtrip-clone.fits" fits.clone.path test.prepare-path drop
fits.clone fits.clone.path save-FITSimage-to

T{ fits.source FRAME_WIDTH @ }T fits.clone FRAME_WIDTH @ ==
T{ fits.source FRAME_HEIGHT @ }T fits.clone FRAME_HEIGHT @ ==
T{ fits.source frame-size }T fits.clone frame-size ==
T{ s" EMPTY" fits.clone FRAME_METADATA @ map@ }T 0 0 ==
T{ fits.source FRAME_METADATA @ map-count }T
    fits.clone FRAME_METADATA @ map-count ==
T{ fits.roundtrip.path buffer-to-string hashF }T fits.clone.path buffer-to-string hashF ==
\ The external fixture has three header blocks, unlike our four-block writer.
s" E:\images\tests\astap\known-good\LUM-E8-F5100-12365844e78a.fits" xisf.load-FITSfile
T{ dup }T 0 == drop constant fits.fixture
T{ fits.fixture FRAME_BITMAP w@ }T 777 ==
fits.fixture free-frame
Tend

fits.source free-frame
fits.clone free-frame
fits.roundtrip.path buffer-to-string delete-file drop
fits.clone.path buffer-to-string delete-file drop
fits.roundtrip.path free-buffer
fits.clone.path free-buffer
