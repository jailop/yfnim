## Intraday Analysis Example
##
## Demonstrates working with high-frequency intraday data (1m, 5m intervals)

import yfnim
import std/[times, math, strutils, httpclient, os]

proc analyzeIntraday(symbol: string, interval: Interval, hours: int = 6) =
  echo "\n=== Intraday Analysis: ", symbol, " (", interval, ") ===\n"
  
  let now = getTime().toUnix()
  let pastTime = now - (hours * 3600)
  
  try:
    let history = getHistory(symbol, interval, pastTime, now)
    
    if history.len == 0:
      echo "No data available for this period"
      return
    
    echo "Retrieved ", history.len, " bars over ", hours, " hours"
    
    # Find session high/low
    var sessionHigh = 0.0
    var sessionLow = float64.high
    var totalVolume: int64 = 0
    
    for record in history.data:
      if record.high > sessionHigh:
        sessionHigh = record.high
      if record.low < sessionLow:
        sessionLow = record.low
      totalVolume += record.volume
    
    echo "\nSession Statistics:"
    echo "  High: $", sessionHigh.formatFloat(ffDecimal, 2)
    echo "  Low: $", sessionLow.formatFloat(ffDecimal, 2)
    echo "  Range: $", (sessionHigh - sessionLow).formatFloat(ffDecimal, 2)
    echo "  Total Volume: ", totalVolume
    
    # Opening and closing prices
    let openPrice = history.data[0].open
    let closePrice = history.data[^1].close
    let priceChange = closePrice - openPrice
    let percentChange = (priceChange / openPrice) * 100.0
    
    echo "\nPrice Movement:"
    echo "  Open: $", openPrice.formatFloat(ffDecimal, 2)
    echo "  Close: $", closePrice.formatFloat(ffDecimal, 2)
    echo "  Change: $", priceChange.formatFloat(ffDecimal, 2), 
         " (", percentChange.formatFloat(ffDecimal, 2), "%)"
    
    # Find most volatile bar
    var maxRange = 0.0
    var maxRangeIdx = 0
    for i, record in history.data:
      let barRange = record.high - record.low
      if barRange > maxRange:
        maxRange = barRange
        maxRangeIdx = i
    
    if maxRangeIdx < history.data.len:
      let volatileBar = history.data[maxRangeIdx]
      let barTime = fromUnix(volatileBar.time)
      echo "\nMost Volatile Bar:"
      echo "  Time: ", barTime.format("HH:mm:ss")
      echo "  Range: $", maxRange.formatFloat(ffDecimal, 2)
      echo "  High: $", volatileBar.high.formatFloat(ffDecimal, 2)
      echo "  Low: $", volatileBar.low.formatFloat(ffDecimal, 2)
    
    # Calculate average bar size
    var totalRange = 0.0
    for record in history.data:
      totalRange += (record.high - record.low)
    let avgBarSize = totalRange / float(history.len)
    echo "\nAverage Bar Size: $", avgBarSize.formatFloat(ffDecimal, 4)
    
    # Show last 5 bars
    echo "\nLast 5 Bars:"
    let startIdx = max(0, history.len - 5)
    for i in startIdx..<history.len:
      let record = history.data[i]
      let barTime = fromUnix(record.time)
      let barChange = record.close - record.open
      echo "  ", barTime.format("HH:mm"), 
           " | O:", record.open.formatFloat(ffDecimal, 2),
           " H:", record.high.formatFloat(ffDecimal, 2),
           " L:", record.low.formatFloat(ffDecimal, 2),
           " C:", record.close.formatFloat(ffDecimal, 2),
           " (", (if barChange >= 0: "+" else: ""), barChange.formatFloat(ffDecimal, 2), ")"
    
  except HttpRequestError as e:
    echo "HTTP Error: ", e.msg
    if "422" in e.msg:
      echo "Note: 1m interval is limited to 7 days of history"
  except YahooApiError as e:
    echo "API Error: ", e.msg
  except CatchableError as e:
    echo "Error: ", e.msg

proc main() =
  echo "=== Intraday Data Analysis Example ==="
  echo "\nNote: This example fetches recent intraday data."
  echo "      Market hours: Check if market is open for real-time data."
  
  # Example 1: 1-minute data for the last 6 hours
  analyzeIntraday("SPY", Int1m, hours = 6)
  
  # Add delay
  sleep(2000)
  
  # Example 2: 5-minute data for the last 24 hours
  analyzeIntraday("AAPL", Int5m, hours = 24)
  
  sleep(2000)
  
  # Example 3: 15-minute data for the last 2 days
  analyzeIntraday("MSFT", Int15m, hours = 48)
  
  echo "\n=== Analysis Complete ==="
  echo "\nReminder: Intraday data availability:"
  echo "  - 1m interval: Last 7 days maximum"
  echo "  - 5m/15m/30m: Last 60 days approximately"
  echo "  - 1h: Last 730 days approximately"

when isMainModule:
  main()
