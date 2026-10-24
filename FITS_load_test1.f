need forthXISF
need simple-tester

4096 buffer: buf1
4096 buffer: buf2

cr
Tstart

T{ s" BZERO   = 32768                                                                 " 
    FITS.read-line nip nip nip nip }T 0 ==
T{ s" BZERO   = 32768                                                                 " 
    FITS.read-line drop hashS -rot hashS swap }T s" 32768" hashS s" BZERO" hashS ==
T{ s" INSTRUME= 'ZWO ASI6200MM Pro'                                                   " 
    FITS.read-line drop hashS -rot hashS swap }T s" ZWO ASI6200MM Pro" hashS s" INSTRUME" hashS ==
T{ s" INSTRUME  'ZWO ASI6200MM Pro'                                                   " 
    FITS.read-line }T 3 ==
T{ s" END                                                                             " 
    FITS.read-line }T 1 ==
T{ s" SIMPLE  = T                                                                     " 
    FITS.read-line }T 2 ==

: test.XISF.scan-FITSgeometry ( caddr u -- width height depth )
    xisf.open-FITSfile 
    if abort" xisf.open-FITSfile failed"
    else
        >R R@ XISF.scan-FITSgeometry
        R> close-file drop
    then
;

T{ s" E:\coding\ForthAstroFormats\testdata\test1.fits" test.XISF.scan-FITSgeometry }T 640 480 1 ==
T{ s" E:\testdata\images\LUM-E8-F5100-12365844e78a.fits" test.XISF.scan-FITSgeometry }T 9576 6388 1 ==  

: test.reverseConvertDataFITS
    4096 0 do
        0x10000 choose buf1 i + w!   \ random 16 bit words
    loop
    buf1 buf2 4096 convertDataFITS
;

T{ test.reverseConvertDataFITS buf1 4096 hashS }T buf2 4096 2dup reverseConvertDataFITS hashS ==
T{ s" E:\coding\ForthAstroFormats\testdata\test1.fits" xisf.load-FITSfile swap free-frame }T 0 ==
T{ s" E:\testdata\images\LUM-E8-F5100-12365844e78a.fits" xisf.load-FITSfile swap free-frame }T 0 ==
CR
Tend
CR