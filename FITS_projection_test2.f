\ Adversarial values remain byte strings, not numbers or NUL-terminated text.
NEED FITS_projection
NEED simple-tester

4 3 1 allocate-frame constant projection.bad-image
FITS_PROJECTION_SIZE allocate-buffer constant projection.bad-buffer
create projection.bad-bytes 255 allot
create projection.bad-zero 0 c,
create projection.bad-controls 9 c, 13 c, 10 c,
: projection.bad-fill ( -- )
    255 0 do i projection.bad-bytes i + c! loop
;

: projection.bad-check { caddr u -- flag }
    projection.bad-image FRAME_METADATA @ reset-map
    caddr u projection.bad-image FRAME_METADATA @ =>" BAD"
    projection.bad-buffer reset-buffer
    projection.bad-buffer ['] XISF.mapIterProjection
        projection.bad-image FRAME_METADATA @ simple-iterate-map drop
    projection.bad-buffer buffer_used u 6 + =
    projection.bad-buffer BUFFER_ADDR 4 + u caddr u compare 0= and
;

: projection.bad-overflow ( -- )
    projection.bad-image FRAME_METADATA @ reset-map
    100 0 do
        projection.bad-bytes 255 i (.)
        projection.bad-image FRAME_METADATA @ =>
    loop
    projection.bad-buffer reset-buffer
    projection.bad-buffer ['] XISF.mapIterProjection
        projection.bad-image FRAME_METADATA @ simple-iterate-map drop
;

Tstart
T{ 0 0 projection.bad-check }T -1 ==
T{ s" 0" projection.bad-check }T -1 ==
T{ s" null" projection.bad-check }T -1 ==
T{ projection.bad-zero 1 projection.bad-check }T -1 ==
T{ projection.bad-controls 3 projection.bad-check }T -1 ==
projection.bad-fill
T{ projection.bad-bytes 255 projection.bad-check }T -1 ==
s" E:\" s" images\logs\projection-regression" makeDirLevels throw
s" E:\images\logs\projection-regression" $-> log.directory
LOG-ON
-1 -> FITS.projection-debug
T{ projection.bad-bytes 255 projection.bad-check }T -1 ==
T{ projection.bad-zero 1 projection.bad-check }T -1 ==
T{ 0 0 projection.bad-check }T -1 ==
0 -> FITS.projection-debug
T{ ' projection.bad-overflow catch }T -2 ==
T{ depth }T 0 ==
projection.bad-image free-frame
projection.bad-buffer free-buffer
Tend
