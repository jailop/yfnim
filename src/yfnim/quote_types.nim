## Yahoo Finance Quote Types Module
##
## This module defines data types for real-time/delayed market quotes.
##
## **Core Types:**
## - `MarketState`_: Enum for market trading state
## - `QuoteType`_: Enum for security type classification
## - `Quote`_: Complete quote data for a symbol
##
## **Key Functions:**
## - `newQuote`_: Create empty Quote object
## - `toJson`_: Export Quote to JSON
## - `fromJson`_: Import Quote from JSON
## - `parseQuoteType`_: Convert string to QuoteType enum
## - `parseMarketState`_: Convert string to MarketState enum
##
## **Example:**
##
## .. code-block:: nim
##   import yfnim/quote_types
##   
##   # Parse from API response
##   let quote = fromJson(jsonNode, Quote)
##   
##   echo "Symbol: ", quote.symbol
##   echo "Price: $", quote.regularMarketPrice
##   echo "Market: ", quote.marketState
##

import std/[json, strutils, options]

type
  MarketState* = enum
    ## Current state of the market for this symbol
    PreMarket = "PRE"           ## Pre-market trading
    Regular = "REGULAR"          ## Regular market hours
    Post = "POST"                ## Post-market trading
    Closed = "CLOSED"            ## Market closed
    Unknown = "UNKNOWN"          ## Unknown state
  
  QuoteType* = enum
    ## Type/category of the security
    Equity = "EQUITY"                    ## Stock
    ETF = "ETF"                          ## Exchange Traded Fund
    Mutualfund = "MUTUALFUND"            ## Mutual Fund
    Index = "INDEX"                      ## Market Index
    Currency = "CURRENCY"                ## Fiat Currency
    Cryptocurrency = "CRYPTOCURRENCY"    ## Cryptocurrency
    Future = "FUTURE"                    ## Futures Contract
    Option = "OPTION"                    ## Options Contract
    UnknownType = "UNKNOWN"              ## Unknown type
  
  Quote* = object
    ## Complete quote data for a security
    ## 
    ## Contains real-time or delayed market data including price,
    ## volume, valuation metrics, and market state.
    
    # Identification
    symbol*: string                      ## Ticker symbol (e.g., "AAPL")
    shortName*: string                   ## Short display name
    longName*: string                    ## Full company/security name
    quoteType*: QuoteType                ## Type of security
    currency*: string                    ## Currency code (e.g., "USD")
    exchange*: string                    ## Exchange code (e.g., "NMS")
    exchangeTimezone*: string            ## Exchange timezone
    
    # Price Data
    regularMarketPrice*: float64         ## Current/last price
    regularMarketTime*: int64            ## Time of last price (Unix timestamp)
    regularMarketChange*: float64        ## Price change from previous close
    regularMarketChangePercent*: float64 ## Percent change from previous close
    regularMarketOpen*: float64          ## Opening price
    regularMarketDayHigh*: float64       ## Day's high price
    regularMarketDayLow*: float64        ## Day's low price
    regularMarketVolume*: int64          ## Volume traded today
    regularMarketPreviousClose*: float64 ## Previous closing price
    
    # Bid/Ask
    bid*: float64                        ## Current bid price
    ask*: float64                        ## Current ask price
    bidSize*: int64                      ## Bid size (number of shares)
    askSize*: int64                      ## Ask size (number of shares)
    
    # 52-Week Range
    fiftyTwoWeekLow*: float64            ## 52-week low price
    fiftyTwoWeekHigh*: float64           ## 52-week high price
    fiftyTwoWeekChangePercent*: float64  ## Change from 52-week low (%)
    
    # Moving Averages
    fiftyDayAverage*: float64            ## 50-day moving average
    fiftyDayAverageChange*: float64      ## Change from 50-day MA
    fiftyDayAverageChangePercent*: float64 ## % change from 50-day MA
    twoHundredDayAverage*: float64       ## 200-day moving average
    twoHundredDayAverageChange*: float64 ## Change from 200-day MA
    twoHundredDayAverageChangePercent*: float64 ## % change from 200-day MA
    
    # Volume Averages
    averageDailyVolume3Month*: int64     ## Average volume over 3 months
    averageDailyVolume10Day*: int64      ## Average volume over 10 days
    
    # Valuation Metrics
    marketCap*: int64                    ## Market capitalization
    sharesOutstanding*: int64            ## Total shares outstanding
    trailingPE*: Option[float64]         ## Trailing P/E ratio (can be null)
    forwardPE*: Option[float64]          ## Forward P/E ratio (can be null)
    priceToBook*: Option[float64]        ## Price to Book ratio (can be null)
    bookValue*: Option[float64]          ## Book value per share
    
    # Earnings
    earningsPerShare*: Option[float64]   ## Earnings per share (can be null)
    epsTrailingTwelveMonths*: Option[float64] ## EPS TTM
    epsForward*: Option[float64]         ## Forward EPS estimate
    epsCurrentYear*: Option[float64]     ## Current year EPS estimate
    
    # Dividend Info
    dividendRate*: Option[float64]       ## Annual dividend rate
    dividendYield*: Option[float64]      ## Dividend yield (%)
    exDividendDate*: Option[int64]       ## Ex-dividend date (Unix timestamp)
    trailingAnnualDividendRate*: Option[float64]  ## Trailing annual dividend
    trailingAnnualDividendYield*: Option[float64] ## Trailing dividend yield
    
    # Trading State
    marketState*: MarketState            ## Current market state
    tradeable*: bool                     ## Whether symbol is tradeable
    triggerable*: bool                   ## Whether triggers are supported


