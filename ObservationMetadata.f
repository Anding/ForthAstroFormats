\ Observation identity and acquisition timestamps, independent of image formats.
NEED ForthBase
NEED ordered-maps
NEED Windows

0 value obs.type
BEGIN-ENUM
    +enum BIAS
    +enum DARK
    +enum FLAT
    +enum LIGHT
    +enum MASTERBIAS
    +enum MASTERDARK
    +enum MASTERFLAT
    +enum MASTERLIGHT
END-ENUM

\ ( type -- caddr u ) Return the observation type's metadata label.
BEGIN-ENUMS observationType
    +" Bias"
    +" Dark"
    +" Flat"
    +" Light"
    +" MasterBias"
    +" MasterDark"
    +" MasterFlat"
    +" MasterLight"
END-ENUMS

s"  " $value obs.observer
s"  " $value obs.target
TSlength buffer: xisf.TSstring
0 value image_type

: frames ( type -- )
\ Select the observation type for subsequent acquisitions.
    -> obs.type
;

: frames? ( -- caddr u )
\ Return the selected observation type's metadata label.
    obs.type observationType
;

: add-startFITS ( map -- )
\ Reserve the unheaded camera prefix, then record identity and start timestamps.
    >R
    0 0 R@ =>" BITPIX"
    0 0 R@ =>" NAXIS"
    0 0 R@ =>" NAXIS1"
    0 0 R@ =>" NAXIS2"
    0 0 R@ =>" XORGSUBF"
    0 0 R@ =>" YORGSUBF"
    0 0 R@ =>" BZERO"
    0 0 R@ =>" BSCALE"
    0 0 R@ =>" XBINNING"
    0 0 R@ =>" YBINNING"
    0 0 R@ =>" PEDESTAL"
    0 0 R@ =>" EXPTIME"
    0 0 R@ =>" EXPOINUS"
    0 0 R@ =>" EXPOINMS"
    s"  " R@ =>" #IDENTITY"
    xisf.TSstring 0 make-timestamp R@ =>" DATE-OBS"
    0 0 R@ =>" DATE-END"
    xisf.TSstring 1 make-timestamp R@ =>" LOCAL-DT"
    xisf.TSstring 3 make-timestamp drop 10 R@ =>" NIGHTOF"
    UUID R@ =>" UUID"
    R> drop
;

: add-observationFITS ( map -- )
\ Add the selected observation identity without querying equipment.
    >R
    obs.type observationType R@ =>" IMAGETYP"
    obs.target R@ =>" TARGET"
    0 0 R@ =>" OBJECT"
    obs.observer R@ =>" OBSERVER"
    R> drop
;

: add-observationEndFITS ( map -- )
\ Record UTC completion immediately after image download.
    >R
    xisf.TSstring 0 make-timestamp R@ =>" DATE-END"
    R> drop
;
