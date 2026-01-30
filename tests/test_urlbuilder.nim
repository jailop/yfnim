## Unit tests for yfnim/urlbuilder module

import unittest
import std/strutils
import yfnim/types
import yfnim/urlbuilder

suite "QueryParam tests":
  test "create QueryParam":
    let param = QueryParam(name: "interval", value: "1m")
    check param.name == "interval"
    check param.value == "1m"


suite "buildQuery tests":
  test "build query with single parameter":
    let params = @[QueryParam(name: "interval", value: "1m")]
    let query = buildQuery(params)
    check query == "interval=1m"
  
  test "build query with multiple parameters":
    let params = @[
      QueryParam(name: "interval", value: "1m"),
      QueryParam(name: "period1", value: "1609459200"),
      QueryParam(name: "period2", value: "1609545600")
    ]
    let query = buildQuery(params)
    check "interval=1m" in query
    check "period1=1609459200" in query
    check "period2=1609545600" in query
    check query.count("&") == 2
  
  test "build query with empty parameters":
    let params: seq[QueryParam] = @[]
    let query = buildQuery(params)
    check query == ""
  
  test "build query with special characters":
    let params = @[
      QueryParam(name: "symbol", value: "BRK.B"),
      QueryParam(name: "test", value: "a&b=c")
    ]
    let query = buildQuery(params)
    # URL encoding should handle special characters
    check "symbol=" in query
    check "test=" in query
    # Period should be encoded as %2E
    check "%2E" in query or "BRK.B" in query
  
  test "build query parameter order preserved":
    let params = @[
      QueryParam(name: "first", value: "1"),
      QueryParam(name: "second", value: "2"),
      QueryParam(name: "third", value: "3")
    ]
    let query = buildQuery(params)
    let firstPos = query.find("first=1")
    let secondPos = query.find("second=2")
    let thirdPos = query.find("third=3")
    check firstPos < secondPos
    check secondPos < thirdPos


suite "makeUrl tests":
  test "construct URL with symbol and parameters":
    let params = @[
      QueryParam(name: "interval", value: "1m"),
      QueryParam(name: "period1", value: "123456")
    ]
    let url = makeUrl("https://example.com/chart", "AAPL", params)
    
    check "https://example.com/chart" in url
    check "/AAPL?" in url
    check "interval=1m" in url
    check "period1=123456" in url
  
  test "construct URL with different base URL":
    let params = @[QueryParam(name: "test", value: "value")]
    let url = makeUrl("https://api.example.com/v2/data", "MSFT", params)
    
    check "https://api.example.com/v2/data/MSFT?" in url
    check "test=value" in url
  
  test "construct URL with no parameters":
    let params: seq[QueryParam] = @[]
    let url = makeUrl("https://example.com", "GOOGL", params)
    
    check url == "https://example.com/GOOGL?"


suite "buildYahooUrl tests - different intervals":
  test "build URL with 1-minute interval":
    let url = buildYahooUrl("AAPL", Int1m, 1609459200, 1609545600)
    
    check "query2.finance.yahoo.com" in url
    check "/v8/finance/chart" in url
    check "AAPL" in url
    check "interval=1m" in url
    check "period1=1609459200" in url
    check "period2=1609545600" in url
  
  test "build URL with 5-minute interval":
    let url = buildYahooUrl("MSFT", Int5m, 1609459200, 1609545600)
    check "interval=5m" in url
    check "MSFT" in url
  
  test "build URL with 15-minute interval":
    let url = buildYahooUrl("GOOGL", Int15m, 1609459200, 1609545600)
    check "interval=15m" in url
  
  test "build URL with 30-minute interval":
    let url = buildYahooUrl("TSLA", Int30m, 1609459200, 1609545600)
    check "interval=30m" in url
  
  test "build URL with 1-hour interval":
    let url = buildYahooUrl("AMZN", Int1h, 1609459200, 1609545600)
    check "interval=1h" in url
  
  test "build URL with 1-day interval":
    let url = buildYahooUrl("META", Int1d, 1577836800, 1640995200)
    check "interval=1d" in url
    check "period1=1577836800" in url
    check "period2=1640995200" in url
  
  test "build URL with 1-week interval":
    let url = buildYahooUrl("NFLX", Int1wk, 1577836800, 1640995200)
    check "interval=1wk" in url
  
  test "build URL with 1-month interval":
    let url = buildYahooUrl("NVDA", Int1mo, 1577836800, 1640995200)
    check "interval=1mo" in url


