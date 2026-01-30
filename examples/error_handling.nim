## Error Handling Example
##
## Demonstrates comprehensive error handling for various failure scenarios

import yfnim
import std/[times, httpclient]

proc testValidSymbol() =
  echo "Test 1: Valid symbol (should succeed)"
  try:
    let now = getTime().toUnix()
    let weekAgo = now - (7 * 24 * 3600)
    let history = getHistory("AAPL", Int1d, weekAgo, now)
    echo "  ✓ Success: Retrieved ", history.len, " records\n"
  except CatchableError as e:
    echo "  ✗ Failed: ", e.msg, "\n"

proc testInvalidSymbol() =
  echo "Test 2: Invalid symbol (might fail or return empty)"
  try:
    let now = getTime().toUnix()
    let weekAgo = now - (7 * 24 * 3600)
    let history = getHistory("INVALID_XYZ123", Int1d, weekAgo, now)
    echo "  ✓ Handled gracefully: Retrieved ", history.len, " records\n"
  except YahooApiError as e:
    echo "  ✓ Expected API error: ", e.msg, "\n"
  except HttpRequestError as e:
    echo "  ✓ Expected HTTP error: ", e.msg, "\n"
  except CatchableError as e:
    echo "  ✗ Unexpected error: ", e.msg, "\n"

proc testEmptySymbol() =
  echo "Test 3: Empty symbol (should fail validation)"
  try:
    let now = getTime().toUnix()
    let weekAgo = now - (7 * 24 * 3600)
    discard getHistory("", Int1d, weekAgo, now)
    echo "  ✗ Should have raised ValueError\n"
  except ValueError as e:
    echo "  ✓ Expected validation error: ", e.msg, "\n"
  except CatchableError as e:
    echo "  ✗ Wrong exception type: ", e.msg, "\n"

proc testInvalidDateRange() =
  echo "Test 4: Start time after end time (should fail validation)"
  try:
    let now = getTime().toUnix()
    let future = now + 86400
    discard getHistory("AAPL", Int1d, future, now)  # Reversed
    echo "  ✗ Should have raised ValueError\n"
  except ValueError as e:
    echo "  ✓ Expected validation error: ", e.msg, "\n"
  except CatchableError as e:
    echo "  ✗ Wrong exception type: ", e.msg, "\n"

proc testNegativeTimestamp() =
  echo "Test 5: Negative timestamp (should fail validation)"
  try:
    discard getHistory("AAPL", Int1d, -1000, -500)
    echo "  ✗ Should have raised ValueError\n"
  except ValueError as e:
    echo "  ✓ Expected validation error: ", e.msg, "\n"
  except CatchableError as e:
    echo "  ✗ Wrong exception type: ", e.msg, "\n"

proc testLargeRange1mInterval() =
  echo "Test 6: 1m interval with too large date range (should fail)"
  try:
    let now = getTime().toUnix()
    let monthAgo = now - (30 * 24 * 3600)  # 30 days - too much for 1m
    let history = getHistory("AAPL", Int1m, monthAgo, now)
    echo "  ~ Handled by Yahoo: Retrieved ", history.len, " records\n"
  except HttpRequestError as e:
    echo "  ✓ Expected HTTP error (422): ", e.msg, "\n"
  except YahooApiError as e:
    echo "  ✓ Expected API error: ", e.msg, "\n"
  except CatchableError as e:
    echo "  ✗ Unexpected error: ", e.msg, "\n"

proc testInternationalSymbol() =
  echo "Test 7: International symbol (should work)"
  try:
    let now = getTime().toUnix()
    let weekAgo = now - (7 * 24 * 3600)
    let history = getHistory("SAP.DE", Int1d, weekAgo, now)
    echo "  ✓ Success: Retrieved ", history.len, " records for ", history.symbol, "\n"
  except CatchableError as e:
    echo "  ~ May fail depending on market: ", e.msg, "\n"

proc testCryptoSymbol() =
  echo "Test 8: Cryptocurrency symbol (should work)"
  try:
    let now = getTime().toUnix()
    let weekAgo = now - (7 * 24 * 3600)
    let history = getHistory("BTC-USD", Int1d, weekAgo, now)
    echo "  ✓ Success: Retrieved ", history.len, " records for ", history.symbol, "\n"
  except CatchableError as e:
    echo "  ~ May fail: ", e.msg, "\n"

proc main() =
  echo "=== Error Handling Test Suite ===\n"
  
  testValidSymbol()
  testInvalidSymbol()
  testEmptySymbol()
  testInvalidDateRange()
  testNegativeTimestamp()
  testLargeRange1mInterval()
  testInternationalSymbol()
  testCryptoSymbol()
  
  echo "=== All tests completed ==="

when isMainModule:
  main()
