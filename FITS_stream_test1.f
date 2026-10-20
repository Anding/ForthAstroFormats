\ Multi-chunk FITS write/load round-trip.

NEED simple-tester
include "%idir%\ForthAstroFormats_test_support.f"

FILEPATH_SIZE allocate-buffer constant fits.stream.path
FILEPATH_SIZE allocate-buffer constant fits.stream.clone-path
0 value fits.stream.source
0 value fits.stream.clone

: fits.stream.load { filepath-buffer -- frame }
    filepath-buffer buffer-to-string xisf.load-FITSfile
    if abort" Cannot load streamed FITS file" then
;

256 128 test.make-frame-sized -> fits.stream.source
s" stream.fits" fits.stream.path test.prepare-path drop
fits.stream.source fits.stream.path save-FITSimage-to
fits.stream.path fits.stream.load -> fits.stream.clone
s" stream-clone.fits" fits.stream.clone-path test.prepare-path drop
fits.stream.clone fits.stream.clone-path save-FITSimage-to

Tstart
T{ fits.stream.source frame-size FITS_TRANSFER_SIZE > }T -1 ==
T{ fits.stream.source frame-size }T fits.stream.clone frame-size ==
T{ fits.stream.path buffer-to-string hashF }T
    fits.stream.clone-path buffer-to-string hashF ==
Tend

fits.stream.source free-frame
fits.stream.clone free-frame
fits.stream.path buffer-to-string delete-file drop
fits.stream.clone-path buffer-to-string delete-file drop
fits.stream.path free-buffer
fits.stream.clone-path free-buffer
