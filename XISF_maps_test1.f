\ Historical metadata demo; requires the retired add-observationXISF vocabulary.

NEED windows

NEED ForthAstroFormats

NEED ordered-maps
allocate-map CONSTANT FITSmap
allocate-map CONSTANT XISFmap

s" Takahashi Epsilon 160-ED" $-> rig.telescope
160 -> rig.aperature_dia
18000 -> rig.aperature_area
530 -> rig.focal_len

s" Patrick Moore" $-> obs.observer
s" Gaia DR3 2781184739422799232" $-> obs.target
3 -> obs.type

CR
." FITSmap"
FITSmap add-observationFITS 
FITSmap add-rigFITS
FITSmap .map CR

." XISFmap"
XISFmap add-observationXISF
XISFmap .map CR
