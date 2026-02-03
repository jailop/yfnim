# Quick Start Guide - yf CLI Tool

This guide will get you started with the `yf` command-line tool in about 5 minutes.

## Prerequisites

Make sure you have installed the `yf` tool. If not, see the [Installation Guide](installation.md).

Verify installation:
```bash
yf quote AAPL
```

## Basic Commands

The `yf` tool has nine main commands:

| Command | Purpose | Example |
|---------|---------|---------|
| `history` | Get historical price data | `yf history --symbol=AAPL --lookback=30d` |
| `quote` | Get current price quotes | `yf quote AAPL MSFT` |
| `compare` | Compare multiple stocks | `yf compare AAPL MSFT GOOGL` |
| `screen` | Filter stocks by criteria | `yf screen AAPL MSFT --criteria=value` |
| `dividends` | Get dividend history | `yf dividends --symbol=AAPL --lookback=5y` |
| `splits` | Get stock split history | `yf splits --symbol=TSLA --lookback=10y` |
| `actions` | Get all corporate actions | `yf actions --symbol=AAPL --lookback=5y` |
| `download` | Batch download data | `yf download AAPL MSFT --lookback=30d` |
| `indicators` | Calculate technical indicators | `yf indicators --symbol=AAPL --rsi=14 --macd` |

**Tip**: Use command abbreviations for faster typing: `yf h`, `yf q`, `yf comp`, etc.

## 1. Get Current Quotes

Retrieve real-time or delayed quotes for one or more symbols:

```bash
# Single symbol
yf quote AAPL

# Multiple symbols
yf quote AAPL MSFT GOOGL

# International stocks
yf quote AAPL SHOP.TO BP.L  # Canadian, British stocks

# Cryptocurrencies
yf quote BTC-USD ETH-USD
```

**Output:**
```
Symbol  Price     Change    Change%   Volume        Market Cap
AAPL    $225.50   +2.30     +1.03%    65432100      $3.45T
```

## 2. Get Historical Data

Retrieve historical price data:

```bash
# Last 7 days (default)
yf history --symbol=AAPL --lookback=7d

# Last 30 days
yf history --symbol=AAPL --lookback=30d

# Last 6 months
yf history --symbol=AAPL --lookback=180d

# Specific date range
yf history --symbol=AAPL --start 2024-01-01 --end 2024-01-31
```

**Output:**
```
Date        Open      High      Low       Close     Volume
2024-01-15  $185.90   $189.50   $185.20   $188.63   52431000
2024-01-16  $188.70   $191.20   $188.30   $190.92   48723000
...
```

## 3. Compare Stocks

View multiple stocks side-by-side:

```bash
yf compare AAPL MSFT GOOGL
```

**Output:**
```
Symbol  Price     Change%   Volume        52W Low   52W High  Market Cap
AAPL    $225.50   +1.03%    65432100      $164.08   $237.23   $3.45T
MSFT    $415.20   +0.87%    23456789      $309.45   $430.82   $3.08T
GOOGL   $155.80   -0.45%    18765432      $121.46   $166.83   $1.95T
```

## 4. Screen Stocks

Filter stocks based on criteria:

```bash
# Predefined criteria
yf screen AAPL MSFT GOOGL AMZN --criteria=value     # Value stocks
yf screen AAPL MSFT GOOGL AMZN --criteria=growth    # Growth stocks
yf screen AAPL MSFT GOOGL AMZN --criteria=dividend  # High dividend

# Custom filter
yf screen AAPL MSFT GOOGL --criteria=custom --where "price > 200"
yf screen AAPL MSFT GOOGL --criteria=custom --where "pe < 30 and yield > 1"
```

## 5. Get Dividend History

Retrieve historical dividend payments:

```bash
# Get all dividend history
yf dividends AAPL

# Get dividends for last 5 years
yf dividends --symbol=JNJ --lookback=5y

# Export to CSV
yf dividends --symbol=MSFT --format=csv > dividends.csv
```

## 6. Check Stock Splits

View historical stock split events:

```bash
# Get all split history
yf splits AAPL

# Get recent splits
yf splits --symbol=TSLA --lookback=5y

# Export to JSON
yf splits --symbol=NVDA --format=json
```

## 7. Batch Download Data

Download data for multiple symbols efficiently:

```bash
# Download for multiple symbols
yf download AAPL MSFT GOOGL --lookback=30d

# Export to CSV
yf download AAPL MSFT GOOGL --lookback=90d --format=csv > data.csv
```

## 8. Technical Analysis

Calculate technical indicators:

```bash
# Moving averages
yf indicators --symbol=AAPL --sma 20,50,200

# Momentum indicators
yf indicators --symbol=AAPL --rsi --macd

# All indicators
yf indicators --symbol=AAPL --all
```

## Output Formats

Change the output format with `--format`:

```bash
# Table format (default, human-readable)
yf quote AAPL --format=table

# CSV format (for spreadsheets)
yf quote AAPL --format=csv

# JSON format (for scripts/programs)
yf quote AAPL --format=json

# TSV format (tab-separated)
yf quote AAPL --format=tsv

# Minimal format (values only)
yf quote AAPL --format=minimal
```

## Common Use Cases

### Export to CSV File

```bash
yf history --symbol=AAPL --lookback=30d --format=csv > aapl_data.csv
```

### Monitor Multiple Stocks

```bash
yf quote AAPL MSFT GOOGL AMZN TSLA
```

### Get Intraday Data

```bash
# Hourly data for last 3 days
yf history --symbol=AAPL --lookback=3d --interval=1h

# 5-minute data for today
yf history --symbol=AAPL --lookback=1d --interval 5m
```

### Filter High-Volume Stocks

```bash
yf screen AAPL MSFT GOOGL AMZN TSLA NVDA \
  --criteria=custom \
  --where "volume > 50000000"
```

### Find Gainers

```bash
yf screen AAPL MSFT GOOGL AMZN TSLA \
  --criteria=custom \
  --where "changepercent > 2"
```

## Intervals

Historical data supports different time intervals:

```bash
# Intraday
yf history --symbol=AAPL --lookback=1d --interval 1m   # 1-minute bars
yf history --symbol=AAPL --lookback=5d --interval 5m   # 5-minute bars
yf history --symbol=AAPL --lookback=7d --interval=1h   # 1-hour bars

# Daily and longer
yf history --symbol=AAPL --lookback=90d --interval=1d  # Daily bars (default)
yf history --symbol=AAPL --lookback=365d --interval=1wk  # Weekly bars
yf history --symbol=AAPL --lookback=1825d --interval 1mo # Monthly bars (5 years)
```

**Note:** Shorter intervals have limited historical data availability (1-minute data is typically limited to ~7 days).

## Caching

The tool caches quote data for 5 minutes to reduce API calls:

```bash
# First request - fetches from Yahoo Finance
yf quote AAPL

# Second request within 5 minutes - uses cache
yf quote AAPL

# Force refresh (bypass cache)
yf quote AAPL --refresh
```

Historical data is not cached by default since it changes less frequently.

## Practical Examples

### Daily Market Check

```bash
# Check your portfolio
yf quote AAPL MSFT GOOGL

# See which are up/down
yf screen AAPL MSFT GOOGL AMZN TSLA \
  --criteria=custom \
  --where "changepercent > 0"
```

### Research a Stock

```bash
# Current quote
yf quote AAPL

# Recent price history
yf history --symbol=AAPL --lookback=30d

# Dividend history
yf dividends --symbol=AAPL --lookback=5y

# Check for splits
yf splits --symbol=AAPL --lookback=10y

# Technical indicators
yf indicators --symbol=AAPL --sma 50,200 --rsi

# Compare to competitors
yf compare AAPL MSFT GOOGL
```

### Export for Analysis

```bash
# Get data in different formats
yf history --symbol=AAPL --lookback=90d --format=csv > data.csv
yf quote AAPL MSFT GOOGL --format=json > quotes.json

# Download multiple symbols at once
yf download AAPL MSFT GOOGL --lookback=30d --format=csv > portfolio.csv

# Export technical indicators
yf indicators --symbol=AAPL --all --format=csv > indicators.csv

# Export dividend history
yf dividends --symbol=AAPL --lookback=10y --format=csv > dividends.csv
```

