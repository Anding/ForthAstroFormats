need ForthAstroFormats
need simple-tester

cr
Tstart

T{ '+' IsFITSnumchar? }T -1 ==
T{ '_' IsFITSnumchar? }T  0 ==
T{ '3' IsFITSnumchar? }T -1 ==
T{ 'A' IsFITSnumchar? }T  0 ==

T{ s" 1.75E10" StrToFITSStr hashS }T s" 1.75E10" hashS ==
T{ s" 1,75E10" StrToFITSStr hashS }T s" '1,75E10'" hashS ==
T{ s" '12 30 00'" FITSstrToStr hashS }T s" 12 30 00" hashS ==
T{ s" 1.75E10" FITSstrToStr hashS }T s" 1.75E10" hashS ==

Tend cr