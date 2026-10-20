\ Regression coverage for ordered FITS-map projection and atomic publication.

need ForthXISF
need FITS_projection
need simple-tester

256 allocate-buffer constant projection.path
256 allocate-buffer constant publication.source
256 allocate-buffer constant publication.destination
256 allocate-buffer constant projection.expected

: test.write-file { caddr u filepath-buffer | fileid -- }
    filepath-buffer create-imageDirectory
    filepath-buffer buffer-to-string w/o
        create-file abort" Cannot create test file" -> fileid
    caddr u fileid write-file abort" Cannot write test file"
    fileid close-file abort" Cannot close test file"
;

: test.file-hash { filepath-buffer | fileid buffer -- }
    filepath-buffer buffer-to-string r/o
        open-file abort" Cannot open test file" -> fileid
    fileid file-to-buffer -> buffer
    buffer buffer-to-string hashS
    buffer free-buffer
;

s" E:\images\tests\ForthAstroFormats" publication.source write-buffer drop
publication.source buffer-punctuate-filepath
s" \publication.tmp" publication.source write-buffer drop
s" E:\images\tests\ForthAstroFormats" publication.destination write-buffer drop
publication.destination buffer-punctuate-filepath
s" \publication.dat" publication.destination write-buffer drop
s" E:\images\tests\ForthAstroFormats" projection.path write-buffer drop
projection.path buffer-punctuate-filepath
s" \projection.dat" projection.path write-buffer drop
s" FIRST" projection.expected write-buffer drop
9 projection.expected echo-buffer drop
s" first" projection.expected write-buffer drop
13 projection.expected echo-buffer drop
10 projection.expected echo-buffer drop
s" SECOND" projection.expected write-buffer drop
9 projection.expected echo-buffer drop
s" second" projection.expected write-buffer drop
13 projection.expected echo-buffer drop
10 projection.expected echo-buffer drop

4 3 1 allocate-frame constant projection.image
s" first" projection.image FRAME_METADATA @ =>" FIRST"
s" second" projection.image FRAME_METADATA @ =>" SECOND"

Tstart

T{ projection.image projection.path save-FITSprojection-to }T ==
T{ projection.path test.file-hash }T projection.expected buffer-to-string hashS ==

s" old" publication.destination test.write-file
s" published" publication.source test.write-file
T{ publication.source publication.destination replace-file-atomically }T ==
T{ publication.destination test.file-hash }T s" published" hashS ==
T{ publication.source buffer-to-string FileExists? }T 0 ==

Tend

projection.image free-frame
projection.path free-buffer
publication.source free-buffer
publication.destination free-buffer
projection.expected free-buffer