proc parseQuoteType*(s: string): QuoteType =
  ## Converts a string to QuoteType enum
  ##
  ## Example:
  ##   let qt = parseQuoteType("EQUITY")  # Returns QuoteType.Equity
  case s.toUpper()
  of "EQUITY": Equity
  of "ETF": ETF
  of "MUTUALFUND", "MUTUAL_FUND": Mutualfund
  of "INDEX": Index
  of "CURRENCY": Currency
  of "CRYPTOCURRENCY": Cryptocurrency
  of "FUTURE": Future
  of "OPTION": Option
  else: UnknownType


proc parseMarketState*(s: string): MarketState =
  ## Converts a string to MarketState enum
  ##
  ## Example:
  ##   let ms = parseMarketState("REGULAR")  # Returns MarketState.Regular
  case s.toUpper()
  of "PRE", "PREPRE", "PRE_MARKET": PreMarket
  of "REGULAR": Regular
  of "POST", "POSTPOST", "POST_MARKET": Post
  of "CLOSED": Closed
  else: Unknown


proc newQuote*(symbol: string): Quote =
  ## Creates a new Quote with default values
  ##
  ## Example:
  ##   let quote = newQuote("AAPL")
  result = Quote(
    symbol: symbol,
    shortName: "",
    longName: "",
    quoteType: UnknownType,
    currency: "USD",
    exchange: "",
    exchangeTimezone: "",
    regularMarketPrice: 0.0,
    regularMarketTime: 0,
    regularMarketChange: 0.0,
    regularMarketChangePercent: 0.0,
    regularMarketOpen: 0.0,
    regularMarketDayHigh: 0.0,
    regularMarketDayLow: 0.0,
    regularMarketVolume: 0,
    regularMarketPreviousClose: 0.0,
    bid: 0.0,
    ask: 0.0,
    bidSize: 0,
    askSize: 0,
    fiftyTwoWeekLow: 0.0,
    fiftyTwoWeekHigh: 0.0,
    fiftyTwoWeekChangePercent: 0.0,
    fiftyDayAverage: 0.0,
    fiftyDayAverageChange: 0.0,
    fiftyDayAverageChangePercent: 0.0,
    twoHundredDayAverage: 0.0,
    twoHundredDayAverageChange: 0.0,
    twoHundredDayAverageChangePercent: 0.0,
    averageDailyVolume3Month: 0,
    averageDailyVolume10Day: 0,
    marketCap: 0,
    sharesOutstanding: 0,
    trailingPE: none(float64),
    forwardPE: none(float64),
    priceToBook: none(float64),
    bookValue: none(float64),
    earningsPerShare: none(float64),
    epsTrailingTwelveMonths: none(float64),
    epsForward: none(float64),
    epsCurrentYear: none(float64),
    dividendRate: none(float64),
    dividendYield: none(float64),
    exDividendDate: none(int64),
    trailingAnnualDividendRate: none(float64),
    trailingAnnualDividendYield: none(float64),
    marketState: Unknown,
    tradeable: false,
    triggerable: false
  )


