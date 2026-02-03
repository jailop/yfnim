#!/bin/bash
# Unix Piping and Integration Examples for yf CLI Tool
#
# Demonstrates how to integrate yf with standard Unix tools
# for powerful data processing workflows.

echo "=============================================="
echo "yf CLI Tool - Piping & Integration Examples"
echo "=============================================="
echo ""

# Check if yf is available
if ! command -v yf &> /dev/null; then
    echo "Error: 'yf' command not found in PATH"
    echo "Please build and install: nimble build -d:ssl"
    exit 1
fi

echo "=== Basic Piping Examples ==="
echo ""

echo "1. Pipe to grep (Filter Output)"
echo "--------------------------------------"
echo "Show only stocks with 'Market' in the line:"
echo "Command: yf quote AAPL MSFT GOOGL | grep -i market"
echo ""
yf quote AAPL MSFT GOOGL | grep -i market
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "2. Pipe to head/tail (Limit Output)"
echo "--------------------------------------"
echo "Get first 10 days of history:"
echo "Command: yf history --symbol=AAPL --lookback=30d | head -12"
echo "(12 lines = header + 10 data rows)"
echo ""
yf history --symbol=AAPL --lookback=30d | head -12
echo ""
echo "Get last 5 days:"
echo "Command: yf history --symbol=AAPL --lookback=30d | tail -5"
echo ""
yf history --symbol=AAPL --lookback=30d | tail -5
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "3. Pipe to wc (Count Lines/Words)"
echo "--------------------------------------"
echo "Count how many days of data returned:"
echo "Command: yf history --symbol=AAPL --lookback=365d --format=csv | wc -l"
echo ""
days=$(yf history --symbol=AAPL --lookback=365d --format=csv | wc -l)
echo "Total lines: $days (includes 1 header line)"
echo "Trading days: $((days - 1))"
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "=== CSV Processing with awk ==="
echo ""

echo "4. Extract Specific Columns with awk"
echo "--------------------------------------"
echo "Extract just date and closing price:"
echo "Command: yf history --symbol=AAPL --lookback=7d --format=csv | awk -F, '{print \$1, \$5}'"
echo ""
yf history --symbol=AAPL --lookback=7d --format=csv | awk -F, '{print $1, $5}'
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "5. Filter by Value with awk"
echo "--------------------------------------"
echo "Find days where closing price > 220:"
echo "Command: yf history --symbol=AAPL --lookback=30d --format=csv | awk -F, 'NR>1 && \$5>220'"
echo ""
yf history --symbol=AAPL --lookback=30d --format=csv | awk -F, 'NR>1 && $5>220'
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "6. Calculate with awk"
echo "--------------------------------------"
echo "Calculate average closing price:"
echo "Command: yf history --symbol=AAPL --lookback=30d --format=csv | awk -F, 'NR>1 {sum+=\$5; count++} END {print \"Average:\", sum/count}'"
echo ""
yf history --symbol=AAPL --lookback=30d --format=csv | awk -F, 'NR>1 {sum+=$5; count++} END {print "Average:", sum/count}'
echo ""
echo "Find highest close:"
echo ""
yf history --symbol=AAPL --lookback=30d --format=csv | awk -F, 'NR>1 {if($5>max) max=$5} END {print "Highest close:", max}'
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "=== JSON Processing with jq ==="
echo ""

if ! command -v jq &> /dev/null; then
    echo "Note: jq not found, skipping JSON examples"
    echo "Install jq: sudo apt install jq"
