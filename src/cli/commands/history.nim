## History Command Implementation
##
## Retrieves and displays historical OHLCV data for a symbol

import std/[options]
import ../[types, config, utils, formatters, cache]
import ../../yfnim/[types as ytypes, retriever]

proc executeHistory*(config: GlobalConfig, options: HistoryOptions, symbol: string) =
  ## Execute the history command
  ##
  ## Args:
  ##   config: Global configuration
  ##   options: History-specific options
  ##   symbol: Stock symbol to retrieve
  
  # Validate symbol
  if symbol.len == 0:
    raise newException(CliError, "Symbol is required")
  
  # Show progress message unless quiet
  if config.verbose:
    printInfo("Fetching historical data for " & symbol & "...", config)
  
  try:
    # Parse dates to timestamps
    var startTime: int64
    var endTime: int64
    
    if options.lookback.len > 0:
      # Use lookback period
      let (startLb, endLb) = parseLookback(options.lookback)
      startTime = startLb
      endTime = endLb
    else:
      # Use explicit start/end dates
      startTime = if options.startDate.len > 0:
        parseDateString(options.startDate)
      else:
        0'i64
      
      endTime = if options.endDate.len > 0:
        parseDateString(options.endDate)
      else:
        0'i64
    
    # Initialize cache
    let cacheObj = newCache(config.cacheEnabled, config.cacheTtl)
    
    # Try to get from cache first (unless refresh flag is set)
    var history: History
    var usedCache = false
    
    if not config.refresh:
      let cached = cacheObj.getCachedHistory(symbol, options.interval, startTime, endTime)
      if cached.isSome:
        history = cached.get()
        usedCache = true
        if config.verbose:
          printInfo("Using cached data", config)
    
    # If not in cache or refresh requested, fetch from API
    if not usedCache:
      history = getHistory(
        symbol = symbol,
        interval = options.interval,
        startTime = startTime,
        endTime = endTime
      )
      # Cache the result
      cacheObj.setCachedHistory(symbol, options.interval, startTime, endTime, history)
    
    # Check if we got any data
    if history.data.len == 0:
      if config.verbose:
        printWarning("No data available for " & symbol, config)
      return
    
    # Show success message unless quiet
    if config.verbose:
      printSuccess("Retrieved " & $history.data.len & " records", config)
    
    # Format and display output
    let formatter = newFormatter(config)
    echo formatter.formatHistory(history)
    
  except CatchableError as e:
    raise newException(CliError, "Failed to retrieve data: " & e.msg)


proc runHistory*() =
  ## Parse arguments and execute history command
  
  # Parse all arguments using existing config module function
  let (config, options) = parseHistoryArgs()
  
  # Get the symbol from options
  if options.symbols.len == 0:
    raise newException(CliError, "Symbol argument is required\nUsage: yf history <SYMBOL> [options]")
  
  let symbol = options.symbols[0]
  
  # Execute the command
  executeHistory(config, options, symbol)