proc toJson*(quote: Quote): JsonNode =
  ## Converts a Quote to JSON
  ##
  ## Example:
  ##   let jsonNode = quote.toJson()
  ##   echo $jsonNode
  result = %*{
    "symbol": quote.symbol,
    "shortName": quote.shortName,
    "longName": quote.longName,
    "quoteType": $quote.quoteType,
    "currency": quote.currency,
    "exchange": quote.exchange,
    "exchangeTimezone": quote.exchangeTimezone,
    "regularMarketPrice": quote.regularMarketPrice,
    "regularMarketTime": quote.regularMarketTime,
    "regularMarketChange": quote.regularMarketChange,
    "regularMarketChangePercent": quote.regularMarketChangePercent,
    "regularMarketOpen": quote.regularMarketOpen,
    "regularMarketDayHigh": quote.regularMarketDayHigh,
    "regularMarketDayLow": quote.regularMarketDayLow,
    "regularMarketVolume": quote.regularMarketVolume,
    "regularMarketPreviousClose": quote.regularMarketPreviousClose,
    "bid": quote.bid,
    "ask": quote.ask,
    "bidSize": quote.bidSize,
    "askSize": quote.askSize,
    "fiftyTwoWeekLow": quote.fiftyTwoWeekLow,
    "fiftyTwoWeekHigh": quote.fiftyTwoWeekHigh,
    "fiftyTwoWeekChangePercent": quote.fiftyTwoWeekChangePercent,
    "fiftyDayAverage": quote.fiftyDayAverage,
    "fiftyDayAverageChange": quote.fiftyDayAverageChange,
    "fiftyDayAverageChangePercent": quote.fiftyDayAverageChangePercent,
    "twoHundredDayAverage": quote.twoHundredDayAverage,
    "twoHundredDayAverageChange": quote.twoHundredDayAverageChange,
    "twoHundredDayAverageChangePercent": quote.twoHundredDayAverageChangePercent,
    "averageDailyVolume3Month": quote.averageDailyVolume3Month,
    "averageDailyVolume10Day": quote.averageDailyVolume10Day,
    "marketCap": quote.marketCap,
    "sharesOutstanding": quote.sharesOutstanding,
    "marketState": $quote.marketState,
    "tradeable": quote.tradeable,
    "triggerable": quote.triggerable
  }
  
  # Handle Option fields
  if quote.trailingPE.isSome:
    result["trailingPE"] = %quote.trailingPE.get()
  if quote.forwardPE.isSome:
    result["forwardPE"] = %quote.forwardPE.get()
  if quote.priceToBook.isSome:
    result["priceToBook"] = %quote.priceToBook.get()
  if quote.bookValue.isSome:
    result["bookValue"] = %quote.bookValue.get()
  if quote.earningsPerShare.isSome:
    result["earningsPerShare"] = %quote.earningsPerShare.get()
  if quote.epsTrailingTwelveMonths.isSome:
    result["epsTrailingTwelveMonths"] = %quote.epsTrailingTwelveMonths.get()
  if quote.epsForward.isSome:
    result["epsForward"] = %quote.epsForward.get()
  if quote.epsCurrentYear.isSome:
    result["epsCurrentYear"] = %quote.epsCurrentYear.get()
  if quote.dividendRate.isSome:
    result["dividendRate"] = %quote.dividendRate.get()
  if quote.dividendYield.isSome:
    result["dividendYield"] = %quote.dividendYield.get()
  if quote.exDividendDate.isSome:
    result["exDividendDate"] = %quote.exDividendDate.get()
  if quote.trailingAnnualDividendRate.isSome:
    result["trailingAnnualDividendRate"] = %quote.trailingAnnualDividendRate.get()
  if quote.trailingAnnualDividendYield.isSome:
    result["trailingAnnualDividendYield"] = %quote.trailingAnnualDividendYield.get()


