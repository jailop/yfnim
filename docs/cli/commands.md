# Commands Reference

Complete reference for all `yf` CLI commands and options.

## Table of Contents

- [Global Options](#global-options)
- [history Command](#history-command)
- [quote Command](#quote-command)
- [compare Command](#compare-command)
- [screen Command](#screen-command)
- [Common Examples](#common-examples)

## Global Options

These options work with all commands:

| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--format <type>` | `-f` | Output format: table, csv, json, tsv, minimal | table |
| `--quiet` | `-q` | Suppress extra output | false |
| `--no-header` | | Don't print column headers | false |
| `--no-color` | | Disable colored output | false |
| `--precision <n>` | `-p` | Decimal places for numbers (0-10) | 2 |
| `--date-format <type>` | | Date format: iso, us, unix, full | iso |
| `--refresh` | | Bypass cache and fetch fresh data | false |
| `--debug` | | Show debug information | false |
| `--help` | `-h` | Show help for command | |
| `--version` | `-v` | Show version information | |

### Format Options

**table** (default)
- Human-readable table format
- Aligned columns
- Colored output (if supported)

**csv**
- Comma-separated values
- Header row included (use `--no-header` to exclude)
- Good for spreadsheets

**json**
- JSON object or array
- Good for programmatic processing
- Can be piped to `jq`

**tsv**
- Tab-separated values
- Good for piping to Unix tools

**minimal**
- Just the values, no formatting
- Space-separated
- Good for parsing in scripts

### Date Format Options

**iso** (default): `2024-01-15`  
**us**: `01/15/2024`  
**unix**: `1705276800` (Unix timestamp)  
**full**: `2024-01-15 14:30:00`

## history Command

Retrieve historical OHLCV (Open, High, Low, Close, Volume) data.

### Synopsis

```bash
yf history <SYMBOL> [OPTIONS]
```

### Arguments

`SYMBOL` - Stock ticker symbol (e.g., AAPL, MSFT)

### Options

| Option | Short | Description | Default | Example |
|--------|-------|-------------|---------|---------|
| `--interval <type>` | `-i` | Time interval | 1d | --interval 1h |
| `--lookback <period>` | `-l` | Lookback period | 7d | --lookback 30d |
| `--start <date>` | `-s` | Start date | | --start 2024-01-01 |
| `--end <date>` | `-e` | End date | today | --end 2024-12-31 |

### Intervals

| Interval | Description | Max History | Use Case |
|----------|-------------|-------------|----------|
| `1m` | 1 minute | ~7 days | Day trading |
| `5m` | 5 minutes | ~60 days | Intraday analysis |
| `15m` | 15 minutes | ~60 days | Short-term patterns |
| `30m` | 30 minutes | ~60 days | Intraday trends |
| `1h` | 1 hour | ~2 years | Multi-day analysis |
| `1d` | 1 day (default) | Many years | General analysis |
| `1wk` | 1 week | Many years | Long-term trends |
| `1mo` | 1 month | Many years | Historical research |

### Lookback Period Format

Format: `<number><unit>` where unit is:
- `d` - days
- `w` - weeks  
- `m` - months
- `y` - years

Examples: `7d`, `30d`, `6m`, `1y`

### Date Format

Dates can be specified as:
- ISO format: `YYYY-MM-DD` (e.g., `2024-01-15`)
- US format: `MM/DD/YYYY` (e.g., `01/15/2024`)

### Examples

```bash
# Last 7 days (default)
yf history AAPL

# Last 30 days with daily interval
yf history AAPL --lookback 30d

# Last 3 days with hourly data
yf history AAPL --lookback 3d --interval 1h

# Specific date range
yf history AAPL --start 2024-01-01 --end 2024-01-31

# Last year of weekly data
yf history AAPL --lookback 1y --interval 1wk

# Export to CSV
yf history AAPL --lookback 30d --format csv > data.csv

# JSON format with no header
yf history AAPL --lookback 7d --format json --no-header
```

### Output Columns

- **Date** - Trading date/time
- **Open** - Opening price
- **High** - Highest price
- **Low** - Lowest price
- **Close** - Closing price
- **Volume** - Trading volume

### Notes

- Intraday intervals (1m, 5m, etc.) have limited historical data
- 1-minute data typically available for last ~7 days only
- Weekends and holidays excluded for stock data
- Dates are in exchange local time

## quote Command

Get current market data for one or more symbols.

### Synopsis

```bash
yf quote <SYMBOL> [SYMBOL...] [OPTIONS]
```

### Arguments

`SYMBOL` - One or more ticker symbols

### Options

All global options apply. No command-specific options.

### Examples

```bash
# Single quote
yf quote AAPL

# Multiple quotes
yf quote AAPL MSFT GOOGL

# CSV format for spreadsheet
yf quote AAPL MSFT --format csv > quotes.csv

# JSON for processing
yf quote AAPL --format json | jq '.regularMarketPrice'

# International stocks
yf quote AAPL SHOP.TO BP.L

# Cryptocurrencies
yf quote BTC-USD ETH-USD

# Minimal format (just values)
yf quote AAPL --format minimal
```

### Output Fields

**Identification:**
- Symbol
- Name

**Price Data:**
- Price - Current/last price
- Change - Absolute price change
- Change% - Percentage change
- Open - Opening price
- High - Day's high
- Low - Day's low
- Previous Close

**Volume:**
- Volume - Today's volume
- Avg Volume - Average volume

**Market Data:**
- Market Cap - Market capitalization
- P/E Ratio - Price-to-earnings ratio
- Dividend Yield - Annual dividend yield
- 52W High - 52-week high
- 52W Low - 52-week low

Note: Available fields vary by security type and format.

### Symbol Formats

**US Stocks:** `AAPL`, `MSFT`, `GOOGL`  
**Canadian:** `SHOP.TO` (Toronto)  
**UK:** `BP.L` (London)  
**Japanese:** `6758.T` (Tokyo)  
**Crypto:** `BTC-USD`, `ETH-USD`

### Notes

- Data may be delayed 15-20 minutes
- Quote data is cached for 5 minutes by default
- Use `--refresh` to bypass cache
- Not all fields available for all securities

## compare Command

Compare key metrics across multiple stocks side-by-side.

### Synopsis

```bash
yf compare <SYMBOL> <SYMBOL> [SYMBOL...] [OPTIONS]
```

### Arguments

At least 2 ticker symbols required.

### Options

All global options apply. No command-specific options.

### Examples

```bash
# Compare tech stocks
yf compare AAPL MSFT GOOGL

# Compare with different format
yf compare AAPL MSFT GOOGL --format csv

# Compare many stocks
yf compare AAPL MSFT GOOGL AMZN TSLA NVDA META

# Export comparison
yf compare AAPL MSFT --format json > comparison.json
```

### Output Columns

- Symbol
- Price
- Change%
- Volume
- Market Cap
- P/E Ratio
- 52W Low
- 52W High

### Notes

- Makes comparison easier than viewing quotes separately
- Shows only key metrics (use `quote` for full details)
- Good for quick competitive analysis

## screen Command

Filter stocks based on criteria or custom expressions.

### Synopsis

```bash
yf screen <SYMBOL> [SYMBOL...] --criteria <type> [OPTIONS]
```

### Arguments

`SYMBOL` - One or more ticker symbols to screen

### Options

| Option | Short | Description | Required |
|--------|-------|-------------|----------|
| `--criteria <type>` | `-c` | Screening criteria type | Yes |
| `--where <expr>` | `-w` | Custom filter expression | With custom criteria |

### Predefined Criteria

**value**
- Low P/E ratio (< 20)
- High dividend yield (> 2%)
- Focuses on undervalued stocks

**growth**
- Positive price change today
- Focuses on momentum

**dividend**
- High dividend yield (> 2%)
- Focuses on income stocks

**momentum**
- Strong positive change (> 2%)
- High relative volume
- Focuses on strong movers

**custom**
- Uses `--where` expression
- Define your own criteria

### Custom Expressions

When using `--criteria custom`, provide a `--where` expression.

#### Syntax

```
<field> <operator> <value>
```

**Operators:**
- `<` - Less than
- `>` - Greater than
- `<=` - Less than or equal
- `>=` - Greater than or equal
- `=` - Equal to
- `!=` - Not equal to

**Boolean Operators:**
- `and` - Both conditions must be true
- `or` - Either condition must be true

**Parentheses:** `(` `)` for grouping (in development)

#### Available Fields

**Price Fields:**
- `price` - Current price
- `change` - Absolute change
- `changepercent` - Percentage change
- `open` - Opening price
- `high` - Day high
- `low` - Day low
- `prevclose` - Previous close

**52-Week Fields:**
- `52whigh` - 52-week high
- `52wlow` - 52-week low
- `52wchangepercent` - 52-week change %

**Volume Fields:**
- `volume` - Current volume
- `avgvolume` - Average volume

**Valuation Fields:**
- `pe` - P/E ratio
- `yield` - Dividend yield %
- `marketcap` - Market capitalization

### Examples

```bash
# Predefined: Value stocks
yf screen AAPL MSFT JPM KO PG --criteria value

# Predefined: Growth stocks
yf screen AAPL MSFT GOOGL NVDA --criteria growth

# Predefined: Dividend stocks
yf screen T VZ XOM CVX --criteria dividend

# Custom: Price filter
yf screen AAPL MSFT GOOGL --criteria custom --where "price > 200"

# Custom: Multiple conditions (AND)
yf screen AAPL MSFT GOOGL JPM --criteria custom \
  --where "pe < 30 and yield > 1"

# Custom: Multiple conditions (OR)
yf screen AAPL MSFT GOOGL --criteria custom \
  --where "changepercent > 2 or changepercent < -2"

# Custom: Complex expression
yf screen AAPL MSFT GOOGL AMZN TSLA --criteria custom \
  --where "price > 100 and volume > 10000000 and changepercent > 0"

# Custom: Value investing filter
yf screen AAPL MSFT JPM BAC WFC --criteria custom \
  --where "pe < 20 and yield > 2 and price > 50"

# Custom: Near 52-week high
yf screen AAPL MSFT GOOGL NVDA --criteria custom \
  --where "price >= 52whigh * 0.95"

# Export results
yf screen AAPL MSFT GOOGL --criteria value --format csv > value_stocks.csv

# Get just the symbols that pass
yf screen AAPL MSFT GOOGL AMZN TSLA --criteria custom \
  --where "changepercent > 1" --format minimal
```

### Expression Examples

```bash
# Price-based
"price > 100"
"price < 50"
"price > 100 and price < 500"

# Change-based
"changepercent > 2"
"changepercent < -1"
"change > 5"

# Volume-based
"volume > 50000000"
"volume > avgvolume * 2"

# Valuation-based
"pe < 20"
"yield > 3"
"pe < 15 and yield > 2"

# Combined filters
"price > 200 and changepercent > 0 and volume > 10000000"
"pe < 25 and yield > 1 and price > 50"
"changepercent > 1 or volume > avgvolume * 2"
```

### Notes

- Only symbols that match criteria are returned
- If no stocks match, empty result is returned
- Custom expressions are case-insensitive
- Field names can use aliases (e.g., `changepct` for `changepercent`)

## Common Examples

### Data Export

```bash
# Export historical data to CSV
yf history AAPL --lookback 90d --format csv > aapl_90d.csv

# Export quotes to JSON
yf quote AAPL MSFT GOOGL --format json > quotes.json

# Export comparison to TSV
yf compare AAPL MSFT GOOGL --format tsv > comparison.tsv
```

### Piping

```bash
# Use with jq
yf quote AAPL --format json | jq '.regularMarketPrice'

# Use with awk
yf history AAPL --lookback 30d --format csv | \
  awk -F, 'NR>1 && $5>220 {print $1, $5}'

# Use with grep
yf quote AAPL MSFT GOOGL | grep -i "market"

# Sort by change percentage
yf quote AAPL MSFT GOOGL AMZN --format csv | \
  tail -n +2 | sort -t, -k3 -nr
```

### Monitoring

```bash
# Watch a stock (update every 60 seconds)
watch -n 60 yf quote AAPL

# Monitor multiple stocks with refresh
watch -n 60 'yf quote AAPL MSFT GOOGL --refresh'

# Check portfolio
yf quote $(cat portfolio.txt)
```

### Screening Workflows

```bash
# Find value stocks and export
yf screen AAPL MSFT JPM BAC GS --criteria value --format csv > value.csv

# Find stocks up >1% today
yf screen AAPL MSFT GOOGL AMZN TSLA --criteria custom \
  --where "changepercent > 1" --format minimal

# Complex screening pipeline
cat watchlist.txt | xargs yf quote --format csv | \
  tail -n +2 | awk -F, '$3 > 2' | cut -d, -f1
```

### International Markets

```bash
# North American stocks
yf quote AAPL SHOP.TO MXN.TO

# European stocks
yf quote BP.L VOD.L RIO.L

# Asian stocks
yf quote 9984.T 6758.T

# Global comparison
yf compare AAPL SHOP.TO BP.L 9984.T
```

## Error Messages

**"Symbol not found"**
- Symbol doesn't exist or is delisted
- Check symbol format on Yahoo Finance website

**"No data returned"**
- Date range is invalid
- Requesting future dates
- 1m interval used with old dates

**"Connection error"**
- No internet connection
- Yahoo Finance is down
- Firewall blocking requests

**"Invalid expression"**
- Syntax error in custom screening expression
- Check field names and operators

## Exit Codes

- `0` - Success
- `1` - Command error (invalid arguments, API failure, etc.)

## See Also

- [Quick Start Guide](quick-start.md) - Get started quickly
- [Screening Guide](screening.md) - Advanced screening techniques
- [Installation Guide](installation.md) - Installation instructions
- [Example Scripts](../../examples/cli/) - Working examples
