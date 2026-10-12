NEED ForthPublication
NEED simple-tester

FILEPATH_SIZE allocate-buffer constant publication.test.filepath
1 1 1 allocate-frame constant publication.test.frame
s" 11111111-2222-3333-4444-555555555555"
    publication.test.frame FRAME_METADATA @ =>" UUID"

: publication.test-contains? { filepath-buffer text-addr text-u | fileid buffer found -- found }
\ Report whether a publication file contains the selected text.
    filepath-buffer buffer-to-string r/o
        open-file abort" Cannot open publication test file" -> fileid
    fileid file-to-buffer -> buffer
    buffer buffer-to-string text-addr text-u search nip nip -> found
    buffer free-buffer
    fileid close-file abort" Cannot close publication test file"
    found
;

: publication.test-write { | fileid -- }
\ Write representative absolute and frame-relative manifest records.
    publication.test.filepath reset-buffer
    s" E:\Coding\ForthAstroFormats\testdata\"
        publication.test.filepath write-buffer drop
    publication.test.filepath buffer-punctuate-filepath
    s" publication.dat" publication.test.filepath write-buffer drop
    publication.test.filepath open-publication-file -> fileid
    fileid s" image name" s" test-image" write-manifest-line
    fileid s" image filepath" publication.test.filepath
        write-path-manifest-line
    fileid close-file abort" Cannot close publication test file"
;

: publication.test-extension { fileid -- }
    fileid s" test extension" s" test value" write-manifest-line
;

: publication.test-versioned-path ( -- caddr u )
\ Build one representative UUID-versioned publication pathname.
    publication.test.filepath reset-buffer
    s" E:\stream\11111111-2222-3333-4444-555555555555\image.bmp"
        publication.test.filepath write-buffer drop
    publication.test.filepath buffer-to-string
;

Tstart

T{ publication.test-versioned-path hashS
}T s" E:\stream\11111111-2222-3333-4444-555555555555\image.bmp" hashS ==

T{ publication.test-write }T ==
T{ publication.test.filepath
   s" E:\\Coding\\ForthAstroFormats\\testdata\\publication.dat"
   publication.test-contains?
}T -1 ==

ASSIGN publication.test-extension TO-DO write-preview-manifest-extension
T{ publication.test.filepath open-publication-file dup
   write-preview-manifest-extension close-file
}T 0 ==
T{ publication.test.filepath
   s\" test extension: \"test value\""
   publication.test-contains?
}T -1 ==

publication.test.filepath buffer-to-string delete-file drop
publication.test.frame free-frame

Tend
