## Compare Command Implementation
##
## Compares multiple stocks side-by-side

import ../[types, config, utils, formatters]
import ../../yfnim/[quote_retriever]

proc executeCompare*(config: GlobalConfig, options: CompareOptions, symbols: seq[string]) =
  ## Execute the compare command
  ##
  ## Args:
  ##   config: Global configuration
  ##   options: Compare-specific options
  ##   symbols: Stock symbols to compare (minimum 2)
  
  # Validate symbols
  if symbols.len < 2:
    raise newException(CliError, "At least two symbols are required for comparison")
  
  # Show progress message unless quiet
  if config.verbose:
    printInfo("Comparing " & $symbols.len & " symbols...", config)
  
  try:
    # Retrieve quotes using the library
    let quotes = getQuotes(symbols)
    
    # Check if we got any data
    if quotes.len == 0:
      if config.verbose:
        printWarning("No quote data available", config)
      return
    
    if quotes.len < 2:
      if config.verbose:
        printWarning("Need at least 2 quotes for comparison (got " & $quotes.len & ")", config)
      return
    
    # Show success message unless quiet
    if config.verbose:
      printSuccess("Retrieved " & $quotes.len & " quote(s) for comparison", config)
    
    # Format and display output (using same formatter as quote)
    let formatter = newFormatter(config)
    echo formatter.formatQuotes(quotes)
    
  except CatchableError as e:
    raise newException(CliError, "Failed to compare symbols: " & e.msg)


proc runCompare*() =
  ## Parse arguments and execute compare command
  
  # Parse all arguments using existing config module function
  let (config, options) = parseCompareArgs()
  
  # Get symbols from options
  if options.symbols.len < 2:
    raise newException(CliError, "At least two symbols are required\nUsage: yf compare <SYMBOL> <SYMBOL> [<SYMBOL>...] [options]")
  
  # Execute the command
  executeCompare(config, options, options.symbols)
