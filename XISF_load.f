\ XISF loading into a format-neutral FRAME.

: xisf.open-file ( caddr u -- fileid 0 | ior )
    r/o open-file dup if nip cr ." Cannot open XISF file" cr then
;

: xisf.scan-for-geometry ( header-buffer -- width height depth )
    >R R@ buffer-reset-search
    s\" geometry=\"~\"*\"" R@ buffer-match
    R> drop
    0= if 0 0 0 exit then
    10 /string 1- >number~~~
;

: xisf.scan-for-metadata { frame | map -- }
\ Preserve document order by appending FITSKeyword elements to the frame's
\ ordered map as they appear in the XISF header.
    frame FRAME_METADATA @ -> map
    xisf.header-buffer buffer-reset-search
    begin
        s" <FITSKeyword" xisf.header-buffer buffer-match
    while
        2drop
        s\" name=\"~\"*\"" xisf.header-buffer buffer-match if
            6 /string 1-
            s\" value=\"~\"*\"" xisf.header-buffer buffer-match if
                7 /string 1- FITSstrToStr
                2swap map map!
            then
        then
    repeat
;

: xisf.load-file { caddr u | fileid frame -- frame 0 | ior }
    caddr u xisf.open-file ?dup if exit then -> fileid
    xisf.header-buffer reset-buffer
    xisf.header-buffer XISF_HEADER_SIZE fileid buffer-read-file swap XISF_HEADER_SIZE <> or
    dup .throw ?dup if >R fileid close-file .throw R> exit then
    xisf.header-buffer xisf.scan-for-geometry ?dup if
        allocate-frame -> frame
        frame FRAME_BITMAP frame frame-size fileid read-file swap frame frame-size <> or
        fileid close-file or dup .throw ?dup if frame free-frame exit then
        frame xisf.scan-for-metadata
        frame 0
    else
        2drop
        fileid close-file drop
        cr ." Invalid XISF geometry" cr
        -1
    then
;
