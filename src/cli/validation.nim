## Input Validation Module
##
## Common validation functions for CLI arguments

import std/strutils
import types

proc validateSymbolCount*(symbols: seq[string], min: int = 1, commandName: string = "command"): void =
  ## Validate that we have the required number of symbols
  ## Raises CliError if validation fails
  
  if symbols.len < min:
    if min == 1:
      raise newException(CliError, "At least one symbol is required")
    else:
      raise newException(CliError, "At least " & $min & " symbols are required for " & commandName)

proc validateInterval*(interval: string): void =
  ## Validate interval format
  ## Raises CliError if invalid
  
  const validIntervals = ["1m", "2m", "5m", "15m", "30m", "60m", "90m", 
                          "1h", "1d", "5d", "1wk", "1mo", "3mo"]
  
  if interval notin validIntervals:
    raise newException(CliError, "Invalid interval: " & interval & 
                       ". Valid: 1m, 5m, 15m, 30m, 1h, 1d, 1wk, 1mo")

proc validateLookback*(lookback: string): void =
  ## Validate lookback period format
  ## Raises CliError if invalid
  
  if lookback.len < 2:
    raise newException(CliError, "Invalid lookback format: " & lookback)
  
  let unit = lookback[^1]
  if unit notin ['d', 'w', 'm', 'y']:
    raise newException(CliError, "Invalid lookback unit in '" & lookback & 
                       "'. Use: d (days), w (weeks), m (months), y (years)")
  
  try:
    let num = parseInt(lookback[0..^2])
    if num <= 0:
      raise newException(CliError, "Lookback period must be positive")
  except ValueError:
    raise newException(CliError, "Invalid lookback number in: " & lookback)
