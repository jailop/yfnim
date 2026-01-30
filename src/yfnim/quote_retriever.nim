## Yahoo Finance Quote Retriever Module
##
## This module handles HTTP requests and JSON parsing for quote data.
##
## **Main Functions:**
## - `getQuote`_: Retrieve quote for a single symbol
## - `getQuotes`_: Retrieve quotes for multiple symbols (concurrent requests)
##
## **Example:**
##
## .. code-block:: nim
##   import yfnim/quote_retriever
##   
##   # Single symbol
##   let quote = getQuote("AAPL")
##   echo "Price: $", quote.regularMarketPrice
##   
##   # Multiple symbols
##   let quotes = getQuotes(@["AAPL", "MSFT", "GOOGL"])
##   for q in quotes:
##     echo q.symbol, ": $", q.regularMarketPrice
##

import std/[httpclient, json, strutils, uri, options]
import quote_types
import retriever  # For error types

type
  QuoteError* = object of YahooApiError
    ## Exception raised when quote API returns an error


proc buildQuoteUrl*(symbol: string): string =
  ## Builds Yahoo Finance chart API URL for a symbol
  ##
  ## We use the chart endpoint with range=1d to get the latest quote
  ## data from the 'meta' section of the response.
  ##
  ## Parameters:
  ##   - symbol: Ticker symbol
  ##
  ## Returns:
  ##   Complete URL for chart API request
  ##
  ## Example:
  ##   let url = buildQuoteUrl("AAPL")
  ##   # Returns: https://query2.finance.yahoo.com/v8/finance/chart/AAPL?interval=1d&range=1d
  
  if symbol.strip().len == 0:
    raise newException(ValueError, "Symbol cannot be empty")
  
  let baseUrl = "https://query2.finance.yahoo.com/v8/finance/chart"
  result = baseUrl & "/" & encodeUrl(symbol.strip()) & "?interval=1d&range=1d"


proc retrieveQuoteJson*(url: string): string =
  ## Retrieves JSON data from chart API
  ##
  ## Parameters:
  ##   - url: The URL to fetch
  ##
  ## Returns:
  ##   Response body as string
  ##
  ## Raises:
  ##   - HttpRequestError: On network or HTTP errors
  var client = newHttpClient()
  try:
    # Add user agent to avoid rate limiting
    client.headers = newHttpHeaders({
      "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36"
    })
    
    let response = client.getContent(url)
    return response
  except HttpRequestError as e:
    raise newException(HttpRequestError, "HTTP request failed: " & e.msg)
  except Exception as e:
    raise newException(HttpRequestError, "Network error: " & e.msg)
  finally:
    client.close()



# Helper functions for safe JSON field access
proc safeGetStr(node: JsonNode, key: string, default: string = ""): string =
  if node.hasKey(key) and node[key].kind == JString:
    return node[key].getStr()
  return default

proc safeGetFloat(node: JsonNode, key: string, default: float64 = 0.0): float64 =
  if node.hasKey(key):
    case node[key].kind
    of JFloat: return node[key].getFloat()
    of JInt: return node[key].getInt().float64
    else: return default
  return default

proc safeGetInt64(node: JsonNode, key: string, default: int64 = 0): int64 =
  if node.hasKey(key):
    case node[key].kind
    of JInt: return node[key].getInt().int64
    of JFloat: return node[key].getFloat().int64
    else: return default
  return default

proc safeGetOptFloat(node: JsonNode, key: string): Option[float64] =
  if node.hasKey(key) and node[key].kind != JNull:
    case node[key].kind
    of JFloat: return some(node[key].getFloat())
    of JInt: return some(node[key].getInt().float64)
    else: return none(float64)
  return none(float64)


