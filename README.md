# yfnim - Yahoo Finance Data Retriever for Nim

A lightweight, pure-Nim library for retrieving stock market data from Yahoo Finance. Fetch historical OHLCV (Open, High, Low, Close, Volume) data and real-time/delayed quote information with a simple, type-safe API.

## Features

- **Multiple Data Types**: Historical OHLCV data + Real-time/delayed quotes
- **Multiple Time Intervals**: 1m, 5m, 15m, 30m, 1h, 1d, 1wk, 1mo
- **Type-Safe API**: Strongly typed data structures with comprehensive error handling
- **Zero Dependencies**: Uses only Nim's standard library
- **JSON Support**: Built-in JSON serialization and deserialization
- **Comprehensive Testing**: 100+ unit and integration tests
- **Clean Design**: Data-only library focused on retrieval and parsing

## Installation

```bash
nimble install yfnim
```

Or add to your `.nimble` file:

```nim
requires "yfnim >= 0.1.0"
```

## Quick Start

### Historical Data

```nim
import yfnim
import std/times

# Get the last 7 days of daily data for Apple
let now = getTime().toUnix()
let weekAgo = now - (7 * 24 * 3600)
let history = getHistory("AAPL", Int1d, weekAgo, now)

echo "Symbol: ", history.symbol
echo "Interval: ", history.interval
echo "Records: ", history.len

# Access OHLCV data
for record in history.data:
  echo "Time: ", record.time
  echo "  Open: ", record.open
  echo "  High: ", record.high
  echo "  Low: ", record.low
  echo "  Close: ", record.close
  echo "  Volume: ", record.volume
```

### Quote Data

```nim
import yfnim/quote_retriever

# Get current/delayed quote for a single symbol
let quote = getQuote("AAPL")
echo "Price: $", quote.regularMarketPrice
echo "Change: ", quote.regularMarketChangePercent, "%"
echo "Volume: ", quote.regularMarketVolume
echo "52-Week Range: $", quote.fiftyTwoWeekLow, " - $", quote.fiftyTwoWeekHigh

# Get multiple quotes efficiently
let quotes = getQuotes(@["AAPL", "MSFT", "GOOGL"])
for q in quotes:
  echo q.symbol, ": $", q.regularMarketPrice
```

**Important**: You must compile with SSL support:

```bash
nim c -d:ssl your_program.nim
```

## API Reference

### Core Types

#### `Interval` Enum

Represents the time interval for historical data:

```nim
type Interval* = enum
  Int1m = "1m"    # 1 minute
  Int5m = "5m"    # 5 minutes
  Int15m = "15m"  # 15 minutes
  Int30m = "30m"  # 30 minutes
  Int1h = "1h"    # 1 hour
  Int1d = "1d"    # 1 day
  Int1wk = "1wk"  # 1 week
  Int1mo = "1mo"  # 1 month
```

#### `HistoryRecord` Object

Represents a single OHLCV data point:

```nim
type HistoryRecord* = object
  time*: int64      # Unix timestamp
  open*: float64    # Opening price
  low*: float64     # Lowest price
  high*: float64    # Highest price
  close*: float64   # Closing price
  volume*: int64    # Trading volume
```

#### `History` Object

Represents a time series of historical data:

```nim
type History* = object
  symbol*: string           # Ticker symbol (e.g., "AAPL")
  interval*: Interval       # Time interval
  data*: seq[HistoryRecord] # OHLCV records
```

### Main Function

#### `getHistory`

Retrieves historical data from Yahoo Finance:

```nim
proc getHistory*(symbol: string, interval: Interval, 
                 startTime: int64, endTime: int64): History
```

**Parameters:**
- `symbol`: Stock ticker symbol (e.g., "AAPL", "MSFT", "BTC-USD")
- `interval`: Time interval (Int1m, Int1h, Int1d, etc.)
- `startTime`: Start date as Unix timestamp
- `endTime`: End date as Unix timestamp

**Returns:**
- `History` object containing OHLCV data

**Raises:**
- `ValueError`: Invalid input parameters (empty symbol, negative timestamps, start > end)
- `HttpRequestError`: Network or HTTP errors
- `JsonParsingError`: Invalid JSON response
- `YahooApiError`: Yahoo Finance API errors

**Example:**

```nim
import yfnim
import std/times

let now = getTime().toUnix()
let monthAgo = now - (30 * 24 * 3600)

try:
  let history = getHistory("MSFT", Int1h, monthAgo, now)
  echo "Retrieved ", history.len, " records"
except YahooApiError as e:
  echo "API error: ", e.msg
except HttpRequestError as e:
  echo "Network error: ", e.msg
```

### Helper Functions

#### `newHistory`

Creates a new empty History object:

```nim
proc newHistory*(symbol: string, interval: Interval): History
```

#### `len`

Returns the number of records:

```nim
proc len*(h: History): int
```

#### `append`

Adds a record to history:

```nim
proc append*(h: var History, record: HistoryRecord)
```

#### `toJson`

Converts History to JSON string:

```nim
proc toJson*(h: History): string
```

#### `fromJson`

Creates History from JSON string:

```nim
proc fromJson*(jsonStr: string): History
```

#### `parseInterval`

Converts string to Interval enum:

```nim
proc parseInterval*(s: string): Interval
```

### Quote Data API

#### `Quote` Object

Represents real-time or delayed market quote data:

```nim
type Quote* = object
  # Identification
  symbol*: string
  shortName*: string
  longName*: string
  quoteType*: QuoteType  # EQUITY, ETF, CRYPTOCURRENCY, etc.
  currency*: string
  exchange*: string
  
  # Price Data
  regularMarketPrice*: float64
  regularMarketChange*: float64
  regularMarketChangePercent*: float64
  regularMarketOpen*: float64
  regularMarketDayHigh*: float64
  regularMarketDayLow*: float64
  regularMarketVolume*: int64
  regularMarketPreviousClose*: float64
  
  # 52-Week Range
  fiftyTwoWeekLow*: float64
  fiftyTwoWeekHigh*: float64
  fiftyTwoWeekChangePercent*: float64
  
  # Market State
  marketState*: MarketState  # PreMarket, Regular, Post, Closed
  tradeable*: bool
  
  # ... and many more fields (see quote_types module documentation)
```

#### `getQuote`

Retrieves quote for a single symbol:

```nim
proc getQuote*(symbol: string): Quote
```

**Parameters:**
- `symbol`: Stock ticker symbol (e.g., "AAPL", "BTC-USD", "^GSPC")

**Returns:**
- `Quote` object with current market data

**Raises:**
- `ValueError`: If symbol is empty
- `HttpRequestError`: Network errors
- `QuoteError`: Symbol not found or API error

**Example:**

```nim
import yfnim/quote_retriever

let quote = getQuote("AAPL")
echo "Price: $", quote.regularMarketPrice
echo "Day Range: $", quote.regularMarketDayLow, " - $", quote.regularMarketDayHigh
```

#### `getQuotes`

Retrieves quotes for multiple symbols (makes concurrent requests):

```nim
proc getQuotes*(symbols: seq[string]): seq[Quote]
```

**Parameters:**
- `symbols`: Sequence of ticker symbols

**Returns:**
- Sequence of Quote objects (may be shorter if some symbols are invalid)

**Example:**

```nim
import yfnim/quote_retriever

let quotes = getQuotes(@["AAPL", "MSFT", "GOOGL"])
for quote in quotes:
  echo quote.symbol, ": $", quote.regularMarketPrice
```

#### `QuoteType` Enum

Classification of securities:

```nim
type QuoteType* = enum
  Equity = "EQUITY"                    # Stock
  ETF = "ETF"                          # Exchange Traded Fund
  Mutualfund = "MUTUALFUND"            # Mutual Fund
  Index = "INDEX"                      # Market Index
  Currency = "CURRENCY"                # Fiat Currency
  Cryptocurrency = "CRYPTOCURRENCY"    # Cryptocurrency
  Future = "FUTURE"                    # Futures Contract
  Option = "OPTION"                    # Options Contract
```

#### `MarketState` Enum

Current trading state:

```nim
type MarketState* = enum
  PreMarket = "PRE"       # Pre-market trading
  Regular = "REGULAR"      # Regular market hours
  Post = "POST"            # Post-market trading
  Closed = "CLOSED"        # Market closed
```

## Yahoo Finance API Limitations

Yahoo Finance imposes different history length limits based on the time interval:

| Interval | Maximum History | Notes |
|----------|----------------|-------|
| 1m | ~7 days | Yahoo enforces strict 7-day limit |
| 5m | ~60 days | Approximately 2 months |
| 15m | ~60 days | Approximately 2 months |
| 30m | ~60 days | Approximately 2 months |
| 1h | ~730 days | Approximately 2 years |
| 1d | Many years | No practical limit |
| 1wk | Many years | No practical limit |
| 1mo | Many years | No practical limit |

Requesting data beyond these limits will result in a `YahooApiError` or `HttpRequestError`.

## Usage Examples

### Basic Usage

```nim
import yfnim
import std/times

let now = getTime().toUnix()
let weekAgo = now - (7 * 24 * 3600)
let history = getHistory("AAPL", Int1d, weekAgo, now)

for record in history.data:
  echo record.time, " -> Close: $", record.close
```

### Multiple Symbols with Error Handling

