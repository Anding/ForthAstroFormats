\ Adversarial values remain byte strings, not numbers or NUL-terminated text.
NEED ForthAstroFormats
NEED simple-tester

4 3 1 allocate-frame constant projection.bad-image
FITS_PROJECTION_SIZE allocate-buffer constant projection.bad-buffer
256 allocate-buffer constant projection.bad-path
create projection.bad-bytes 255 allot
create projection.bad-zero 0 c,
create projection.bad-controls 9 c, 13 c, 10 c,
: projection.bad-fill ( -- )
    255 0 do i projection.bad-bytes i + c! loop
;

: projection.bad-check { caddr u -- flag }
    projection.bad-image FRAME_METADATA @ erase-map
    caddr u projection.bad-image FRAME_METADATA @ =>" BAD"
    projection.bad-buffer reset-buffer
    projection.bad-buffer ['] XISF.mapIterProjection
        projection.bad-image FRAME_METADATA @ map-for-each drop
    projection.bad-buffer buffer_used u 6 + =
    projection.bad-buffer BUFFER_ADDR 4 + u caddr u compare 0= and
;

s" E:\images\tests\ForthAstroFormats\projection-too-large.dat"
    projection.bad-path write-buffer drop

: projection.bad-save-overflow ( -- )
    projection.bad-image FRAME_METADATA @ erase-map
    100 0 do
        projection.bad-bytes 255 i (.)
        projection.bad-image FRAME_METADATA @ map!
    loop
    projection.bad-image projection.bad-path save-FITSprojection-to
;

Tstart
T{ 0 0 projection.bad-check }T -1 ==
T{ s" 0" projection.bad-check }T -1 ==
T{ s" null" projection.bad-check }T -1 ==
T{ projection.bad-zero 1 projection.bad-check }T -1 ==
T{ projection.bad-controls 3 projection.bad-check }T -1 ==
projection.bad-fill
T{ projection.bad-bytes 255 projection.bad-check }T -1 ==
T{ projection.bad-save-overflow }T ==
T{ projection.bad-path buffer_used }T 0 ==
\ Compile the writer against a failed OS write, keeping real create/close/delete.
\ Plain diagnostics keep VFXControl's native-caret framing out of this mock.
: .throw ( ior -- ) ?dup if cr ." I/O error " . cr then ;
include "%idir%\Paths.f"
: write-file ( caddr u fileid -- ior ) 3drop -37 ;
include "%idir%\FITS.f"
: projection.failed-write ( -- )
    projection.bad-path reset-buffer
    s" E:\images\tests\ForthAstroFormats\" projection.bad-path write-buffer drop
    projection.bad-path buffer-punctuate-filepath
    s" partial.fits" projection.bad-path write-buffer drop
    projection.bad-image projection.bad-path save-FITSimage-to
;
T{ projection.failed-write projection.failed-write projection.failed-write }T ==
T{ projection.bad-path buffer_used }T 0 ==
T{ s" E:\images\tests\ForthAstroFormats\partial.fits" FileExists? }T 0 ==
T{ depth }T 0 ==
projection.bad-image free-frame
projection.bad-buffer free-buffer
projection.bad-path free-buffer
Tend