### Create a Watchlist

Create a text file with symbols:

```bash
# Create watchlist.txt
cat > watchlist.txt << EOF
AAPL
MSFT
GOOGL
AMZN
TSLA
EOF

# Monitor all symbols
yf quote $(cat watchlist.txt)
```

## Tips

1. **Use short lookback periods** for intraday intervals (1m, 5m, 15m)
2. **Cache results** - quote data is cached for 5 minutes automatically
3. **Pipe to other tools** - all commands work well with grep, awk, jq
4. **Use CSV/JSON for automation** - easier to parse than table format
5. **Check symbol format** - international stocks may need exchange suffix (e.g., "SHOP.TO")
6. **Use `download` for multiple symbols** - more efficient than multiple `history` commands
7. **Combine indicators** - use multiple technical indicators for better analysis
8. **Export for charting** - CSV output works well with spreadsheets and charting tools

## Common Issues

**"Symbol not found"**
- Check the symbol is valid on Yahoo Finance website
- Try different formats (e.g., "BRK-B" not "BRK.B")
- Add exchange suffix for international stocks

**"No data returned"**
- Check date range is valid (not in the future)
- 1-minute interval only works for recent data (~7 days)
- Some symbols have limited historical data

**"Connection error"**
- Check internet connection
- Yahoo Finance may be temporarily unavailable
- Try again after a few seconds

## Next Steps

- **[Commands Reference](commands.md)** - Complete documentation of all commands and options
- **[Screening Guide](screening.md)** - Advanced filtering and custom expressions
- **[Example Scripts](../../examples/cli/)** - Working shell script examples

## Getting Help

Show command help:
```bash
yf --help           # General help
yf history --help   # Command-specific help
yf quote --help
yf compare --help
yf screen --help
```

For issues or questions:
- Check the [Commands Reference](commands.md)
- See [Example Scripts](../../examples/cli/)
- Report bugs: https://github.com/yourusername/yfnim/issues

## New Features

### Command Abbreviations

Use any unique prefix to abbreviate commands:

```bash
yf h --symbol=AAPL --lookback=30d      # history
yf q AAPL MSFT                         # quote
yf comp AAPL MSFT GOOGL                # compare
yf down AAPL MSFT --lookback=1y        # download
yf div --symbol=JNJ --lookback=5y      # dividends
yf ind --symbol=AAPL --rsi=14          # indicators
```

### Piped Input

Read symbols from stdin for batch processing:

```bash
# From a file
cat symbols.txt | yf quote --read-stdin

# From echo
echo "AAPL MSFT GOOGL" | yf quote --read-stdin

# Mixed format (comma and space separated)
echo -e "AAPL,MSFT\nGOOGL AMZN" | yf download --read-stdin --lookback=30d

# From other commands
grep "^A" symbols.txt | yf quote --read-stdin
```

### Output Redirection

Separate data and messages for clean piping:

```bash
# Data goes to stdout, messages to stderr
yf quote AAPL --verbose > data.csv 2> status.log

# Silent mode (no messages)
yf quote AAPL > data.csv

# Only see errors
yf quote AAPL 2>&1 | grep -i error

# Chain commands
yf quote AAPL MSFT --format=csv | awk -F, '$3 > 0 {print $1, $3}'
```

### Verbose Mode

Use `--verbose` (or `-v`) to see progress messages:

```bash
# With progress messages
yf download AAPL MSFT GOOGL --lookback=1y --verbose

# Silent (default)
yf download AAPL MSFT GOOGL --lookback=1y
```

## Help and Documentation

Get help for any command:

```bash
# General help
yf --help

# Command-specific help
yf history --help
yf quote --help
yf indicators --help

# See all commands
yf help
```

## Next Steps

- [Complete Commands Reference](commands.md) - Detailed documentation for all commands
- [Stock Screening Guide](screening.md) - Advanced filtering and screening
- [Installation Guide](installation.md) - Build and install from source
