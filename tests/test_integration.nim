## Integration test with real Yahoo Finance API

import yfnim
import std/times
import std/strutils
import std/httpclient
import std/json

echo "="
echo "=" & repeat("=", 70)
echo "= Yahoo Finance API Integration Test"
echo "=" & repeat("=", 70)
echo "="
echo ""

# Test 1: Fetch daily data for AAPL
echo "Test 1: Fetching daily data for AAPL (last 7 days)"
echo "-" & repeat("-", 70)

try:
  let now = getTime().toUnix()
  let sevenDaysAgo = now - (7 * 24 * 3600)
  
  echo "  Symbol: AAPL"
  echo "  Interval: 1d (daily)"
  echo "  Period: ", sevenDaysAgo, " to ", now
  echo ""
  
  let history = getHistory("AAPL", Int1d, sevenDaysAgo, now)
  
  echo "  ✓ Successfully retrieved data"
  echo "  ✓ Symbol: ", history.symbol
  echo "  ✓ Interval: ", history.interval
  echo "  ✓ Records: ", history.len
  echo ""
  
  if history.len > 0:
    echo "  First record:"
    echo "    Time: ", history.data[0].time
    echo "    Open: ", history.data[0].open
    echo "    High: ", history.data[0].high
    echo "    Low: ", history.data[0].low
    echo "    Close: ", history.data[0].close
    echo "    Volume: ", history.data[0].volume
    echo ""
    
    if history.len > 1:
      echo "  Last record:"
      let last = history.len - 1
      echo "    Time: ", history.data[last].time
      echo "    Open: ", history.data[last].open
      echo "    High: ", history.data[last].high
      echo "    Low: ", history.data[last].low
      echo "    Close: ", history.data[last].close
      echo "    Volume: ", history.data[last].volume
  
  echo ""
  echo "✓ Test 1 PASSED"
  
except HttpRequestError as e:
  echo "✗ Test 1 FAILED: HTTP Error - ", e.msg
except JsonParsingError as e:
  echo "✗ Test 1 FAILED: JSON Parse Error - ", e.msg
except YahooApiError as e:
  echo "✗ Test 1 FAILED: Yahoo API Error - ", e.msg
except Exception as e:
  echo "✗ Test 1 FAILED: ", e.msg

echo ""
echo "="
echo "=" & repeat("=", 70)
echo ""

# Test 2: Fetch hourly data for MSFT
echo "Test 2: Fetching hourly data for MSFT (last 3 days)"
echo "-" & repeat("-", 70)

try:
  let now = getTime().toUnix()
  let threeDaysAgo = now - (3 * 24 * 3600)
  
  echo "  Symbol: MSFT"
  echo "  Interval: 1h (hourly)"
  echo "  Period: ", threeDaysAgo, " to ", now
  echo ""
  
  let history = getHistory("MSFT", Int1h, threeDaysAgo, now)
  
  echo "  ✓ Successfully retrieved data"
  echo "  ✓ Symbol: ", history.symbol
  echo "  ✓ Interval: ", history.interval
  echo "  ✓ Records: ", history.len
  echo ""
  
  if history.len > 0:
    echo "  Sample records (first 3):"
    for i in 0..<min(3, history.len):
      echo "    [", i, "] Time: ", history.data[i].time, 
           ", Close: ", history.data[i].close,
           ", Volume: ", history.data[i].volume
  
  echo ""
  echo "✓ Test 2 PASSED"
  
except HttpRequestError as e:
  echo "✗ Test 2 FAILED: HTTP Error - ", e.msg
except JsonParsingError as e:
  echo "✗ Test 2 FAILED: JSON Parse Error - ", e.msg
except YahooApiError as e:
  echo "✗ Test 2 FAILED: Yahoo API Error - ", e.msg
except Exception as e:
  echo "✗ Test 2 FAILED: ", e.msg

echo ""
echo "="
echo "=" & repeat("=", 70)
echo ""

# Test 3: Test with specific historical dates
echo "Test 3: Fetching specific date range for GOOGL"
echo "-" & repeat("-", 70)

try:
  # Jan 1, 2024 to Jan 31, 2024
  let startTime: int64 = 1704067200  # 2024-01-01
  let endTime: int64 = 1706745600    # 2024-02-01
  
  echo "  Symbol: GOOGL"
  echo "  Interval: 1d (daily)"
  echo "  Period: 2024-01-01 to 2024-02-01"
  echo ""
  
  let history = getHistory("GOOGL", Int1d, startTime, endTime)
  
  echo "  ✓ Successfully retrieved data"
  echo "  ✓ Symbol: ", history.symbol
  echo "  ✓ Records: ", history.len
  echo ""
  
  echo "✓ Test 3 PASSED"
  
except HttpRequestError as e:
  echo "✗ Test 3 FAILED: HTTP Error - ", e.msg
except JsonParsingError as e:
  echo "✗ Test 3 FAILED: JSON Parse Error - ", e.msg
except YahooApiError as e:
  echo "✗ Test 3 FAILED: Yahoo API Error - ", e.msg
except Exception as e:
  echo "✗ Test 3 FAILED: ", e.msg

echo ""
echo "="
echo "=" & repeat("=", 70)
echo "= Integration Tests Complete"
echo "=" & repeat("=", 70)
echo "="
