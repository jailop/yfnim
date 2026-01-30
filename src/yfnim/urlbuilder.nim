## Yahoo Finance URL Builder Module
##
## This module handles URL construction for Yahoo Finance API requests.
## It builds properly encoded URLs with query parameters for fetching
## historical data.
##
## **Functions:**
## - `buildQuery`_: Create query string from parameters
## - `makeUrl`_: Combine base URL with query string
## - `buildYahooUrl`_: Build complete Yahoo Finance API URL
##
## **Example:**
##
## .. code-block:: nim
##   import yfnim/urlbuilder
##   import yfnim/types
##   
##   # Build URL for AAPL daily data
##   let url = buildYahooUrl("AAPL", Int1d, 1609459200, 1640995200)
##   # Returns: https://query2.finance.yahoo.com/v8/finance/chart/AAPL?interval=1d&period1=1609459200&period2=1640995200
##
## **Internal Use:**
## This module is primarily used internally by the retriever module.
## Most users will not need to call these functions directly.
##

import std/strutils
import std/uri
import types

type
  QueryParam* = object
    ## A URL query parameter
    name*: string
    value*: string


proc buildQuery*(params: seq[QueryParam]): string =
  ## Builds a URL query string from parameters
  ##
  ## Example:
  ##   let query = buildQuery(@[
  ##     QueryParam(name: "interval", value: "1m"),
  ##     QueryParam(name: "period1", value: "123456")
  ##   ])
  ##   # Returns: "interval=1m&period1=123456"
  var parts: seq[string] = @[]
  for param in params:
    parts.add(encodeUrl(param.name) & "=" & encodeUrl(param.value))
  result = parts.join("&")


proc makeUrl*(baseUrl: string, symbol: string, params: seq[QueryParam]): string =
  ## Constructs a complete URL with symbol and query parameters
  ##
  ## Example:
  ##   let url = makeUrl("https://example.com/chart", "AAPL", params)
  let query = buildQuery(params)
  result = baseUrl & "/" & symbol & "?" & query


proc buildYahooUrl*(symbol: string, interval: Interval, startTime: int64, endTime: int64): string =
  ## Builds a complete Yahoo Finance API URL
  ##
  ## Parameters:
  ##   - symbol: Stock ticker symbol (e.g., "AAPL")
  ##   - interval: Time interval (Int1m, Int1h, Int1d, etc.)
  ##   - startTime: Start date as Unix timestamp
  ##   - endTime: End date as Unix timestamp
  ##
  ## Returns:
  ##   Complete Yahoo Finance API URL
  ##
  ## Example:
  ##   let url = buildYahooUrl("AAPL", Int1m, 1234567890, 1234567999)
  const baseUrl = "https://query2.finance.yahoo.com/v8/finance/chart"
  
  let params = @[
    QueryParam(name: "interval", value: $interval),
    QueryParam(name: "period1", value: $startTime),
    QueryParam(name: "period2", value: $endTime)
  ]
  
  result = makeUrl(baseUrl, symbol, params)
