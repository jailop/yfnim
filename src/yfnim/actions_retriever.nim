## Yahoo Finance Corporate Actions Retriever Module
##
## This module handles retrieval of dividends, stock splits, and other corporate actions
##

import std/[httpclient, json, times, strformat, algorithm, strutils]
import types

type
  ActionsError* = object of CatchableError
    ## Exception raised when corporate actions retrieval fails


proc retrieveActionsJson(url: string): string =
  ## Retrieves JSON data from Yahoo Finance
  ##
  ## Internal function that handles HTTP requests for corporate actions
  var client = newHttpClient()
  try:
    client.headers = newHttpHeaders({
      "User-Agent": "yfnim/0.2.0 (Nim Yahoo Finance Data Retriever)"
    })
    
    let response = client.getContent(url)
    return response
  except HttpRequestError as e:
    raise newException(ActionsError, "HTTP request failed: " & e.msg)
  except Exception as e:
    raise newException(ActionsError, "Network error: " & e.msg)
  finally:
    client.close()


proc parseCorporateActions(jsonStr: string): CorporateAction =
  ## Parse JSON response into CorporateAction object
  ##
  ## Extracts dividends and splits from Yahoo Finance chart API response
  result = CorporateAction(dividends: @[], splits: @[])
  
  try:
    let json = parseJson(jsonStr)
    
    # Check for API errors
    if json.hasKey("chart") and json["chart"].hasKey("error") and 
       json["chart"]["error"].kind != JNull:
      let errorMsg = json["chart"]["error"].getStr("Unknown API error")
      raise newException(ActionsError, "Yahoo Finance API error: " & errorMsg)
    
    if not json.hasKey("chart"):
      raise newException(ActionsError, "Missing 'chart' field in response")
    
    let chartNode = json["chart"]
    
    if not chartNode.hasKey("result") or chartNode["result"].kind != JArray:
      raise newException(ActionsError, "Missing or invalid 'result' field")
    
    if chartNode["result"].len == 0:
      # No data is not an error - just means no corporate actions
      return result
    
    let resultNode = chartNode["result"][0]
    
    # Check if events field exists
    if not resultNode.hasKey("events"):
      # No events is not an error - symbol may not have dividends/splits
      return result
    
    let events = resultNode["events"]
    
    # Parse dividends
    if events.hasKey("dividends") and events["dividends"].kind == JObject:
      for timestamp, divData in events["dividends"].pairs:
        let date = fromUnix(divData["date"].getInt()).utc()
        let amount = divData["amount"].getFloat()
        result.dividends.add(DividendAction(
          date: date,
          amount: amount
        ))
    
    # Parse splits
    if events.hasKey("splits") and events["splits"].kind == JObject:
      for timestamp, splitData in events["splits"].pairs:
        let date = fromUnix(splitData["date"].getInt()).utc()
        let numerator = splitData["numerator"].getInt()
        let denominator = splitData["denominator"].getInt()
        let splitRatio = splitData["splitRatio"].getStr()
        result.splits.add(SplitAction(
          date: date,
          numerator: numerator,
          denominator: denominator,
          splitRatio: splitRatio
        ))
    
    # Sort by date (oldest to newest)
    result.dividends.sort(proc(a, b: DividendAction): int = cmp(a.date, b.date))
    result.splits.sort(proc(a, b: SplitAction): int = cmp(a.date, b.date))
    
  except JsonParsingError as e:
    raise newException(ActionsError, "Failed to parse JSON: " & e.msg)
  except Exception as e:
    raise newException(ActionsError, "Failed to parse corporate actions: " & e.msg)


proc getActions*(ticker: string, startDate = dateTime(1970, mJan, 1, zone = utc()),
                 endDate = now().utc()): CorporateAction =
  ## Retrieve dividend and split history for a ticker
  ## 
  ## Args:
  ##   ticker: Stock symbol (e.g., "AAPL")
  ##   startDate: Start of date range (default: all history)
  ##   endDate: End of date range (default: today)
  ## 
  ## Returns:
  ##   CorporateAction object with dividends and splits
  ## 
  ## Raises:
  ##   ActionsError: If API request fails or data is invalid
  ## 
  ## Example:
  ##   let actions = getActions("AAPL")
  ##   echo "Found ", actions.dividends.len, " dividends"
  ##   echo "Found ", actions.splits.len, " splits"
  
  # Input validation
  if ticker.len == 0 or ticker.strip().len == 0:
    raise newException(ActionsError, "Ticker cannot be empty or whitespace")
  
  let normalizedTicker = ticker.strip().toUpperAscii()
  
  let period1 = startDate.toTime.toUnix
  let period2 = endDate.toTime.toUnix
  
  # Build URL with events parameter
  let url = fmt"https://query1.finance.yahoo.com/v8/finance/chart/{normalizedTicker}" &
            fmt"?events=div,split&period1={period1}&period2={period2}&interval=1d"
  
  # Fetch and parse data
  let response = retrieveActionsJson(url)
  result = parseCorporateActions(response)


proc getDividends*(ticker: string, startDate = dateTime(1970, mJan, 1, zone = utc()),
                   endDate = now().utc()): seq[DividendAction] =
  ## Convenience function to get only dividends
  ## 
  ## Args:
  ##   ticker: Stock symbol (e.g., "AAPL")
  ##   startDate: Start of date range (default: all history)
  ##   endDate: End of date range (default: today)
  ## 
  ## Returns:
  ##   Sequence of DividendAction objects
  ## 
  ## Example:
  ##   let dividends = getDividends("AAPL")
  ##   for div in dividends:
  ##     echo div.date.format("yyyy-MM-dd"), ": $", div.amount
  result = getActions(ticker, startDate, endDate).dividends


proc getSplits*(ticker: string, startDate = dateTime(1970, mJan, 1, zone = utc()),
                endDate = now().utc()): seq[SplitAction] =
  ## Convenience function to get only splits
  ## 
  ## Args:
  ##   ticker: Stock symbol (e.g., "AAPL")
  ##   startDate: Start of date range (default: all history)
  ##   endDate: End of date range (default: today)
  ## 
  ## Returns:
  ##   Sequence of SplitAction objects
  ## 
  ## Example:
  ##   let splits = getSplits("AAPL")
  ##   for split in splits:
  ##     echo split.date.format("yyyy-MM-dd"), ": ", split.splitRatio
  result = getActions(ticker, startDate, endDate).splits
