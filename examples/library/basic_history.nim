## Basic Historical Data Example
##
## Retrieves and displays historical OHLCV data for a symbol.
## Demonstrates simple date range query with daily interval.

import yfnim
import std/times
import std/strutils

proc main() =
  let symbol = "AAPL"
  let interval = Int1d
  let days = 30
  
  # Calculate date range (last 30 days)
  let endTime = getTime().toUnix()
  let startTime = endTime - (days * 86400)
  
  # Fetch historical data
  echo "Fetching ", days, " days of data for ", symbol, "..."
  
  try:
    let history = getHistory(symbol, interval, startTime, endTime)
    
    echo "Retrieved ", history.data.len, " bars"
    echo ""
    echo "Date       | Open     | High     | Low      | Close    | Volume"
    echo "-----------|----------|----------|----------|----------|-------------"
    
    # Display data
    for bar in history.data:
      let date = fromUnix(bar.time).format("yyyy-MM-dd")
      echo date, " | $", bar.open.formatFloat(ffDecimal, 2),
           " | $", bar.high.formatFloat(ffDecimal, 2),
           " | $", bar.low.formatFloat(ffDecimal, 2),
           " | $", bar.close.formatFloat(ffDecimal, 2),
           " | ", bar.volume
    
    # Calculate simple statistics
    var total = 0.0
    var high = 0.0
    var low = 999999.0
    
    for bar in history.data:
      total += bar.close
      if bar.high > high:
        high = bar.high
      if bar.low < low:
        low = bar.low
    
    let average = total / history.data.len.float
    
    echo ""
    echo "Statistics:"
    echo "  Average Close: $", average.formatFloat(ffDecimal, 2)
    echo "  Period High:   $", high.formatFloat(ffDecimal, 2)
    echo "  Period Low:    $", low.formatFloat(ffDecimal, 2)
    
  except CatchableError as e:
    echo "Error: ", e.msg
    quit(1)

when isMainModule:
  main()