proc parseQuoteResponse*(body: string): Quote =
  ## Parses Yahoo Finance chart JSON response to extract quote data
  ##
  ## Parameters:
  ##   - body: JSON response body as string
  ##
  ## Returns:
  ##   Quote object with market data
  ##
  ## Raises:
  ##   - JsonParsingError: On invalid JSON
  ##   - QuoteError: If API returns an error
  try:
    let jsonNode = parseJson(body)
    
    # Check for chart response structure
    if not jsonNode.hasKey("chart"):
      raise newException(JsonParsingError, "Missing 'chart' field in response")
    
    let chart = jsonNode["chart"]
    
    # Check for error
    if chart.hasKey("error") and chart["error"].kind != JNull:
      let errorMsg = chart["error"].getStr("Unknown API error")
      raise newException(QuoteError, "Yahoo Finance API error: " & errorMsg)
    
    if not chart.hasKey("result"):
      raise newException(JsonParsingError, "Missing 'result' field in chart")
    
    let resultArray = chart["result"]
    
    if resultArray.kind != JArray or resultArray.len == 0:
      raise newException(QuoteError, "No data returned from API")
    
    # Get the first result and extract meta
    let result = resultArray[0]
    if not result.hasKey("meta"):
      raise newException(JsonParsingError, "Missing 'meta' field in result")
    
    let meta = result["meta"]
    
    # Parse Quote object from meta
    # Get symbol first to initialize Quote
    let symbol = safeGetStr(meta, "symbol")
    var quote = newQuote(symbol)
    quote.shortName = safeGetStr(meta, "shortName")
    quote.longName = safeGetStr(meta, "longName")
    quote.currency = safeGetStr(meta, "currency")
    quote.exchange = safeGetStr(meta, "exchangeName")
    quote.exchangeTimezone = safeGetStr(meta, "exchangeTimezoneName")
    
    # Parse quote type
    let quoteTypeStr = safeGetStr(meta, "instrumentType")
    quote.quoteType = parseQuoteType(quoteTypeStr)
    
    # Market state (infer from time)
    quote.marketState = Regular  # Default, could be enhanced
    
    # Price data
    quote.regularMarketPrice = safeGetFloat(meta, "regularMarketPrice")
    quote.regularMarketTime = safeGetInt64(meta, "regularMarketTime")
    quote.regularMarketOpen = safeGetFloat(meta, "regularMarketDayOpen", 
                                           safeGetFloat(meta, "previousClose"))
    quote.regularMarketDayHigh = safeGetFloat(meta, "regularMarketDayHigh")
    quote.regularMarketDayLow = safeGetFloat(meta, "regularMarketDayLow")
    quote.regularMarketVolume = safeGetInt64(meta, "regularMarketVolume")
    quote.regularMarketPreviousClose = safeGetFloat(meta, "chartPreviousClose",
                                                     safeGetFloat(meta, "previousClose"))
    
    # Calculate change if we have current and previous
    if quote.regularMarketPreviousClose > 0:
      quote.regularMarketChange = quote.regularMarketPrice - quote.regularMarketPreviousClose
      quote.regularMarketChangePercent = (quote.regularMarketChange / quote.regularMarketPreviousClose) * 100.0
    
    # 52-week range
    quote.fiftyTwoWeekLow = safeGetFloat(meta, "fiftyTwoWeekLow")
    quote.fiftyTwoWeekHigh = safeGetFloat(meta, "fiftyTwoWeekHigh")
    
    # Calculate 52-week change percent
    if quote.fiftyTwoWeekLow > 0:
      quote.fiftyTwoWeekChangePercent = ((quote.regularMarketPrice - quote.fiftyTwoWeekLow) / quote.fiftyTwoWeekLow) * 100.0
    
    # Moving averages
    quote.fiftyDayAverage = safeGetFloat(meta, "fiftyDayAverage")
    if quote.fiftyDayAverage > 0:
      quote.fiftyDayAverageChange = quote.regularMarketPrice - quote.fiftyDayAverage
      quote.fiftyDayAverageChangePercent = (quote.fiftyDayAverageChange / quote.fiftyDayAverage) * 100.0
    
    quote.twoHundredDayAverage = safeGetFloat(meta, "twoHundredDayAverage")
    if quote.twoHundredDayAverage > 0:
      quote.twoHundredDayAverageChange = quote.regularMarketPrice - quote.twoHundredDayAverage
      quote.twoHundredDayAverageChangePercent = (quote.twoHundredDayAverageChange / quote.twoHundredDayAverage) * 100.0
    
    # Volume info
    quote.averageDailyVolume3Month = safeGetInt64(meta, "averageDailyVolume3Month")
    quote.averageDailyVolume10Day = safeGetInt64(meta, "averageDailyVolume10Day")
    
    # Market cap and shares
    quote.marketCap = safeGetInt64(meta, "marketCap")
    quote.sharesOutstanding = safeGetInt64(meta, "sharesOutstanding")
    
    # Optional fields that may not be in meta (would need additional API call)
    # These are left as defaults/zero
    
    return quote
    
  except JsonParsingError:
    raise
  except QuoteError:
    raise
  except Exception as e:
    raise newException(JsonParsingError, "JSON parsing failed: " & e.msg)



