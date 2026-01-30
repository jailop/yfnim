## Custom Intervals Example
##
## Demonstrates using different time intervals for historical data.
## Shows when to use each interval and their limitations.

import yfnim
import std/[times, strformat]

proc displayBars(history: History, maxBars: int = 10) =
  ## Display first few bars from history
  let count = min(maxBars, history.data.len)
  for i in 0..<count:
    let bar = history.data[i]
    let dt = fromUnix(bar.time).format("yyyy-MM-dd HH:mm")
    echo &"  {dt}: O=${bar.open:>7.2f} H=${bar.high:>7.2f} L=${bar.low:>7.2f} C=${bar.close:>7.2f} V={bar.volume}"
  
  if history.data.len > maxBars:
    echo &"  ... and {history.data.len - maxBars} more bars"

proc example1_intraday1minute() =
  ## Example: 1-minute interval (only available for last 7 days)
  echo "=== 1-Minute Interval (Int1m) ==="
  echo "Use case: High-frequency analysis, day trading"
  echo "Limitation: Only last 7 days available"
  echo ""
  
  let symbol = "AAPL"
  let now = getTime().toUnix()
  let oneDayAgo = now - (1 * 86400)  # 1 day
  
  try:
    echo &"Fetching 1-minute data for {symbol} (last 24 hours)..."
    let history = getHistory(symbol, Int1m, oneDayAgo, now)
    echo &"Retrieved {history.data.len} bars"
    echo "First 10 bars:"
    displayBars(history, 10)
  except CatchableError as e:
    echo "Error: ", e.msg
  
  echo ""

proc example2_intraday5minute() =
  ## Example: 5-minute interval
  echo "=== 5-Minute Interval (Int5m) ==="
  echo "Use case: Intraday analysis, swing trading"
  echo "Limitation: Limited history (typically 60 days)"
  echo ""
  
  let symbol = "MSFT"
  let now = getTime().toUnix()
  let threeDaysAgo = now - (3 * 86400)  # 3 days
  
  try:
    echo &"Fetching 5-minute data for {symbol} (last 3 days)..."
    let history = getHistory(symbol, Int5m, threeDaysAgo, now)
    echo &"Retrieved {history.data.len} bars"
    echo "First 10 bars:"
    displayBars(history, 10)
  except CatchableError as e:
    echo "Error: ", e.msg
  
  echo ""

proc example3_intraday30minute() =
  ## Example: 30-minute interval
  echo "=== 30-Minute Interval (Int30m) ==="
  echo "Use case: Short-term trend analysis"
  echo ""
  
  let symbol = "GOOGL"
  let now = getTime().toUnix()
  let oneWeekAgo = now - (7 * 86400)  # 7 days
  
  try:
    echo &"Fetching 30-minute data for {symbol} (last week)..."
    let history = getHistory(symbol, Int30m, oneWeekAgo, now)
    echo &"Retrieved {history.data.len} bars"
    echo "First 10 bars:"
    displayBars(history, 10)
  except CatchableError as e:
    echo "Error: ", e.msg
  
  echo ""

proc example4_hourly() =
  ## Example: 1-hour interval
  echo "=== 1-Hour Interval (Int1h) ==="
  echo "Use case: Medium-term trend analysis"
  echo ""
  
  let symbol = "TSLA"
  let now = getTime().toUnix()
  let twoWeeksAgo = now - (14 * 86400)  # 2 weeks
  
  try:
    echo &"Fetching hourly data for {symbol} (last 2 weeks)..."
    let history = getHistory(symbol, Int1h, twoWeeksAgo, now)
    echo &"Retrieved {history.data.len} bars"
    echo "First 10 bars:"
    displayBars(history, 10)
  except CatchableError as e:
    echo "Error: ", e.msg
  
  echo ""

proc example5_daily() =
  ## Example: Daily interval (most common)
  echo "=== Daily Interval (Int1d) ==="
  echo "Use case: General analysis, long-term trends"
  echo "Advantage: Years of history available"
  echo ""
  
  let symbol = "NVDA"
  let now = getTime().toUnix()
  let sixMonthsAgo = now - (180 * 86400)  # ~6 months
  
  try:
    echo &"Fetching daily data for {symbol} (last 6 months)..."
    let history = getHistory(symbol, Int1d, sixMonthsAgo, now)
    echo &"Retrieved {history.data.len} bars"
    echo "First 10 bars:"
    displayBars(history, 10)
  except CatchableError as e:
    echo "Error: ", e.msg
  
  echo ""

