## Download Command Implementation
##
## Downloads historical data for multiple tickers simultaneously

import std/[strformat, tables, times, strutils]
import ../[types, config, utils]
import ../../yfnim/[types as ytypes, batch_retriever]

proc executeDownload*(config: GlobalConfig, options: HistoryOptions) =
  ## Execute the download command (batch history for multiple symbols)
  ##
  ## Args:
  ##   config: Global configuration
  ##   options: History-specific options (contains multiple symbols)
  
  # Validate we have symbols
  if options.symbols.len == 0:
    raise newException(CliError, "At least one symbol is required")
  
  # Show progress message unless quiet
  if not config.quiet:
    printInfo("Downloading data for " & $options.symbols.len & " symbols...", config)
  
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
    
    # Download batch
    let startDownload = now()
    let result = downloadBatch(options.symbols, options.interval, startTime, endTime)
    let duration = (now() - startDownload).inSeconds
    
    # Count successes and failures
    var successCount = 0
    var failCount = 0
    for _ in result.successful.keys:
      successCount += 1
    for _ in result.failed.keys:
      failCount += 1
    
    # Show summary unless quiet
    if not config.quiet:
      echo ""
      echo "═".repeat(60)
      echo fmt"Download complete in {duration} seconds"
      echo fmt"✓ Successful: {successCount}"
      if failCount > 0:
        echo fmt"✗ Failed: {failCount}"
      echo "═".repeat(60)
    
    # Report failures
    if failCount > 0 and not config.quiet:
      echo ""
      echo "❌ Failed downloads:"
      for ticker, error in result.failed:
        echo fmt"  {ticker}: {error}"
      echo ""
    
    # Output successful downloads
    case config.format
    of FormatJSON:
      # JSON output - array of ticker objects
      echo "{"
      var first = true
      for ticker, history in result.successful:
        if not first: echo ","
        echo "  \"" & ticker & "\": {"
        echo "    \"symbol\": \"" & history.symbol & "\","
        echo "    \"interval\": \"" & $history.interval & "\","
        echo "    \"data\": ["
        for i, bar in history.data:
          if i > 0: echo ","
          echo "      {\"time\": " & $bar.time & ", \"open\": " & $bar.open & ", \"high\": " & $bar.high & ", \"low\": " & $bar.low & ", \"close\": " & $bar.close & ", \"volume\": " & $bar.volume & "}"
        echo "    ]"
        echo "  }"
        first = false
      echo "}"
    
    of FormatCSV:
      # CSV output - combined with ticker column
      if not config.noHeader:
        echo "Ticker,Date,Open,High,Low,Close,Volume"
      for ticker, history in result.successful:
        for bar in history.data:
          let dateStr = formatDate(bar.time, config.dateFormat)
          echo fmt"{ticker},{dateStr},{bar.open},{bar.high},{bar.low},{bar.close},{bar.volume}"
    
    of FormatTSV:
      # TSV output - combined with ticker column
      if not config.noHeader:
        echo "Ticker\tDate\tOpen\tHigh\tLow\tClose\tVolume"
      for ticker, history in result.successful:
        for bar in history.data:
          let dateStr = formatDate(bar.time, config.dateFormat)
          echo fmt"{ticker}\t{dateStr}\t{bar.open}\t{bar.high}\t{bar.low}\t{bar.close}\t{bar.volume}"
    
    else:
      # Table format - summary only
      if not config.quiet:
        echo "📊 Summary:"
        for ticker, history in result.successful:
          if history.data.len > 0:
            let first = history.data[0]
            let last = history.data[^1]
            let firstDate = formatDate(first.time, config.dateFormat)
            let lastDate = formatDate(last.time, config.dateFormat)
            echo fmt"  {ticker:<6} {history.data.len:>4} bars  {firstDate} to {lastDate}  ${last.close:.2f}"
          else:
            echo fmt"  {ticker:<6}    0 bars  (no data)"
        
        echo ""
        echo "Tip: Use --format csv or --format json for full data export"
    
    # Exit with error code if any downloads failed
    if failCount > 0:
      quit(1)
    
  except CatchableError as e:
    raise newException(CliError, "Failed to download data: " & e.msg)


proc runDownload*() =
  ## Parse arguments and execute download command
  
  # Parse arguments using download-specific parser
  let (config, options) = parseDownloadArgs()
  
  # Execute the command
  executeDownload(config, options)
