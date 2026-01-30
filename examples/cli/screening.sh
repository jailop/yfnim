#!/bin/bash
# Stock Screening Examples for yf CLI Tool
#
# This script demonstrates the powerful screening capabilities of the yf tool.
# Shows predefined criteria and custom filter expressions.

echo "=============================================="
echo "yf CLI Tool - Stock Screening Examples"
echo "=============================================="
echo ""

# Check if yf is available
if ! command -v yf &> /dev/null; then
    echo "Error: 'yf' command not found in PATH"
    echo "Please build and install: nimble build -d:ssl"
    exit 1
fi

# Define a universe of stocks to screen
TECH_STOCKS="AAPL MSFT GOOGL AMZN TSLA NVDA META NFLX AMD INTC CRM ORCL ADBE CSCO AVGO"
POPULAR_STOCKS="AAPL MSFT GOOGL AMZN TSLA NVDA META JPM JNJ V WMT PG UNH MA HD BAC"

echo "=== Predefined Screening Criteria ==="
echo ""

echo "1. Value Stocks (Low P/E, High Dividend Yield)"
echo "--------------------------------------"
echo "Command: yf screen $POPULAR_STOCKS --criteria value"
echo ""
yf screen $POPULAR_STOCKS --criteria value
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "2. Growth Stocks (High Change %)"
echo "--------------------------------------"
echo "Command: yf screen $TECH_STOCKS --criteria growth"
echo ""
yf screen $TECH_STOCKS --criteria growth
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "3. Dividend Stocks (High Yield)"
echo "--------------------------------------"
echo "Command: yf screen $POPULAR_STOCKS --criteria dividend"
echo ""
yf screen $POPULAR_STOCKS --criteria dividend
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "4. Momentum Stocks (Strong Recent Performance)"
echo "--------------------------------------"
echo "Command: yf screen $TECH_STOCKS --criteria momentum"
echo ""
yf screen $TECH_STOCKS --criteria momentum
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "=== Custom Filter Expressions ==="
echo ""

echo "5. Price-Based Filters"
echo "--------------------------------------"
echo "Stocks under $200:"
echo "Command: yf screen $TECH_STOCKS --criteria custom --where 'price < 200'"
echo ""
yf screen $TECH_STOCKS --criteria custom --where "price < 200"
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "6. Change-Based Filters"
echo "--------------------------------------"
echo "Stocks up more than 2% today:"
echo "Command: yf screen $POPULAR_STOCKS --criteria custom --where 'changepercent > 2'"
echo ""
yf screen $POPULAR_STOCKS --criteria custom --where "changepercent > 2"
echo ""
echo "Stocks down more than 1% today:"
echo "Command: yf screen $POPULAR_STOCKS --criteria custom --where 'changepercent < -1'"
echo ""
yf screen $POPULAR_STOCKS --criteria custom --where "changepercent < -1"
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "7. Volume-Based Filters"
echo "--------------------------------------"
echo "High volume stocks (>50M shares):"
echo "Command: yf screen $TECH_STOCKS --criteria custom --where 'volume > 50000000'"
echo ""
yf screen $TECH_STOCKS --criteria custom --where "volume > 50000000"
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "8. Combined Filters (AND Logic)"
echo "--------------------------------------"
echo "Value + momentum (cheap stocks going up):"
echo "Command: yf screen $POPULAR_STOCKS --criteria custom --where 'pe < 25 and changepercent > 0'"
echo ""
yf screen $POPULAR_STOCKS --criteria custom --where "pe < 25 and changepercent > 0"
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "9. Complex Multi-Condition Filters"
echo "--------------------------------------"
echo "Mid-range stocks with positive momentum:"
echo "Command: yf screen $TECH_STOCKS --criteria custom --where 'price > 100 and price < 500 and changepercent > 0'"
echo ""
yf screen $TECH_STOCKS --criteria custom --where "price > 100 and price < 500 and changepercent > 0"
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "10. Alternative Filters (OR Logic)"
echo "--------------------------------------"
echo "Extreme movers (up >3% OR down >3%):"
echo "Command: yf screen $POPULAR_STOCKS --criteria custom --where 'changepercent > 3 or changepercent < -3'"
echo ""
yf screen $POPULAR_STOCKS --criteria custom --where "changepercent > 3 or changepercent < -3"
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "11. 52-Week Range Filters"
echo "--------------------------------------"
echo "Near 52-week high (within 10%):"
echo "Command: yf screen $TECH_STOCKS --criteria custom --where 'price >= 52whigh * 0.9'"
echo ""
yf screen $TECH_STOCKS --criteria custom --where "price >= 52whigh * 0.9"
echo ""
echo "Near 52-week low (within 10%):"
echo "Command: yf screen $TECH_STOCKS --criteria custom --where 'price <= 52wlow * 1.1'"
echo ""
yf screen $TECH_STOCKS --criteria custom --where "price <= 52wlow * 1.1"
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "12. Dividend Yield Filters"
echo "--------------------------------------"
echo "High dividend yield (>3%):"
echo "Command: yf screen $POPULAR_STOCKS --criteria custom --where 'yield > 3'"
echo ""
yf screen $POPULAR_STOCKS --criteria custom --where "yield > 3"
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "13. Practical Screening Workflow"
echo "--------------------------------------"
echo "Step 1: Find value stocks"
yf screen $POPULAR_STOCKS --criteria value --format csv > value_stocks.csv
echo "Saved to: value_stocks.csv"
echo ""
echo "Step 2: Find growth stocks"
yf screen $TECH_STOCKS --criteria growth --format csv > growth_stocks.csv
echo "Saved to: growth_stocks.csv"
echo ""
echo "Step 3: Compare the lists"
echo "Value stocks:"
head -5 value_stocks.csv
echo ""
echo "Growth stocks:"
head -5 growth_stocks.csv
echo ""
rm -f value_stocks.csv growth_stocks.csv
echo "Press Enter to continue..."
read

