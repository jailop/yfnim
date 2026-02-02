# yfnim - Yahoo Finance Data Retriever for Nim

<div align="center">
  <p>
    <strong>A library and command-line tool for retrieving stock market data from Yahoo Finance. Written in Nim.</strong>
  </p>
</div>

---

## Highlights

- 📊 **Complete market data**: Historical prices, real-time quotes, dividends, splits
- 🔍 **Powerful screening**: Filter stocks with custom expressions
- 📈 **Technical analysis**: Built-in indicators (RSI, MACD, Bollinger Bands, and more)
- 🚀 **Fast & efficient**: Written in Nim, minimal dependencies
- 🔧 **Unix-friendly**: Pipes, CSV/JSON export, works great with standard tools
- 📦 **Dual interface**: Use as a library or standalone CLI tool

## Features

### Library

- Historical OHLCV data retrieval
- Real-time/delayed quote data
- Multiple time intervals (1m, 5m, 15m, 30m, 1h, 1d, 1wk, 1mo)
- Type-safe API
- Uses only Nim standard library
- JSON serialization support

### CLI Tool

- Unix-friendly command-line interface
- Multiple output formats (table, CSV, JSON, TSV, minimal)
- Stock screening with custom filter expressions
- Dividend and stock split history tracking
- Corporate actions timeline
- Batch data download for multiple symbols
- Technical indicators (SMA, EMA, RSI, MACD, Bollinger Bands, ATR, and more)
- In-memory caching
- Works well with standard Unix tools

## Quick Start

### Library

```nim
import yfnim
import std/times

# Historical data
let endTime = getTime().toUnix()
let startTime = endTime - (7 * 86400)
let history = getHistory("AAPL", Int1d, startTime, endTime)

echo "Retrieved ", history.data.len, " records for ", history.symbol
for bar in history.data:
  echo "Date: ", fromUnix(bar.date).format("yyyy-MM-dd"), 
       " Close: $", bar.close

# Current quote
let quote = getQuote("AAPL")
echo "Price: $", quote.regularMarketPrice
echo "Change: ", quote.regularMarketChangePercent, "%"
```

Compile with SSL support:
```bash
nim c -d:ssl your_program.nim
```

### CLI Tool

```bash
# Get current quotes
yf quote AAPL MSFT GOOGL

# Get historical data
yf history AAPL --lookback 30d

# Compare stocks
yf compare AAPL MSFT GOOGL

# Screen stocks
yf screen AAPL MSFT GOOGL --criteria custom --where "pe < 20 and yield > 2"

# Get dividend history
yf dividends AAPL --lookback 5y

# Check stock splits
yf splits TSLA --lookback 10y

# Calculate technical indicators
yf indicators AAPL --sma 20,50,200 --rsi --macd

# Export to CSV
yf history AAPL --lookback 90d --format csv > data.csv
```

## Documentation

### Library

- [Getting Started](library/getting-started.md) - Installation and first program
- [Historical Data Guide](library/historical-data.md) - Working with OHLCV data
- [Quote Data Guide](library/quote-data.md) - Real-time quotes and market data
- [API Documentation](api/index.md) - Complete API reference

### CLI Tool

- [Installation Guide](cli/installation.md) - Installation instructions
- [Quick Start](cli/quick-start.md) - Get started in 5 minutes
- [Commands Reference](cli/commands.md) - Complete command documentation
- [Screening Guide](cli/screening.md) - Advanced stock screening

## Available Commands

| Command | Purpose |
|---------|---------|
| `history` | Retrieve historical OHLCV data |
| `quote` | Get current market quotes |
| `compare` | Compare multiple stocks side-by-side |
| `screen` | Filter stocks by criteria or custom expressions |
| `dividends` | Get dividend payment history |
| `splits` | Get stock split history |
| `actions` | Get all corporate actions (dividends + splits) |
| `download` | Batch download data for multiple symbols |
| `indicators` | Calculate technical indicators (SMA, EMA, RSI, MACD, BB, ATR, etc.) |

## Installation

### From Source

```bash
git clone https://codeberg.org/jailop/yfnim.git
cd yfnim
nimble build -d:ssl
nimble install
```

### Building

```bash
# Build CLI tool
nimble build -d:ssl

# Build with optimizations
nimble build -d:ssl -d:release

# Generate documentation
nimble docs

# Run tests
nimble test
```

## Data Limitations

Yahoo Finance imposes limits on historical data availability:

| Interval | Max History | Notes |
|----------|-------------|-------|
| 1m | ~7 days | Strictly enforced |
| 5m, 15m, 30m | ~60 days | Approximately 2 months |
| 1h | ~2 years | Approximately 730 days |
| 1d, 1wk, 1mo | Many years | No practical limit |

Quote data may be delayed 15-20 minutes depending on exchange and access level.

## Symbol Formats

- **US Stocks**: `AAPL`, `MSFT`, `GOOGL`  
- **International**: `SHOP.TO` (Toronto), `BP.L` (London), `6758.T` (Tokyo)  
- **Cryptocurrencies**: `BTC-USD`, `ETH-USD`  
- **Indices**: `^GSPC` (S&P 500), `^DJI` (Dow Jones)

## Error Handling

The library uses typed exceptions:

- `ValueError` - Invalid input parameters
- `HttpRequestError` - Network or HTTP errors
- `JsonParsingError` - Invalid JSON responses
- `YahooApiError` - Yahoo Finance API errors
- `QuoteError` - Quote-specific errors

Always wrap API calls in try-except blocks for production use.

## License

MIT License - see [License](license.md) file.

## Disclaimer

This project is not affiliated with Yahoo Finance. Use of Yahoo Finance data is subject to their Terms of Service. This tool is for educational and research purposes. Use responsibly.
