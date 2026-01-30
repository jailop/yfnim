## Fundamental Analysis Example
##
## Demonstrates using quote data for fundamental analysis and stock screening

import yfnim/quote_types
import yfnim/quote_retriever
import std/[strformat, strutils, tables, options, sequtils]

proc displayFinancialMetrics(quote: Quote) =
  ## Display comprehensive financial metrics for a symbol
  echo "\n" & "=".repeat(70)
  echo &"{quote.symbol} - {quote.longName}"
  echo "=".repeat(70)
  
  # Price Information
  echo "\n📊 PRICE INFORMATION"
  echo &"  Current Price: ${quote.regularMarketPrice:.2f}"
  echo &"  Change: ${quote.regularMarketChange:.2f} ({quote.regularMarketChangePercent:+.2f}%)"
  echo &"  52-Week Range: ${quote.fiftyTwoWeekLow:.2f} - ${quote.fiftyTwoWeekHigh:.2f}"
  
  let change52w = quote.getPriceChange52Week()
  if change52w > 0:
    echo &"  From 52-Week Low: +{change52w:.1f}%"
  
  # Position in range
  if quote.isNearHigh52Week(0.95):
    echo "  ⚠️  Trading near 52-week HIGH"
  elif quote.isNearLow52Week(1.10):
    echo "  ⚠️  Trading near 52-week LOW"
  
  # Valuation Metrics
  if quote.hasFinancialMetrics():
    echo "\n💰 VALUATION METRICS"
    
    let pe = quote.getPERatio()
    if pe > 0:
      echo &"  P/E Ratio (TTM): {pe:.2f}"
      if pe < 15:
        echo "    → Potentially undervalued"
      elif pe > 30:
        echo "    → Potentially overvalued"
    
    let fwdPE = quote.getPERatio(useForward = true)
    if fwdPE > 0 and fwdPE != pe:
      echo &"  Forward P/E: {fwdPE:.2f}"
    
    if quote.priceToBook.isSome:
      let pb = quote.priceToBook.get()
      echo &"  P/B Ratio: {pb:.2f}"
      if pb < 1.0:
        echo "    → Trading below book value"
    
    let eps = quote.getEPS()
    if eps > 0:
      echo &"  EPS (TTM): ${eps:.2f}"
  
  # Dividend Information
  if quote.hasDividends():
    echo "\n💵 DIVIDEND INFORMATION"
    
    let divYield = quote.getDividendYield()
    if divYield > 0:
      echo &"  Dividend Yield: {divYield:.2f}%"
      if divYield > 4.0:
        echo "    → High yield stock"
    
    if quote.dividendRate.isSome:
      echo &"  Annual Dividend: ${quote.dividendRate.get():.2f}"
    
    # Example yield on cost calculation
    let purchasePrice = quote.regularMarketPrice * 0.8  # Assume bought 20% lower
    let yoc = quote.getYieldOnCost(purchasePrice)
    if yoc > 0:
      echo &"  Yield on Cost (if bought at ${purchasePrice:.2f}): {yoc:.2f}%"
  
  # Market Data
  echo "\n📈 MARKET DATA"
  echo &"  Market Cap: ${quote.marketCap}"
  if quote.regularMarketVolume > 0:
    echo "  Volume: ", quote.regularMarketVolume
  if quote.averageDailyVolume3Month > 0:
    echo "  Avg 3M Volume: ", quote.averageDailyVolume3Month
  
  echo &"  Exchange: {quote.exchange}"
  echo &"  Currency: {quote.currency}"


proc screenStocks(symbols: seq[string], criteria: string) =
  ## Screen stocks based on simple criteria
  echo "\n" & "=".repeat(70)
  echo &"STOCK SCREENING: {criteria}"
  echo "=".repeat(70)
  
  echo "\nFetching quotes for ", symbols.len, " symbols..."
  let quotes = getQuotes(symbols)
  
  echo "Symbol".alignLeft(8), "Price".alignLeft(12), "P/E".alignLeft(10), 
       "Div Yield".alignLeft(12), "52W Change".alignLeft(12)
  echo "-".repeat(70)
  
  var matchCount = 0
  
  for quote in quotes:
    let pe = quote.getPERatio()
    let divYield = quote.getDividendYield()
    let change52w = quote.getPriceChange52Week()
    
    # Apply screening criteria
    var matches = false
    case criteria:
    of "value":
      # Value stocks: Low P/E, decent dividend
      matches = pe > 0 and pe < 20 and divYield > 2.0
    of "growth":
      # Growth stocks: Strong 52-week performance
      matches = change52w > 20.0
    of "dividend":
      # Dividend stocks: High yield
      matches = divYield > 3.0
    of "momentum":
      # Momentum: Near 52-week highs
      matches = quote.isNearHigh52Week(0.95)
    else:
      matches = true  # Show all
    
    if matches:
      matchCount += 1
      echo quote.symbol.alignLeft(8),
           (&"${quote.regularMarketPrice:.2f}").alignLeft(12),
           (if pe > 0: &"{pe:.2f}" else: "N/A").alignLeft(10),
           (if divYield > 0: &"{divYield:.2f}%" else: "N/A").alignLeft(12),
           (if change52w != 0: &"{change52w:+.1f}%" else: "N/A").alignLeft(12)
  
  echo "\nMatched ", matchCount, " out of ", quotes.len, " stocks"


