\ XISF loading into a format-neutral FRAME.

: xisf.open-file ( caddr u -- fileid 0 | ior )
    r/o open-file ?dup if ." Cannot open XISF file" exit then
    0
;

: xisf.read-header { fileid -- }
\ Read the complete fixed header so the file position lands at the attachment.
    xisf.header-buffer reset-buffer
    xisf.header-buffer XISF_HEADER_SIZE fileid buffer-read-file
    abort" Cannot read XISF header"
    XISF_HEADER_SIZE <> abort" Cannot read full XISF header"
;

: xisf.scan-for-geometry ( header-buffer -- width height depth )
    >R R@ buffer-reset-search
    s\" geometry=\"~\"*\"" R@ buffer-match
    R> drop
    0= if 0 0 0 exit then
    10 /string 1- >number~~~
;

: xisf.read-file { fileid frame -- }
\ The caller has already consumed XISF_HEADER_SIZE bytes; read only the
\ geometry-derived attachment and ignore any future trailing blocks.
    frame FRAME_BITMAP frame frame-size fileid read-file 2drop
    fileid close-file drop
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
    caddr u xisf.open-file if exit then -> fileid
    fileid xisf.read-header
    xisf.header-buffer xisf.scan-for-geometry ?dup if
        allocate-frame -> frame
        fileid frame xisf.read-file
        frame xisf.scan-for-metadata
        frame 0
    else
        2drop
        fileid close-file drop
        -1
    then
;
