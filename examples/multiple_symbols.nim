## Multiple Symbols Example
##
## Demonstrates fetching data for multiple symbols with proper error handling
## and rate limiting to be respectful to Yahoo Finance

import yfnim
import std/[times, os, strutils, httpclient]

proc formatPrice(price: float64): string =
  ## Format price as currency with 2 decimal places
  "$" & price.formatFloat(ffDecimal, 2)

proc calculateStats(history: History) =
  ## Calculate and display simple statistics
  if history.len == 0:
    echo "  No data available"
    return
  
  var sum = 0.0
  var minPrice = float64.high
  var maxPrice = 0.0
  
  for record in history.data:
    sum += record.close
    if record.close < minPrice:
      minPrice = record.close
    if record.close > maxPrice:
      maxPrice = record.close
  
  let avgPrice = sum / float(history.len)
  
  echo "  Records: ", history.len
  echo "  Average Close: ", formatPrice(avgPrice)
  echo "  Min Close: ", formatPrice(minPrice)
  echo "  Max Close: ", formatPrice(maxPrice)
  echo "  Range: ", formatPrice(maxPrice - minPrice)

proc main() =
  echo "Fetching data for multiple symbols...\n"
  
  let symbols = @["AAPL", "MSFT", "GOOGL", "TSLA", "AMZN"]
  let now = getTime().toUnix()
  let monthAgo = now - (30 * 24 * 3600)
  
  var successCount = 0
  var failCount = 0
  
  for symbol in symbols:
    echo "Fetching ", symbol, "..."
    
    try:
      let history = getHistory(symbol, Int1d, monthAgo, now)
      calculateStats(history)
      successCount.inc()
      
    except ValueError as e:
      echo "  Input error: ", e.msg
      failCount.inc()
      
    except YahooApiError as e:
      echo "  API error: ", e.msg
      failCount.inc()
      
    except CatchableError as e:
      echo "  Error: ", e.msg
      failCount.inc()
    
    echo ""
    
    # Be respectful to Yahoo Finance - add delay between requests
    if symbol != symbols[^1]:  # Don't sleep after last symbol
      sleep(1000)  # 1 second delay
  
  echo "Summary:"
  echo "  Successful: ", successCount
  echo "  Failed: ", failCount

when isMainModule:
  main()