proc example6_weekly() =
  ## Example: Weekly interval
  echo "=== Weekly Interval (Int1wk) ==="
  echo "Use case: Long-term trend analysis, reduced noise"
  echo ""
  
  let symbol = "AMZN"
  let now = getTime().toUnix()
  let twoYearsAgo = now - (730 * 86400)  # 2 years
  
  try:
    echo &"Fetching weekly data for {symbol} (last 2 years)..."
    let history = getHistory(symbol, Int1wk, twoYearsAgo, now)
    echo &"Retrieved {history.data.len} bars (should be ~104 weeks)"
    echo "First 10 bars:"
    displayBars(history, 10)
  except CatchableError as e:
    echo "Error: ", e.msg
  
  echo ""

proc example7_monthly() =
  ## Example: Monthly interval
  echo "=== Monthly Interval (Int1mo) ==="
  echo "Use case: Very long-term analysis, historical research"
  echo ""
  
  let symbol = "SPY"  # S&P 500 ETF
  let now = getTime().toUnix()
  let fiveYearsAgo = now - (5 * 365 * 86400)  # 5 years
  
  try:
    echo &"Fetching monthly data for {symbol} (last 5 years)..."
    let history = getHistory(symbol, Int1mo, fiveYearsAgo, now)
    echo &"Retrieved {history.data.len} bars (should be ~60 months)"
    echo "First 10 bars:"
    displayBars(history, 10)
  except CatchableError as e:
    echo "Error: ", e.msg
  
  echo ""

proc example8_intervalComparison() =
  ## Example: Compare same period with different intervals
  echo "=== Interval Comparison ==="
  echo "Fetching last 7 days of AAPL with different intervals:"
  echo ""
  
  let symbol = "AAPL"
  let now = getTime().toUnix()
  let weekAgo = now - (7 * 86400)
  
  # Try each interval
  let intervals = [
    (Int1d, "Daily"),
    (Int1h, "Hourly"),
    (Int30m, "30-min"),
    (Int5m, "5-min")
  ]
  
  for (interval, name) in intervals:
    try:
      let history = getHistory(symbol, interval, weekAgo, now)
      echo &"  {name:>10}: {history.data.len:>4} bars"
    except CatchableError as e:
      echo &"  {name:>10}: Error - {e.msg}"
  
  echo ""

proc example9_intervalLimitations() =
  ## Example: Demonstrate interval limitations
  echo "=== Interval Limitations ==="
  echo ""
  
  # Try to get 1-minute data from 30 days ago (will fail or return empty)
  echo "Attempting 1-minute data from 30 days ago (should fail):"
  let symbol = "AAPL"
  let now = getTime().toUnix()
  let thirtyDaysAgo = now - (30 * 86400)
  
  try:
    let history = getHistory(symbol, Int1m, thirtyDaysAgo, now)
    echo &"  Retrieved {history.data.len} bars"
    if history.data.len == 0:
      echo "  ✓ As expected: No data (1m only available for ~7 days)"
  except CatchableError as e:
    echo "  ✓ As expected: ", e.msg
  
  echo ""

proc example10_choosingInterval() =
  ## Example: Guide for choosing the right interval
  echo "=== Choosing the Right Interval ==="
  echo ""
  echo "Interval    | Max History  | Bars/Day | Use Case"
  echo "------------|--------------|----------|-----------------------------------"
  echo "1-minute    | ~7 days      | 390      | Day trading, tick analysis"
  echo "5-minute    | ~60 days     | 78       | Intraday patterns"
  echo "15-minute   | ~60 days     | 26       | Short-term swing trading"
  echo "30-minute   | ~60 days     | 13       | Intraday trends"
  echo "1-hour      | ~730 days    | 6.5      | Multi-day analysis"
  echo "1-day       | Many years   | 1        | General analysis (RECOMMENDED)"
  echo "1-week      | Many years   | 0.2      | Long-term trends"
  echo "1-month     | Many years   | 0.03     | Historical research"
  echo ""
  echo "Recommendation: Start with Int1d (daily) for most use cases."
  echo "Use intraday intervals only when you need recent detailed data."
  echo ""

proc main() =
  echo "yfnim Custom Intervals Examples"
  echo "================================"
  echo ""
  
  # Run all examples
  example1_intraday1minute()
  example2_intraday5minute()
  example3_intraday30minute()
  example4_hourly()
  example5_daily()
  example6_weekly()
  example7_monthly()
  example8_intervalComparison()
  example9_intervalLimitations()
  example10_choosingInterval()
  
  echo "Examples completed!"
  echo ""
  echo "Note: Some examples may fail depending on market hours and data availability."

when isMainModule:
  main()
