## Stdin Reader Module
##
## Provides utilities for reading stock symbols from stdin
## Supports multiple input formats: line-separated, comma-separated, space-separated

import std/[strutils, terminal]

proc isStdinAvailable*(): bool =
  ## Check if stdin has data available (not a TTY)
  not stdin.isatty()

proc readSymbolsFromStdin*(): seq[string] =
  ## Read stock symbols from stdin
  ## Supports multiple formats:
  ##   - Line-separated: one symbol per line
  ##   - Comma-separated: AAPL,MSFT,GOOGL
  ##   - Space-separated: AAPL MSFT GOOGL
  ##   - Mixed: AAPL MSFT,GOOGL
  ##
  ## Returns a sequence of trimmed, uppercase symbols
  result = @[]
  
  # Read all input
  var input = ""
  try:
    while not stdin.endOfFile():
      input.add(stdin.readLine() & "\n")
  except EOFError:
    discard
  
  if input.len == 0:
    return result
  
  # Split by lines first
  let lines = input.split('\n')
  
  for line in lines:
    let trimmedLine = line.strip()
    if trimmedLine.len == 0:
      continue
    
    # Check if line contains commas
    if ',' in trimmedLine:
      # Comma-separated
      for part in trimmedLine.split(','):
        let symbol = part.strip().toUpperAscii()
        if symbol.len > 0 and symbol notin result:
          result.add(symbol)
    else:
      # Space-separated or single symbol
      for part in trimmedLine.split():
        let symbol = part.strip().toUpperAscii()
        if symbol.len > 0 and symbol notin result:
          result.add(symbol)

proc validateSymbol*(symbol: string): bool =
  ## Basic validation for stock ticker symbols
  ## Returns true if the symbol looks valid
  if symbol.len == 0 or symbol.len > 10:
    return false
  
  # Should contain only letters, numbers, dots, and hyphens
  for c in symbol:
    if not (c.isAlphaNumeric() or c == '.' or c == '-'):
      return false
  
  return true

proc readAndValidateSymbols*(): seq[string] =
  ## Read symbols from stdin and validate them
  ## Returns only valid symbols
  let symbols = readSymbolsFromStdin()
  result = @[]
  
  for symbol in symbols:
    if validateSymbol(symbol):
      result.add(symbol)