else
    echo "7. Extract Fields with jq"
    echo "--------------------------------------"
    echo "Get just the symbol and price:"
    echo "Command: yf quote AAPL --format=json | jq '.symbol, .regularMarketPrice'"
    echo ""
    yf quote AAPL --format=json | jq '.symbol, .regularMarketPrice'
    echo ""
    echo "Press Enter to continue..."
    read

    echo ""
    echo "8. Format JSON Output"
    echo "--------------------------------------"
    echo "Pretty-print with custom format:"
    echo "Command: yf quote AAPL MSFT --format=json | jq '{symbol: .symbol, price: .regularMarketPrice, change: .regularMarketChangePercent}'"
    echo ""
    yf quote AAPL MSFT --format=json | jq '{symbol: .symbol, price: .regularMarketPrice, change: .regularMarketChangePercent}'
    echo ""
    echo "Press Enter to continue..."
    read

    echo ""
    echo "9. Filter JSON with jq"
    echo "--------------------------------------"
    echo "Get quotes only if change > 0:"
    echo "Command: yf quote AAPL MSFT GOOGL TSLA --format=json | jq 'select(.regularMarketChangePercent > 0)'"
    echo ""
    yf quote AAPL MSFT GOOGL TSLA --format=json | jq 'select(.regularMarketChangePercent > 0)'
    echo ""
    echo "Press Enter to continue..."
    read
fi

echo ""
echo "=== Combining Multiple Commands ==="
echo ""

echo "10. Compare Stocks with Custom Format"
echo "--------------------------------------"
echo "Get prices and format as table:"
echo ""
echo "Symbol  Price   Change%"
echo "------------------------"
for symbol in AAPL MSFT GOOGL TSLA; do
    yf quote $symbol --format=minimal | awk -v sym=$symbol '{printf "%-7s $%-7.2f %+.2f%%\n", sym, $1, $2}'
done
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "11. Batch Processing with Loop"
echo "--------------------------------------"
echo "Download 30 days of data for multiple stocks:"
echo ""
for symbol in AAPL MSFT GOOGL; do
    echo "Downloading $symbol..."
    yf history $symbol --lookback=30d --format=csv > "${symbol}_30d.csv"
    lines=$(wc -l < "${symbol}_30d.csv")
    echo "  Saved ${lines} lines to ${symbol}_30d.csv"
done
echo ""
echo "Files created:"
ls -lh *_30d.csv
rm -f *_30d.csv
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "12. Find Best Performers"
echo "--------------------------------------"
echo "Get quotes and sort by change percentage:"
echo ""
echo "Command: yf quote AAPL MSFT GOOGL AMZN TSLA NVDA --format=csv | tail -n +2 | sort -t, -k3 -nr"
echo ""
yf quote AAPL MSFT GOOGL AMZN TSLA NVDA --format=csv | tail -n +2 | sort -t, -k3 -nr
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "13. Create Daily Report"
echo "--------------------------------------"
echo "Generate a formatted daily report:"
echo ""
cat > daily_report.sh << 'EOFSCRIPT'
#!/bin/bash
echo "Daily Market Report - $(date +%Y-%m-%d)"
echo "========================================"
echo ""
echo "Tech Leaders:"
yf quote AAPL MSFT GOOGL AMZN --format=table
echo ""
echo "Top Gainers (from watchlist):"
yf quote AAPL MSFT GOOGL AMZN TSLA NVDA META --format=csv | \
    tail -n +2 | sort -t, -k3 -nr | head -3 | \
    awk -F, '{printf "%s: +%.2f%%\n", $1, $3}'
echo ""
EOFSCRIPT

chmod +x daily_report.sh
./daily_report.sh
rm -f daily_report.sh
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "14. Export to Different Formats"
echo "--------------------------------------"
echo "CSV to TSV conversion:"
echo "Command: yf history --symbol=AAPL --lookback=7d --format=csv | tr ',' '\t'"
echo ""
yf history --symbol=AAPL --lookback=7d --format=csv | tr ',' '\t' | head -5
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "15. Complex Pipeline Example"
echo "--------------------------------------"
echo "Find stocks with price > \$200 and volume > 10M:"
echo ""
echo "Command:"
echo "for s in AAPL MSFT GOOGL AMZN TSLA NVDA; do"
echo "  yf quote \$s --format=csv | tail -1"
echo "done | awk -F, '\$2>200 && \$6>10000000 {print \$1, \"Price:\", \$2, \"Volume:\", \$6}'"
echo ""
for s in AAPL MSFT GOOGL AMZN TSLA NVDA; do
  yf quote $s --format=csv 2>/dev/null | tail -1
