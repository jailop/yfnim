## Screen Command Implementation
##
## Screens stocks based on various criteria

import std/[options]
import ../[types, config, utils, formatters, filter]
import ../../yfnim/[quote_types, quote_retriever]

proc executeScreen*(config: GlobalConfig, options: ScreenOptions, symbols: seq[string]) =
  ## Execute the screen command
  ##
  ## Args:
  ##   config: Global configuration
  ##   options: Screen-specific options
  ##   symbols: Stock symbols to screen
  
  # Validate symbols
  if symbols.len == 0:
    raise newException(CliError, "At least one symbol is required")
  
  # Show progress message unless quiet
  if config.verbose:
    printInfo("Screening " & $symbols.len & " symbols with criteria: " & $options.criteria & "...", config)
  
  try:
    # Retrieve quotes using the library
    let quotes = getQuotes(symbols)
    
    # Check if we got any data
    if quotes.len == 0:
      if config.verbose:
        printWarning("No quote data available", config)
      return
    
    # Filter based on criteria
    var filteredQuotes: seq[Quote] = @[]
    
    case options.criteria
    of CriteriaValue:
      # Value stocks: Low P/E (< 20), High dividend yield (> 2%)
      for quote in quotes:
        if quote.trailingPE.isSome and quote.dividendYield.isSome:
          let pe = quote.trailingPE.get()
          let dy = quote.dividendYield.get()
          if pe < 20.0 and pe > 0.0 and dy > 2.0:
            filteredQuotes.add(quote)
    
    of CriteriaGrowth:
      # Growth stocks: High price momentum (52-week change > 20%)
      for quote in quotes:
        if quote.fiftyTwoWeekChangePercent > 20.0:
          filteredQuotes.add(quote)
    
    of CriteriaDividend:
      # Dividend stocks: Dividend yield > 3%
      for quote in quotes:
        if quote.dividendYield.isSome:
          let dy = quote.dividendYield.get()
          if dy > 3.0:
            filteredQuotes.add(quote)
    
    of CriteriaMomentum:
      # Momentum stocks: Positive change today
      for quote in quotes:
        if quote.regularMarketChangePercent > 0.0:
          filteredQuotes.add(quote)
    
    of CriteriaCustom:
      # Custom filtering using expression parser
      if options.whereClause.len == 0:
        if config.verbose:
          printWarning("Custom criteria requires --where clause", config)
        filteredQuotes = quotes
      else:
        # Use expression parser
        for quote in quotes:
          try:
            if evalFilter(options.whereClause, quote):
              filteredQuotes.add(quote)
          except ParseError as e:
            raise newException(CliError, "Filter error: " & e.msg)
    
    # Show results
    if filteredQuotes.len == 0:
      if config.verbose:
        printWarning("No symbols match the criteria", config)
      return
    
    # Show success message unless quiet
    if config.verbose:
      printSuccess($filteredQuotes.len & " of " & $quotes.len & " symbols match the criteria", config)
    
    # Format and display output
    let formatter = newFormatter(config)
    echo formatter.formatQuotes(filteredQuotes)
    
  except CatchableError as e:
    raise newException(CliError, "Failed to screen symbols: " & e.msg)


proc runScreen*() =
  ## Parse arguments and execute screen command
  
  # Parse all arguments using existing config module function
  let (config, options) = parseScreenArgs()
  
  # Get symbols from options
  if options.symbols.len == 0:
    raise newException(CliError, "At least one symbol is required\nUsage: yf screen <SYMBOL> [<SYMBOL>...] [options]")
  
  # Execute the command
  executeScreen(config, options, options.symbols)
