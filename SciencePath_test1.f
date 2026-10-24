\ Shared deferred science pathname used by the FITS and XISF codecs.

NEED simple-tester
include "%idir%\ForthAstroFormats_test_support.f"

: science.test-write-filepath { frame suffix-addr suffix-u filepath-buffer -- }
\ Direct both science formats to one deterministic test stem and suffix.
    frame drop
    filepath-buffer reset-buffer
    s" E:\Coding\ForthAstroFormats\testdata"
        filepath-buffer write-buffer drop
    filepath-buffer buffer-punctuate-filepath
    s" \science-path" filepath-buffer write-buffer drop
    suffix-addr suffix-u filepath-buffer write-buffer drop
;

ACTION-OF write-filepath-xisf constant science.test.saved-XISF-path
ACTION-OF write-filepath-fits constant science.test.saved-FITS-path
ASSIGN science.test-write-filepath TO-DO write-filepath-xisf
ASSIGN science.test-write-filepath TO-DO write-filepath-fits

test.make-frame constant science.test-frame
4 3 test.make-frame-sized constant science.test-other
science.test-frame save-XISFimage
science.test-frame save-FITSimage

Tstart
T{ XISFfilepath buffer-to-string hashS
}T s" E:\Coding\ForthAstroFormats\testdata\science-path.xisf" hashS ==
T{ FITSfilepath buffer-to-string hashS
}T s" E:\Coding\ForthAstroFormats\testdata\science-path.fits" hashS ==
T{ XISFfilepath buffer-to-string FileExists? }T -1 ==
T{ FITSfilepath buffer-to-string FileExists? }T -1 ==
\ Writing another retained frame must not change the source used by later calls.
science.test-other save-XISFimage
science.test-other save-FITSimage
T{ science.test-frame save-XISFimage science.test-frame save-FITSimage }T ==
XISFfilepath buffer-to-string xisf.load-file throw constant science.test-xisf
FITSfilepath buffer-to-string xisf.load-FITSfile throw constant science.test-fits
T{ science.test-xisf FRAME_WIDTH @ science.test-xisf FRAME_HEIGHT @
    science.test-xisf FRAME_BITMAP science.test-xisf frame-size hashS
}T 64 48 science.test-frame FRAME_BITMAP science.test-frame frame-size hashS ==
T{ science.test-fits FRAME_WIDTH @ science.test-fits FRAME_HEIGHT @
    science.test-fits FRAME_BITMAP science.test-fits frame-size hashS
}T 64 48 science.test-frame FRAME_BITMAP science.test-frame frame-size hashS ==
Tend

science.test.saved-XISF-path TO-DO write-filepath-xisf
science.test.saved-FITS-path TO-DO write-filepath-fits
XISFfilepath buffer-to-string delete-file drop
FITSfilepath buffer-to-string delete-file drop
science.test-frame free-frame
science.test-other free-frame
science.test-xisf free-frame
science.test-fits free-frame