proc fromJson*(node: JsonNode, T: typedesc[Quote]): Quote =
  ## Parses a Quote from JSON
  ##
  ## Handles null/missing values gracefully using Option types.
  ##
  ## Example:
  ##   let quote = fromJson(jsonNode, Quote)
  
  # Helper to safely get string
  proc safeGetStr(n: JsonNode, key: string, default: string = ""): string =
    if n.hasKey(key) and n[key].kind != JNull:
      n[key].getStr(default)
    else:
      default
  
  # Helper to safely get int
  proc safeGetInt(n: JsonNode, key: string, default: int64 = 0): int64 =
    if n.hasKey(key) and n[key].kind != JNull:
      n[key].getInt(default)
    else:
      default
  
  # Helper to safely get float
  proc safeGetFloat(n: JsonNode, key: string, default: float64 = 0.0): float64 =
    if n.hasKey(key) and n[key].kind != JNull:
      n[key].getFloat(default)
    else:
      default
  
  # Helper to safely get bool
  proc safeGetBool(n: JsonNode, key: string, default: bool = false): bool =
    if n.hasKey(key) and n[key].kind != JNull:
      n[key].getBool(default)
    else:
      default
  
  # Helper to get optional float
  proc safeGetOptFloat(n: JsonNode, key: string): Option[float64] =
    if n.hasKey(key) and n[key].kind != JNull:
      some(n[key].getFloat())
    else:
      none(float64)
  
  # Helper to get optional int
  proc safeGetOptInt(n: JsonNode, key: string): Option[int64] =
    if n.hasKey(key) and n[key].kind != JNull:
      some(int64(n[key].getInt()))
    else:
      none(int64)
  
  result = Quote(
    symbol: node.safeGetStr("symbol"),
    shortName: node.safeGetStr("shortName"),
    longName: node.safeGetStr("longName"),
    quoteType: parseQuoteType(node.safeGetStr("quoteType", "UNKNOWN")),
    currency: node.safeGetStr("currency", "USD"),
    exchange: node.safeGetStr("exchange"),
    exchangeTimezone: node.safeGetStr("exchangeTimezoneShortName"),
    
    regularMarketPrice: node.safeGetFloat("regularMarketPrice"),
    regularMarketTime: node.safeGetInt("regularMarketTime"),
    regularMarketChange: node.safeGetFloat("regularMarketChange"),
    regularMarketChangePercent: node.safeGetFloat("regularMarketChangePercent"),
    regularMarketOpen: node.safeGetFloat("regularMarketOpen"),
    regularMarketDayHigh: node.safeGetFloat("regularMarketDayHigh"),
    regularMarketDayLow: node.safeGetFloat("regularMarketDayLow"),
    regularMarketVolume: node.safeGetInt("regularMarketVolume"),
    regularMarketPreviousClose: node.safeGetFloat("regularMarketPreviousClose"),
    
    bid: node.safeGetFloat("bid"),
    ask: node.safeGetFloat("ask"),
    bidSize: node.safeGetInt("bidSize"),
    askSize: node.safeGetInt("askSize"),
    
    fiftyTwoWeekLow: node.safeGetFloat("fiftyTwoWeekLow"),
    fiftyTwoWeekHigh: node.safeGetFloat("fiftyTwoWeekHigh"),
    fiftyTwoWeekChangePercent: node.safeGetFloat("fiftyTwoWeekChangePercent"),
    
    fiftyDayAverage: node.safeGetFloat("fiftyDayAverage"),
    fiftyDayAverageChange: node.safeGetFloat("fiftyDayAverageChange"),
    fiftyDayAverageChangePercent: node.safeGetFloat("fiftyDayAverageChangePercent"),
    twoHundredDayAverage: node.safeGetFloat("twoHundredDayAverage"),
    twoHundredDayAverageChange: node.safeGetFloat("twoHundredDayAverageChange"),
    twoHundredDayAverageChangePercent: node.safeGetFloat("twoHundredDayAverageChangePercent"),
    
    averageDailyVolume3Month: node.safeGetInt("averageDailyVolume3Month"),
    averageDailyVolume10Day: node.safeGetInt("averageDailyVolume10Day"),
    
    marketCap: node.safeGetInt("marketCap"),
    sharesOutstanding: node.safeGetInt("sharesOutstanding"),
    
    trailingPE: node.safeGetOptFloat("trailingPE"),
    forwardPE: node.safeGetOptFloat("forwardPE"),
    priceToBook: node.safeGetOptFloat("priceToBook"),
    bookValue: node.safeGetOptFloat("bookValue"),
    
    earningsPerShare: node.safeGetOptFloat("epsTrailingTwelveMonths"),
    epsTrailingTwelveMonths: node.safeGetOptFloat("epsTrailingTwelveMonths"),
    epsForward: node.safeGetOptFloat("epsForward"),
    epsCurrentYear: node.safeGetOptFloat("epsCurrentYear"),
    
    dividendRate: node.safeGetOptFloat("dividendRate"),
    dividendYield: node.safeGetOptFloat("dividendYield"),
    exDividendDate: node.safeGetOptInt("exDividendDate"),
    trailingAnnualDividendRate: node.safeGetOptFloat("trailingAnnualDividendRate"),
    trailingAnnualDividendYield: node.safeGetOptFloat("trailingAnnualDividendYield"),
    
    marketState: parseMarketState(node.safeGetStr("marketState", "UNKNOWN")),
    tradeable: node.safeGetBool("tradeable"),
    triggerable: node.safeGetBool("triggerable")
  )


