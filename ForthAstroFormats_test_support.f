\ Shared frame and filepath helpers for codec regression tests.

NEED ForthAstroFormats

: test.make-frame-sized { width height | frame map -- frame }
    width height 1 allocate-frame -> frame
    frame FRAME_METADATA @ -> map
    s" 16" map =>" BITPIX"
    s" 2" map =>" NAXIS"
    width (.) map =>" NAXIS1"
    height (.) map =>" NAXIS2"
    s" UInt16" map =>" SMPLFRMT"
    s" Gray" map =>" COLORSPC"
    s" Light" map =>" IMAGETYP"
    s" -50" map =>" OFFSET"
    s" test-frame" map =>" UUID"
    width height * 0 do
        i 257 * 0x10000 mod frame FRAME_BITMAP i 2* + w!
    loop
    frame
;

: test.make-frame ( -- frame )
    64 48 test.make-frame-sized
;

: test.prepare-path { filename-addr filename-u filepath-buffer -- filepath-buffer }
    filepath-buffer reset-buffer
    s" E:\Coding\ForthAstroFormats\testdata\" filepath-buffer write-buffer drop
    filepath-buffer buffer-punctuate-filepath
    filename-addr filename-u filepath-buffer write-buffer drop
    filepath-buffer
;