echo ""
echo "14. Screening with Output Formats"
echo "--------------------------------------"
echo "JSON format (for programmatic processing):"
yf screen AAPL MSFT GOOGL --criteria value --format json | head -20
echo ""
echo "Minimal format (just symbols):"
yf screen $TECH_STOCKS --criteria growth --format minimal
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "15. Advanced Expression Examples"
echo "--------------------------------------"
echo ""
echo "a) Quality value stocks:"
echo "   Low P/E + High dividend + Positive change"
yf screen $POPULAR_STOCKS --criteria custom --where "pe < 20 and yield > 2 and changepercent > 0"
echo ""
echo "b) Volatile high-flyers:"
echo "   High price + Large daily change"
yf screen $TECH_STOCKS --criteria custom --where "price > 200 and (changepercent > 2 or changepercent < -2)"
echo ""
echo "c) Breakout candidates:"
echo "   Near 52-week high + Good volume"
yf screen $TECH_STOCKS --criteria custom --where "price >= 52whigh * 0.95 and volume > 10000000"
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "=== Available Filter Fields ==="
echo "--------------------------------------"
echo "Price fields:"
echo "  - price            : Current price"
echo "  - change           : Absolute change"
echo "  - changepercent    : Percentage change"
echo "  - open             : Opening price"
echo "  - high             : Day high"
echo "  - low              : Day low"
echo "  - prevclose        : Previous close"
echo ""
echo "52-week fields:"
echo "  - 52whigh          : 52-week high"
echo "  - 52wlow           : 52-week low"
echo "  - 52wchangepercent : 52-week change %"
echo ""
echo "Volume fields:"
echo "  - volume           : Current volume"
echo "  - avgvolume        : Average volume"
echo ""
echo "Valuation fields:"
echo "  - pe               : P/E ratio"
echo "  - yield            : Dividend yield"
echo "  - marketcap        : Market capitalization"
echo ""
echo "Operators:"
echo "  Comparison: <, >, <=, >=, =, !="
echo "  Logical: and, or"
echo "  Arithmetic: +, -, *, /"
echo ""

echo ""
echo "=============================================="
echo "Screening examples completed!"
echo "=============================================="
echo ""
echo "Tips:"
echo "  1. Start with predefined criteria (value, growth, dividend, momentum)"
echo "  2. Use custom filters for specific requirements"
echo "  3. Combine multiple conditions with 'and' for stricter filters"
echo "  4. Use 'or' to find stocks matching any of several criteria"
echo "  5. Export results to CSV/JSON for further analysis"
echo ""
echo "For more information:"
echo "  - Full screening guide: docs/cli/screening.md"
echo "  - Command reference: docs/cli/commands.md"
echo ""
