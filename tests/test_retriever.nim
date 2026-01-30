## Unit tests for yfnim/retriever module

import unittest
import std/json
import std/math
import yfnim/types
import yfnim/urlbuilder
include yfnim/retriever

# Mock JSON response data
const mockYahooResponse = """{
  "chart": {
    "result": [{
      "meta": {
        "currency": "USD",
        "symbol": "AAPL"
      },
      "timestamp": [1609459200, 1609459260, 1609459320],
      "indicators": {
        "quote": [{
          "open": [130.0, 131.0, 132.0],
          "high": [131.0, 132.0, 133.0],
          "low": [129.0, 130.0, 131.0],
          "close": [130.5, 131.5, 132.5],
          "volume": [1000000, 1100000, 1200000]
        }]
      }
    }],
    "error": null
  }
}"""

const mockYahooResponseWithNulls = """{
  "chart": {
    "result": [{
      "timestamp": [1609459200, 1609459260, 1609459320],
      "indicators": {
        "quote": [{
          "open": [130.0, null, 132.0],
          "high": [131.0, null, 133.0],
          "low": [129.0, null, 131.0],
          "close": [130.5, null, 132.5],
          "volume": [1000000, 0, 1200000]
        }]
      }
    }],
    "error": null
  }
}"""

const mockYahooResponseWithZeros = """{
  "chart": {
    "result": [{
      "timestamp": [1609459200, 1609459260, 1609459320],
      "indicators": {
        "quote": [{
          "open": [130.0, 0.0, 132.0],
          "high": [131.0, 0.0, 133.0],
          "low": [129.0, 0.0, 131.0],
          "close": [130.5, 0.0, 132.5],
          "volume": [1000000, 0, 1200000]
        }]
      }
    }],
    "error": null
  }
}"""

const mockErrorResponse = """{
  "chart": {
    "result": null,
    "error": {
      "code": "Not Found",
      "description": "No data found for INVALID"
    }
  }
}"""

const mockEmptyResultResponse = """{
  "chart": {
    "result": [],
    "error": null
  }
}"""


suite "nanZeroPrices tests":
  test "convert zero prices to NaN":
    let prices = @[100.0, 0.0, 150.0, 0.0, 200.0]
    let result = nanZeroPrices(prices)
    
    check result[0] == 100.0
    check classify(result[1]) == fcNaN
    check result[2] == 150.0
    check classify(result[3]) == fcNaN
    check result[4] == 200.0
  
  test "handle all non-zero prices":
    let prices = @[100.0, 150.0, 200.0]
    let result = nanZeroPrices(prices)
    
    check result[0] == 100.0
    check result[1] == 150.0
    check result[2] == 200.0
  
  test "handle all zero prices":
    let prices = @[0.0, 0.0, 0.0]
    let result = nanZeroPrices(prices)
    
    check classify(result[0]) == fcNaN
    check classify(result[1]) == fcNaN
    check classify(result[2]) == fcNaN
  
  test "handle empty sequence":
    let prices: seq[float64] = @[]
    let result = nanZeroPrices(prices)
    
    check result.len == 0


suite "parseYahooJson tests":
  test "parse valid Yahoo Finance response":
    let response = parseYahooJson(mockYahooResponse)
    
    check response.chart.result.len == 1
    check response.chart.result[0].timestamp.len == 3
    check response.chart.result[0].timestamp[0] == 1609459200
    check response.chart.result[0].indicators.quote.len == 1
  
  test "parse response with null values":
    let response = parseYahooJson(mockYahooResponseWithNulls)
    
    check response.chart.result.len == 1
    check response.chart.result[0].indicators.quote[0].open[1] == 0.0
  
  test "parse response with zero prices":
    let response = parseYahooJson(mockYahooResponseWithZeros)
    
    check response.chart.result.len == 1
    let quoteData = response.chart.result[0].indicators.quote[0]
    check quoteData.open[1] == 0.0
    check quoteData.high[1] == 0.0
  
  test "parse empty result raises error":
    expect(YahooApiError):
      discard parseYahooJson(mockEmptyResultResponse)
  
  test "parse invalid JSON raises error":
    expect(JsonParsingError):
      discard parseYahooJson("{invalid json}")
  
  test "parse missing chart field raises error":
    expect(JsonParsingError):
      discard parseYahooJson("""{"data": {}}""")
  
  test "parse missing result field raises error":
    expect(JsonParsingError):
      discard parseYahooJson("""{"chart": {}}""")


