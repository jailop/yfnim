## Error Handling Example
##
## Demonstrates proper error handling patterns when working with yfnim library.
## Shows how to catch and handle different types of errors gracefully.

import yfnim
import std/[times, strutils]

proc example1_invalidSymbol() =
  ## Example: Handling invalid/non-existent symbols
  echo "=== Example 1: Invalid Symbol ==="
  
  let badSymbol = "NOTAREALSYMBOL123"
  echo "Attempting to fetch quote for: ", badSymbol
  
  try:
    let quote = getQuote(badSymbol)
    echo "Success: ", quote.symbol, " = $", quote.regularMarketPrice
  except QuoteError as e:
    echo "✗ Quote error (expected): ", e.msg
  except YahooApiError as e:
    echo "✗ API error: ", e.msg
  except CatchableError as e:
    echo "✗ Other error: ", e.msg
  
  echo ""

proc example2_emptySymbol() =
  ## Example: Handling empty/whitespace input
  echo "=== Example 2: Empty Symbol ==="
  
  try:
    let quote = getQuote("   ")  # Whitespace only
    echo "Success: ", quote.symbol
  except ValueError as e:
    echo "✓ Validation error (expected): ", e.msg
  except CatchableError as e:
    echo "✗ Unexpected error: ", e.msg
  
  echo ""

proc example3_networkError() =
  ## Example: Simulating network errors
  echo "=== Example 3: Network Error ==="
  echo "Note: This would require actual network failure to trigger"
  echo "In real code, you would catch YahooApiError:"
  echo """
  try:
    let quote = getQuote("AAPL")
  except YahooApiError as e:
    echo "Network problem: ", e.msg
    # Could retry, use cached data, or notify user
  """
  echo ""

proc example4_invalidDateRange() =
  ## Example: Handling invalid date ranges
  echo "=== Example 4: Invalid Date Range ==="
  
  # Try to get data with end date before start date
  let now = getTime().toUnix()
  let weekAgo = now - (7 * 86400)
  
  echo "Attempting to fetch with reversed date range..."
  try:
    # This should work but return empty data
    let history = getHistory("AAPL", Int1d, now, weekAgo)  # Reversed!
    echo "Retrieved ", history.data.len, " records (expected: 0)"
  except CatchableError as e:
    echo "Error: ", e.msg
  
  echo ""

proc example5_batchWithSomeInvalid() =
  ## Example: Batch requests with some invalid symbols
  echo "=== Example 5: Batch with Invalid Symbols ==="
  
  let mixed = @["AAPL", "INVALID123", "MSFT", "BADSTOCK", "GOOGL"]
  echo "Fetching quotes for: ", mixed.join(", ")
  
  try:
    let quotes = getQuotes(mixed)
    echo "Successfully retrieved ", quotes.len, " out of ", mixed.len, " symbols:"
    for quote in quotes:
      echo "  ✓ ", quote.symbol, ": $", quote.regularMarketPrice
    
    # Identify which ones failed
    var failed: seq[string]
    for symbol in mixed:
      var found = false
      for quote in quotes:
        if quote.symbol == symbol:
          found = true
          break
      if not found:
        failed.add(symbol)
    
    if failed.len > 0:
      echo "Failed symbols: ", failed.join(", ")
  
  except ValueError as e:
    echo "Validation error: ", e.msg
  except CatchableError as e:
    echo "Error: ", e.msg
  
  echo ""

proc example6_properErrorRecovery() =
  ## Example: Error recovery with retry logic
  echo "=== Example 6: Error Recovery Pattern ==="
  
  let symbols = @["AAPL", "MSFT"]
  let maxRetries = 3
  
  for symbol in symbols:
    var success = false
    var attempt = 0
    
    while not success and attempt < maxRetries:
      attempt += 1
      
      try:
        echo "Fetching ", symbol, " (attempt ", attempt, ")..."
        let quote = getQuote(symbol)
        echo "  ✓ Success: $", quote.regularMarketPrice
        success = true
      
      except YahooApiError as e:
        echo "  ✗ Network error: ", e.msg
        if attempt < maxRetries:
          echo "  Retrying..."
      
      except QuoteError as e:
        echo "  ✗ API error: ", e.msg
        break  # Don't retry API errors (invalid symbol, etc.)
      
      except CatchableError as e:
        echo "  ✗ Unexpected error: ", e.msg
        break
  
  echo ""

proc example7_defensiveProgramming() =
  ## Example: Defensive programming with validation
  echo "=== Example 7: Defensive Programming ==="
  
  proc safeGetQuote(symbol: string): bool =
    ## Wrapper that validates input and handles all errors
    # Input validation
    if symbol.strip().len == 0:
      echo "✗ Invalid input: empty symbol"
      return false
    
    if symbol.len > 10:
      echo "✗ Invalid input: symbol too long (max 10 chars)"
      return false
    
    # Fetch with error handling
    try:
      let quote = getQuote(symbol)
      echo "✓ ", quote.symbol, ": $", quote.regularMarketPrice, 
           " (", quote.regularMarketChangePercent, "%)"
      return true
    
    except QuoteError:
      echo "✗ Symbol not found or API error"
      return false
    
    except YahooApiError:
      echo "✗ Network error - check connection"
      return false
    
    except CatchableError as e:
      echo "✗ Unexpected error: ", e.msg
      return false
  
  # Test the wrapper
  discard safeGetQuote("AAPL")
  discard safeGetQuote("")
  discard safeGetQuote("VERYLONGSYMBOLNAME")
  
  echo ""

proc main() =
  echo "yfnim Error Handling Examples"
  echo "=============================="
  echo ""
  
  example1_invalidSymbol()
  example2_emptySymbol()
  example3_networkError()
  example4_invalidDateRange()
  example5_batchWithSomeInvalid()
  example6_properErrorRecovery()
  example7_defensiveProgramming()
  
  echo "Examples completed!"

when isMainModule:
  main()
