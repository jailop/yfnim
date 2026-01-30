## Yahoo Finance Data Retriever Module
##
## This module handles HTTP requests and JSON parsing for Yahoo Finance data
##

import std/httpclient
import std/json
import std/strutils
import std/math
import types
import urlbuilder

type
  YahooApiError* = object of CatchableError
    ## Exception raised when Yahoo Finance API returns an error
  
  # Internal JSON response structure matching Yahoo Finance API
  QuoteData = object
    open: seq[float64]
    low: seq[float64]
    high: seq[float64]
    close: seq[float64]
    volume: seq[int64]
  
  IndicatorsData = object
    quote: seq[QuoteData]
  
  ResultData = object
    timestamp: seq[int64]
    indicators: IndicatorsData
  
  ChartData = object
    result: seq[ResultData]
    error: JsonNode  # Optional error field
  
  YahooResponse = object
    chart: ChartData


proc nanZeroPrices*(prices: seq[float64]): seq[float64] =
  ## Converts zero prices to NaN
  ##
  ## Yahoo Finance sometimes returns 0.0 for missing data.
  ## This function converts those to NaN for proper handling.
  ##
  ## Parameters:
  ##   - prices: Sequence of price values
  ##
  ## Returns:
  ##   Sequence with 0.0 values replaced by NaN
  result = newSeq[float64](prices.len)
  for i in 0..<prices.len:
    if prices[i] == 0.0:
      result[i] = NaN
    else:
      result[i] = prices[i]


proc retrieveJson*(url: string): string =
  ## Retrieves JSON data from a URL via HTTP GET
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
    # Add user agent to identify our application
    client.headers = newHttpHeaders({
      "User-Agent": "yfnim/0.1.0 (Nim Yahoo Finance Data Retriever)"
    })
    
    let response = client.getContent(url)
    return response
  except HttpRequestError as e:
    raise newException(HttpRequestError, "HTTP request failed: " & e.msg)
  except Exception as e:
    raise newException(HttpRequestError, "Network error: " & e.msg)
  finally:
    client.close()


proc parseYahooJson*(body: string): YahooResponse =
  ## Parses Yahoo Finance JSON response
  ##
  ## Parameters:
  ##   - body: JSON response body as string
  ##
  ## Returns:
  ##   Parsed YahooResponse object
  ##
  ## Raises:
  ##   - JsonParsingError: On invalid JSON
  ##   - YahooApiError: If API returns an error
  try:
    let jsonNode = parseJson(body)
    
    # Check if response contains error
    if jsonNode.hasKey("chart") and jsonNode["chart"].hasKey("error") and 
       jsonNode["chart"]["error"].kind != JNull:
      let errorMsg = jsonNode["chart"]["error"].getStr("Unknown API error")
      raise newException(YahooApiError, "Yahoo Finance API error: " & errorMsg)
    
    # Parse the response structure
    var response = YahooResponse()
    
    if not jsonNode.hasKey("chart"):
      raise newException(JsonParsingError, "Missing 'chart' field in response")
    
    let chartNode = jsonNode["chart"]
    
    if not chartNode.hasKey("result") or chartNode["result"].kind != JArray:
      raise newException(JsonParsingError, "Missing or invalid 'result' field")
    
    if chartNode["result"].len == 0:
      raise newException(YahooApiError, "No data returned from Yahoo Finance")
    
    let resultNode = chartNode["result"][0]
    
    # Extract timestamps
    if not resultNode.hasKey("timestamp"):
      raise newException(JsonParsingError, "Missing 'timestamp' field")
    
    var timestamps = newSeq[int64]()
    for ts in resultNode["timestamp"]:
      timestamps.add(ts.getInt())
    
    # Extract indicators
    if not resultNode.hasKey("indicators"):
      raise newException(JsonParsingError, "Missing 'indicators' field")
    
    let indicatorsNode = resultNode["indicators"]
    
    if not indicatorsNode.hasKey("quote") or indicatorsNode["quote"].len == 0:
      raise newException(JsonParsingError, "Missing 'quote' data in indicators")
    
    let quoteNode = indicatorsNode["quote"][0]
    
    # Extract OHLCV data
    var quoteData = QuoteData()
    
    # Helper to extract float array, handling null values
    proc extractFloatArray(node: JsonNode, key: string): seq[float64] =
      result = newSeq[float64]()
      if node.hasKey(key):
        for val in node[key]:
          if val.kind == JNull:
            result.add(0.0)
          else:
            result.add(val.getFloat())
    
    # Helper to extract int array, handling null values
    proc extractIntArray(node: JsonNode, key: string): seq[int64] =
      result = newSeq[int64]()
      if node.hasKey(key):
        for val in node[key]:
          if val.kind == JNull:
            result.add(0)
          else:
            result.add(val.getInt())
    
    quoteData.open = extractFloatArray(quoteNode, "open")
    quoteData.low = extractFloatArray(quoteNode, "low")
    quoteData.high = extractFloatArray(quoteNode, "high")
    quoteData.close = extractFloatArray(quoteNode, "close")
    quoteData.volume = extractIntArray(quoteNode, "volume")
    
    # Build response
    var resultData = ResultData(
      timestamp: timestamps,
      indicators: IndicatorsData(quote: @[quoteData])
    )
    
    response.chart = ChartData(result: @[resultData])
    
    return response
    
  except JsonParsingError:
    raise
  except YahooApiError:
    raise
  except Exception as e:
    raise newException(JsonParsingError, "JSON parsing failed: " & e.msg)


