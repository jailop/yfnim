# Getting Started with yfnim Library

Welcome to **yfnim** - a lightweight, pure-Nim library for retrieving stock market data from Yahoo Finance!

This guide will help you get started with the library in just a few minutes.

## Table of Contents

- [Installation](#installation)
- [Your First Program](#your-first-program)
- [Understanding the Basics](#understanding-the-basics)
- [Common Patterns](#common-patterns)
- [Next Steps](#next-steps)

## Installation

### Using Nimble (Recommended)

```bash
nimble install yfnim
```

### From Source

```bash
git clone https://github.com/yourusername/yfnim.git
cd yfnim
nimble install
```

## Your First Program

Let's write a simple program that fetches the last 7 days of stock data for Apple (AAPL):

```nim
import yfnim
import std/times

# Calculate date range (last 7 days)
let endTime = getTime().toUnix()
let startTime = endTime - (7 * 86400)  # 7 days * 86400 seconds/day

# Fetch historical data
let history = getHistory("AAPL", Int1d, startTime, endTime)

# Display results
echo "Retrieved ", history.data.len, " days of data for ", history.symbol

for bar in history.data:
  echo "Date: ", fromUnix(bar.date).format("yyyy-MM-dd"), 
       " Close: $", bar.close
```

### Compiling and Running

**Important:** You must compile with the `-d:ssl` flag to enable HTTPS support:

```bash
nim c -d:ssl -r myprogram.nim
```

Without `-d:ssl`, you'll get SSL/HTTPS errors when trying to connect to Yahoo Finance.

## Understanding the Basics

### Core Concepts

#### 1. Time Intervals

yfnim supports multiple time intervals for historical data:

| Interval | Description | Max History | Use Case |
|----------|-------------|-------------|----------|
| `Int1m`  | 1 minute    | ~7 days     | Day trading, tick analysis |
| `Int5m`  | 5 minutes   | ~60 days    | Intraday patterns |
| `Int15m` | 15 minutes  | ~60 days    | Short-term analysis |
| `Int30m` | 30 minutes  | ~60 days    | Intraday trends |
| `Int1h`  | 1 hour      | ~2 years    | Multi-day analysis |
| `Int1d`  | 1 day       | Many years  | **Most common** |
| `Int1wk` | 1 week      | Many years  | Long-term trends |
| `Int1mo` | 1 month     | Many years  | Historical research |

**Recommendation:** Start with `Int1d` (daily) for most use cases.

#### 2. Unix Timestamps

yfnim uses Unix timestamps (seconds since Jan 1, 1970) for date/time handling. Nim's `std/times` module makes this easy:

```nim
import std/times

# Current time
let now = getTime().toUnix()

# 30 days ago
let thirtyDaysAgo = now - (30 * 86400)

# Specific date
let specificDate = parse("2024-01-15", "yyyy-MM-dd").toTime().toUnix()

# Convert back to readable format
echo fromUnix(now).format("yyyy-MM-dd HH:mm:ss")
```

#### 3. Data Structures

**HistoryRecord** - A single data point (OHLCV bar):

```nim
type HistoryRecord = object
  date: int64      # Unix timestamp
  open: float64    # Opening price
  high: float64    # High price
  low: float64     # Low price
  close: float64   # Closing price
  volume: int64    # Trading volume
```

**History** - A time series of data:

```nim
type History = object
  symbol: string
  interval: Interval
  data: seq[HistoryRecord]  # Array of OHLCV bars
```

## Common Patterns

### Pattern 1: Fetch Last N Days

```nim
import yfnim
import std/times

proc getLastNDays(symbol: string, days: int): History =
  let endTime = getTime().toUnix()
  let startTime = endTime - (days * 86400)
  return getHistory(symbol, Int1d, startTime, endTime)

# Usage
let history = getLastNDays("AAPL", 30)
echo "Retrieved ", history.data.len, " days"
```

### Pattern 2: Fetch Specific Date Range

```nim
import yfnim
import std/times

let startDate = parse("2024-01-01", "yyyy-MM-dd").toTime().toUnix()
let endDate = parse("2024-01-31", "yyyy-MM-dd").toTime().toUnix()

let history = getHistory("MSFT", Int1d, startDate, endDate)
```

### Pattern 3: Calculate Simple Statistics

```nim
import yfnim
import std/[times, math]

let history = getLastNDays("GOOGL", 30)

# Calculate average close
var sum = 0.0
for bar in history.data:
  sum += bar.close
let average = sum / history.data.len.float

echo "30-day average: $", average.formatFloat(ffDecimal, 2)

# Find highest and lowest
var highest = 0.0
var lowest = Inf

for bar in history.data:
  highest = max(highest, bar.high)
  lowest = min(lowest, bar.low)

echo "30-day high: $", highest
echo "30-day low: $", lowest
```

### Pattern 4: Error Handling

Always wrap Yahoo Finance API calls in try/except blocks:

```nim
import yfnim

try:
  let history = getHistory("AAPL", Int1d, startTime, endTime)
  echo "Success! Got ", history.data.len, " records"

except ValueError as e:
  echo "Invalid input: ", e.msg

except HttpRequestError as e:
  echo "Network error: ", e.msg
  echo "Check your internet connection"

except YahooApiError as e:
  echo "API error: ", e.msg
  echo "Symbol may not exist or data unavailable"

except CatchableError as e:
  echo "Unexpected error: ", e.msg
```

### Pattern 5: Fetch Quote Data

For real-time/current prices:

```nim
import yfnim

# Single quote
let quote = getQuote("AAPL")
echo quote.symbol, ": $", quote.regularMarketPrice
echo "Change: ", quote.regularMarketChangePercent, "%"

# Multiple quotes
let quotes = getQuotes(@["AAPL", "MSFT", "GOOGL"])
for q in quotes:
  echo q.symbol, ": $", q.regularMarketPrice
```

## API Functions Quick Reference

### Historical Data

```nim
# Main function
proc getHistory*(symbol: string, interval: Interval, 
                 startTime: int64, endTime: int64): History

# Helper functions
proc newHistory*(symbol: string, interval: Interval): History
proc len*(history: History): int
proc append*(history: var History, record: HistoryRecord)
```

### Quote Data

```nim
# Single symbol
proc getQuote*(symbol: string): Quote

# Multiple symbols (concurrent requests)
proc getQuotes*(symbols: seq[string]): seq[Quote]
```

### Type Conversions

```nim
# Parse interval from string
proc parseInterval*(s: string): Interval

# JSON export/import
proc toJson*(history: History): JsonNode
proc fromJson*(node: JsonNode, T: typedesc[History]): History
```

## Compilation Flags

### Required

- `-d:ssl` - Enable HTTPS support (required for Yahoo Finance)

### Recommended

- `-d:release` - Enable optimizations for production
- `--opt:speed` - Optimize for speed

### Example Build Commands

```bash
# Development
nim c -d:ssl myprogram.nim

# Production
nim c -d:ssl -d:release --opt:speed myprogram.nim

# With output path
nim c -d:ssl --out:bin/myapp myprogram.nim
```

## Complete Working Example

Here's a complete program you can copy and run:

```nim
## my_first_yfnim_program.nim
## Fetches and analyzes stock data

import yfnim
import std/[times, strformat]

proc main() =
  # Configuration
  let symbol = "AAPL"
  let days = 30
  
  # Calculate date range
  let endTime = getTime().toUnix()
  let startTime = endTime - (days * 86400)
  
  echo &"Fetching {days} days of data for {symbol}..."
  
  try:
    # Fetch historical data
    let history = getHistory(symbol, Int1d, startTime, endTime)
    
    echo &"Retrieved {history.data.len} records\n"
    
    # Show last 5 days
    echo "Last 5 days:"
    let start = max(0, history.data.len - 5)
    for i in start..<history.data.len:
      let bar = history.data[i]
      let date = fromUnix(bar.date).format("yyyy-MM-dd")
      echo &"{date}: Close=${bar.close:>7.2f} Volume={bar.volume}"
    
    # Calculate statistics
    var total = 0.0
    var high = 0.0
    var low = 999999.0
    
    for bar in history.data:
      total += bar.close
      high = max(high, bar.high)
      low = min(low, bar.low)
    
    let average = total / history.data.len.float
    
    echo ""
    echo "Statistics:"
    echo &"  Average: ${average:.2f}"
    echo &"  High:    ${high:.2f}"
    echo &"  Low:     ${low:.2f}"
    
    # Get current quote
    echo ""
    echo "Current Quote:"
    let quote = getQuote(symbol)
    echo &"  Price:  ${quote.regularMarketPrice:.2f}"
    echo &"  Change: {quote.regularMarketChangePercent:+.2f}%"
    
  except CatchableError as e:
    echo "Error: ", e.msg
    quit(1)

when isMainModule:
  main()
```

Save this as `my_first_yfnim_program.nim` and run:

```bash
nim c -d:ssl -r my_first_yfnim_program.nim
```

## Next Steps

Now that you have the basics, explore these topics:

1. **[Historical Data Guide](historical-data.md)** - Deep dive into historical data retrieval, intervals, and date handling

2. **[Quote Data Guide](quote-data.md)** - Learn about real-time quotes, batch requests, and available fields

3. **[Example Programs](../../examples/library/)** - Study working examples:
   - `basic_history.nim` - Simple historical data fetching
   - `batch_quotes.nim` - Retrieving multiple quotes efficiently
   - `error_handling.nim` - Robust error handling patterns
   - `custom_intervals.nim` - Using different time intervals

4. **[API Documentation](../../docs/api/)** - Complete API reference (generate with `nim doc`)

## Troubleshooting

### "Error: undeclared identifier: 'newHttpClient'"

**Solution:** Compile with `-d:ssl` flag:
```bash
nim c -d:ssl myprogram.nim
```

### "SSL support is not available"

**Solution:** Install OpenSSL development libraries:
```bash
# Ubuntu/Debian
sudo apt-get install libssl-dev

# macOS (via Homebrew)
brew install openssl

# Then rebuild
nim c -d:ssl myprogram.nim
```

### "Symbol not found" or "No data returned"

**Common causes:**
1. Invalid ticker symbol (check Yahoo Finance website)
2. Symbol uses different format (try `SHOP.TO` for Canadian, `BTC-USD` for crypto)
3. Requesting data outside available range (1m interval only works for last ~7 days)

### Empty data returned

**Check:**
1. Date range is correct (start before end)
2. Not requesting future dates
3. Dates fall within trading days (not weekends/holidays for stocks)
4. Interval is appropriate for date range

## Getting Help

- **Issues:** Report bugs at https://github.com/yourusername/yfnim/issues
- **Examples:** Check `examples/library/` directory
- **API Docs:** Generate with `nim doc --project src/yfnim.nim`

## Summary

You now know how to:
- ✅ Install and configure yfnim
- ✅ Fetch historical data
- ✅ Work with Unix timestamps
- ✅ Handle errors properly
- ✅ Retrieve current quotes
- ✅ Calculate basic statistics

Happy coding! 🚀
