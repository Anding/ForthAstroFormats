\ XISF write/load round-trip with explicit codec destinations.

NEED simple-tester
include "%idir%\ForthAstroFormats_test_support.f"

FILEPATH_SIZE allocate-buffer constant xisf.roundtrip.path
FILEPATH_SIZE allocate-buffer constant xisf.clone.path
0 value xisf.source
0 value xisf.clone

: xisf.load-roundtrip { filepath-buffer -- frame }
    filepath-buffer buffer-to-string xisf.load-file
    if abort" Cannot load XISF round-trip" then
;

test.make-frame -> xisf.source
0 0 xisf.source FRAME_METADATA @ =>" EMPTY"
s" roundtrip.xisf" xisf.roundtrip.path test.prepare-path drop
xisf.source xisf.roundtrip.path save-XISFimage-to
xisf.roundtrip.path xisf.load-roundtrip -> xisf.clone
s" roundtrip-clone.xisf" xisf.clone.path test.prepare-path drop
xisf.clone xisf.clone.path save-XISFimage-to

Tstart
T{ xisf.source FRAME_WIDTH @ }T xisf.clone FRAME_WIDTH @ ==
T{ xisf.source FRAME_HEIGHT @ }T xisf.clone FRAME_HEIGHT @ ==
T{ xisf.source frame-size }T xisf.clone frame-size ==
T{ s" EMPTY" xisf.clone FRAME_METADATA @ map@ }T 0 0 ==
T{ xisf.source FRAME_METADATA @ map-count }T
    xisf.clone FRAME_METADATA @ map-count ==
T{ xisf.roundtrip.path buffer-to-string hashF }T xisf.clone.path buffer-to-string hashF ==
Tend

xisf.source free-frame
xisf.clone free-frame
xisf.roundtrip.path buffer-to-string delete-file drop
xisf.clone.path buffer-to-string delete-file drop
xisf.roundtrip.path free-buffer
xisf.clone.path free-buffer
