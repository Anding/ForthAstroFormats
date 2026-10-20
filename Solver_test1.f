NEED ForthAstroSolver
NEED simple-tester

4 3 1 allocate-frame constant solver.test-frame
solver.test-frame FRAME_METADATA @ constant solver.test-metadata

s" 04:29:05.0" solver.test-metadata =>" OBJCTRA"
s" +29:33:59.0" solver.test-metadata =>" OBJCTDEC"
s" 00:00:00.0" solver.test-metadata =>" SIDEREAL"
s" 2461082.0" solver.test-metadata =>" NIGHTOF"
s" EAST" solver.test-metadata =>" PIERSIDE"
s" 67.2708" solver.test-metadata =>" CRVAL1"
s" 29.5664" solver.test-metadata =>" CRVAL2"

256 allocate-buffer constant solver.test-original

: solver.test-align ( -- )
    solver.test-metadata solver.alignment-FITS
;

: solver.test-reject { value-addr value-u key-addr key-u | status -- flag }
    solver.test-original reset-buffer
    key-addr key-u solver.test-metadata map@
        solver.test-original write-buffer drop
    value-addr value-u key-addr key-u solver.test-metadata map!
    s" unchanged" $-> solver.alignment-command
    ['] solver.test-align catch -> status
    solver.test-original buffer-to-string
        key-addr key-u solver.test-metadata map!
    status -2 =
    solver.alignment-command s" unchanged" compare 0= and
;

Tstart

T{ solver.test-metadata solver.alignment-FITS }T ==
T{ s" 10UALPT" solver.test-metadata map@ nip 0> }T -1 ==
T{ s" 10UALPT" solver.test-metadata map@ s\" s\" " search nip nip }T -1 ==
T{ s" 10UALPT" solver.test-metadata map@
   s" add-alignment-point" search nip nip
}T -1 ==
T{ s" 10UALPT" solver.test-metadata map@
   s" ,E," search nip nip
}T -1 ==

T{ 0 0 s" OBJCTRA" solver.test-reject }T -1 ==
T{ 0 0 s" OBJCTDEC" solver.test-reject }T -1 ==
T{ 0 0 s" SIDEREAL" solver.test-reject }T -1 ==
T{ 0 0 s" NIGHTOF" solver.test-reject }T -1 ==
T{ 0 0 s" PIERSIDE" solver.test-reject }T -1 ==
T{ 0 0 s" CRVAL1" solver.test-reject }T -1 ==
T{ 0 0 s" CRVAL2" solver.test-reject }T -1 ==
T{ s" bad" s" OBJCTRA" solver.test-reject }T -1 ==
T{ s" 29:bad:59" s" OBJCTDEC" solver.test-reject }T -1 ==
T{ s" 00:00:bad" s" SIDEREAL" solver.test-reject }T -1 ==
T{ s" 2026-02-bad" s" NIGHTOF" solver.test-reject }T -1 ==
T{ s" UNKNOWN" s" PIERSIDE" solver.test-reject }T -1 ==
T{ s" bad" s" CRVAL1" solver.test-reject }T -1 ==
T{ s" bad" s" CRVAL2" solver.test-reject }T -1 ==
T{ s" 04:29" s" OBJCTRA" solver.test-reject }T -1 ==
T{ s" 00::00" s" SIDEREAL" solver.test-reject }T -1 ==
T{ s" 2461082.bad" s" NIGHTOF" solver.test-reject }T -1 ==
T{ s"   " s" NIGHTOF" solver.test-reject }T -1 ==
T{ s"   " s" CRVAL1" solver.test-reject }T -1 ==
T{ s"   " s" CRVAL2" solver.test-reject }T -1 ==
T{ s" 00:00: " s" SIDEREAL" solver.test-reject }T -1 ==
T{ s" 2026-02-10" solver.alignment-night~ }T 2026 2 10 ~ ==
T{ s" 2461082.0" solver.alignment-night~ }T 2461082 0 0 ~ ==
T{ s" 2461082" solver.alignment-night~ }T 2461082 0 0 ~ ==
T{ s" +04:29:05.0" ':' solver.alignment-number~ }T 4 29 5 ~ ==
T{ s" -29:33:59.0" ':' solver.alignment-number~ }T -29 -33 -59 ~ ==
s" 2026-02-10" solver.test-metadata =>" NIGHTOF"
T{ solver.test-align fdepth }T 0 ==
solver.test-metadata erase-map
T{ ' solver.test-align catch }T -2 ==

Tend

solver.test-original free-buffer
solver.test-frame free-frame
