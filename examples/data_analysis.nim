## Data Analysis Example
##
## Demonstrates basic data analysis: moving averages, volatility, trends

import yfnim
import std/[times, math, strutils, os]

proc calculateSMA(closes: seq[float64], period: int): seq[float64] =
  ## Calculate Simple Moving Average
  result = newSeq[float64](closes.len)
  
  for i in 0..<closes.len:
    if i < period - 1:
      result[i] = NaN  # Not enough data yet
    else:
      var sum = 0.0
      for j in (i - period + 1)..i:
        sum += closes[j]
      result[i] = sum / float(period)

proc calculateVolatility(closes: seq[float64], period: int): float64 =
  ## Calculate volatility (standard deviation of returns)
  if closes.len < period + 1:
    return NaN
  
  # Calculate daily returns
  var returns = newSeq[float64](closes.len - 1)
  for i in 1..<closes.len:
    returns[i-1] = (closes[i] - closes[i-1]) / closes[i-1]
  
  # Use last 'period' returns
  let startIdx = max(0, returns.len - period)
  var sum = 0.0
  var count = 0
  
  for i in startIdx..<returns.len:
    sum += returns[i]
    count.inc()
  
  let mean = sum / float(count)
  
  # Calculate standard deviation
  var variance = 0.0
  for i in startIdx..<returns.len:
    let diff = returns[i] - mean
    variance += diff * diff
  variance = variance / float(count)
  
  return sqrt(variance)

proc findTrend(closes: seq[float64], lookback: int): string =
  ## Simple trend detection based on price movement
  if closes.len < lookback:
    return "insufficient data"
  
  let recentStart = closes[^lookback]
  let recentEnd = closes[^1]
  let change = (recentEnd - recentStart) / recentStart * 100.0
  
  if change > 2.0:
    return "uptrend (+" & change.formatFloat(ffDecimal, 2) & "%)"
  elif change < -2.0:
    return "downtrend (" & change.formatFloat(ffDecimal, 2) & "%)"
  else:
    return "sideways (" & change.formatFloat(ffDecimal, 2) & "%)"

proc analyzeStock(symbol: string, days: int = 60) =
  echo "\n=== Analyzing ", symbol, " ===\n"
  
  let now = getTime().toUnix()
  let pastTime = now - (days * 24 * 3600)
  
  try:
    let history = getHistory(symbol, Int1d, pastTime, now)
    
    if history.len < 10:
      echo "Not enough data for analysis (need at least 10 days)"
      return
    
    echo "Data period: ", history.len, " days"
    
    # Extract closing prices
    var closes = newSeq[float64](history.len)
    for i, record in history.data:
      closes[i] = record.close
    
    # Current price
    let currentPrice = closes[^1]
    echo "Current price: $", currentPrice.formatFloat(ffDecimal, 2)
    
    # Price change
    let firstPrice = closes[0]
    let totalChange = (currentPrice - firstPrice) / firstPrice * 100.0
    echo "Total change: ", totalChange.formatFloat(ffDecimal, 2), "%"
    
    # Calculate moving averages
    let sma20 = calculateSMA(closes, 20)
    let sma50 = calculateSMA(closes, 50)
    
    if not sma20[^1].isNaN:
      echo "20-day SMA: $", sma20[^1].formatFloat(ffDecimal, 2)
    
    if not sma50[^1].isNaN:
      echo "50-day SMA: $", sma50[^1].formatFloat(ffDecimal, 2)
    
    # Volatility
    let vol20 = calculateVolatility(closes, 20)
    if not vol20.isNaN:
      echo "20-day volatility: ", (vol20 * 100).formatFloat(ffDecimal, 2), "%"
    
    # Find high and low
    var highPrice = 0.0
    var lowPrice = float64.high
    for price in closes:
      if price > highPrice:
        highPrice = price
      if price < lowPrice:
        lowPrice = price
    
    echo "\nPeriod range:"
    echo "  High: $", highPrice.formatFloat(ffDecimal, 2)
    echo "  Low: $", lowPrice.formatFloat(ffDecimal, 2)
    echo "  Range: $", (highPrice - lowPrice).formatFloat(ffDecimal, 2)
    
    # Trend analysis
    echo "\nTrend (last 10 days): ", findTrend(closes, 10)
    if history.len >= 20:
      echo "Trend (last 20 days): ", findTrend(closes, 20)
    
    # Volume analysis
    var totalVolume: int64 = 0
    for record in history.data:
      totalVolume += record.volume
    let avgVolume = totalVolume div history.len
    echo "\nAverage volume: ", avgVolume
    
  except CatchableError as e:
    echo "Error analyzing ", symbol, ": ", e.msg

proc main() =
  echo "=== Stock Data Analysis Example ==="
  
  # Analyze multiple stocks
  let symbols = @["AAPL", "MSFT", "GOOGL"]
  
  for i, symbol in symbols:
    analyzeStock(symbol, days = 60)
    
    # Add delay between requests
    if i < symbols.len - 1:
      sleep(1000)
  
  echo "\n=== Analysis Complete ==="

when isMainModule:
  main()