```nim
import yfnim
import std/[times, os]

let symbols = @["AAPL", "MSFT", "GOOGL", "TSLA"]
let now = getTime().toUnix()
let monthAgo = now - (30 * 24 * 3600)

for symbol in symbols:
  try:
    let history = getHistory(symbol, Int1d, monthAgo, now)
    echo symbol, ": ", history.len, " records"
    
    # Calculate simple statistics
    if history.len > 0:
      var total = 0.0
      for record in history.data:
        total += record.close
      let average = total / float(history.len)
      echo "  Average close: $", average.formatFloat(ffDecimal, 2)
    
    # Be nice to Yahoo Finance - add delay between requests
    sleep(1000)  # 1 second delay
    
  except YahooApiError as e:
    echo symbol, ": API error - ", e.msg
  except HttpRequestError as e:
    echo symbol, ": Network error - ", e.msg
```

### JSON Export

```nim
import yfnim
import std/[times, os as osmod]

let now = getTime().toUnix()
let weekAgo = now - (7 * 24 * 3600)
let history = getHistory("AAPL", Int1d, weekAgo, now)

# Export to JSON
let jsonStr = history.toJson()
writeFile("aapl_history.json", jsonStr)

# Import from JSON
let loaded = fromJson(readFile("aapl_history.json"))
echo "Loaded ", loaded.len, " records for ", loaded.symbol
```

### Intraday Trading Analysis

```nim
import yfnim
import std/times

# Get 1-minute data for the last day (max 7 days for 1m interval)
let now = getTime().toUnix()
let oneDayAgo = now - (24 * 3600)

try:
  let history = getHistory("SPY", Int1m, oneDayAgo, now)
  
  # Find highest and lowest prices
  var highest = 0.0
  var lowest = float64.high
  
  for record in history.data:
    if record.high > highest:
      highest = record.high
    if record.low < lowest:
      lowest = record.low
  
  echo "SPY Intraday Range:"
  echo "  High: $", highest
  echo "  Low: $", lowest
  echo "  Range: $", (highest - lowest)
  
except HttpRequestError as e:
  # 1m interval might return 422 Unprocessable Entity if range is too large
  echo "Error: ", e.msg
  echo "Note: 1m interval is limited to 7 days of history"
```

### International and Crypto Symbols

```nim
import yfnim
import std/times

let now = getTime().toUnix()
let weekAgo = now - (7 * 24 * 3600)

# German stock (SAP on Frankfurt exchange)
let sapDE = getHistory("SAP.DE", Int1d, weekAgo, now)
echo "SAP.DE: ", sapDE.len, " records"

# Cryptocurrency
let bitcoin = getHistory("BTC-USD", Int1d, weekAgo, now)
echo "BTC-USD: ", bitcoin.len, " records"

# Berkshire Hathaway Class B (hyphenated symbol)
let brkB = getHistory("BRK-B", Int1d, weekAgo, now)
echo "BRK-B: ", brkB.len, " records"
```

### Quote Data - Real-time Price Lookup

```nim
import yfnim/quote_retriever
import std/strformat

# Get current price and daily performance
let quote = getQuote("AAPL")

echo &"{quote.symbol} - {quote.shortName}"
echo &"Price: ${quote.regularMarketPrice:.2f}"
echo &"Change: ${quote.regularMarketChange:.2f} ({quote.regularMarketChangePercent:.2f}%)"
echo &"Day Range: ${quote.regularMarketDayLow:.2f} - ${quote.regularMarketDayHigh:.2f}"
echo &"Volume: {quote.regularMarketVolume}"
echo &"Market State: {quote.marketState}"
```

### Multiple Quote Lookup

```nim
import yfnim/quote_retriever

# Get quotes for a portfolio
let symbols = @["AAPL", "MSFT", "GOOGL", "AMZN", "META"]
let quotes = getQuotes(symbols)

echo "Portfolio Summary:"
echo "Symbol", "\t", "Price", "\t", "Change %"
echo "------", "\t", "-----", "\t", "--------"

for quote in quotes:
  let sign = if quote.regularMarketChangePercent >= 0: "+" else: ""
  echo quote.symbol, "\t", 
       "$", quote.regularMarketPrice, "\t", 
       sign, quote.regularMarketChangePercent, "%"
```

### Different Asset Types

```nim
import yfnim/quote_retriever

# Stock
let apple = getQuote("AAPL")
echo "Stock: ", apple.symbol, " (", apple.quoteType, ")"

# ETF
let spy = getQuote("SPY")
echo "ETF: ", spy.symbol, " (", spy.quoteType, ")"

# Cryptocurrency
let bitcoin = getQuote("BTC-USD")
echo "Crypto: ", bitcoin.symbol, " (", bitcoin.quoteType, ")"

# Index
let sp500 = getQuote("^GSPC")
echo "Index: ", sp500.symbol, " (", sp500.quoteType, ")"
```