proc getQuotes*(symbols: seq[string]): seq[Quote] =
  ## Retrieves quotes for multiple symbols from Yahoo Finance
  ##
  ## This function makes concurrent requests for each symbol.
  ## 
  ## Parameters:
  ##   - symbols: Sequence of ticker symbols (e.g., @["AAPL", "MSFT"])
  ##
  ## Returns:
  ##   Sequence of Quote objects (may be shorter than input if symbols invalid)
  ##
  ## Raises:
  ##   - ValueError: If symbols list is empty
  ##
  ## Example:
  ##   let quotes = getQuotes(@["AAPL", "MSFT", "GOOGL"])
  ##   for quote in quotes:
  ##     echo quote.symbol, ": $", quote.regularMarketPrice
  
  # Input validation
  if symbols.len == 0:
    raise newException(ValueError, "Symbols list cannot be empty")
  
  # Validate and normalize symbols
  var normalizedSymbols = newSeq[string]()
  for symbol in symbols:
    let trimmed = symbol.strip()
    if trimmed.len == 0:
      raise newException(ValueError, "Symbol cannot be empty or whitespace")
    normalizedSymbols.add(trimmed)
  
  # Fetch quotes for each symbol
  result = newSeq[Quote]()
  for symbol in normalizedSymbols:
    try:
      let url = buildQuoteUrl(symbol)
      let body = retrieveQuoteJson(url)
      let quote = parseQuoteResponse(body)
      result.add(quote)
    except QuoteError, HttpRequestError, JsonParsingError:
      # Skip invalid symbols, continue with others
      discard


proc getQuote*(symbol: string): Quote =
  ## Retrieves quote for a single symbol from Yahoo Finance
  ##
  ## Parameters:
  ##   - symbol: Ticker symbol (e.g., "AAPL", "BTC-USD")
  ##
  ## Returns:
  ##   Quote object with market data
  ##
  ## Raises:
  ##   - ValueError: If symbol is empty
  ##   - HttpRequestError: On network errors
  ##   - JsonParsingError: On invalid JSON
  ##   - QuoteError: If symbol not found or API error
  ##
  ## Example:
  ##   let quote = getQuote("AAPL")
  ##   echo "Current price: $", quote.regularMarketPrice
  ##   echo "Market cap: ", quote.marketCap
  ##   if quote.trailingPE.isSome:
  ##     echo "P/E ratio: ", quote.trailingPE.get()
  
  # Input validation
  if symbol.strip().len == 0:
    raise newException(ValueError, "Symbol cannot be empty or whitespace")
  
  # Build URL and fetch
  let url = buildQuoteUrl(symbol)
  let body = retrieveQuoteJson(url)
  let quote = parseQuoteResponse(body)
  
  return quote

