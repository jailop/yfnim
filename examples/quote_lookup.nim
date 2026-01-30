## Quote Lookup Example
##
## Demonstrates retrieving real-time/delayed quote data for stocks

import yfnim/quote_types
import yfnim/quote_retriever
import std/[strformat, times, strutils]

proc formatPrice(price: float): string =
  ## Format price to 2 decimal places
  return &"${price:.2f}"

proc formatLargeNumber(num: int64): string =
  ## Format large numbers with comma separators
  if num == 0:
    return "N/A"
  let str = $num
  var result = ""
  var count = 0
  for i in countdown(str.len - 1, 0):
    if count > 0 and count mod 3 == 0:
      result = "," & result
    result = str[i] & result
    inc count
  return result

proc formatPercent(pct: float): string =
  ## Format percentage with sign and color indicator
  let sign = if pct >= 0: "+" else: ""
  return &"{sign}{pct:.2f}%"

proc displayQuote(quote: Quote) =
  ## Display formatted quote information
  echo "\n" & "=".repeat(70)
  echo &"{quote.symbol} - {quote.longName}"
  echo "=".repeat(70)
  
  # Price information
  echo "\nPrice: ", formatPrice(quote.regularMarketPrice)
  echo "Change: ", formatPrice(quote.regularMarketChange), " (", formatPercent(quote.regularMarketChangePercent), ")"
  echo "Previous Close: ", formatPrice(quote.regularMarketPreviousClose)
  
  # Daily range
  if quote.regularMarketDayLow > 0 and quote.regularMarketDayHigh > 0:
    echo &"Day Range: {formatPrice(quote.regularMarketDayLow)} - {formatPrice(quote.regularMarketDayHigh)}"
  
  # 52-week range
  if quote.fiftyTwoWeekLow > 0 and quote.fiftyTwoWeekHigh > 0:
    echo &"52-Week Range: {formatPrice(quote.fiftyTwoWeekLow)} - {formatPrice(quote.fiftyTwoWeekHigh)}"
    echo "52-Week Change: ", formatPercent(quote.fiftyTwoWeekChangePercent)
  
  # Volume
  if quote.regularMarketVolume > 0:
    echo &"Volume: {formatLargeNumber(quote.regularMarketVolume)}"
  
  # Market info
  echo &"\nExchange: {quote.exchange}"
  echo &"Currency: {quote.currency}"
  echo &"Market State: {quote.marketState}"
  
  # Timestamp
  let quoteTime = fromUnix(quote.regularMarketTime)
  echo &"Quote Time: {quoteTime.format(\"yyyy-MM-dd HH:mm:ss\")}"

proc main() =
  echo "Yahoo Finance Quote Lookup Demo"
  echo "================================\n"
  
  # Example 1: Single stock quote
  echo "Example 1: Getting quote for Apple (AAPL)"
  try:
    let appleQuote = getQuote("AAPL")
    displayQuote(appleQuote)
  except CatchableError as e:
    echo "Error fetching AAPL: ", e.msg
  
  # Example 2: Multiple quotes
  echo "\n\nExample 2: Getting quotes for multiple tech stocks"
  echo "---------------------------------------------------"
  
  try:
    let techSymbols = @["AAPL", "MSFT", "GOOGL", "AMZN"]
    let quotes = getQuotes(techSymbols)
    
    echo &"\nRetrieved {quotes.len} quotes:\n"
    
    # Display compact table
    echo "Symbol".alignLeft(8), 
         "Name".alignLeft(30), 
         "Price".alignLeft(12), 
         "Change".alignLeft(12)
    echo "-".repeat(70)
    
    for quote in quotes:
      let name = if quote.shortName.len > 28: quote.shortName[0..27] & ".." else: quote.shortName
      echo quote.symbol.alignLeft(8),
           name.alignLeft(30),
           formatPrice(quote.regularMarketPrice).alignLeft(12),
           formatPercent(quote.regularMarketChangePercent).alignLeft(12)
    
  except CatchableError as e:
    echo "Error fetching multiple quotes: ", e.msg
  
  # Example 3: Different asset types
  echo "\n\nExample 3: Different asset types"
  echo "---------------------------------------------------"
  
  let symbols = @[
    ("SPY", "ETF"),
    ("BTC-USD", "Cryptocurrency"),
    ("^GSPC", "Index")
  ]
  
  for (symbol, assetType) in symbols:
    try:
      let quote = getQuote(symbol)
      echo &"\n{assetType}: {symbol}"
      echo &"  Name: {quote.shortName}"
      echo &"  Price: {formatPrice(quote.regularMarketPrice)}"
      echo &"  Type: {quote.quoteType}"
    except CatchableError as e:
      echo &"\n{assetType}: {symbol}"
      echo "  Error: ", e.msg
  
  echo "\n\nDone!"

when isMainModule:
  main()
