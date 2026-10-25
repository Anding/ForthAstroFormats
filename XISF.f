\ PixInsight XISF codec for format-neutral FRAME values.

NEED Frame
NEED ForthXML

8192 constant XISF_HEADER_SIZE
XISF_HEADER_SIZE allocate-buffer constant xisf.header-buffer
\ The XML header occupies a fixed block and the pixel attachment begins at
\ XISF_HEADER_SIZE. This shared scratch buffer makes the codec synchronous.

: XISF.mapIterXISF { buf ior key-addr key-u value-addr value-u -- buf ior }
    buf
    ior if ior exit then
    s" FITSKeyword" buf xml.<tag ?dup if exit then
    s" name" key-addr key-u buf xml.keyval ?dup if exit then
    s" value" value-addr value-u StrToFITSStr buf xml.keyval ?dup if exit then
    buf xml./>
;

: XISF.write-map-XISF ( map buf -- ior )
    0 ['] XISF.mapIterXISF 3 roll map-for-each nip
;

: XISF.encode-header { frame header-buffer -- ior }
\ The attachment offset written into XML must remain equal to the exact fixed
\ header size emitted by save-XISFimage-to. The binary prefix records only
\ the XML byte count; the remaining fixed-block padding stays zero.
    header-buffer reset-buffer
    s" XISF0100" header-buffer write-buffer ?dup if exit then
    8 header-buffer BUFFER_POINTER +! \ Zeroed length and reserved fields.
    header-buffer xml.<??> ?dup if exit then
    s" xisf" header-buffer xml.<tag ?dup if exit then
        s" version" s" 1.0" header-buffer xml.keyval ?dup if exit then
    header-buffer xml.> ?dup if exit then
    s" Image" header-buffer xml.<tag ?dup if exit then
        s" geometry"
            frame FRAME_WIDTH @ frame FRAME_HEIGHT @ frame FRAME_DEPTH @
            ~~~$ header-buffer xml.keyval ?dup if exit then
        s" sampleFormat" s" SMPLFRMT" frame FRAME_METADATA @ map@ header-buffer xml.keyval ?dup if exit then
        s" colorSpace" s" COLORSPC" frame FRAME_METADATA @ map@ header-buffer xml.keyval ?dup if exit then
        s" offset" s" OFFSET" frame FRAME_METADATA @ map@ header-buffer xml.keyval ?dup if exit then
        s" imageType" s" IMAGETYP" frame FRAME_METADATA @ map@ header-buffer xml.keyval ?dup if exit then
        s" uuid" s" UUID" frame FRAME_METADATA @ map@ header-buffer xml.keyval ?dup if exit then
        s" location" s" attachment:" header-buffer xml.keyval ?dup if exit then
            XISF_HEADER_SIZE 0 <# #s #> header-buffer xml.append ?dup if exit then
            s" :" header-buffer xml.append ?dup if exit then
            frame frame-size 0 <# #s #> header-buffer xml.append ?dup if exit then
    header-buffer xml.> ?dup if exit then
    frame FRAME_METADATA @ header-buffer XISF.write-map-XISF ?dup if exit then
    s" Image" header-buffer xml.</tag> ?dup if exit then
    s" xisf" header-buffer xml.</tag> ?dup if exit then
    header-buffer buffer_used 16 - header-buffer BUFFER_ADDR 8 + !
    0
;

: save-XISFimage-to { frame filepath-buffer | fileid -- }
\ Save an XISF frame to an explicitly prepared pathname.
    filepath-buffer buffer_used 0= if exit then
    frame xisf.header-buffer XISF.encode-header if
        cr ." Cannot encode XISF header" cr filepath-buffer reset-buffer exit
    then
    filepath-buffer open-publication-file -> fileid
    fileid 0= if exit then
    fileid
    xisf.header-buffer BUFFER_ADDR XISF_HEADER_SIZE fileid write-file
    frame FRAME_BITMAP frame frame-size fileid write-file or
    filepath-buffer finish-image-file
;

: save-XISFframe-to { frame filepath-buffer -- }
\ Save a selected frame through the configured XISF writer.
    frame s" .xisf" filepath-buffer write-filepath-xisf
    frame filepath-buffer save-XISFimage-to
;

: save-XISFimage ( frame -- )
\ Save the supplied frame and retain its resulting XISF pathname.
    XISFfilepath save-XISFframe-to
;
