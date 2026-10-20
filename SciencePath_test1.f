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

test.make-frame -> image
save-XISFimage
save-FITSimage

Tstart
T{ XISFfilepath buffer-to-string hashS
}T s" E:\Coding\ForthAstroFormats\testdata\science-path.xisf" hashS ==
T{ FITSfilepath buffer-to-string hashS
}T s" E:\Coding\ForthAstroFormats\testdata\science-path.fits" hashS ==
T{ XISFfilepath buffer-to-string FileExists? }T -1 ==
T{ FITSfilepath buffer-to-string FileExists? }T -1 ==
T{ save-XISFimage save-FITSimage }T ==
Tend

science.test.saved-XISF-path TO-DO write-filepath-xisf
science.test.saved-FITS-path TO-DO write-filepath-fits
XISFfilepath buffer-to-string delete-file drop
FITSfilepath buffer-to-string delete-file drop
image free-frame
