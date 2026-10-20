need forthXISF
include "%idir%\PNG.f"

0 shared value image

s" E:\testdata\images\LUM-E155-F5100-f7843758a3f5.xisf" xisf.load-file drop -> image
    
: test_write-PNGfilepath { map buf -- }
	s" E:\testdata\images\" buf write-buffer drop	
	buf buffer-punctuate-filepath
	s" FILTER" map map@ buf write-buffer drop
	'-' buf echo-buffer drop	
	'E' buf echo-buffer drop	
	s" EXPTIME" map map@ buf write-buffer drop
	'-' buf echo-buffer drop		
	'F' buf echo-buffer drop
	s" FOCUSPOS" map map@ buf write-buffer drop
	s" UUID" map map@ buf append-UUID-suffix
	s" .png" buf write-buffer drop
	0   buf echo-buffer drop                                   \ zero terminated string
;

    ASSIGN test_write-PNGfilepath TO-DO write-PNGfilepath      
 
    image save-PNGimage