suite "buildYahooUrl tests - different symbols":
  test "build URL with standard symbol":
    let url = buildYahooUrl("AAPL", Int1d, 1609459200, 1609545600)
    check "AAPL" in url
  
  test "build URL with multi-letter symbol":
    let url = buildYahooUrl("GOOGL", Int1d, 1609459200, 1609545600)
    check "GOOGL" in url
  
  test "build URL with symbol containing period":
    let url = buildYahooUrl("BRK.B", Int1d, 1609459200, 1609545600)
    check "BRK" in url
  
  test "build URL with symbol containing hyphen":
    let url = buildYahooUrl("BRK-B", Int1d, 1609459200, 1609545600)
    check "BRK" in url or "BRK-B" in url


suite "buildYahooUrl tests - timestamp validation":
  test "build URL with valid timestamp range":
    let startTime: int64 = 1609459200  # 2021-01-01
    let endTime: int64 = 1640995200    # 2022-01-01
    let url = buildYahooUrl("AAPL", Int1d, startTime, endTime)
    
    check "period1=1609459200" in url
    check "period2=1640995200" in url
  
  test "build URL with same start and end time":
    let timestamp: int64 = 1609459200
    let url = buildYahooUrl("MSFT", Int1d, timestamp, timestamp)
    
    check "period1=1609459200" in url
    check "period2=1609459200" in url
  
  test "build URL with recent timestamps":
    let startTime: int64 = 1700000000  # Nov 2023
    let endTime: int64 = 1710000000    # Mar 2024
    let url = buildYahooUrl("TSLA", Int1h, startTime, endTime)
    
    check "period1=1700000000" in url
    check "period2=1710000000" in url
  
  test "build URL with zero timestamps":
    let url = buildYahooUrl("TEST", Int1d, 0, 0)
    check "period1=0" in url
    check "period2=0" in url


suite "buildYahooUrl tests - URL format validation":
  test "URL has correct protocol":
    let url = buildYahooUrl("AAPL", Int1d, 1609459200, 1609545600)
    check url.startsWith("https://")
  
  test "URL has correct domain":
    let url = buildYahooUrl("AAPL", Int1d, 1609459200, 1609545600)
    check "query2.finance.yahoo.com" in url
  
  test "URL has correct API version":
    let url = buildYahooUrl("AAPL", Int1d, 1609459200, 1609545600)
    check "/v8/finance/chart" in url
  
  test "URL has all required parameters":
    let url = buildYahooUrl("AAPL", Int1d, 1609459200, 1609545600)
    check "interval=" in url
    check "period1=" in url
    check "period2=" in url
  
  test "URL format matches expected pattern":
    let url = buildYahooUrl("AAPL", Int1m, 1609459200, 1609545600)
    # Expected format: https://query2.finance.yahoo.com/v8/finance/chart/AAPL?interval=1m&period1=...&period2=...
    check url.startsWith("https://query2.finance.yahoo.com/v8/finance/chart/")
    check url.contains("?")
    check url.count("=") == 3  # Three parameters


suite "Edge cases and error handling":
  test "buildQuery handles empty parameter values":
    let params = @[
      QueryParam(name: "test", value: "")
    ]
    let query = buildQuery(params)
    check "test=" in query
  
  test "buildQuery handles empty parameter names":
    let params = @[
      QueryParam(name: "", value: "value")
    ]
    let query = buildQuery(params)
    check "=value" in query
  
  test "makeUrl handles empty symbol":
    let params = @[QueryParam(name: "test", value: "value")]
    let url = makeUrl("https://example.com", "", params)
    check "https://example.com/?" in url
  
  test "buildYahooUrl with negative timestamps":
    let url = buildYahooUrl("AAPL", Int1d, -1000, -500)
    check "period1=-1000" in url
    check "period2=-500" in url
