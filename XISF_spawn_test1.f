need ForthAstroFormats

need simple-tester
0 value image1
0 value image2
	
: make-test.xisf { | map img -- img }
    640 480 1 allocate-frame -> img
    img FRAME_METADATA @ -> map
    s" 16" map =>" BITPIX"	
    s" 2"	map =>" NAXIS"	
    s" 640" map =>" NAXIS1"
    s" 480" map =>" NAXIS2" 
    640 480 * 0 do
        0x10000 choose img FRAME_BITMAP i 2* + w!   \ random 16 bit words
    loop   
    img
;

    make-test.xisf -> image1      
    image1 frame.allocate-like -> image2
    
cr 
Tstart
T{ image1 FRAME_SIZE_BYTES @ }T image2 FRAME_SIZE_BYTES @ ==
T{ image1 FRAME_METADATA @ }T image2 FRAME_METADATA @ <>
cr
Tend
cr

image1 free-frame
image2 free-frame
bye
    