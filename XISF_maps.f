\ write rig and observation properties to the maps
\ these property sets are known from the system not from any device

need Windows

TSlength buffer: xisf.TSstring

\ the camera driver does not know - this must be set manually or by script
0 value image_type

: add-startFITS ( map -- )
	>R
	s"  "                                   R@ =>" #OBS"            \ a header to indicate the source of these FITS values	
	xisf.TSstring 0 make-timestamp          R@ =>" DATE-OBS"        \ UTC date and time in ISO format
	xisf.TSstring 1 make-timestamp          R@ =>" LOCAL-DT"        \ local date and time in ISO format
	xisf.TSstring 3 make-timestamp drop 10  R@ =>" NIGHTOF"         \ local date in midday to midday format
 	UUID                                    R@ =>" UUID"											
	R> drop
;	

: add-observationFITS ( map -- )
    >R
    obs.type observationType R@ =>" IMAGETYP"
    obs.target R@ =>" TARGET"
    0 0 R@ =>" OBJECT"
    obs.observer R@ =>" OBSERVER"
    R> drop
;

: add-observationEndFITS ( map --)
\ Record the UTC completion timestamp immediately after image download.
    >R
    xisf.TSstring 0 make-timestamp R@ =>" DATE-END"
    R> drop
;

: add-rigFITS ( map --)
\ add key value pairs for FITS rig parameters
	>R
	s"  "                                   R@ =>" #RIG"            \ a header to indicate the source of these FITS values	
	rig.telescope                           R@ =>" TELESCOP"
	rig.focal_len                           R@ =>" FOCALLEN"	
	rig.focal_ratio                         R@ =>" FOCRATIO"	
	rig.aperature_dia                       R@ =>" APTDIA"			
	rig.aperature_area                      R@ =>" APTAREA"
	rig.software                            R@ =>" SWCREATE"		
	R> drop
;	
