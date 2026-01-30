# Historical Data Guide

This guide covers how to retrieve and work with historical OHLCV (Open, High, Low, Close, Volume) data using yfnim.

## Table of Contents

- [Overview](#overview)
- [Basic Usage](#basic-usage)
- [Time Intervals](#time-intervals)
- [Date and Time Handling](#date-and-time-handling)
- [Data Structures](#data-structures)
- [Common Tasks](#common-tasks)
- [Error Handling](#error-handling)
- [Limitations](#limitations)

## Overview

The `getHistory` function retrieves historical price and volume data from Yahoo Finance. This is useful for:

- Analyzing past price movements
- Calculating technical indicators
- Backtesting trading strategies
- Historical research and reporting

## Basic Usage

The main function for retrieving historical data is `getHistory`:

```nim
proc getHistory*(symbol: string, interval: Interval, 
                 startTime: int64, endTime: int64): History
```

**Parameters:**
- `symbol`: Ticker symbol (e.g., "AAPL", "MSFT")
- `interval`: Time interval (e.g., Int1d, Int1h)
- `startTime`: Start date as Unix timestamp
- `endTime`: End date as Unix timestamp

**Returns:** A `History` object containing the symbol, interval, and a sequence of OHLCV records.

**Example:**

```nim
import yfnim
import std/times

let endTime = getTime().toUnix()
let startTime = endTime - (30 * 86400)  # 30 days ago

let history = getHistory("AAPL", Int1d, startTime, endTime)
echo "Retrieved ", history.data.len, " records"
```

## Time Intervals

yfnim supports eight time intervals, each with different characteristics:

### Intraday Intervals

**1-Minute (Int1m)**
- Available for approximately the last 7 days
- Useful for: Day trading analysis, very short-term patterns
- Note: Yahoo Finance restricts 1-minute data to recent periods

```nim
let history = getHistory("AAPL", Int1m, oneDayAgo, now)
```

**5-Minute (Int5m)**
- Available for approximately 60 days
- Useful for: Intraday analysis

**15-Minute (Int15m)**
- Available for approximately 60 days
- Useful for: Short-term swing trading

**30-Minute (Int30m)**
- Available for approximately 60 days
- Useful for: Intraday trend analysis

**1-Hour (Int1h)**
- Available for approximately 2 years
- Useful for: Multi-day analysis

### Daily and Longer Intervals

**Daily (Int1d)** - Most Common
- Available for many years
- Useful for: General analysis, most common use case
- Recommended as the default for most applications

```nim
let history = getHistory("AAPL", Int1d, oneYearAgo, now)
```

**Weekly (Int1wk)**
- Available for many years
- Useful for: Long-term trend analysis, reduced noise

**Monthly (Int1mo)**
- Available for many years
- Useful for: Very long-term analysis, historical research

### Choosing an Interval

For most use cases, start with `Int1d` (daily). Use intraday intervals only when you specifically need recent high-frequency data. Keep in mind that shorter intervals have limited historical availability.

## Date and Time Handling

yfnim uses Unix timestamps (seconds since January 1, 1970 UTC) for all date/time operations.

### Working with Unix Timestamps

```nim
import std/times

# Current time
let now = getTime().toUnix()

# Relative times
let oneWeekAgo = now - (7 * 86400)
let oneMonthAgo = now - (30 * 86400)
let oneYearAgo = now - (365 * 86400)

# Specific date
let specificDate = parse("2024-01-15", "yyyy-MM-dd").toTime().toUnix()

# Convert timestamp to readable format
let timestamp = 1705276800
echo fromUnix(timestamp).format("yyyy-MM-dd")  # "2024-01-15"
```

### Date Range Best Practices

1. **End time typically set to current time:**
   ```nim
   let endTime = getTime().toUnix()
   ```

2. **Calculate start time based on desired lookback:**
   ```nim
   let startTime = endTime - (days * 86400)
   ```

3. **Or use specific dates:**
   ```nim
   let start = parse("2024-01-01", "yyyy-MM-dd").toTime().toUnix()
   let end = parse("2024-12-31", "yyyy-MM-dd").toTime().toUnix()
   ```

### Time Zone Considerations

Unix timestamps are always in UTC. Yahoo Finance returns data aligned to the exchange's trading hours, so the timestamps correspond to when the market was actually open in that exchange's local time zone.

## Data Structures

### HistoryRecord

A single OHLCV data point:

```nim
type HistoryRecord = object
  date: int64      # Unix timestamp
  open: float64    # Opening price
  high: float64    # High price  
  low: float64     # Low price
  close: float64   # Closing price
  volume: int64    # Trading volume
```

### History

A time series of records:

```nim
type History = object
  symbol: string               # Ticker symbol
  interval: Interval           # Time interval used
  data: seq[HistoryRecord]     # Array of OHLCV records
```

### Accessing Data

```nim
let history = getHistory("AAPL", Int1d, startTime, endTime)

# Number of records
echo history.data.len

# Access individual records
for bar in history.data:
  echo "Date: ", bar.date
  echo "Close: $", bar.close
  echo "Volume: ", bar.volume

# Access by index
let latestBar = history.data[^1]  # Last record
let oldestBar = history.data[0]   # First record
```

## Common Tasks

### Calculate Average Price

```nim
var sum = 0.0
for bar in history.data:
  sum += bar.close

let average = sum / history.data.len.float
echo "Average close: $", average
```

### Find Highest and Lowest

```nim
import std/math

var highest = 0.0
var lowest = Inf

for bar in history.data:
  highest = max(highest, bar.high)
  lowest = min(lowest, bar.low)

echo "Period high: $", highest
echo "Period low: $", lowest
```

### Calculate Returns

```nim
# Calculate daily returns
for i in 1..<history.data.len:
  let prevClose = history.data[i-1].close
  let currClose = history.data[i].close
  let return = ((currClose - prevClose) / prevClose) * 100.0
  echo "Return: ", return, "%"
```

### Export to CSV

```nim
import std/[times, strformat]

# Write to file
let f = open("output.csv", fmWrite)
f.writeLine("Date,Open,High,Low,Close,Volume")

for bar in history.data:
  let date = fromUnix(bar.date).format("yyyy-MM-dd")
  f.writeLine(&"{date},{bar.open},{bar.high},{bar.low},{bar.close},{bar.volume}")

f.close()
```

### Filter by Date

```nim
import std/times

# Get only bars from January 2024
let janStart = parse("2024-01-01", "yyyy-MM-dd").toTime().toUnix()
let janEnd = parse("2024-02-01", "yyyy-MM-dd").toTime().toUnix()

var januaryBars: seq[HistoryRecord]
for bar in history.data:
  if bar.date >= janStart and bar.date < janEnd:
    januaryBars.add(bar)

echo "January bars: ", januaryBars.len
```

### Calculate Moving Average

```nim
proc simpleMovingAverage(history: History, period: int): seq[float64] =
  result = newSeq[float64](history.data.len)
  
  for i in period-1..<history.data.len:
    var sum = 0.0
    for j in i-period+1..i:
      sum += history.data[j].close
    result[i] = sum / period.float

# Calculate 20-day SMA
let sma20 = simpleMovingAverage(history, 20)
```

## Error Handling

Always handle potential errors when retrieving data:

```nim
import yfnim

try:
  let history = getHistory("AAPL", Int1d, startTime, endTime)
  # Process data...
  
except ValueError as e:
  # Invalid input parameters
  echo "Input error: ", e.msg
  
except HttpRequestError as e:
  # Network or HTTP errors
  echo "Network error: ", e.msg
  echo "Check your internet connection"
  
except YahooApiError as e:
  # Yahoo Finance API errors
  echo "API error: ", e.msg
  echo "The symbol may not exist or data is unavailable"
  
except JsonParsingError as e:
  # JSON parsing errors (rare)
  echo "Parsing error: ", e.msg
  
except CatchableError as e:
  # Other unexpected errors
  echo "Unexpected error: ", e.msg
```

### Common Error Scenarios

**Empty symbol:**
```nim
getHistory("", Int1d, start, end)  # Raises ValueError
```

**Invalid date range:**
```nim
getHistory("AAPL", Int1d, endTime, startTime)  # start > end, raises ValueError
```

**Invalid symbol:**
```nim
getHistory("NOTAREALSYMBOL", Int1d, start, end)  # Raises YahooApiError
```

**Network issues:**
```nim
# No internet connection -> Raises HttpRequestError
```

## Limitations

### Data Availability

- **1-minute data**: Only available for approximately the last 7 days
- **Intraday data (5m, 15m, 30m, 1h)**: Limited to approximately 60 days to 2 years
- **Daily and longer intervals**: Many years of history available

### Market Hours

Historical data reflects actual trading hours:
- Stock data: Only includes trading days (no weekends/holidays)
- Intraday data: Only includes market hours (e.g., 9:30 AM - 4:00 PM ET for US stocks)

### Data Quality

- Some fields may be zero or NaN for certain periods (e.g., low volume periods)
- Corporate actions (splits, dividends) may affect price continuity
- Delisted stocks may have limited or no data

### API Rate Limits

While Yahoo Finance doesn't publish official rate limits, making too many requests in a short time may result in temporary throttling. For production use, consider:
- Caching data locally
- Adding delays between requests
- Implementing retry logic with exponential backoff

## See Also

- [Getting Started Guide](getting-started.md) - Basic introduction
- [Quote Data Guide](quote-data.md) - Real-time quote data
- [Example: custom_intervals.nim](../../examples/library/custom_intervals.nim) - Demonstrates all intervals
- [Example: basic_history.nim](../../examples/library/basic_history.nim) - Simple historical data example
