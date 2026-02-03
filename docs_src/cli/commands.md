# Commands Reference

Complete reference for all `yf` CLI commands and options.

## Table of Contents

- [Global Options](#global-options)
- [history Command](#history-command)
- [quote Command](#quote-command)
- [compare Command](#compare-command)
- [screen Command](#screen-command)
- [dividends Command](#dividends-command)
- [splits Command](#splits-command)
- [actions Command](#actions-command)
- [download Command](#download-command)
- [indicators Command](#indicators-command)
- [Common Examples](#common-examples)

## Global Options

These options work with all commands:

| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--format=<type>` | `-f` | Output format: table, csv, json, tsv, minimal | table |
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
| `--interval <type>` | `-i` | Time interval | 1d | --interval=1h |
| `--lookback <period>` | `-l` | Lookback period | 7d | --lookback=30d |
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
yf history --symbol=AAPL --lookback=30d

# Last 3 days with hourly data
yf history --symbol=AAPL --lookback=3d --interval=1h

# Specific date range
yf history --symbol=AAPL --start 2024-01-01 --end 2024-01-31

# Last year of weekly data
yf history --symbol=AAPL --lookback=1y --interval=1wk

# Export to CSV
yf history --symbol=AAPL --lookback=30d --format=csv > data.csv

# JSON format with no header
yf history --symbol=AAPL --lookback=7d --format=json --no-header
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
yf quote AAPL MSFT --format=csv > quotes.csv

# JSON for processing
yf quote AAPL --format=json | jq '.regularMarketPrice'

# International stocks
yf quote AAPL SHOP.TO BP.L

# Cryptocurrencies
yf quote BTC-USD ETH-USD

# Minimal format (just values)
yf quote AAPL --format=minimal
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
yf compare AAPL MSFT GOOGL --format=csv

# Compare many stocks
yf compare AAPL MSFT GOOGL AMZN TSLA NVDA META

# Export comparison
yf compare AAPL MSFT --format=json > comparison.json
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
yf screen <SYMBOL> [SYMBOL...] --criteria=<type> [OPTIONS]
```

### Arguments

`SYMBOL` - One or more ticker symbols to screen

### Options

| Option | Short | Description | Required |
|--------|-------|-------------|----------|
| `--criteria=<type>` | `-c` | Screening criteria type | Yes |
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

When using `--criteria=custom`, provide a `--where` expression.

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
yf screen AAPL MSFT JPM KO PG --criteria=value

# Predefined: Growth stocks
yf screen AAPL MSFT GOOGL NVDA --criteria=growth

# Predefined: Dividend stocks
yf screen T VZ XOM CVX --criteria=dividend

# Custom: Price filter
yf screen AAPL MSFT GOOGL --criteria=custom --where "price > 200"

# Custom: Multiple conditions (AND)
yf screen AAPL MSFT GOOGL JPM --criteria=custom \
  --where "pe < 30 and yield > 1"

# Custom: Multiple conditions (OR)
yf screen AAPL MSFT GOOGL --criteria=custom \
  --where "changepercent > 2 or changepercent < -2"

# Custom: Complex expression
yf screen AAPL MSFT GOOGL AMZN TSLA --criteria=custom \
  --where "price > 100 and volume > 10000000 and changepercent > 0"

# Custom: Value investing filter
yf screen AAPL MSFT JPM BAC WFC --criteria=custom \
  --where "pe < 20 and yield > 2 and price > 50"

# Custom: Near 52-week high
yf screen AAPL MSFT GOOGL NVDA --criteria=custom \
  --where "price >= 52whigh * 0.95"

# Export results
yf screen AAPL MSFT GOOGL --criteria=value --format=csv > value_stocks.csv

# Get just the symbols that pass
yf screen AAPL MSFT GOOGL AMZN TSLA --criteria=custom \
  --where "changepercent > 1" --format=minimal
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

## dividends Command

Retrieve historical dividend payments for a stock.

### Synopsis

```bash
yf dividends <SYMBOL> [OPTIONS]
```

### Arguments

`SYMBOL` - Stock ticker symbol (e.g., AAPL, MSFT, JNJ)

### Options

| Option | Short | Description | Default | Example |
|--------|-------|-------------|---------|---------|
| `--start <date>` | `-s` | Start date | | --start 2020-01-01 |
| `--end <date>` | `-e` | End date | today | --end 2023-12-31 |
| `--lookback <period>` | `-l` | Lookback period | max | --lookback=5y |

### Lookback Period Format

Same as history command: `<number><unit>` where unit is:
- `d` - days
- `w` - weeks
- `m` - months
- `y` - years
- `max` - all available history

Examples: `1y`, `5y`, `10y`, `max`

### Examples

```bash
# Get all dividend history
yf dividends AAPL

# Get dividends for last 5 years
yf dividends --symbol=AAPL --lookback=5y

# Get dividends for specific date range
yf dividends --symbol=JNJ --start 2020-01-01 --end 2023-12-31

# Export to CSV
yf dividends --symbol=MSFT --format=csv > msft_dividends.csv

# JSON format for processing
yf dividends --symbol=KO --format=json

# Multiple stocks (use a loop)
for symbol in AAPL MSFT JNJ; do
  echo "=== $symbol ===" 
  yf dividends $symbol --lookback=1y
done
```

### Output Columns

- **Date** - Ex-dividend date
- **Dividend** - Dividend amount per share

### Notes

- Only shows stocks that pay dividends
- Ex-dividend date is when stock trades without dividend
- Historical dividend amounts may be adjusted for splits
- Not all stocks pay dividends (growth stocks typically don't)

## splits Command

Retrieve historical stock split events.

### Synopsis

```bash
yf splits <SYMBOL> [OPTIONS]
```

### Arguments

`SYMBOL` - Stock ticker symbol (e.g., AAPL, TSLA, NVDA)

### Options

| Option | Short | Description | Default | Example |
|--------|-------|-------------|---------|---------|
| `--start <date>` | `-s` | Start date | | --start 2020-01-01 |
| `--end <date>` | `-e` | End date | today | --end 2023-12-31 |
| `--lookback <period>` | `-l` | Lookback period | max | --lookback=10y |

### Examples

```bash
# Get all split history
yf splits AAPL

# Get splits for last 10 years
yf splits --symbol=TSLA --lookback=10y

# Get splits for specific date range
yf splits --symbol=NVDA --start 2020-01-01 --end 2024-12-31

# Export to JSON
yf splits --symbol=AAPL --format=json > aapl_splits.json

# Export to CSV
yf splits --symbol=GOOGL --format=csv > googl_splits.csv
```

### Output Columns

- **Date** - Split effective date
- **Split** - Split ratio (e.g., "2:1", "3:1", "4:1")

### Split Ratio Format

- **2:1** - Each share becomes 2 shares (price halves)
- **3:1** - Each share becomes 3 shares (price divided by 3)
- **1:2** - Reverse split - 2 shares become 1 (price doubles)

### Notes

- Stock splits don't change company value
- Historical prices are adjusted for splits
- Not all stocks have split history
- Reverse splits (1:2, 1:5, etc.) are less common

## actions Command

Retrieve all corporate actions (dividends and splits combined).

### Synopsis

```bash
yf actions <SYMBOL> [OPTIONS]
```

### Arguments

`SYMBOL` - Stock ticker symbol

### Options

| Option | Short | Description | Default | Example |
|--------|-------|-------------|---------|---------|
| `--start <date>` | `-s` | Start date | | --start 2020-01-01 |
| `--end <date>` | `-e` | End date | today | --end 2023-12-31 |
| `--lookback <period>` | `-l` | Lookback period | max | --lookback=5y |

### Examples

```bash
# Get all corporate actions
yf actions AAPL

# Get actions for last 5 years
yf actions --symbol=MSFT --lookback=5y

# Get actions for specific date range
yf actions --symbol=GOOGL --start 2020-01-01 --end 2023-12-31

# Export to CSV
yf actions --symbol=JNJ --format=csv > jnj_actions.csv

# JSON format
yf actions --symbol=KO --format=json
```

### Output Columns

- **Date** - Action date
- **Dividends** - Dividend amount (if applicable)
- **Splits** - Split ratio (if applicable)

### Notes

- Combines both dividends and splits in chronological order
- Shows all corporate actions that affect shareholders
- Convenient for getting complete corporate action history
- Use specific commands (`dividends` or `splits`) if you need only one type

## download Command

Batch download historical data for multiple symbols efficiently.

### Synopsis

```bash
yf download <SYMBOL> [SYMBOL...] [OPTIONS]
```

### Arguments

`SYMBOL` - One or more ticker symbols (space or comma-separated)

### Options

| Option | Short | Description | Default | Example |
|--------|-------|-------------|---------|---------|
| `--interval <type>` | `-i` | Time interval | 1d | --interval=1wk |
| `--lookback <period>` | `-l` | Lookback period | 30d | --lookback=1y |
| `--start <date>` | `-s` | Start date | | --start 2024-01-01 |
| `--end <date>` | `-e` | End date | today | --end 2024-12-31 |

### Intervals

Same as history command: `1d` (default), `1wk`, `1mo`

### Examples

```bash
# Download 30 days for multiple symbols
yf download AAPL MSFT GOOGL --lookback=30d

# Download with comma-separated symbols
yf download AAPL,MSFT,GOOGL --lookback=1y

# Download with specific date range
yf download AAPL MSFT --start 2024-01-01 --end 2024-12-31

# Export to CSV
yf download AAPL MSFT GOOGL --lookback=90d --format=csv > data.csv

# Weekly data
yf download AAPL MSFT --lookback=1y --interval=1wk

# Download from file list
cat symbols.txt | xargs yf download --lookback=1y

# Download large portfolio
yf download $(cat portfolio.txt) --lookback=30d --format=csv > portfolio_data.csv
```

### Output Format

The output contains data for all symbols with a `Symbol` column to identify each stock.

### Notes

- More efficient than running `history` multiple times
- All symbols are fetched with same date range and interval
- Output includes all symbols combined (use `--format=csv` to process)
- Failed symbols are logged but don't stop other downloads
- Good for portfolio analysis and batch data collection

## indicators Command

Calculate technical indicators for analysis and trading signals.

### Synopsis

```bash
yf indicators <SYMBOL> [OPTIONS]
```

### Arguments

`SYMBOL` - Stock ticker symbol to analyze

### Options

| Option | Description | Default | Example |
|--------|-------------|---------|---------|
| `--lookback <period>` | Lookback period | 1y | --lookback=6mo |
| `--interval <type>` | Data interval | 1d | --interval=1wk |
| `--start <date>` | Start date | | --start 2024-01-01 |
| `--end <date>` | End date | today | --end 2024-12-31 |

### Moving Averages

| Option | Description | Example |
|--------|-------------|---------|
| `--sma <periods>` | Simple Moving Averages | --sma 20,50,200 |
| `--ema <periods>` | Exponential Moving Averages | --ema 12,26 |
| `--wma <periods>` | Weighted Moving Averages | --wma 10,20 |

### Momentum Indicators

| Option | Description | Default Period |
|--------|-------------|----------------|
| `--rsi [period]` | Relative Strength Index | 14 |
| `--macd` | MACD (Moving Average Convergence Divergence) | 12,26,9 |
| `--stochastic` | Stochastic Oscillator | 14,3,3 |

### Volatility Indicators

| Option | Description | Default Period |
|--------|-------------|----------------|
| `--bb [period]` | Bollinger Bands | 20 |
| `--atr [period]` | Average True Range | 14 |

### Trend Indicators

| Option | Description | Default Period |
|--------|-------------|----------------|
| `--adx [period]` | Average Directional Index | 14 |

### Volume Indicators

| Option | Description |
|--------|-------------|
| `--obv` | On-Balance Volume |
| `--vwap` | Volume Weighted Average Price |

### Special Options

| Option | Description |
|--------|-------------|
| `--all` | Calculate all indicators with default periods |

### Examples

```bash
# Calculate common moving averages
yf indicators --symbol=AAPL --sma 20,50,200

# EMA for short-term trading
yf indicators --symbol=AAPL --ema 12,26

# RSI for momentum analysis
yf indicators --symbol=AAPL --rsi

# RSI with custom period
yf indicators --symbol=AAPL --rsi 10

# MACD and RSI together
yf indicators --symbol=AAPL --rsi --macd

# Bollinger Bands for volatility
yf indicators --symbol=AAPL --bb

# Bollinger Bands with custom period
yf indicators --symbol=AAPL --bb 30

# Multiple indicators
yf indicators --symbol=AAPL --sma 50,200 --rsi --macd --bb

# All indicators with defaults
yf indicators --symbol=AAPL --all

# Custom lookback period
yf indicators --symbol=AAPL --all --lookback=6mo

# Export to CSV for charting
yf indicators --symbol=AAPL --sma 20,50,200 --rsi --macd --format=csv > aapl_indicators.csv

# Weekly intervals
yf indicators --symbol=AAPL --sma 10,20,50 --interval=1wk --lookback=2y
```

### Indicator Descriptions

**Simple Moving Average (SMA)**
- Average price over N periods
- Common periods: 20 (short), 50 (medium), 200 (long-term)
- Crossovers signal trend changes

**Exponential Moving Average (EMA)**
- Weighted average emphasizing recent prices
- More responsive than SMA
- Common for MACD calculation (12, 26)

**Relative Strength Index (RSI)**
- Momentum oscillator (0-100)
- > 70: Overbought
- < 30: Oversold
- Default period: 14

**MACD (Moving Average Convergence Divergence)**
- Trend-following momentum indicator
- Shows relationship between two EMAs (12, 26)
- Signal line (9-period EMA) for buy/sell signals

**Bollinger Bands**
- Volatility indicator
- Middle band: SMA (typically 20)
- Upper/Lower bands: ±2 standard deviations
- Price touching bands indicates extreme levels

**Average True Range (ATR)**
- Volatility indicator
- Measures price range movement
- Higher values = more volatility
- Default period: 14

**Stochastic Oscillator**
- Momentum indicator (0-100)
- Compares closing price to price range
- > 80: Overbought
- < 20: Oversold

**Average Directional Index (ADX)**
- Trend strength indicator (0-100)
- < 20: Weak trend
- 20-40: Moderate trend
- > 40: Strong trend
- Doesn't indicate direction

**On-Balance Volume (OBV)**
- Volume-based indicator
- Rising OBV = buying pressure
- Falling OBV = selling pressure
- Confirms price trends

**Volume Weighted Average Price (VWAP)**
- Average price weighted by volume
- Intraday trading benchmark
- Price above VWAP: Bullish
- Price below VWAP: Bearish

### Output Columns

Output includes:
- Date
- OHLCV data (Open, High, Low, Close, Volume)
- All calculated indicators

### Notes

- Indicators require sufficient historical data
- More periods = more historical data needed
- SMA(200) needs at least 200 days of data
- Use appropriate intervals (1d for daily, 1wk for weekly)
- Combine multiple indicators for better signals
- Export to CSV/JSON for further analysis or charting

## Common Examples

### Data Export

```bash
# Export historical data to CSV
yf history --symbol=AAPL --lookback=90d --format=csv > aapl_90d.csv

# Export quotes to JSON
yf quote AAPL MSFT GOOGL --format=json > quotes.json

# Export comparison to TSV
yf compare AAPL MSFT GOOGL --format=tsv > comparison.tsv
```

### Piping

```bash
# Use with jq
yf quote AAPL --format=json | jq '.regularMarketPrice'

# Use with awk
yf history --symbol=AAPL --lookback=30d --format=csv | \
  awk -F, 'NR>1 && $5>220 {print $1, $5}'

# Use with grep
yf quote AAPL MSFT GOOGL | grep -i "market"

# Sort by change percentage
yf quote AAPL MSFT GOOGL AMZN --format=csv | \
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
yf screen AAPL MSFT JPM BAC GS --criteria=value --format=csv > value.csv

# Find stocks up >1% today
yf screen AAPL MSFT GOOGL AMZN TSLA --criteria=custom \
  --where "changepercent > 1" --format=minimal

# Complex screening pipeline
cat watchlist.txt | xargs yf quote --format=csv | \
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

### Dividend Analysis

```bash
# Research dividend stocks
yf dividends --symbol=JNJ --lookback=10y
yf dividends --symbol=KO --lookback=10y --format=csv

# Compare dividend histories
yf dividends --symbol=JNJ --lookback=5y > jnj_div.txt
yf dividends --symbol=PG --lookback=5y > pg_div.txt

# Export for spreadsheet analysis
yf dividends --symbol=AAPL MSFT JNJ KO --format=csv > dividends.csv

# Track dividend growth
yf dividends --symbol=AAPL --format=json | jq '.[] | {date, dividend}'
```

### Corporate Actions Tracking

```bash
# View all actions for a stock
yf actions --symbol=AAPL --lookback=10y

# Check recent splits
yf splits --symbol=TSLA --lookback=5y
yf splits --symbol=NVDA --lookback=5y

# Export actions timeline
yf actions --symbol=GOOGL --format=csv > googl_actions.csv
```

### Portfolio Analysis

```bash
# Download portfolio data
yf download AAPL MSFT GOOGL AMZN --lookback=90d --format=csv > portfolio.csv

# Get indicators for multiple stocks
for symbol in AAPL MSFT GOOGL; do
  yf indicators $symbol --rsi --macd --format=csv > ${symbol}_indicators.csv
done

# Batch technical analysis
yf indicators --symbol=AAPL --all --lookback=1y --format=csv > aapl_full_analysis.csv
```

### Technical Analysis

```bash
# Quick trend check with moving averages
yf indicators --symbol=AAPL --sma 20,50,200

# Momentum analysis
yf indicators --symbol=AAPL --rsi --macd --stochastic

# Volatility analysis
yf indicators --symbol=AAPL --bb --atr

# Complete technical picture
yf indicators --symbol=AAPL --all --format=json > aapl_technicals.json
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

## Command Summary

| Command | Purpose | Common Use |
|---------|---------|------------|
| `history` | Historical OHLCV data | Price trends, backtesting |
| `quote` | Current quotes | Market monitoring, quick checks |
| `compare` | Side-by-side comparison | Stock comparison, screening |
| `screen` | Filter by criteria | Finding opportunities |
| `dividends` | Dividend history | Income investing, dividend growth |
| `splits` | Stock splits | Historical analysis, adjustments |
| `actions` | All corporate actions | Complete event timeline |
| `download` | Batch data download | Portfolio analysis, bulk data |
| `indicators` | Technical indicators | Trading signals, analysis |
