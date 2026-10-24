\ Executable optical/software configuration and its metadata projection.
NEED ForthBase
NEED ordered-maps

s" " $value rig.aperature_dia
s" " $value rig.aperature_area
s" " $value rig.focal_len
s" " $value rig.focal_ratio
s"  " $value rig.telescope
s" github.com/Anding/Ptolemy" $value rig.software

: add-rigFITS ( map -- )
\ Add configured telescope, aperture, focal and software metadata.
    >R
    s"  " R@ =>" #RIG"
    rig.telescope R@ =>" TELESCOP"
    rig.focal_len R@ =>" FOCALLEN"
    rig.focal_ratio R@ =>" FOCRATIO"
    rig.aperature_dia R@ =>" APTDIA"
    rig.aperature_area R@ =>" APTAREA"
    rig.software R@ =>" SWCREATE"
    R> drop
;
