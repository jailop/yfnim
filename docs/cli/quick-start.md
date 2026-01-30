# Quick Start Guide - yf CLI Tool

This guide will get you started with the `yf` command-line tool in about 5 minutes.

## Prerequisites

Make sure you have installed the `yf` tool. If not, see the [Installation Guide](installation.md).

Verify installation:
```bash
yf quote AAPL
```

## Basic Commands

The `yf` tool has four main commands:

| Command | Purpose | Example |
|---------|---------|---------|
| `history` | Get historical price data | `yf history AAPL --lookback 30d` |
| `quote` | Get current price quotes | `yf quote AAPL MSFT` |
| `compare` | Compare multiple stocks | `yf compare AAPL MSFT GOOGL` |
| `screen` | Filter stocks by criteria | `yf screen AAPL MSFT --criteria value` |

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
yf history AAPL --lookback 7d

# Last 30 days
yf history AAPL --lookback 30d

# Last 6 months
yf history AAPL --lookback 180d

# Specific date range
yf history AAPL --start 2024-01-01 --end 2024-01-31
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
yf screen AAPL MSFT GOOGL AMZN --criteria value     # Value stocks
yf screen AAPL MSFT GOOGL AMZN --criteria growth    # Growth stocks
yf screen AAPL MSFT GOOGL AMZN --criteria dividend  # High dividend

# Custom filter
yf screen AAPL MSFT GOOGL --criteria custom --where "price > 200"
yf screen AAPL MSFT GOOGL --criteria custom --where "pe < 30 and yield > 1"
```

## Output Formats

Change the output format with `--format`:

```bash
# Table format (default, human-readable)
yf quote AAPL --format table

# CSV format (for spreadsheets)
yf quote AAPL --format csv

# JSON format (for scripts/programs)
yf quote AAPL --format json

# TSV format (tab-separated)
yf quote AAPL --format tsv

# Minimal format (values only)
yf quote AAPL --format minimal
```

## Common Use Cases

### Export to CSV File

```bash
yf history AAPL --lookback 30d --format csv > aapl_data.csv
```

### Monitor Multiple Stocks

```bash
yf quote AAPL MSFT GOOGL AMZN TSLA
```

### Get Intraday Data

```bash
# Hourly data for last 3 days
yf history AAPL --lookback 3d --interval 1h

# 5-minute data for today
yf history AAPL --lookback 1d --interval 5m
```

### Filter High-Volume Stocks

```bash
yf screen AAPL MSFT GOOGL AMZN TSLA NVDA \
  --criteria custom \
  --where "volume > 50000000"
```

### Find Gainers

```bash
yf screen AAPL MSFT GOOGL AMZN TSLA \
  --criteria custom \
  --where "changepercent > 2"
```

## Intervals

Historical data supports different time intervals:

```bash
# Intraday
yf history AAPL --lookback 1d --interval 1m   # 1-minute bars
yf history AAPL --lookback 5d --interval 5m   # 5-minute bars
yf history AAPL --lookback 7d --interval 1h   # 1-hour bars

# Daily and longer
yf history AAPL --lookback 90d --interval 1d  # Daily bars (default)
yf history AAPL --lookback 365d --interval 1wk  # Weekly bars
yf history AAPL --lookback 1825d --interval 1mo # Monthly bars (5 years)
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
  --criteria custom \
  --where "changepercent > 0"
```

### Research a Stock

```bash
# Current quote
yf quote AAPL

# Recent price history
yf history AAPL --lookback 30d

# Compare to competitors
yf compare AAPL MSFT GOOGL
```

### Export for Analysis

```bash
# Get data in different formats
yf history AAPL --lookback 90d --format csv > data.csv
yf quote AAPL MSFT GOOGL --format json > quotes.json
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
