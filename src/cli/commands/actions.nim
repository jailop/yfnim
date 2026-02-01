## Actions Command Implementation
##
## Retrieves and displays corporate actions (dividends, splits) for a symbol

import std/[os, times, strutils, strformat]
import ../[types, config, utils, formatters]
import ../../yfnim/[types as ytypes, actions_retriever]

proc executeDividends*(config: GlobalConfig, options: ActionsOptions) =
  ## Execute the dividends command
  ##
  ## Args:
  ##   config: Global configuration
  ##   options: Actions-specific options
  
  # Validate symbol
  if options.symbol.len == 0:
    raise newException(CliError, "Symbol is required")
  
  # Show progress message unless quiet
  if not config.quiet:
    printInfo("Fetching dividend history for " & options.symbol & "...", config)
  
  try:
    # Parse dates if provided
    var startDate = dateTime(1970, mJan, 1, zone = utc())
    var endDate = now().utc()
    
    if options.lookback.len > 0 and options.lookback != "max":
      let (startLb, endLb) = parseLookback(options.lookback)
      startDate = fromUnix(startLb).utc()
      endDate = fromUnix(endLb).utc()
    elif options.startDate.len > 0:
      startDate = fromUnix(parseDateString(options.startDate)).utc()
    
    if options.endDate.len > 0:
      endDate = fromUnix(parseDateString(options.endDate)).utc()
    
    # Fetch dividends
    let dividends = getDividends(options.symbol, startDate, endDate)
    
    # Check if we got any data
    if dividends.len == 0:
      if not config.quiet:
        printWarning("No dividend history available for " & options.symbol, config)
      return
    
    # Show success message unless quiet
    if not config.quiet:
      printSuccess("Retrieved " & $dividends.len & " dividends", config)
    
    # Format and display output
    case config.format
    of FormatJSON:
      # JSON output
      var jsonStr = "["
      for i, dividend in dividends:
        if i > 0: jsonStr &= ","
        jsonStr &= "\n  {\"date\": \"" & dividend.date.format("yyyy-MM-dd") & 
                   "\", \"amount\": " & $dividend.amount & "}"
      jsonStr &= "\n]"
      echo jsonStr
    
    of FormatCSV:
      # CSV output
      if not config.noHeader:
        echo "Date,Amount"
      for dividend in dividends:
        echo dividend.date.format("yyyy-MM-dd") & "," & $dividend.amount
    
    of FormatTSV:
      # TSV output
      if not config.noHeader:
        echo "Date\tAmount"
      for dividend in dividends:
        echo dividend.date.format("yyyy-MM-dd") & "\t" & $dividend.amount
    
    else:
      # Table format (default)
      echo ""
      echo "Dividend History: " & options.symbol
      echo "─".repeat(50)
      echo "Date          Amount"
      echo "─".repeat(50)
      
      # Show all dividends (or recent ones if too many)
      let maxShow = 100
      let toShow = if dividends.len > maxShow: maxShow else: dividends.len
      let startIdx = if dividends.len > maxShow: dividends.len - maxShow else: 0
      
      for i in startIdx..<dividends.len:
        let dividend = dividends[i]
        let dateStr = dividend.date.format("yyyy-MM-dd")
        let amountStr = formatFloat(dividend.amount, ffDecimal, config.precision)
        echo fmt"{dateStr:<12}  ${amountStr:>8}"
      
      if dividends.len > maxShow:
        echo ""
        echo fmt"(Showing last {maxShow} of {dividends.len} dividends)"
      
      echo "─".repeat(50)
      echo fmt"Total: {dividends.len} dividends"
    
  except ActionsError as e:
    raise newException(CliError, "Failed to retrieve dividends: " & e.msg)
  except CatchableError as e:
    raise newException(CliError, "Failed to retrieve dividends: " & e.msg)


proc executeSplits*(config: GlobalConfig, options: ActionsOptions) =
  ## Execute the splits command
  ##
  ## Args:
  ##   config: Global configuration
  ##   options: Actions-specific options
  
  # Validate symbol
  if options.symbol.len == 0:
    raise newException(CliError, "Symbol is required")
  
  # Show progress message unless quiet
  if not config.quiet:
    printInfo("Fetching split history for " & options.symbol & "...", config)
  
  try:
    # Parse dates if provided
    var startDate = dateTime(1970, mJan, 1, zone = utc())
    var endDate = now().utc()
    
    if options.lookback.len > 0 and options.lookback != "max":
      let (startLb, endLb) = parseLookback(options.lookback)
      startDate = fromUnix(startLb).utc()
      endDate = fromUnix(endLb).utc()
    elif options.startDate.len > 0:
      startDate = fromUnix(parseDateString(options.startDate)).utc()
    
    if options.endDate.len > 0:
      endDate = fromUnix(parseDateString(options.endDate)).utc()
    
    # Fetch splits
    let splits = getSplits(options.symbol, startDate, endDate)
    
    # Check if we got any data
    if splits.len == 0:
      if not config.quiet:
        printWarning("No split history available for " & options.symbol, config)
      return
    
    # Show success message unless quiet
    if not config.quiet:
      printSuccess("Retrieved " & $splits.len & " splits", config)
    
    # Format and display output
    case config.format
    of FormatJSON:
      # JSON output
      var jsonStr = "["
      for i, split in splits:
        if i > 0: jsonStr &= ","
        jsonStr &= "\n  {\"date\": \"" & split.date.format("yyyy-MM-dd") & 
                   "\", \"splitRatio\": \"" & split.splitRatio & "\"}"
      jsonStr &= "\n]"
      echo jsonStr
    
    of FormatCSV:
      # CSV output
      if not config.noHeader:
        echo "Date,Ratio"
      for split in splits:
        echo split.date.format("yyyy-MM-dd") & "," & split.splitRatio
    
    of FormatTSV:
      # TSV output
      if not config.noHeader:
        echo "Date\tRatio"
      for split in splits:
        echo split.date.format("yyyy-MM-dd") & "\t" & split.splitRatio
    
    else:
      # Table format (default)
      echo ""
      echo "Stock Split History: " & options.symbol
      echo "─".repeat(50)
      echo "Date          Ratio"
      echo "─".repeat(50)
      
      for split in splits:
        let dateStr = split.date.format("yyyy-MM-dd")
        echo fmt"{dateStr:<12}  {split.splitRatio:>10}"
      
      echo "─".repeat(50)
      echo fmt"Total: {splits.len} splits"
    
  except ActionsError as e:
    raise newException(CliError, "Failed to retrieve splits: " & e.msg)
  except CatchableError as e:
    raise newException(CliError, "Failed to retrieve splits: " & e.msg)


