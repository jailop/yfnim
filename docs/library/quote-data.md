# Quote Data Guide

This guide covers how to retrieve real-time and delayed quote data using yfnim.

## Table of Contents

- [Overview](#overview)
- [Basic Usage](#basic-usage)
- [Single vs Batch Requests](#single-vs-batch-requests)
- [Quote Fields Reference](#quote-fields-reference)
- [Working with Optional Fields](#working-with-optional-fields)
- [Common Patterns](#common-patterns)
- [Error Handling](#error-handling)
- [Limitations](#limitations)

## Overview

The quote API provides current market data for stocks, ETFs, indices, cryptocurrencies, and other securities. This includes:

- Current price and price changes
- Trading volume
- Bid/ask spreads
- Market capitalization
- Valuation metrics (P/E ratio, dividend yield)
- Moving averages

Note that data may be real-time or delayed depending on your access level and the exchange rules.

## Basic Usage

### Single Symbol

```nim
import yfnim

let quote = getQuote("AAPL")
echo quote.symbol, ": $", quote.regularMarketPrice
echo "Change: ", quote.regularMarketChangePercent, "%"
```

### Multiple Symbols

```nim
import yfnim

let quotes = getQuotes(@["AAPL", "MSFT", "GOOGL"])
for quote in quotes:
  echo quote.symbol, ": $", quote.regularMarketPrice
```

## Single vs Batch Requests

### Single Quote: `getQuote`

Use `getQuote` for retrieving data for one symbol:

```nim
proc getQuote*(symbol: string): Quote
```

This function will raise an exception if the symbol is invalid or data is unavailable.

**Example:**
```nim
try:
  let quote = getQuote("AAPL")
  echo "Price: $", quote.regularMarketPrice
except QuoteError:
  echo "Symbol not found"
```

### Batch Quotes: `getQuotes`

Use `getQuotes` for retrieving data for multiple symbols:

```nim
proc getQuotes*(symbols: seq[string]): seq[Quote]
```

This function silently skips invalid symbols and returns only the successful results. This behavior is useful when processing watchlists that may contain inactive symbols.

**Example:**
```nim
let symbols = @["AAPL", "INVALID123", "MSFT"]
let quotes = getQuotes(symbols)  # Returns 2 quotes (AAPL, MSFT)
echo "Retrieved ", quotes.len, " out of ", symbols.len, " quotes"
```

### Performance Considerations

Currently, `getQuotes` makes individual requests for each symbol. For large watchlists, this may take some time. Each request takes approximately 0.5-2 seconds depending on network conditions.

```nim
# Approximate timing
let quotes = getQuotes(@["AAPL", "MSFT", "GOOGL"])  # ~1.5-6 seconds
```

## Quote Fields Reference

The `Quote` type contains many fields. Here are the most commonly used ones:

### Identification

```nim
quote.symbol           # "AAPL"
quote.shortName        # "Apple Inc."
quote.longName         # "Apple Inc."
quote.quoteType        # Equity, ETF, Cryptocurrency, etc.
quote.currency         # "USD"
quote.exchange         # "NMS" (NASDAQ)
```

### Current Price

```nim
quote.regularMarketPrice              # Current price
quote.regularMarketChange             # Absolute change
quote.regularMarketChangePercent      # Percentage change
quote.regularMarketPreviousClose      # Previous closing price
```

### Daily Range

```nim
quote.regularMarketOpen      # Opening price
quote.regularMarketDayHigh   # Day's high
quote.regularMarketDayLow    # Day's low
quote.regularMarketVolume    # Volume traded today
```

### 52-Week Range

```nim
quote.fiftyTwoWeekHigh               # 52-week high
quote.fiftyTwoWeekLow                # 52-week low
quote.fiftyTwoWeekChangePercent      # Change from 52-week low
```

### Moving Averages

```nim
quote.fiftyDayAverage                # 50-day MA
quote.fiftyDayAverageChange          # Distance from 50-day MA
quote.twoHundredDayAverage           # 200-day MA
quote.twoHundredDayAverageChange     # Distance from 200-day MA
```

### Volume Metrics

```nim
quote.averageDailyVolume3Month   # 3-month average volume
quote.averageDailyVolume10Day    # 10-day average volume
```

### Valuation Metrics

```nim
quote.marketCap          # Market capitalization
quote.sharesOutstanding  # Number of shares outstanding
quote.trailingPE         # P/E ratio (Option[float64])
quote.forwardPE          # Forward P/E (Option[float64])
quote.dividendYield      # Dividend yield (Option[float64])
```

### Market State

```nim
quote.marketState        # PreMarket, Regular, Post, Closed
quote.regularMarketTime  # Unix timestamp of last update
```

## Working with Optional Fields

Some fields are wrapped in `Option[T]` because they may not be available for all securities. For example, cryptocurrencies don't have P/E ratios.

```nim
import std/options

let quote = getQuote("AAPL")

# Check if field exists
if quote.trailingPE.isSome:
  echo "P/E Ratio: ", quote.trailingPE.get()
else:
  echo "P/E Ratio: N/A"

# Provide default value
let pe = quote.trailingPE.get(0.0)  # Returns 0.0 if not available

# Pattern matching
case quote.dividendYield.isSome
of true:
  let yield = quote.dividendYield.get()
  echo "Dividend Yield: ", yield, "%"
of false:
  echo "No dividend"
```

## Common Patterns

### Display Price with Color

```nim
import std/terminal

let quote = getQuote("AAPL")

if quote.regularMarketChangePercent >= 0:
  stdout.styledWrite(fgGreen, "+", $quote.regularMarketChangePercent, "%")
else:
  stdout.styledWrite(fgRed, $quote.regularMarketChangePercent, "%")
echo ""
```

### Monitor Multiple Stocks

```nim
import std/[times, os]

let watchlist = @["AAPL", "MSFT", "GOOGL"]

while true:
  echo "=== ", now().format("HH:mm:ss"), " ==="
  
  let quotes = getQuotes(watchlist)
  for quote in quotes:
    echo quote.symbol, ": $", quote.regularMarketPrice,
         " (", quote.regularMarketChangePercent, "%)"
  
  echo ""
  sleep(60000)  # Update every minute
```

### Find Best Performer

```nim
let quotes = getQuotes(@["AAPL", "MSFT", "GOOGL", "AMZN", "TSLA"])

var bestQuote = quotes[0]
for quote in quotes:
  if quote.regularMarketChangePercent > bestQuote.regularMarketChangePercent:
    bestQuote = quote

echo "Best performer: ", bestQuote.symbol,
     " (", bestQuote.regularMarketChangePercent, "%)"
```

### Calculate Market Cap Totals

```nim
let quotes = getQuotes(@["AAPL", "MSFT", "GOOGL"])

var totalMarketCap: int64 = 0
for quote in quotes:
  totalMarketCap += quote.marketCap

let trillions = totalMarketCap.float / 1_000_000_000_000.0
echo "Total market cap: $", trillions, " trillion"
```

### Filter by Criteria

```nim
let quotes = getQuotes(@["AAPL", "MSFT", "GOOGL", "AMZN", "TSLA"])

# Find stocks up more than 1%
echo "Gainers (>1%):"
for quote in quotes:
  if quote.regularMarketChangePercent > 1.0:
    echo "  ", quote.symbol, ": +", quote.regularMarketChangePercent, "%"

# Find stocks with P/E < 30
echo "Value stocks (P/E < 30):"
for quote in quotes:
  if quote.trailingPE.isSome:
    let pe = quote.trailingPE.get()
    if pe < 30.0 and pe > 0:
      echo "  ", quote.symbol, ": P/E = ", pe
```

### Export to CSV

```nim
import std/strformat

let quotes = getQuotes(@["AAPL", "MSFT", "GOOGL"])

echo "Symbol,Price,Change%,Volume,MarketCap"
for quote in quotes:
  echo &"{quote.symbol},{quote.regularMarketPrice},{quote.regularMarketChangePercent},{quote.regularMarketVolume},{quote.marketCap}"
```

## Error Handling

### Single Quote Errors

```nim
import yfnim

try:
  let quote = getQuote("AAPL")
  # Process quote...
  
except ValueError as e:
  # Empty or invalid input
  echo "Input error: ", e.msg
  
except QuoteError as e:
  # Symbol not found or API error
  echo "Quote error: ", e.msg
  
except HttpRequestError as e:
  # Network error
  echo "Network error: ", e.msg
  
except JsonParsingError as e:
  # JSON parsing error (rare)
  echo "Parsing error: ", e.msg
```

### Batch Quote Errors

`getQuotes` handles errors differently - it skips invalid symbols rather than raising exceptions:

```nim
let symbols = @["AAPL", "INVALID", "MSFT", "BADSTOCK"]
let quotes = getQuotes(symbols)

# Identify which symbols failed
var successSymbols: seq[string]
for quote in quotes:
  successSymbols.add(quote.symbol)

var failedSymbols: seq[string]
for symbol in symbols:
  if symbol notin successSymbols:
    failedSymbols.add(symbol)

if failedSymbols.len > 0:
  echo "Failed to retrieve: ", failedSymbols.join(", ")
```

## Limitations

### Data Timeliness

- Quote data may be delayed by 15-20 minutes depending on exchange rules
- Real-time data availability depends on your access level
- Check `quote.regularMarketTime` to see when the data was last updated

### Field Availability

Not all fields are available for all security types:

- **Stocks**: Most fields available
- **ETFs**: Limited valuation metrics
- **Indices**: No P/E ratios or dividends
- **Cryptocurrencies**: Limited fundamental data
- **Options/Futures**: Different field sets

Always check `Option` fields before using them.

### Market Hours

- During market hours: Prices update in near real-time (with potential delays)
- After hours: May show pre-market or post-market prices
- Market closed: Shows last closing price
- Check `quote.marketState` to determine current market status

### Rate Limits

Yahoo Finance doesn't publish official rate limits, but excessive requests may be throttled. For monitoring applications, avoid requesting quotes more frequently than once per minute unless necessary.

## International Markets

yfnim works with international exchanges. Use the appropriate symbol format:

```nim
# Canadian stocks (Toronto Stock Exchange)
let shopify = getQuote("SHOP.TO")

# UK stocks (London Stock Exchange)
let bp = getQuote("BP.L")

# Japanese stocks (Tokyo Stock Exchange)
let sony = getQuote("6758.T")

# Cryptocurrencies
let bitcoin = getQuote("BTC-USD")
let ethereum = getQuote("ETH-USD")
```

Note that field availability and data quality may vary by exchange.

## See Also

- [Getting Started Guide](getting-started.md) - Basic introduction
- [Historical Data Guide](historical-data.md) - Historical OHLCV data
- [Example: batch_quotes.nim](../../examples/library/batch_quotes.nim) - Batch quote retrieval example
- [Example: error_handling.nim](../../examples/library/error_handling.nim) - Error handling patterns
