# yfnim - Yahoo Finance Data Retriever for Nim

A library and command-line tool for retrieving stock market data from
Yahoo Finance. Written in Nim.

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
- In-memory caching
- Works well with standard Unix tools

## Installation

```bash
git clone https://codeberg.org/jailop/yfnim.git
cd yfnim
nimble build
nimble install
```


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

# Export to CSV
yf history AAPL --lookback 90d --format csv > data.csv
```

## Documentation

### Library

- [Getting Started](docs/library/getting-started.md) - Installation and first program
- [Historical Data Guide](docs/library/historical-data.md) - Working with OHLCV data
- [Quote Data Guide](docs/library/quote-data.md) - Real-time quotes and market data
- [API Documentation](docs/api/yfnim.html) - Complete API reference (generate with `nimble docs`)

### CLI Tool

- [Installation Guide](docs/cli/installation.md) - Installation instructions
- [Quick Start](docs/cli/quick-start.md) - Get started in 5 minutes
- [Commands Reference](docs/cli/commands.md) - Complete command documentation
- [Screening Guide](docs/cli/screening.md) - Advanced stock screening

### Examples

Library examples in [examples/library/](examples/library/):
- `basic_history.nim` - Simple historical data retrieval
- `batch_quotes.nim` - Batch quote retrieval
- `error_handling.nim` - Error handling patterns
- `custom_intervals.nim` - Using different time intervals

CLI examples in [examples/cli/](examples/cli/):
- `basic_usage.sh` - Common CLI usage patterns
- `screening.sh` - Stock screening examples
- `piping.sh` - Unix piping and integration

## Building

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

US Stocks: `AAPL`, `MSFT`, `GOOGL`  
International: `SHOP.TO` (Toronto), `BP.L` (London), `6758.T` (Tokyo)  
Cryptocurrencies: `BTC-USD`, `ETH-USD`  
Indices: `^GSPC` (S&P 500), `^DJI` (Dow Jones)

## Error Handling

The library uses typed exceptions:

- `ValueError` - Invalid input parameters
- `HttpRequestError` - Network or HTTP errors
- `JsonParsingError` - Invalid JSON responses
- `YahooApiError` - Yahoo Finance API errors
- `QuoteError` - Quote-specific errors

Always wrap API calls in try-except blocks for production use.

## License

MIT License - see [LICENSE](LICENSE) file.

## Disclaimer

This project is not affiliated with Yahoo Finance. Use of Yahoo Finance data is subject to their Terms of Service. This tool is for educational and research purposes. Use responsibly.
