\ Native atomic file replacement boundary for publication manifests.

NEED ForthAstroPaths

LIBRARY: XISF.dll
Extern: int "C" ReplaceFileAtomic( char * source, char * destination ) ;

: replace-file-atomically
    { source-buffer destination-buffer -- }
\ Replace a completed publication, restoring both descriptor paths before returning.
    source-buffer native-image-filepath 0= if destination-buffer reset-buffer exit then
    destination-buffer native-image-filepath 0= if source-buffer discard-image-file exit then
    source-buffer BUFFER_ADDR destination-buffer BUFFER_ADDR ReplaceFileAtomic dup .throw
    if
        source-buffer discard-image-file destination-buffer reset-buffer
    then
;
