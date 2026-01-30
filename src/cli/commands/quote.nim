## Quote Command Implementation
##
## Retrieves and displays current quote data for one or more symbols

import std/[os, strutils, sequtils, options]
import ../[types, config, utils, formatters, cache]
import ../../yfnim/[quote_types, quote_retriever]

proc executeQuote*(config: GlobalConfig, options: QuoteOptions, symbols: seq[string]) =
  ## Execute the quote command
  ##
  ## Args:
  ##   config: Global configuration
  ##   options: Quote-specific options
  ##   symbols: Stock symbols to retrieve
  
  # Validate symbols
  if symbols.len == 0:
    raise newException(CliError, "At least one symbol is required")
  
  # Show progress message unless quiet
  if not config.quiet:
    let symbolStr = if symbols.len == 1: symbols[0] else: $symbols.len & " symbols"
    printInfo("Fetching quote data for " & symbolStr & "...", config)
  
  try:
    # Initialize cache
    let cacheObj = newCache(config.cacheEnabled, config.cacheTtl)
    
    # Try to get quotes from cache or fetch fresh
    var quotes: seq[Quote] = @[]
    var cachedCount = 0
    var fetchSymbols: seq[string] = @[]
    
    if not config.refresh:
      # Try cache for each symbol
      for symbol in symbols:
        let cached = cacheObj.getCachedQuote(symbol)
        if cached.isSome:
          quotes.add(cached.get())
          cachedCount.inc
        else:
          fetchSymbols.add(symbol)
    else:
      fetchSymbols = symbols
    
    # Fetch symbols not in cache
    if fetchSymbols.len > 0:
      let freshQuotes = getQuotes(fetchSymbols)
      for quote in freshQuotes:
        cacheObj.setCachedQuote(quote.symbol, quote)
        quotes.add(quote)
    
    if not config.quiet and cachedCount > 0:
      printInfo("Used cached data for " & $cachedCount & " symbol(s)", config)
    
    # Check if we got any data
    if quotes.len == 0:
      if not config.quiet:
        printWarning("No quote data available", config)
      return
    
    # Show success message unless quiet
    if not config.quiet:
      printSuccess("Retrieved " & $quotes.len & " quote(s)", config)
    
    # Format and display output
    let formatter = newFormatter(config)
    echo formatter.formatQuotes(quotes)
    
  except CatchableError as e:
    raise newException(CliError, "Failed to retrieve quotes: " & e.msg)


proc runQuote*() =
  ## Parse arguments and execute quote command
  
  # Parse all arguments using existing config module function
  let (config, options) = parseQuoteArgs()
  
  # Get symbols from options
  if options.symbols.len == 0:
    raise newException(CliError, "At least one symbol is required\nUsage: yf quote <SYMBOL> [<SYMBOL>...] [options]")
  
  # Execute the command
  executeQuote(config, options, options.symbols)
