\ Native atomic file replacement boundary for publication manifests.

LIBRARY: XISF.dll
Extern: int "C" ReplaceFileAtomic( char * source, char * destination ) ;

: replace-file-atomically
    { source-buffer destination-buffer | replaced? -- }
\ Replace a completed publication, restoring both descriptor paths before returning.
    0 source-buffer echo-buffer abort" Publication source path buffer full"
    0 destination-buffer echo-buffer abort" Publication destination path buffer full"
    10 0 do
        source-buffer buffer-to-string drop
        destination-buffer buffer-to-string drop
        ReplaceFileAtomic 0= if -1 -> replaced? leave then
        100 ms
    loop
    source-buffer backspace-buffer abort" Cannot restore publication source path"
    destination-buffer backspace-buffer abort" Cannot restore publication destination path"
    replaced? 0= abort" Cannot replace publication manifest"
;
