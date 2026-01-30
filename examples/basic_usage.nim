## Basic Usage Example
##
## Demonstrates simple data retrieval and display

import yfnim
import std/times

proc main() =
  # Get the last 7 days of daily data for Apple
  echo "Fetching AAPL daily data for the last 7 days..."
  
  let now = getTime().toUnix()
  let weekAgo = now - (7 * 24 * 3600)
  
  let history = getHistory("AAPL", Int1d, weekAgo, now)
  
  echo "\nSymbol: ", history.symbol
  echo "Interval: ", history.interval
  echo "Records retrieved: ", history.len
  echo "\nOHLCV Data:\n"
  
  # Display each record
  for i, record in history.data:
    echo "Record #", i + 1
    echo "  Timestamp: ", record.time, " (", fromUnix(record.time).format("yyyy-MM-dd HH:mm:ss"), ")"
    echo "  Open:   $", record.open
    echo "  High:   $", record.high
    echo "  Low:    $", record.low
    echo "  Close:  $", record.close
    echo "  Volume: ", record.volume
    echo ""

when isMainModule:
  main()