proc yahooResponseToHistory*(response: YahooResponse, symbol: string, interval: Interval): History =
  ## Converts Yahoo Finance JSON response to History object
  ##
  ## Parameters:
  ##   - response: Parsed Yahoo Finance JSON response
  ##   - symbol: Stock ticker symbol
  ##   - interval: Time interval
  ##
  ## Returns:
  ##   History object with OHLCV data
  if response.chart.result.len == 0:
    raise newException(YahooApiError, "No data in Yahoo Finance response")
  
  let resultData = response.chart.result[0]
  let quoteData = resultData.indicators.quote[0]
  
  # Verify data consistency
  let dataLen = resultData.timestamp.len
  if quoteData.open.len != dataLen or
     quoteData.low.len != dataLen or
     quoteData.high.len != dataLen or
     quoteData.close.len != dataLen or
     quoteData.volume.len != dataLen:
    raise newException(YahooApiError, "Inconsistent data array lengths in response")
  
  # Create History object
  var history = newHistory(symbol, interval)
  
  # Convert NaN zero prices
  let openPrices = nanZeroPrices(quoteData.open)
  let lowPrices = nanZeroPrices(quoteData.low)
  let highPrices = nanZeroPrices(quoteData.high)
  let closePrices = nanZeroPrices(quoteData.close)
  
  # Build history records
  for i in 0..<dataLen:
    let record = HistoryRecord(
      time: resultData.timestamp[i],
      open: openPrices[i],
      low: lowPrices[i],
      high: highPrices[i],
      close: closePrices[i],
      volume: quoteData.volume[i]
    )
    history.append(record)
  
  return history


proc getHistory*(symbol: string, interval: Interval, startTime: int64, endTime: int64): History =
  ## Retrieves historical data from Yahoo Finance
  ##
  ## This is the main entry point for fetching stock data.
  ##
  ## Parameters:
  ##   - symbol: Stock ticker symbol (e.g., "AAPL", "MSFT")
  ##   - interval: Time interval (Int1m, Int1h, Int1d, etc.)
  ##   - startTime: Start date as Unix timestamp
  ##   - endTime: End date as Unix timestamp
  ##
  ## Returns:
  ##   History object containing OHLCV data
  ##
  ## Raises:
  ##   - ValueError: On invalid input parameters
  ##   - HttpRequestError: On network errors
  ##   - JsonParsingError: On invalid JSON
  ##   - YahooApiError: On API errors
  ##
  ## Example:
  ##   let history = getHistory("AAPL", Int1d, 1609459200, 1640995200)
  ##   echo "Retrieved ", history.len, " records"
  
  # Input validation
  if symbol.len == 0 or symbol.strip().len == 0:
    raise newException(ValueError, "Symbol cannot be empty or whitespace")
  
  if startTime < 0:
    raise newException(ValueError, "Start time cannot be negative")
  
  if endTime < 0:
    raise newException(ValueError, "End time cannot be negative")
  
  if startTime > endTime:
    raise newException(ValueError, "Start time must be before or equal to end time")
  
  # Warning for 1m interval with large date range
  # Yahoo Finance limits 1m interval to ~7 days
  if interval == Int1m:
    let rangeSeconds = endTime - startTime
    let maxSevenDays = 7 * 24 * 3600
    if rangeSeconds > maxSevenDays:
      # Note: We don't raise an error here, as Yahoo will handle it
      # This is just informational
      discard
  
  # Normalize symbol (trim whitespace)
  let normalizedSymbol = symbol.strip()
  
  # Build URL
  let url = buildYahooUrl(normalizedSymbol, interval, startTime, endTime)
  
  # Fetch data
  let body = retrieveJson(url)
  
  # Parse JSON
  let response = parseYahooJson(body)
  
  # Convert to History
  let history = yahooResponseToHistory(response, normalizedSymbol, interval)
  
  return history
