## Batch Quote Retrieval Example
##
## Demonstrates retrieving quotes for multiple symbols efficiently.
## Shows how to handle batch requests and display comparative data.

import yfnim
import std/[strformat, terminal]

proc formatPrice(value: float): string =
  ## Format price with currency symbol
  &"${value:>8.2f}"

proc formatPercent(value: float): string =
  ## Format percentage with color
  let sign = if value >= 0: "+" else: ""
  let color = if value >= 0: fgGreen else: fgRed
  result = sign & &"{value:.2f}%"
  stdout.styledWrite(color, result)
  result = ""  # Clear since we already wrote

proc main() =
  # Define watchlist of symbols to monitor
  let watchlist = @["AAPL", "MSFT", "GOOGL", "AMZN", "TSLA", "NVDA", "META", "BRK-B"]
  
  echo "Fetching quotes for ", watchlist.len, " symbols..."
  echo ""
  
  try:
    # Fetch all quotes in batch
    let quotes = getQuotes(watchlist)
    
    if quotes.len == 0:
      echo "No quotes retrieved. Check symbols and network connection."
      quit(1)
    
    echo "Retrieved ", quotes.len, " quotes"
    echo ""
    
    # Display table header
    echo "Symbol   | Company Name              | Price     | Change    | Volume       | Mkt Cap"
    echo "---------|---------------------------|-----------|-----------|--------------|------------------"
    
    # Display each quote
    for quote in quotes:
      # Truncate company name if too long
      let name = if quote.shortName.len > 25:
                   quote.shortName[0..21] & "..."
                 else:
                   quote.shortName
      
      # Format market cap
      let mktCapStr = if quote.marketCap > 0:
                        let trillion = quote.marketCap.float / 1_000_000_000_000.0
                        let billion = quote.marketCap.float / 1_000_000_000.0
                        if trillion >= 1.0:
                          &"{trillion:.2f}T"
                        else:
                          &"{billion:.2f}B"
                      else:
                        "N/A"
      
      # Print row with formatted data
      stdout.write &"{quote.symbol:<8} | {name:<25} | "
      stdout.write formatPrice(quote.regularMarketPrice), " | "
      stdout.write formatPercent(quote.regularMarketChangePercent)
      stdout.write &" | {quote.regularMarketVolume:>12} | {mktCapStr}\n"
    
    # Calculate summary statistics
    echo ""
    echo "Summary Statistics:"
    echo "-------------------"
    
    var gainers = 0
    var losers = 0
    var totalChange = 0.0
    var maxGain = -999999.0
    var maxLoss = 999999.0
    var maxGainerSymbol = ""
    var maxLoserSymbol = ""
    
    for quote in quotes:
      let change = quote.regularMarketChangePercent
      totalChange += change
      
      if change > 0:
        gainers += 1
        if change > maxGain:
          maxGain = change
          maxGainerSymbol = quote.symbol
      elif change < 0:
        losers += 1
        if change < maxLoss:
          maxLoss = change
          maxLoserSymbol = quote.symbol
    
    let avgChange = totalChange / quotes.len.float
    
    echo "  Gainers: ", gainers
    echo "  Losers:  ", losers
    echo "  Unchanged: ", quotes.len - gainers - losers
    echo "  Average change: ", &"{avgChange:.2f}%"
    
    if maxGainerSymbol != "":
      echo "  Top gainer: ", maxGainerSymbol, " (", &"{maxGain:+.2f}%", ")"
    if maxLoserSymbol != "":
      echo "  Top loser:  ", maxLoserSymbol, " (", &"{maxLoss:+.2f}%", ")"
    
    # Show 52-week performance
    echo ""
    echo "52-Week Performance:"
    echo "--------------------"
    for quote in quotes:
      if quote.fiftyTwoWeekLow > 0 and quote.fiftyTwoWeekHigh > 0:
        let range = quote.fiftyTwoWeekHigh - quote.fiftyTwoWeekLow
        let position = quote.regularMarketPrice - quote.fiftyTwoWeekLow
        let pct = (position / range) * 100.0
        
        echo &"  {quote.symbol:<8}: ${quote.fiftyTwoWeekLow:.2f} - ${quote.fiftyTwoWeekHigh:.2f} "
        echo &"             Current: ${quote.regularMarketPrice:.2f} ({pct:.1f}% through range)"
    
  except ValueError as e:
    echo "Invalid input: ", e.msg
    quit(1)
  except CatchableError as e:
    echo "Error: ", e.msg
    quit(1)

when isMainModule:
  main()
