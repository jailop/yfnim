# yfnim - Yahoo Finance Data Retriever for Nim

<div align="center">
  <p>
    <strong>A library and command-line tool for retrieving market data from
    Yahoo Finance. Written in Nim.</strong>
  </p>
</div>

---

## Features

- **Market data**: Historical prices, real-time quotes, dividends, splits
- **Screening**: Filter stocks with custom expressions
- **Technical analysis**: Built-in indicators like RSI, MACD, Bollinger Bands, and others
- **Fast & efficient**: Written in Nim, minimal dependencies
- **Unix-friendly**: Pipes, CSV/JSON export, stdin input, proper stderr logging
- **Command abbreviations**: Use shortcuts like `yf h`, `yf q`, `yf comp`
- **Dual interface**: Use as a library or standalone CLI tool
- **Auto-generated help**: Built with cligen for consistent, colored help text

## Quick Start

### CLI Tool

```bash
# Get current quotes
yf quote AAPL MSFT GOOGL

# Get historical data
yf history --symbol=AAPL --lookback=30d

# Compare stocks
yf compare AAPL MSFT GOOGL

# Screen stocks
yf screen AAPL MSFT GOOGL --criteria=custom --where "pe < 20 and yield > 2"

# Get dividend history
yf dividends --symbol=AAPL --lookback=5y

# Check stock splits
yf splits --symbol=TSLA --lookback=10y

# Calculate technical indicators
yf indicators --symbol=AAPL --sma=20 --sma=50 --sma=200 --rsi=14 --macd

# Export to CSV
yf history --symbol=AAPL --lookback=90d --format=csv > data.csv

# Use piped input
cat symbols.txt | yf quote --read-stdin

# Command abbreviations
yf q AAPL              # quote
yf h --symbol=AAPL     # history
yf comp AAPL MSFT      # compare
```

### Library

```nim
import yfnim
import std/times

# Historical data
let endTime = getTime().toUnix()
let startTime = endTime - (7  86400)
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

## Installation

```bash
git clone https://codeberg.org/jailop/yfnim.git
cd yfnim
nimble build
nimble install
```
## License

MIT License - see [License](license.md) file.

## Disclaimer

This project is not affiliated with Yahoo Finance. Use of Yahoo Finance
data is subject to their Terms of Service. This tool is for educational
and research purposes. Use responsibly.