proc executeActions*(config: GlobalConfig, options: ActionsOptions) =
  ## Execute the actions command (shows both dividends and splits)
  ##
  ## Args:
  ##   config: Global configuration
  ##   options: Actions-specific options
  
  # Validate symbol
  if options.symbol.len == 0:
    raise newException(CliError, "Symbol is required")
  
  # Show progress message unless quiet
  if not config.quiet:
    printInfo("Fetching corporate actions for " & options.symbol & "...", config)
  
  try:
    # Parse dates if provided
    var startDate = dateTime(1970, mJan, 1, zone = utc())
    var endDate = now().utc()
    
    if options.lookback.len > 0 and options.lookback != "max":
      let (startLb, endLb) = parseLookback(options.lookback)
      startDate = fromUnix(startLb).utc()
      endDate = fromUnix(endLb).utc()
    elif options.startDate.len > 0:
      startDate = fromUnix(parseDateString(options.startDate)).utc()
    
    if options.endDate.len > 0:
      endDate = fromUnix(parseDateString(options.endDate)).utc()
    
    # Fetch both dividends and splits
    let actions = getActions(options.symbol, startDate, endDate)
    
    # Check if we got any data
    if actions.dividends.len == 0 and actions.splits.len == 0:
      if not config.quiet:
        printWarning("No corporate actions available for " & options.symbol, config)
      return
    
    # Show success message unless quiet
    if not config.quiet:
      printSuccess("Retrieved " & $actions.dividends.len & " dividends, " & 
                   $actions.splits.len & " splits", config)
    
    # Format and display output
    case config.format
    of FormatJSON:
      # JSON output
      echo "{" 
      echo "  \"symbol\": \"" & options.symbol & "\","
      echo "  \"dividends\": ["
      for i, dividend in actions.dividends:
        if i > 0: echo ","
        echo "    {\"date\": \"" & dividend.date.format("yyyy-MM-dd") & 
             "\", \"amount\": " & $dividend.amount & "}"
      echo "  ],"
      echo "  \"splits\": ["
      for i, split in actions.splits:
        if i > 0: echo ","
        echo "    {\"date\": \"" & split.date.format("yyyy-MM-dd") & 
             "\", \"splitRatio\": \"" & split.splitRatio & "\"}"
      echo "  ]"
      echo "}"
    
    of FormatCSV:
      # CSV output
      if not config.noHeader:
        echo "Type,Date,Value"
      for dividend in actions.dividends:
        echo "Dividend," & dividend.date.format("yyyy-MM-dd") & "," & $dividend.amount
      for split in actions.splits:
        echo "Split," & split.date.format("yyyy-MM-dd") & "," & split.splitRatio
    
    else:
      # Table format (default)
      echo ""
      echo "Corporate Actions: " & options.symbol
      echo "═".repeat(60)
      
      # Show splits first (less common, more impactful)
      if actions.splits.len > 0:
        echo ""
        echo "📊 Stock Splits:"
        echo "─".repeat(60)
        for split in actions.splits:
          echo "  " & split.date.format("yyyy-MM-dd") & "  " & split.splitRatio & " split"
      
      # Show dividends (show last 20 if more than that)
      if actions.dividends.len > 0:
        echo ""
        echo "💰 Dividends:"
        echo "─".repeat(60)
        
        let maxShow = 20
        let toShow = if actions.dividends.len > maxShow: maxShow else: actions.dividends.len
        let startIdx = if actions.dividends.len > maxShow: actions.dividends.len - maxShow else: 0
        
        for i in countdown(actions.dividends.len - 1, startIdx):
          let dividend = actions.dividends[i]
          let amountStr = formatFloat(dividend.amount, ffDecimal, config.precision)
          echo "  " & dividend.date.format("yyyy-MM-dd") & "  $" & amountStr
        
        if actions.dividends.len > maxShow:
          echo ""
          echo fmt"  ... and {actions.dividends.len - maxShow} more (use 'yf dividends {options.symbol}' for full history)"
      
      # Summary
      echo ""
      echo "═".repeat(60)
      echo fmt"Total: {actions.splits.len} splits, {actions.dividends.len} dividends"
    
  except ActionsError as e:
    raise newException(CliError, "Failed to retrieve corporate actions: " & e.msg)
  except CatchableError as e:
    raise newException(CliError, "Failed to retrieve corporate actions: " & e.msg)


proc runDividends*() =
  ## Parse arguments and execute dividends command
  let (config, options) = parseActionsArgs("dividends")
  executeDividends(config, options)


proc runSplits*() =
  ## Parse arguments and execute splits command
  let (config, options) = parseActionsArgs("splits")
  executeSplits(config, options)


proc runActions*() =
  ## Parse arguments and execute actions command
  let (config, options) = parseActionsArgs("actions")
  executeActions(config, options)
