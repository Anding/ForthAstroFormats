NEED ForthAstroFormats
NEED simple-tester

16 8 1 allocate-frame constant test-frame
FILEPATH_SIZE allocate-buffer constant test-filepath

Tstart

T{ test-frame FRAME_METADATA @ map-count }T 0 ==
T{ test-frame FRAME_STATISTICS @ }T 0 ==
T{ test-frame frame-size }T 16 8 * 2 * ==
T{ test-frame frame-capacity }T 16 8 * 2 * ==

test-filepath reset-buffer
s" E:\images\tests\invalid\artifact.dat" test-filepath write-buffer drop
T{ test-filepath valid-filepath-folder? }T 0 ==

test-filepath reset-buffer
s" E:\images\tests\valid\" test-filepath write-buffer drop
test-filepath buffer-punctuate-filepath
s" artifact.dat" test-filepath write-buffer drop
T{ test-filepath valid-filepath-folder? }T -1 ==

s" first" test-frame FRAME_METADATA @ =>" FIRST"
s" second" test-frame FRAME_METADATA @ =>" SECOND"
T{ test-frame FRAME_METADATA @ map-count }T 2 ==

test-frame reset-frame-metadata
T{ test-frame FRAME_METADATA @ map-count }T 0 ==
T{ s" FIRST" test-frame FRAME_METADATA @ map@ }T 0 0 ==

s" reused" test-frame FRAME_METADATA @ =>" FRESH"
T{ test-frame FRAME_METADATA @ map-count }T 1 ==
T{ s" FRESH" test-frame FRAME_METADATA @ map@ hashS }T
    s" reused" hashS ==
s" 8" test-frame FRAME_METADATA @ =>" NAXIS1"
s" 4" test-frame FRAME_METADATA @ =>" NAXIS2"
test-frame initialize-frame
T{ test-frame frame-size }T 8 4 * 2 * ==
T{ test-frame frame-capacity }T 16 8 * 2 * ==

Tend

test-frame free-frame
test-filepath free-buffer
