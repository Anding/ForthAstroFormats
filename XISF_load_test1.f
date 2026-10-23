\ XISF write/load round-trip with explicit codec destinations.

NEED simple-tester
include "%idir%\ForthAstroFormats_test_support.f"

FILEPATH_SIZE allocate-buffer constant xisf.roundtrip.path
FILEPATH_SIZE allocate-buffer constant xisf.clone.path
0 value xisf.source
0 value xisf.clone
create xisf.test-header XISF_HEADER_SIZE allot
s\" </xisf>\r\n" nip constant xisf.test-ending-size

: xisf.load-roundtrip { filepath-buffer -- frame }
\ Load the saved fixture through the fixed-offset reader.
    filepath-buffer buffer-to-string xisf.load-file
    if abort" Cannot load XISF round-trip" then
;

: xisf.read-test-header { filepath-buffer | fileid -- }
\ Inspect serialized bytes independently of the XISF loader.
    filepath-buffer buffer-to-string r/o open-file
        abort" Cannot open XISF test header" -> fileid
    xisf.test-header XISF_HEADER_SIZE fileid read-file
        abort" Cannot read XISF test header"
    XISF_HEADER_SIZE <> abort" Incomplete XISF test header"
    fileid close-file abort" Cannot close XISF test header"
;

test.make-frame -> xisf.source
0 0 xisf.source FRAME_METADATA @ =>" EMPTY"
s" roundtrip.xisf" xisf.roundtrip.path test.prepare-path drop
xisf.source xisf.roundtrip.path save-XISFimage-to
xisf.roundtrip.path xisf.load-roundtrip -> xisf.clone
s" roundtrip-clone.xisf" xisf.clone.path test.prepare-path drop
xisf.clone xisf.clone.path save-XISFimage-to

Tstart
xisf.roundtrip.path xisf.read-test-header
T{ xisf.test-header 8 s" XISF0100" compare }T 0 ==
T{ xisf.test-header 8 + @ dup 0> swap XISF_HEADER_SIZE 16 - <= and }T -1 ==
T{ xisf.test-header 12 + @ }T 0 ==
T{ xisf.test-header 16 + 5 s" <?xml" compare }T 0 ==
T{ xisf.test-header 16 + xisf.test-header 8 + @ + xisf.test-ending-size -
    xisf.test-ending-size s\" </xisf>\r\n" compare }T 0 ==
T{ xisf.source FRAME_WIDTH @ }T xisf.clone FRAME_WIDTH @ ==
T{ xisf.source FRAME_HEIGHT @ }T xisf.clone FRAME_HEIGHT @ ==
T{ xisf.source frame-size }T xisf.clone frame-size ==
T{ s" EMPTY" xisf.clone FRAME_METADATA @ map@ }T 0 0 ==
T{ xisf.source FRAME_METADATA @ map-count }T
    xisf.clone FRAME_METADATA @ map-count ==
T{ xisf.roundtrip.path buffer-to-string hashF }T xisf.clone.path buffer-to-string hashF ==
T{ xisf.source FRAME_BITMAP xisf.source frame-size
    xisf.clone FRAME_BITMAP xisf.clone frame-size compare }T 0 ==
Tend

xisf.source free-frame
xisf.clone free-frame
xisf.roundtrip.path buffer-to-string delete-file drop
xisf.clone.path buffer-to-string delete-file drop
xisf.roundtrip.path free-buffer
xisf.clone.path free-buffer
