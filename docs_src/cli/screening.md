# Stock Screening Guide

This guide covers advanced stock screening techniques using the `yf screen` command.

## Table of Contents

- [Overview](#overview)
- [Predefined Criteria](#predefined-criteria)
- [Custom Expressions](#custom-expressions)
- [Expression Syntax](#expression-syntax)
- [Common Screening Strategies](#common-screening-strategies)
- [Tips and Best Practices](#tips-and-best-practices)

## Overview

Stock screening helps you filter a list of stocks based on specific criteria. The `yf screen` command supports:

1. **Predefined criteria** - Quick filters for common strategies
2. **Custom expressions** - Build your own filtering logic

### Basic Usage

```bash
yf screen <SYMBOLS...> --criteria=<type> [--where <expression>]
```

## Predefined Criteria

Predefined criteria provide quick filtering without writing expressions.

### Value Stocks

Focuses on potentially undervalued stocks.

**Criteria:**
- P/E ratio < 20
- Dividend yield > 2%

```bash
yf screen AAPL MSFT JPM BAC GS WFC KO PG --criteria=value
```

**Use when:** Looking for stocks trading below market average valuation with dividend income.

### Growth Stocks

Focuses on stocks with positive momentum.

**Criteria:**
- Positive price change today (change% > 0)

```bash
yf screen AAPL MSFT GOOGL AMZN TSLA NVDA --criteria=growth
```

**Use when:** Looking for stocks with upward momentum.

### Dividend Stocks

Focuses on income-generating stocks.

**Criteria:**
- Dividend yield > 2%

```bash
yf screen T VZ XOM CVX PFE JNJ --criteria=dividend
```

**Use when:** Building an income portfolio.

### Momentum Stocks

Focuses on strong performers with high activity.

**Criteria:**
- Price change > 2%
- Volume above average

```bash
yf screen AAPL MSFT GOOGL AMZN TSLA NVDA META --criteria=momentum
```

**Use when:** Looking for stocks with strong recent performance.

## Custom Expressions

Custom expressions let you define your own screening logic.

### Basic Format

```bash
yf screen SYMBOLS... --criteria=custom --where "EXPRESSION"
```

### Simple Expression

```bash
yf screen AAPL MSFT GOOGL --criteria=custom --where "price > 200"
```

This returns only stocks priced above $200.

## Expression Syntax

### Comparison Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `<` | Less than | `pe < 20` |
| `>` | Greater than | `price > 100` |
| `<=` | Less than or equal | `pe <= 20` |
| `>=` | Greater than or equal | `yield >= 2` |
| `=` | Equal to | `price = 150` |
| `!=` | Not equal to | `volume != 0` |

### Boolean Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `and` | Both conditions must be true | `pe < 20 and yield > 2` |
| `or` | Either condition must be true | `pe < 15 or yield > 3` |

### Available Fields

**Price Fields:**
- `price` - Current market price
- `change` - Absolute price change
- `changepercent` - Percentage change
- `open` - Opening price
- `high` - Day's high price
- `low` - Day's low price
- `prevclose` - Previous closing price

**52-Week Fields:**
- `52whigh` - 52-week high
- `52wlow` - 52-week low  
- `52wchangepercent` - % change from 52-week low

**Volume Fields:**
- `volume` - Trading volume today
- `avgvolume` - Average daily volume

**Valuation Fields:**
- `pe` - Price-to-earnings ratio
- `yield` - Dividend yield (%)
- `marketcap` - Market capitalization

### Arithmetic in Expressions

You can use basic arithmetic:

```bash
# Near 52-week high (within 5%)
yf screen SYMBOLS --criteria=custom --where "price >= 52whigh * 0.95"

# Volume above 2x average
yf screen SYMBOLS --criteria=custom --where "volume > avgvolume * 2"

# Price range check
yf screen SYMBOLS --criteria=custom --where "price > 52wlow * 1.2 and price < 52whigh * 0.9"
```

## Common Screening Strategies

### Value Investing

Find undervalued stocks with good fundamentals.

```bash
# Low P/E with dividends
yf screen AAPL MSFT JPM BAC WFC GS \
  --criteria=custom \
  --where "pe < 20 and yield > 2"

# Cheap stocks with positive change
yf screen AAPL MSFT JPM BAC WFC \
  --criteria=custom \
  --where "pe < 15 and changepercent > 0 and price > 10"

# Deep value with margin of safety
yf screen AAPL MSFT JPM BAC WFC KO PG \
  --criteria=custom \
  --where "pe < 12 and yield > 3 and price < 52whigh * 0.7"
```

### Growth Investing

Find stocks with strong momentum.

```bash
# Strong daily gainers
yf screen AAPL MSFT GOOGL AMZN TSLA NVDA \
  --criteria=custom \
  --where "changepercent > 2"

# Positive momentum with volume
yf screen AAPL MSFT GOOGL AMZN TSLA \
  --criteria=custom \
  --where "changepercent > 1 and volume > 10000000"

# Near highs with momentum
yf screen AAPL MSFT GOOGL NVDA AMD \
  --criteria=custom \
  --where "price >= 52whigh * 0.9 and changepercent > 0"
```

### Income Investing

Find dividend-paying stocks.

```bash
# High-yield dividend stocks
yf screen T VZ XOM CVX PFE JNJ KO PG \
  --criteria=custom \
  --where "yield > 3"

# Dividend growth
yf screen T VZ XOM CVX PFE JNJ \
  --criteria=custom \
  --where "yield > 2 and changepercent > 0"

# Quality dividends
yf screen T VZ XOM CVX JNJ KO PG \
  --criteria=custom \
  --where "yield > 2 and pe < 25 and price > 50"
```

### Technical Analysis

Find technical setups.

```bash
# Breakout candidates (near 52-week high)
yf screen AAPL MSFT GOOGL NVDA AMD \
  --criteria=custom \
  --where "price >= 52whigh * 0.95"

# Oversold (near 52-week low)
yf screen AAPL MSFT GOOGL AMZN \
  --criteria=custom \
  --where "price <= 52wlow * 1.1"

# High volume breakout
yf screen AAPL MSFT GOOGL TSLA NVDA \
  --criteria=custom \
  --where "changepercent > 2 and volume > avgvolume * 1.5"
```

### Volatility Plays

Find volatile stocks.

```bash
# Large movers (up or down)
yf screen AAPL MSFT GOOGL AMZN TSLA \
  --criteria=custom \
  --where "changepercent > 3 or changepercent < -3"

# High volume activity
yf screen AAPL MSFT GOOGL AMZN TSLA NVDA \
  --criteria=custom \
  --where "volume > 50000000"
```

### Price Range Filters

Find stocks in specific price ranges.

```bash
# Affordable stocks under $50
yf screen AAPL MSFT GOOGL AMZN T VZ \
  --criteria=custom \
  --where "price < 50 and price > 10"

# Mid-cap range
yf screen AAPL MSFT GOOGL AMZN \
  --criteria=custom \
  --where "price > 100 and price < 300"

# High-priced stocks
yf screen AAPL MSFT GOOGL AMZN TSLA \
  --criteria=custom \
  --where "price > 200"
```

## Tips and Best Practices

### 1. Start with a Universe

Define your stock universe before screening:

```bash
# Create a watchlist file
cat > watchlist.txt << EOF
AAPL
MSFT
GOOGL
AMZN
TSLA
NVDA
META
EOF

# Screen the watchlist
yf screen $(cat watchlist.txt) --criteria=value
```

### 2. Combine Multiple Filters

Use `and` to make filters more selective:

```bash
# Quality value stocks
yf screen SYMBOLS --criteria=custom \
  --where "pe < 20 and yield > 2 and price > 50 and volume > 1000000"
```

### 3. Use OR for Alternatives

Find stocks matching any of several criteria:

```bash
# Value OR growth
yf screen SYMBOLS --criteria=custom \
  --where "pe < 15 or changepercent > 3"
```

### 4. Export Results

Save screening results for later analysis:

```bash
# Export to CSV
yf screen SYMBOLS --criteria=value --format=csv > value_stocks.csv

# Export to JSON
yf screen SYMBOLS --criteria=custom \
  --where "pe < 20" --format=json > results.json
```

### 5. Automate Screening

Create scripts for regular screening:

```bash
#!/bin/bash
# daily_screen.sh

UNIVERSE="AAPL MSFT GOOGL AMZN TSLA NVDA META JPM BAC GS"

echo "=== Value Stocks ==="
yf screen $UNIVERSE --criteria=value

echo ""
echo "=== Growth Stocks ==="
yf screen $UNIVERSE --criteria=growth

echo ""
echo "=== Custom: Quality Growth ==="
yf screen $UNIVERSE --criteria=custom \
  --where "changepercent > 1 and volume > 10000000"
```

### 6. Iterate and Refine

Start broad, then narrow down:

```bash
# Step 1: Find all gainers
yf screen SYMBOLS --criteria=custom --where "changepercent > 0"

# Step 2: Add volume filter
yf screen SYMBOLS --criteria=custom \
  --where "changepercent > 0 and volume > 5000000"

# Step 3: Add valuation filter
yf screen SYMBOLS --criteria=custom \
  --where "changepercent > 0 and volume > 5000000 and pe < 30"
```

### 7. Mind the Data Quality

Not all fields are available for all stocks:

```bash
# Some stocks may not have P/E ratios
# Be aware that these will be filtered out
yf screen SYMBOLS --criteria=custom --where "pe < 20"

# Check results manually if needed
yf quote SYMBOL --format=json | grep -i "trailingPE"
```

### 8. Combine with Other Tools

Integrate screening with Unix tools:

```bash
# Screen and sort by change percentage
yf screen SYMBOLS --criteria=growth --format=csv | \
  tail -n +2 | sort -t, -k3 -nr

# Screen and extract symbols only
yf screen SYMBOLS --criteria=value --format=minimal | \
  cut -d' ' -f1 > value_symbols.txt

# Screen multiple times and compare
yf screen SYMBOLS --criteria=value --format=csv > value.csv
yf screen SYMBOLS --criteria=growth --format=csv > growth.csv
comm -12 <(tail -n +2 value.csv | cut -d, -f1 | sort) \
         <(tail -n +2 growth.csv | cut -d, -f1 | sort)
```

## Expression Examples Library

### By P/E Ratio

```bash
# Very cheap (P/E < 10)
"pe < 10"

# Reasonable valuation (P/E < 20)
"pe < 20"

# Growth stocks (P/E 20-40)
"pe > 20 and pe < 40"
```

### By Dividend Yield

```bash
# High yield (> 3%)
"yield > 3"

# Moderate yield (1-3%)
"yield > 1 and yield < 3"

# Dividend payers with growth
"yield > 2 and changepercent > 0"
```

### By Price Change

```bash
# Strong gainers (> 2%)
"changepercent > 2"

# Any gainers
"changepercent > 0"

# Decliners
"changepercent < 0"

# Extreme movers (up or down)
"changepercent > 5 or changepercent < -5"
```

### By Volume

```bash
# High volume (> 50M)
"volume > 50000000"

# Above average volume
"volume > avgvolume"

# Volume spike (2x average)
"volume > avgvolume * 2"
```

### By 52-Week Range

```bash
# Near 52-week high (top 5%)
"price >= 52whigh * 0.95"

# Near 52-week low (bottom 10%)
"price <= 52wlow * 1.1"

# Middle of range
"price > 52wlow * 1.3 and price < 52whigh * 0.7"
```

## Troubleshooting

### No Results Returned

**Cause:** Criteria too restrictive or no stocks match.

**Solution:**
- Relax your criteria
- Check if fields are available for your stocks
- Verify expression syntax

### "Invalid expression" Error

**Cause:** Syntax error in expression.

**Solution:**
- Check field names (use `price` not `Price`)
- Verify operators (`and` not `AND`)
- Ensure proper spacing around operators
- Check for typos

### Unexpected Results

**Cause:** Expression logic issue or data availability.

**Solution:**
- Test with simple expressions first
- Verify data with `yf quote` command
- Check if optional fields (P/E, yield) are available
- Review boolean logic (and vs or)

## See Also

- [Commands Reference](commands.md) - Complete command documentation
- [Quick Start Guide](quick-start.md) - Basic usage
- [Example: screening.sh](../../examples/cli/screening.sh) - Working examples

## Related Commands

For complementary analysis, also check out:
- `yf compare` - Compare stocks side-by-side
- `yf download` - Batch download screened symbols
- `yf indicators` - Technical analysis on screened stocks
- `yf dividends` - Dividend history for income screening
