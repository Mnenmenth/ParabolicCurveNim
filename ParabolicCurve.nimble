# Package

version       = "0.1.0"
author        = "Earl Kennedy"
description   = "Parabolic Curve example using libgraph (In Nim)"
license       = "MIT"

srcDir        = "src"
binDir        = "bin"
bin           = @["ParabolicCurve"]

# Dependencies

requires "nim >= 0.17.2"
requires "libgraph"
requires "sdl2_nim"

task release, "Release Build":
    exec "nim c --d:release --opt:size --deadCodeElim:on --app:gui  -o:bin/ParabolicCurve src/ParabolicCurve.nim"