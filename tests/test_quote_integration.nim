## Quote Integration Tests
##
## Tests real API calls to Yahoo Finance quote endpoint
## Requires network connection and SSL support
##
## Compile with: nim c -d:ssl -r tests/test_quote_integration.nim

import std/[strutils, options]

# Import quote functionality
import yfnim/quote_types
import yfnim/quote_retriever

proc main() =
  echo ""
  echo "======================================================================="
  echo "= Yahoo Finance Quote API Integration Test"
  echo "======================================================================="
  echo ""
  
  # Test 1: Single symbol quote
  echo "Test 1: Fetching quote for AAPL"
  echo "-----------------------------------------------------------------------"
  
  try:
    let quote = getQuote("AAPL")
    
    echo "  ✓ Successfully retrieved quote"
    echo "  Symbol: ", quote.symbol
    echo "  Short Name: ", quote.shortName
    echo "  Quote Type: ", quote.quoteType
    echo "  Currency: ", quote.currency
    echo "  Exchange: ", quote.exchange
    echo ""
    echo "  Price Data:"
    echo "    Current Price: $", quote.regularMarketPrice
    echo "    Change: $", quote.regularMarketChange
    echo "    Change %: ", quote.regularMarketChangePercent, "%"
    echo "    Open: $", quote.regularMarketOpen
    echo "    High: $", quote.regularMarketDayHigh
    echo "    Low: $", quote.regularMarketDayLow
    echo "    Previous Close: $", quote.regularMarketPreviousClose
    echo "    Volume: ", quote.regularMarketVolume
    echo ""
    echo "  Bid/Ask:"
    echo "    Bid: $", quote.bid
    echo "    Ask: $", quote.ask
    echo ""
    echo "  52-Week Range:"
    echo "    Low: $", quote.fiftyTwoWeekLow
    echo "    High: $", quote.fiftyTwoWeekHigh
    echo "    Change %: ", quote.fiftyTwoWeekChangePercent, "%"
    echo ""
    echo "  Moving Averages:"
    echo "    50-Day: $", quote.fiftyDayAverage
    echo "    200-Day: $", quote.twoHundredDayAverage
    echo ""
    echo "  Valuation:"
    echo "    Market Cap: ", quote.marketCap
    echo "    Shares Outstanding: ", quote.sharesOutstanding
    
    if quote.trailingPE.isSome:
      echo "    P/E Ratio: ", quote.trailingPE.get()
    else:
      echo "    P/E Ratio: N/A"
    
    if quote.forwardPE.isSome:
      echo "    Forward P/E: ", quote.forwardPE.get()
    else:
      echo "    Forward P/E: N/A"
    
    echo ""
    echo "  Dividends:"
    if quote.dividendYield.isSome:
      echo "    Dividend Yield: ", quote.dividendYield.get() * 100, "%"
    else:
      echo "    Dividend Yield: N/A"
    
    if quote.dividendRate.isSome:
      echo "    Dividend Rate: $", quote.dividendRate.get()
    else:
      echo "    Dividend Rate: N/A"
    
    echo ""
    echo "  Market State: ", quote.marketState
    echo "  Tradeable: ", quote.tradeable
    
    # Basic validation
    if quote.symbol != "AAPL":
      echo "  ✗ ERROR: Symbol mismatch"
      quit(1)
    
    if quote.regularMarketPrice <= 0.0:
      echo "  ✗ ERROR: Invalid price"
      quit(1)
    
    if quote.currency != "USD":
      echo "  ✗ ERROR: Invalid currency"
      quit(1)
    
    if quote.fiftyTwoWeekLow <= 0.0 or quote.fiftyTwoWeekHigh <= 0.0:
      echo "  ✗ ERROR: Invalid 52-week range"
      quit(1)
    
    echo "✓ Test 1 PASSED"
    
  except Exception as e:
    echo "  ✗ Test 1 FAILED: ", e.msg
    quit(1)
  
  echo ""
  echo "======================================================================="
  echo "Test 2: Fetching multiple quotes (batch)"
  echo "-----------------------------------------------------------------------"
  
  try:
    let symbols = @["AAPL", "MSFT", "GOOGL"]
    let quotes = getQuotes(symbols)
    
    echo "  ✓ Successfully retrieved ", quotes.len, " quotes"
    echo ""
    
    for quote in quotes:
      echo "  ", quote.symbol, ":"
      echo "    Name: ", quote.shortName
      echo "    Price: $", quote.regularMarketPrice
      echo "    Market Cap: ", quote.marketCap
      
      if quote.trailingPE.isSome:
        echo "    P/E: ", quote.trailingPE.get()
      
      echo "    Market State: ", quote.marketState
      echo ""
    
    # Validation
    if quotes.len != 3:
      echo "  ✗ ERROR: Expected 3 quotes, got ", quotes.len
      quit(1)
    
    let gotSymbols = [quotes[0].symbol, quotes[1].symbol, quotes[2].symbol]
    for sym in symbols:
      if sym notin gotSymbols:
        echo "  ✗ ERROR: Missing symbol ", sym
        quit(1)
    
    for quote in quotes:
      if quote.regularMarketPrice <= 0.0:
        echo "  ✗ ERROR: Invalid price for ", quote.symbol
        quit(1)
    
    echo "✓ Test 2 PASSED"
    
  except Exception as e:
    echo "  ✗ Test 2 FAILED: ", e.msg
    quit(1)
  
  echo ""
  echo "======================================================================="
  echo "Test 3: Different security types"
  echo "-----------------------------------------------------------------------"
  
  try:
    # ETF
    echo "  Fetching ETF: SPY"
    let spy = getQuote("SPY")
    echo "    Type: ", spy.quoteType
    echo "    Price: $", spy.regularMarketPrice
    echo ""
    
    # Cryptocurrency
    echo "  Fetching Cryptocurrency: BTC-USD"
    let btc = getQuote("BTC-USD")
    echo "    Type: ", btc.quoteType
    echo "    Price: $", btc.regularMarketPrice
    echo ""
    
    # Index
    echo "  Fetching Index: ^GSPC (S&P 500)"
    let sp500 = getQuote("^GSPC")
    echo "    Type: ", sp500.quoteType
    echo "    Price: ", sp500.regularMarketPrice
    echo ""
    
    # Validation
    if spy.regularMarketPrice <= 0.0:
      echo "  ✗ ERROR: Invalid SPY price"
      quit(1)
    
    if btc.regularMarketPrice <= 0.0:
      echo "  ✗ ERROR: Invalid BTC price"
      quit(1)
    
    if sp500.regularMarketPrice <= 0.0:
      echo "  ✗ ERROR: Invalid S&P 500 price"
      quit(1)
    
    echo "✓ Test 3 PASSED"
    
  except Exception as e:
    echo "  ✗ Test 3 FAILED: ", e.msg
    quit(1)
  
  echo ""
  echo "======================================================================="
  echo "Test 4: Error handling - invalid symbol"
  echo "-----------------------------------------------------------------------"
  
  try:
    echo "  Attempting to fetch invalid symbol: INVALID_XYZ123"
    let quote = getQuote("INVALID_XYZ123")
    echo "  ✗ ERROR: Should have raised an error"
    quit(1)
  except QuoteError as e:
    echo "  ✓ Correctly raised QuoteError: ", e.msg
    echo "✓ Test 4 PASSED"
  except Exception as e:
    echo "  ~ Raised exception: ", e.msg
    echo "✓ Test 4 PASSED (alternative behavior)"
  
  echo ""
  echo "======================================================================="
  echo "Test 5: Empty symbol validation"
  echo "-----------------------------------------------------------------------"
  
  try:
    echo "  Attempting to fetch empty symbol"
    discard getQuote("")
    echo "  ✗ ERROR: Should have raised ValueError"
    quit(1)
  except ValueError as e:
    echo "  ✓ Correctly raised ValueError: ", e.msg
    echo "✓ Test 5 PASSED"
  except Exception as e:
    echo "  ✗ Unexpected exception: ", e.msg
    quit(1)
  
  echo ""
  echo "======================================================================="
  echo "= Integration Tests Complete"
  echo "======================================================================="
  echo ""

when isMainModule:
  main()
