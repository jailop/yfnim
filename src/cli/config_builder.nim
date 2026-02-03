## CLI Configuration Builder Module
##
## Utilities for building GlobalConfig from command-line arguments
## Reduces code duplication across command implementations

import std/strutils
import types

proc buildConfig*(
  format: string,
  verbose: bool,
  no_header: bool,
  no_color: bool,
  precision: int,
  date_format: string
): GlobalConfig =
  ## Build a GlobalConfig from common command-line arguments
  ## Raises CliError if any values are invalid
  
  result = newGlobalConfig()
  result.verbose = verbose
  result.noHeader = no_header
  result.colorize = not no_color
  result.precision = precision
  
  # Parse format
  case format.toLower()
  of "table": result.format = FormatTable
  of "csv": result.format = FormatCSV
  of "json": result.format = FormatJSON
  of "tsv": result.format = FormatTSV
  of "minimal": result.format = FormatMinimal
  else:
    raise newException(CliError, "Invalid format: " & format & ". Use: table, csv, json, tsv, minimal")
  
  # Parse date format
  case date_format.toLower()
  of "iso": result.dateFormat = DateISO
  of "us": result.dateFormat = DateUS
  of "unix": result.dateFormat = DateUnix
  of "full": result.dateFormat = DateFull
  else:
    raise newException(CliError, "Invalid date format: " & date_format & ". Use: iso, us, unix, full")