proc compareStocks(symbols: seq[string]) =
  ## Compare multiple stocks side-by-side
  echo "\n" & "=".repeat(70)
  echo "STOCK COMPARISON"
  echo "=".repeat(70)
  
  let quotes = getQuotes(symbols)
  
  # Price comparison
  echo "\n💰 PRICE METRICS"
  echo "Symbol".alignLeft(8), "Price".alignLeft(12), "Change %".alignLeft(12), "52W Change".alignLeft(12)
  echo "-".repeat(70)
  
  for quote in quotes:
    echo quote.symbol.alignLeft(8),
         (&"${quote.regularMarketPrice:.2f}").alignLeft(12),
         (&"{quote.regularMarketChangePercent:+.2f}%").alignLeft(12),
         (&"{quote.getPriceChange52Week():+.1f}%").alignLeft(12)
  
  # Valuation comparison
  echo "\n📊 VALUATION METRICS"
  echo "Symbol".alignLeft(8), "P/E Ratio".alignLeft(12), "P/B Ratio".alignLeft(12), "EPS".alignLeft(12)
  echo "-".repeat(70)
  
  for quote in quotes:
    let pe = quote.getPERatio()
    let pb = if quote.priceToBook.isSome: quote.priceToBook.get() else: 0.0
    let eps = quote.getEPS()
    
    echo quote.symbol.alignLeft(8),
         (if pe > 0: &"{pe:.2f}" else: "N/A").alignLeft(12),
         (if pb > 0: &"{pb:.2f}" else: "N/A").alignLeft(12),
         (if eps > 0: &"${eps:.2f}" else: "N/A").alignLeft(12)
  
  # Dividend comparison
  if quotes.anyIt(it.hasDividends()):
    echo "\n💵 DIVIDEND METRICS"
    echo "Symbol".alignLeft(8), "Yield".alignLeft(12), "Annual Rate".alignLeft(15)
    echo "-".repeat(70)
    
    for quote in quotes:
      if quote.hasDividends():
        let divYield = quote.getDividendYield()
        let divRate = if quote.dividendRate.isSome: quote.dividendRate.get() else: 0.0
        
        echo quote.symbol.alignLeft(8),
             (if divYield > 0: &"{divYield:.2f}%" else: "N/A").alignLeft(12),
             (if divRate > 0: &"${divRate:.2f}" else: "N/A").alignLeft(15)


proc main() =
  echo "Yahoo Finance Fundamental Analysis Demo"
  echo "======================================="
  
  # Example 1: Detailed financial analysis of a single stock
  echo "\n\n=== EXAMPLE 1: Detailed Analysis of AAPL ==="
  try:
    let quote = getQuote("AAPL")
    displayFinancialMetrics(quote)
  except CatchableError as e:
    echo "Error: ", e.msg
  
  # Example 2: Stock screening
  echo "\n\n=== EXAMPLE 2: Value Stock Screen ==="
  try:
    let symbols = @["AAPL", "MSFT", "GOOGL", "JNJ", "PG", "KO", "PEP", "WMT"]
    screenStocks(symbols, "value")
  except CatchableError as e:
    echo "Error: ", e.msg
  
  # Example 3: Compare multiple stocks
  echo "\n\n=== EXAMPLE 3: Tech Stock Comparison ==="
  try:
    let techStocks = @["AAPL", "MSFT", "GOOGL", "META"]
    compareStocks(techStocks)
  except CatchableError as e:
    echo "Error: ", e.msg
  
  # Example 4: Dividend stocks
  echo "\n\n=== EXAMPLE 4: High Dividend Yield Screen ==="
  try:
    let dividendCandidates = @["T", "VZ", "MO", "IBM", "XOM", "CVX"]
    screenStocks(dividendCandidates, "dividend")
  except CatchableError as e:
    echo "Error: ", e.msg
  
  echo "\n\nAnalysis complete!"

when isMainModule:
  main()
