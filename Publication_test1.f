NEED ForthPublication
NEED simple-tester

\ Keep injected failures visible without native source-caret transport framing.
: .throw ( ior -- ) ?dup if cr ." I/O error " . cr then ;
include "%idir%\Paths.f"
include "%idir%\Publication.f"

FILEPATH_SIZE allocate-buffer constant publication.test.filepath
1 1 1 allocate-frame constant publication.test.frame
s" 11111111-2222-3333-4444-555555555555"
    publication.test.frame FRAME_METADATA @ =>" UUID"

: publication.test-contains? { filepath-buffer text-addr text-u | fileid buffer found -- found }
\ Report whether a publication file contains the selected text.
    filepath-buffer buffer-to-string r/o
        open-file if drop 1 Tfailures +! cr ." Cannot open publication test file" cr 0 exit then -> fileid
    fileid file-to-buffer -> buffer
    buffer 0= if fileid close-file drop 1 Tfailures +! 0 exit then
    buffer buffer-to-string text-addr text-u search nip nip -> found
    buffer free-buffer
    fileid close-file if 1 Tfailures +! cr ." Cannot close publication test file" cr then
    found
;

: publication.test-path { frame suffix-addr suffix-u filepath-buffer -- }
    frame drop
    filepath-buffer reset-buffer
    s" E:\Coding\ForthAstroFormats\testdata\" filepath-buffer write-buffer drop
    filepath-buffer buffer-punctuate-filepath
    s" publication" filepath-buffer write-buffer drop
    suffix-addr suffix-u filepath-buffer write-buffer drop
;

: publication.test-write { | fileid -- }
\ Write representative absolute and frame-relative manifest records.
    publication.test.frame s" .dat" publication.test.filepath publication.test-path
    publication.test.filepath open-publication-file -> fileid
    fileid s" image name" s" test-image" write-manifest-line
        if 1 Tfailures +! then
    fileid s" image filepath" publication.test.filepath
        write-path-manifest-line if 1 Tfailures +! then
    fileid close-file if 1 Tfailures +! cr ." Cannot close publication test file" cr then
;

: publication.test-extension { fileid -- ior }
    fileid s" test extension" s" test value" write-manifest-line
;

: publication.test-failed-extension ( fileid -- ior )
    drop -37
;

Tstart

T{ publication.test-write }T ==
T{ publication.test.filepath
   s" E:\\Coding\\ForthAstroFormats\\testdata\\publication.dat"
   publication.test-contains?
}T -1 ==

ASSIGN publication.test-extension TO-DO write-preview-manifest-extension
T{ publication.test.filepath open-publication-file dup
   write-preview-manifest-extension swap close-file or
}T 0 ==
T{ publication.test.filepath
   s\" test extension: \"test value\""
   publication.test-contains?
}T -1 ==

ASSIGN publication.test-path TO-DO write-filepath-preview-manifest
publication.test.frame s" .dat" preview-manifest-filepath publication.test-path
s" previous manifest" preview-manifest-filepath save-binary-file-to
ASSIGN publication.test-failed-extension TO-DO write-preview-manifest-extension
T{ publication.test.frame 0 0 publish-preview-manifest }T ==
T{ preview-manifest-filepath buffer_used preview-manifest-tmp-filepath buffer_used }T 0 0 ==
publication.test.frame s" .dat" preview-manifest-filepath publication.test-path
T{ preview-manifest-filepath s" previous manifest" publication.test-contains? }T -1 ==
ASSIGN no-preview-manifest-extension TO-DO write-preview-manifest-extension
T{ publication.test.frame 0 0 publish-preview-manifest }T ==
T{ preview-manifest-filepath s" image name" publication.test-contains? }T -1 ==
preview-manifest-filepath buffer-to-string delete-file drop

publication.test.filepath buffer-to-string delete-file drop
publication.test.frame free-frame

Tend