## Error Handling

The library uses specific exception types for different error scenarios:

```nim
# Historical data errors
try:
  let history = getHistory("INVALID", Int1d, startTime, endTime)
except ValueError as e:
  # Input validation errors (empty symbol, invalid timestamps, etc.)
  echo "Invalid input: ", e.msg
except HttpRequestError as e:
  # Network errors, HTTP 4xx/5xx responses
  echo "Network error: ", e.msg
except JsonParsingError as e:
  # Invalid or unexpected JSON structure
  echo "JSON parsing error: ", e.msg
except YahooApiError as e:
  # Yahoo Finance API returned an error
  echo "Yahoo API error: ", e.msg

# Quote data errors
try:
  let quote = getQuote("INVALID_SYMBOL")
except ValueError as e:
  echo "Invalid input: ", e.msg
except HttpRequestError as e:
  echo "Network error: ", e.msg
except QuoteError as e:
  # Quote-specific API errors (inherits from YahooApiError)
  echo "Quote error: ", e.msg
```

## Building and Testing

### Compile the Library

```bash
nim c src/yfnim.nim
```

### Run Unit Tests

```bash
nimble test
```

### Run Integration Tests (requires network)

```bash
# Historical data tests
nim c -d:ssl -r tests/test_integration.nim
nim c -d:ssl -r tests/test_edge_cases.nim

# Quote data tests
nim c -d:ssl -r tests/test_quote_integration.nim
```

### Compile Examples

Compile all examples at once:

```bash
nimble examples
```

Run a specific example:

```bash
nimble runExample basic_usage
nimble runExample data_analysis
nimble runExample quote_lookup
```

Or compile and run manually:

```bash
# Historical data examples
nim c -d:ssl -p:src -r examples/basic_usage.nim
nim c -d:ssl -p:src -r examples/data_analysis.nim

# Quote data example
nim c -d:ssl -p:src -r examples/quote_lookup.nim
```

### Generate Documentation

```bash
nim doc src/yfnim.nim
```

This creates HTML documentation in the project directory.

## Project Structure

```
yfnim/
├── src/
│   ├── yfnim.nim              # Main library export
│   └── yfnim/
│       ├── types.nim          # Historical data types and JSON support
│       ├── urlbuilder.nim     # Yahoo Finance URL construction
│       ├── retriever.nim      # Historical data HTTP client
│       ├── quote_types.nim    # Quote data types and JSON support
│       └── quote_retriever.nim # Quote data HTTP client
├── tests/
│   ├── test_types.nim         # Type system tests
│   ├── test_urlbuilder.nim    # URL builder tests
│   ├── test_retriever.nim     # Retriever unit tests
│   ├── test_integration.nim   # Historical data API tests
│   ├── test_edge_cases.nim    # Edge case and validation tests
│   ├── test_quote.nim         # Quote unit tests
│   └── test_quote_integration.nim  # Quote API tests
├── examples/
│   ├── basic_usage.nim        # Historical data example
│   ├── data_analysis.nim      # Data analysis example
│   ├── quote_lookup.nim       # Quote data example
│   └── ... (more examples)
└── yfnim.nimble               # Package metadata
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass: `nimble test`
5. Submit a pull request

## License

MIT License - See LICENSE file for details

## Acknowledgments

- Based on the Go implementation `yfgo`
- Uses Yahoo Finance's public API (no API key required)
- Built with Nim's standard library

## Disclaimer

This library is for educational and research purposes. Yahoo Finance's Terms of Service apply. Use responsibly and respect rate limits. The authors are not responsible for any misuse or violations of Yahoo Finance's terms.

## Support

- Report issues on GitHub
- Check existing tests for usage examples
- Read the generated documentation: `nim doc src/yfnim.nim`

## Version History

### 0.2.0 (Current - In Development)
- **NEW**: Real-time/delayed quote data retrieval
- **NEW**: Quote types with 50+ fields (price, volume, market cap, P/E ratios, etc.)
- **NEW**: Support for multiple asset types (stocks, ETFs, crypto, indices)
- Added `quote_types` and `quote_retriever` modules
- Added `getQuote()` and `getQuotes()` functions
- Added quote-specific examples and tests
- Expanded test coverage to 100+ tests
- Updated documentation with quote API reference

### 0.1.0 (Initial Release)
- Complete OHLCV historical data retrieval
- Support for 8 time intervals (1m, 5m, 15m, 30m, 1h, 1d, 1wk, 1mo)
- JSON serialization/deserialization
- Comprehensive error handling
- 86+ unit and integration tests
- Input validation and edge case handling
