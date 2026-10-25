NEED ForthAstroFormats
NEED simple-tester

16 8 1 allocate-frame constant test-frame

Tstart
T{ [DEFINED] save-PNGimage-to [DEFINED] save-RAWimage-to }T -1 -1 ==

T{ test-frame FRAME_METADATA @ map-count }T 0 ==
T{ test-frame FRAME_STATISTICS @ 0<> }T -1 ==
T{ test-frame FRAME_STATISTICS @ HISTOGRAM @ }T 0 ==
T{ test-frame FRAME_STARS @ 0<> }T -1 ==
T{ test-frame FRAME_STARS @ star.positive-pixel-count @ }T 0 ==
T{ test-frame frame-size }T 16 8 * 2 * ==
T{ test-frame frame-capacity }T 16 8 * 2 * ==

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

32 allocate T{ dup }T 0 == drop test-frame FRAME_PIPELINE !
T{ test-frame free-frame }T ==
Tend