# Financial Analysis Helper Functions

proc hasFinancialMetrics*(quote: Quote): bool =
  ## Checks if quote has basic financial metrics available
  ##
  ## Returns true if at least one financial metric is present
  ##
  ## Example:
  ##   if quote.hasFinancialMetrics():
  ##     echo "Financial data available"
  quote.trailingPE.isSome or 
  quote.forwardPE.isSome or 
  quote.priceToBook.isSome or
  quote.earningsPerShare.isSome


proc hasDividends*(quote: Quote): bool =
  ## Checks if the symbol pays dividends
  ##
  ## Returns true if dividend rate or yield is available
  ##
  ## Example:
  ##   if quote.hasDividends():
  ##     echo "This stock pays dividends"
  (quote.dividendRate.isSome and quote.dividendRate.get() > 0) or
  (quote.dividendYield.isSome and quote.dividendYield.get() > 0)


proc getPERatio*(quote: Quote, useForward: bool = false): float64 =
  ## Gets P/E ratio, preferring trailing unless useForward is true
  ##
  ## Returns 0.0 if not available
  ##
  ## Parameters:
  ##   - useForward: If true, use forward P/E; otherwise use trailing P/E
  ##
  ## Example:
  ##   let pe = quote.getPERatio()
  ##   if pe > 0:
  ##     echo "P/E Ratio: ", pe
  if useForward and quote.forwardPE.isSome:
    return quote.forwardPE.get()
  elif quote.trailingPE.isSome:
    return quote.trailingPE.get()
  else:
    return 0.0


proc getDividendYield*(quote: Quote): float64 =
  ## Gets dividend yield as a percentage
  ##
  ## Returns 0.0 if not available
  ##
  ## Example:
  ##   let yield = quote.getDividendYield()
  ##   echo "Dividend Yield: ", yield, "%"
  if quote.dividendYield.isSome:
    return quote.dividendYield.get() * 100.0
  else:
    return 0.0


