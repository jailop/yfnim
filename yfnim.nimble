version       = "0.2.0"
author        = "Jaime Lopez"
description   = "A Yahoo Finance historical data retriever with support for multiple intervals"
license       = "MIT"
srcDir        = "src"
bin           = @["yf"]
binDir        = "bin"
installExt    = @["nim"]

requires "nim >= 2.2.6"
requires "cligen >= 1.9.6"

task examples, "Compile all example programs":
  exec "nim c examples/basic_usage.nim"
  exec "nim c examples/multiple_symbols.nim"
  exec "nim c examples/json_export.nim"
  exec "nim c examples/error_handling.nim"
  exec "nim c examples/data_analysis.nim"
  exec "nim c examples/intraday_analysis.nim"

task docs, "Generate API documentation":
  mkDir "docs/api"
  exec "nim doc --project --index:on --outdir:docs/api src/yfnim.nim"
  exec "nim doc --outdir:docs/api src/yfnim/types.nim"
  exec "nim doc --outdir:docs/api src/yfnim/urlbuilder.nim"
  exec "nim doc --outdir:docs/api src/yfnim/retriever.nim"
  exec "nim doc --outdir:docs/api src/yfnim/quote_types.nim"
  exec "nim doc --outdir:docs/api src/yfnim/quote_retriever.nim"