done | awk -F, '$2>200 && $6>10000000 {print $1, "Price:", $2, "Volume:", $6}'
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "=== Advanced Integration Examples ==="
echo ""

echo "16. Create Watchlist Alert System"
echo "--------------------------------------"
cat > check_alerts.sh << 'EOFSCRIPT'
#!/bin/bash
# Check for stocks with significant moves

THRESHOLD=2.0  # Alert if > 2% change
WATCHLIST="AAPL MSFT GOOGL AMZN TSLA"

echo "Checking for significant moves (threshold: ${THRESHOLD}%)..."

for symbol in $WATCHLIST; do
    data=$(yf quote $symbol --format=minimal 2>/dev/null)
    if [ $? -eq 0 ]; then
        price=$(echo $data | awk '{print $1}')
        change=$(echo $data | awk '{print $2}')
        
        # Check if absolute value > threshold
        if awk -v c="$change" -v t="$THRESHOLD" 'BEGIN {exit !(c > t || c < -t)}'; then
            echo "🔔 ALERT: $symbol at \$$price ($change%)"
        fi
    fi
done
EOFSCRIPT

chmod +x check_alerts.sh
./check_alerts.sh
rm -f check_alerts.sh
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "17. Integration with SQLite"
echo "--------------------------------------"
if command -v sqlite3 &> /dev/null; then
    echo "Create database and import data:"
    echo ""
    
    # Create database
    sqlite3 stocks.db << 'EOF'
CREATE TABLE IF NOT EXISTS history (
    date TEXT,
    open REAL,
    high REAL,
    low REAL,
    close REAL,
    volume INTEGER
);
.mode csv
.import /dev/stdin history
EOF
    
    # Import data
    yf history --symbol=AAPL --lookback=30d --format=csv | tail -n +2 | sqlite3 stocks.db
    
    echo "Query data:"
    echo "SELECT date, close FROM history WHERE close > 220 ORDER BY date DESC LIMIT 5;" | sqlite3 -header stocks.db
    
    rm -f stocks.db
else
    echo "sqlite3 not found, skipping database example"
fi
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "18. Creating a Price Tracker"
echo "--------------------------------------"
echo "Log prices over time:"
cat > price_tracker.sh << 'EOFSCRIPT'
#!/bin/bash
LOGFILE="price_history.log"

while true; do
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    price=$(yf quote AAPL --format=minimal 2>/dev/null | awk '{print $1}')
    if [ ! -z "$price" ]; then
        echo "$timestamp,$price" >> $LOGFILE
        echo "Logged: $timestamp - \$$price"
    fi
    sleep 60  # Wait 1 minute
done
EOFSCRIPT

echo "Script created: price_tracker.sh"
echo "Run with: ./price_tracker.sh"
echo "(This would log prices every minute)"
rm -f price_tracker.sh
echo ""

echo ""
echo "=============================================="
echo "Piping examples completed!"
echo "=============================================="
echo ""
echo "Summary of useful commands:"
echo ""
echo "Filtering:"
echo "  yf ... | grep <pattern>           # Filter lines"
echo "  yf ... | awk -F, '\$5>100'        # Filter by value"
echo ""
echo "Processing:"
echo "  yf ... | head -n 10               # First 10 lines"
echo "  yf ... | tail -n 5                # Last 5 lines"
echo "  yf ... | sort -t, -k2 -nr         # Sort by column"
echo "  yf ... | wc -l                    # Count lines"
echo ""
echo "Formatting:"
echo "  yf ... | column -t -s,            # Format as table"
echo "  yf ... | tr ',' '\t'              # Convert to TSV"
echo "  yf ... --format=json | jq         # Process JSON"
echo ""
echo "For more information:"
echo "  - Command reference: docs/cli/commands.md"
echo "  - Quick start: docs/cli/quick-start.md"
echo ""