proc getEPS*(quote: Quote): float64 =
  ## Gets earnings per share (EPS), preferring TTM
  ##
  ## Returns 0.0 if not available
  ##
  ## Example:
  ##   let eps = quote.getEPS()
  ##   if eps > 0:
  ##     echo "EPS: $", eps
  if quote.epsTrailingTwelveMonths.isSome:
    return quote.epsTrailingTwelveMonths.get()
  elif quote.earningsPerShare.isSome:
    return quote.earningsPerShare.get()
  else:
    return 0.0


proc getYieldOnCost*(quote: Quote, purchasePrice: float64): float64 =
  ## Calculates yield on cost based on purchase price
  ##
  ## Returns the dividend yield based on your original purchase price
  ##
  ## Parameters:
  ##   - purchasePrice: The price you paid per share
  ##
  ## Returns:
  ##   Yield on cost as a percentage, or 0.0 if no dividend
  ##
  ## Example:
  ##   let yoc = quote.getYieldOnCost(100.0)
  ##   echo "Yield on cost: ", yoc, "%"
  if quote.dividendRate.isNone or purchasePrice <= 0:
    return 0.0
  return (quote.dividendRate.get() / purchasePrice) * 100.0


proc getPriceChange52Week*(quote: Quote): float64 =
  ## Calculates price change from 52-week low as a percentage
  ##
  ## Already available as fiftyTwoWeekChangePercent, but provided
  ## for convenience
  ##
  ## Example:
  ##   let change = quote.getPriceChange52Week()
  ##   echo "Up ", change, "% from 52-week low"
  return quote.fiftyTwoWeekChangePercent


proc isNearHigh52Week*(quote: Quote, threshold: float64 = 0.95): bool =
  ## Checks if current price is near the 52-week high
  ##
  ## Parameters:
  ##   - threshold: Percentage of 52-week high (default 0.95 = 95%)
  ##
  ## Returns:
  ##   True if current price >= threshold * 52-week high
  ##
  ## Example:
  ##   if quote.isNearHigh52Week(0.98):
  ##     echo "Trading near 52-week high!"
  if quote.fiftyTwoWeekHigh <= 0:
    return false
  return quote.regularMarketPrice >= (quote.fiftyTwoWeekHigh * threshold)


proc isNearLow52Week*(quote: Quote, threshold: float64 = 1.05): bool =
  ## Checks if current price is near the 52-week low
  ##
  ## Parameters:
  ##   - threshold: Multiplier of 52-week low (default 1.05 = 105%)
  ##
  ## Returns:
  ##   True if current price <= threshold * 52-week low
  ##
  ## Example:
  ##   if quote.isNearLow52Week(1.10):
  ##     echo "Trading near 52-week low!"
  if quote.fiftyTwoWeekLow <= 0:
    return false
  return quote.regularMarketPrice <= (quote.fiftyTwoWeekLow * threshold)


proc formatMetrics*(quote: Quote): string =
  ## Formats key financial metrics as a readable string
  ##
  ## Returns:
  ##   Multi-line string with formatted metrics
  ##
  ## Example:
  ##   echo quote.formatMetrics()
  result = "Financial Metrics for " & quote.symbol & ":\n"
  result &= "  Price: $" & $quote.regularMarketPrice & "\n"
  
  let pe = quote.getPERatio()
  if pe > 0:
    result &= "  P/E Ratio: " & $pe & "\n"
  
  if quote.priceToBook.isSome:
    result &= "  P/B Ratio: " & $quote.priceToBook.get() & "\n"
  
  let eps = quote.getEPS()
  if eps > 0:
    result &= "  EPS: $" & $eps & "\n"
  
  if quote.hasDividends():
    result &= "  Dividend Yield: " & $quote.getDividendYield() & "%\n"
    if quote.dividendRate.isSome:
      result &= "  Dividend Rate: $" & $quote.dividendRate.get() & "\n"
  
  if quote.marketCap > 0:
    result &= "  Market Cap: " & $quote.marketCap & "\n"