suite "yahooResponseToHistory tests":
  test "convert valid response to History":
    let response = parseYahooJson(mockYahooResponse)
    let history = yahooResponseToHistory(response, "AAPL", Int1m)
    
    check history.symbol == "AAPL"
    check history.interval == Int1m
    check history.len == 3
    check history.data[0].time == 1609459200
    check history.data[0].open == 130.0
    check history.data[0].close == 130.5
    check history.data[2].volume == 1200000
  
  test "convert response with zeros to NaN":
    let response = parseYahooJson(mockYahooResponseWithZeros)
    let history = yahooResponseToHistory(response, "TEST", Int1d)
    
    check history.len == 3
    check history.data[0].open == 130.0
    check classify(history.data[1].open) == fcNaN
    check classify(history.data[1].high) == fcNaN
    check classify(history.data[1].low) == fcNaN
    check classify(history.data[1].close) == fcNaN
    check history.data[2].open == 132.0
  
  test "convert response with nulls to NaN":
    let response = parseYahooJson(mockYahooResponseWithNulls)
    let history = yahooResponseToHistory(response, "TEST", Int1h)
    
    check history.len == 3
    # Nulls are converted to 0.0 during parsing, then to NaN
    check classify(history.data[1].open) == fcNaN
  
  test "verify all OHLCV fields":
    let response = parseYahooJson(mockYahooResponse)
    let history = yahooResponseToHistory(response, "AAPL", Int1m)
    
    let record = history.data[0]
    check record.time == 1609459200
    check record.open == 130.0
    check record.high == 131.0
    check record.low == 129.0
    check record.close == 130.5
    check record.volume == 1000000
  
  test "verify data consistency across records":
    let response = parseYahooJson(mockYahooResponse)
    let history = yahooResponseToHistory(response, "MSFT", Int1d)
    
    check history.data[0].open == 130.0
    check history.data[1].open == 131.0
    check history.data[2].open == 132.0
    
    check history.data[0].volume == 1000000
    check history.data[1].volume == 1100000
    check history.data[2].volume == 1200000


suite "Integration tests with mock data":
  test "full parsing pipeline":
    # Parse JSON
    let response = parseYahooJson(mockYahooResponse)
    
    # Convert to History
    let history = yahooResponseToHistory(response, "AAPL", Int1m)
    
    # Verify complete data
    check history.symbol == "AAPL"
    check history.interval == Int1m
    check history.len == 3
    
    # Check first record
    check history.data[0].time == 1609459200
    check history.data[0].open == 130.0
    
    # Check last record
    check history.data[2].time == 1609459320
    check history.data[2].close == 132.5
  
  test "handling of edge case data":
    let response = parseYahooJson(mockYahooResponseWithZeros)
    let history = yahooResponseToHistory(response, "TEST", Int1d)
    
    # First record should be normal
    check history.data[0].open == 130.0
    check classify(history.data[0].open) == fcNormal
    
    # Second record should have NaN prices
    check classify(history.data[1].open) == fcNaN
    check classify(history.data[1].close) == fcNaN
    
    # Third record should be normal
    check history.data[2].open == 132.0
    check classify(history.data[2].open) == fcNormal


suite "Error handling tests":
  test "empty result array":
    expect(YahooApiError):
      discard parseYahooJson(mockEmptyResultResponse)
  
  test "malformed JSON":
    expect(JsonParsingError):
      discard parseYahooJson("{malformed")
  
  test "missing required fields":
    expect(JsonParsingError):
      discard parseYahooJson("""{"chart": {"result": [{}]}}""")
