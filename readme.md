# ForthXISF

Forth package to read and write the XISF file format used by PixInsight.

https://pixinsight.com/doc/docs/XISF-1.0-spec/XISF-1.0-spec.html

## Image context

`IMAGE_CONTEXT` is the shared image representation used by XISF, FITS,
preview, analysis, and solver code. `IMAGE_DESCRIPTOR` remains an alias for
compatibility with existing callers.

The context owns dimensions, pixel data, a `FITS_MAP`, and image statistics.
Writers retain their own output paths and update or project the existing
ordered FITS map rather than maintaining separate metadata objects.
Metadata uses ForthBase `ordered-maps`: `allocate-map`/`free-map`, `map!`,
`map@`, `map-count`, and insertion-ordered `map-for-each`. Missing and empty
values both read as `( 0 0 )`. `reset-frame-metadata` uses `erase-map` to
forget all per-exposure keys; `reset-map` instead retains keys and order.

## FITS projection and publication

Load the projection vocabulary through the ForthBase manifest:

```forth
NEED FITS_projection
```

The public words are:

```forth
save-FITSprojection    ( -- )
save-FITSprojection-to ( img filepath-buffer -- )
replace-file-atomically ( source-buffer destination-buffer -- )
```

`save-FITSprojection` writes the shared current image through its dedicated
pathname policy and retains the resulting path. `save-FITSprojection-to` is
the explicit low-level form. Both write the ordered FITS map as UTF-8
`key<TAB>value<CRLF>` lines through an in-memory buffer. Before opening the
output file, projection totals the required bytes with a `map-for-each`
accumulator and rejects oversized metadata. Serializer callbacks consume
the supplied key and value strings directly.

For fault isolation, enable `LOG-ON` and `-1 -> FITS.projection-debug`.
The `fits-projection` channel records each key, value length and hexadecimal
bytes, plus file creation, allocation, iteration, write, free and close
boundaries. Detailed projection logging is off by default and follows
`log.directory`. `FITS_projection_test2.f` covers empty values, zero, NUL,
control bytes and maximum-length counted values without hardware.

`replace-file-atomically` expects ForthBase buffer descriptors containing
source and destination paths. It temporarily appends the required NUL
terminators, calls the native `ReplaceFileAtomic` export, and restores the
retained paths before returning. Replacement exposes the destination only
after a completed temporary manifest exists.

## Output pathname policy

`ForthAstroFormats` provides replaceable complete-path composers:

```forth
s" E:\images" $value astro.root
```

The formats package owns this global root; an observatory environment may
replace it with `$-> astro.root`.

```forth
write-filepath-bmp                ( frame caddr u filepath-buffer -- )
write-filepath-stretched-bmp      ( frame caddr u filepath-buffer -- )
write-filepath-histogram          ( frame caddr u filepath-buffer -- )
write-filepath-preview-manifest   ( frame caddr u filepath-buffer -- )
write-filepath-fits-projection    ( frame caddr u filepath-buffer -- )
write-filepath-metadata-manifest  ( frame caddr u filepath-buffer -- )
write-filepath-xisf               ( frame caddr u filepath-buffer -- )
write-filepath-fits               ( frame caddr u filepath-buffer -- )
write-filepath-wcs                ( frame caddr u filepath-buffer -- )
```

Each writer owns its dedicated deferred pathname creator, retained filepath
buffer, extension, and file I/O. Defaults are assigned when the formats
library loads, so ordinary orchestration only invokes the zero-argument
writers:

Complete-path composers must call `buffer-punctuate-filepath` after the
folder and before the filename. Directory creation rejects buffers without
that recorded boundary rather than passing an invalid length to Windows.

```forth
save-XISFimage
save-FITSimage
```

A private solver temporarily replaces only `write-filepath-fits`, calls
`save-FITSframe-to`, and restores the previous action.

`append-UUID-suffix ( uuid-addr uuid-u filepath-buffer -- )` appends `-` and
UUID bytes at offset 24, length 12, only when at least 36 bytes are present.
Missing, empty, or short UUIDs omit the entire science filename suffix.
Existing science files may be overwritten. UUID-based working directories
are unchanged.

`solver.alignment-FITS` rejects missing or unparseable required alignment
inputs before producing a mount command. Coordinates and sidereal time use
three colon-separated fields, `NIGHTOF` accepts `YYYY-MM-DD` or the existing
numeric date representation, `PIERSIDE` is
`EAST` or `WEST`, and both solved CRVAL fields must parse as floating point.

`NEED ForthPublication` loads the generic UUID-path and manifest record words.
It owns binary output, manifest publication, and atomic replacement mechanics.
`NEED ForthPreview` loads the stretched-BMP and histogram writers.

VFXterm is a 32-bit process and must be able to load the Win32 Release
`XISF.dll`. Deploy
`XISF_project\Release\XISF.dll` beside `VFXterm.exe` before exercising any
native XISF export. An unresolved DLL binding can terminate VFX on its first
native call; `FITS_projection_test1.f` verifies the atomic replacement path.

## Preview BMP output

```forth
save-BMPimage ( img bitmap filepath-buffer -- )
```

The native writer saves an 8-bit, top-down grayscale BMP from the high byte of
each 16-bit image sample. The caller supplies the source bitmap and a
ForthBase filepath buffer.

## Tests

`FITS_projection_test1.f` is a standalone `simple-tester` regression suite.
It verifies ordered projection bytes, atomic replacement and source removal,
without hardware.
`Metadata_test1.f` checks serializer order, replacements, empty values, and
FITS long-key omission. `Frame_test1.f`, `Paths_test1.f`, and
`Solver_test1.f` cover per-exposure erasure, optional UUID suffixes, and
rejection of missing or malformed alignment inputs, respectively.
