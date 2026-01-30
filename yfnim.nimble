# Package

version       = "0.1.0"
author        = "Jaime Lopez"
description   = "A Yahoo Finance historical data retriever with support for multiple intervals"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 2.2.6"

# Standard library modules used:
# - std/httpclient - HTTP requests
# - std/json - JSON parsing
# - std/times - Time/date operations
# - std/strutils - String manipulation and conversions

# Tasks

task examples, "Compile all example programs":
  echo "Compiling examples..."
  
  exec "nim c -d:ssl -p:src examples/basic_usage.nim"
  echo "✓ basic_usage.nim compiled"
  
  exec "nim c -d:ssl -p:src examples/multiple_symbols.nim"
  echo "✓ multiple_symbols.nim compiled"
  
  exec "nim c -d:ssl -p:src examples/json_export.nim"
  echo "✓ json_export.nim compiled"
  
  exec "nim c -d:ssl -p:src examples/error_handling.nim"
  echo "✓ error_handling.nim compiled"
  
  exec "nim c -d:ssl -p:src examples/data_analysis.nim"
  echo "✓ data_analysis.nim compiled"
  
  exec "nim c -d:ssl -p:src examples/intraday_analysis.nim"
  echo "✓ intraday_analysis.nim compiled"
  
  echo ""
  echo "All examples compiled successfully!"
  echo "Run with: ./examples/<example_name>"

task runExample, "Run a specific example (usage: nimble runExample <name>)":
  if paramCount() < 2:
    echo "Usage: nimble runExample <example_name>"
    echo "Available examples:"
    echo "  - basic_usage"
    echo "  - multiple_symbols"
    echo "  - json_export"
    echo "  - error_handling"
    echo "  - data_analysis"
    echo "  - intraday_analysis"
    quit(1)
  
  let exampleName = paramStr(2)
  let examplePath = "examples/" & exampleName & ".nim"
  
  echo "Compiling and running ", examplePath, "..."
  exec "nim c -d:ssl -p:src -r " & examplePath
