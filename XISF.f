\ PixInsight XISF codec for format-neutral FRAME values.

NEED Frame
NEED ForthXML

8192 constant XISF_HEADER_SIZE
XISF_HEADER_SIZE allocate-buffer constant xisf.header-buffer
\ The XML header occupies a fixed block and the pixel attachment begins at
\ XISF_HEADER_SIZE. This shared scratch buffer makes the codec synchronous.

: XISF.mapIterXISF { buf key-addr key-u value-addr value-u -- buf }
    s" FITSKeyword" buf xml.<tag
    s" name" key-addr key-u buf xml.keyval
    s" value" value-addr value-u StrToFITSStr buf xml.keyval
    buf xml./>
    buf
;

: XISF.write-map-XISF ( map buf -- )
    ['] XISF.mapIterXISF rot map-for-each drop
;

: XISF.encode-header { frame header-buffer -- }
\ The attachment offset written into XML must remain equal to the exact fixed
\ header size emitted by save-XISFimage-to.
    header-buffer reset-buffer
    s" XISF010000000000" header-buffer write-buffer abort" XISF header buffer full"
    header-buffer xml.<??>
    s" xisf" header-buffer xml.<tag
        s" version" s" 1.0" header-buffer xml.keyval
    header-buffer xml.>
    s" Image" header-buffer xml.<tag
        s" geometry"
            frame FRAME_WIDTH @ frame FRAME_HEIGHT @ frame FRAME_DEPTH @
            ~~~$ header-buffer xml.keyval
        s" sampleFormat" s" SMPLFRMT" frame FRAME_METADATA @ map@ header-buffer xml.keyval
        s" colorSpace" s" COLORSPC" frame FRAME_METADATA @ map@ header-buffer xml.keyval
        s" offset" s" OFFSET" frame FRAME_METADATA @ map@ header-buffer xml.keyval
        s" imageType" s" IMAGETYP" frame FRAME_METADATA @ map@ header-buffer xml.keyval
        s" uuid" s" UUID" frame FRAME_METADATA @ map@ header-buffer xml.keyval
        s" location" s" attachment:" header-buffer xml.keyval
            XISF_HEADER_SIZE 0 <# #s #> header-buffer xml.append s" :" header-buffer xml.append
            frame frame-size 0 <# #s #> header-buffer xml.append
    header-buffer xml.>
    frame FRAME_METADATA @ dup if header-buffer XISF.write-map-XISF else drop then
    s" Image" header-buffer xml.</tag>
    s" xisf" header-buffer xml.</tag>
;

: save-XISFimage-to { frame filepath-buffer | fileid -- }
\ Save an XISF frame to an explicitly prepared pathname.
    frame xisf.header-buffer XISF.encode-header
    filepath-buffer create-imageDirectory
    filepath-buffer buffer-to-string w/o
        create-file abort" Cannot create XISF file" -> fileid
    xisf.header-buffer BUFFER_ADDR XISF_HEADER_SIZE fileid write-file abort" Cannot access XISF file"
    frame FRAME_BITMAP frame frame-size fileid write-file abort" Cannot access XISF file"
    fileid close-file abort" Cannot close XISF file"
;

: save-XISFframe-to { frame filepath-buffer -- }
\ Save a selected frame through the configured XISF writer.
    frame s" .xisf" filepath-buffer write-filepath-xisf
    frame filepath-buffer save-XISFimage-to
;

: save-XISFimage ( -- )
\ Save the current frame and retain its resulting XISF pathname.
    image XISFfilepath save-XISFframe-to
;
