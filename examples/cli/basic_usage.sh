#!/bin/bash
# Basic Usage Examples for yf CLI Tool
# 
# This script demonstrates common use cases for the yf command-line tool.
# Make sure yf is in your PATH before running these examples.

echo "=============================================="
echo "yf CLI Tool - Basic Usage Examples"
echo "=============================================="
echo ""

# Check if yf is available
if ! command -v yf &> /dev/null; then
    echo "Error: 'yf' command not found in PATH"
    echo "Please build and install: nimble build -d:ssl"
    exit 1
fi

echo "1. Get Historical Data (Last 7 Days)"
echo "--------------------------------------"
echo "Command: yf history --symbol=AAPL --lookback=7d"
echo ""
yf history --symbol=AAPL --lookback=7d
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "2. Get Historical Data with Custom Date Range"
echo "--------------------------------------"
echo "Command: yf history --symbol=MSFT --start=2024-01-01 --end=2024-01-31"
echo ""
yf history --symbol=MSFT --start=2024-01-01 --end=2024-01-31
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "3. Get Real-Time Quote for Single Symbol"
echo "--------------------------------------"
echo "Command: yf quote AAPL"
echo ""
yf quote AAPL
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "4. Get Quotes for Multiple Symbols"
echo "--------------------------------------"
echo "Command: yf quote AAPL MSFT GOOGL AMZN"
echo ""
yf quote AAPL MSFT GOOGL AMZN
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "5. Compare Multiple Stocks"
echo "--------------------------------------"
echo "Command: yf compare AAPL MSFT GOOGL"
echo ""
yf compare AAPL MSFT GOOGL
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "6. Export to CSV"
echo "--------------------------------------"
echo "Command: yf history --symbol=AAPL --lookback=30d --format=csv > aapl_30d.csv"
echo ""
yf history --symbol=AAPL --lookback=30d --format=csv > aapl_30d.csv
echo "Saved to: aapl_30d.csv"
ls -lh aapl_30d.csv
echo ""
echo "First 5 lines:"
head -5 aapl_30d.csv
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "7. Export to JSON"
echo "--------------------------------------"
echo "Command: yf quote AAPL MSFT --format=json > quotes.json"
echo ""
yf quote AAPL MSFT --format=json > quotes.json
echo "Saved to: quotes.json"
cat quotes.json
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "8. Different Output Formats"
echo "--------------------------------------"
echo ""
echo "8a. Table format (default):"
yf quote TSLA --format=table
echo ""
echo "8b. CSV format:"
yf quote TSLA --format=csv
echo ""
echo "8c. TSV format (good for piping):"
yf quote TSLA --format=tsv
echo ""
echo "8d. Minimal format (just values):"
yf quote TSLA --format=minimal
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "9. Using Different Intervals"
echo "--------------------------------------"
echo ""
echo "9a. Hourly data (last 3 days):"
yf history --symbol=NVDA --lookback=3d --interval=1h | head -15
echo ""
echo "9b. Weekly data (last 6 months):"
yf history --symbol=NVDA --lookback=180d --interval=1wk
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "10. Refresh Cache (Bypass Cached Data)"
echo "--------------------------------------"
echo "First request (may use cache):"
time yf quote AAPL > /dev/null
echo ""
echo "Second request with --refresh flag:"
time yf quote AAPL --refresh > /dev/null
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "11. Screen Stocks with Predefined Criteria"
echo "--------------------------------------"
echo "Command: yf screen AAPL MSFT GOOGL AMZN TSLA --criteria value"
echo ""
yf screen AAPL MSFT GOOGL AMZN TSLA --criteria value
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "12. Screen with Custom Filter Expression"
echo "--------------------------------------"
echo "Command: yf screen AAPL MSFT GOOGL TSLA NVDA --criteria custom --where 'price > 100 and changepercent > 0'"
echo ""
yf screen AAPL MSFT GOOGL TSLA NVDA --criteria custom --where "price > 100 and changepercent > 0"
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "13. Watch a Portfolio (Multiple Quotes)"
echo "--------------------------------------"
echo "Create a watchlist file:"
cat > watchlist.txt << 'EOF'
AAPL
MSFT
GOOGL
AMZN
TSLA
NVDA
META
EOF

echo "Command: cat watchlist.txt | yf quote --read-stdin"
echo ""
cat watchlist.txt | yf quote --read-stdin
rm -f watchlist.txt
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "14. Get International Stock Quotes"
echo "--------------------------------------"
echo "Examples of non-US symbols:"
echo ""
echo "Canadian stock (Toronto Stock Exchange):"
yf quote SHOP.TO
echo ""
echo "European stock (London):"
yf quote BP.L
echo ""
echo "Asian stock (Tokyo):"
yf quote 9984.T
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "15. Cryptocurrency Quotes"
echo "--------------------------------------"
echo "Bitcoin and Ethereum:"
yf quote BTC-USD ETH-USD
echo ""
echo "Press Enter to continue..."
read

# Cleanup
rm -f aapl_30d.csv quotes.json

echo ""
echo "=============================================="
echo "Examples completed!"
echo "=============================================="
echo ""
echo "For more information:"
echo "  - CLI commands: docs/cli/commands.md"
echo "  - Screening guide: docs/cli/screening.md"
echo "  - Quick start: docs/cli/quick-start.md"
echo ""
