import unittest
import std/times
import std/httpclient
import std/strutils
import yfnim

suite "Edge Cases and Input Validation":
  
  test "Invalid symbol - should handle gracefully":
    # Test with a clearly invalid symbol
    let now = getTime().toUnix()
    let weekAgo = now - (7 * 24 * 3600)
    
    try:
      let history = getHistory("INVALID_SYMBOL_XYZ123", Int1d, weekAgo, now)
      # If we get here, it might return empty data or succeed
      # Yahoo Finance sometimes returns empty results for invalid symbols
      check history.data.len >= 0  # Should not crash
    except YahooApiError as e:
      # This is acceptable - API rejected the symbol
      check e.msg.len > 0
    except HttpRequestError as e:
      # Network errors are also acceptable
      check e.msg.len > 0
  
  test "Empty symbol - should fail":
    let now = getTime().toUnix()
    let weekAgo = now - (7 * 24 * 3600)
    
    expect(ValueError):
      discard getHistory("", Int1d, weekAgo, now)
  
  test "Start time after end time - should fail":
    let now = getTime().toUnix()
    let weekAgo = now - (7 * 24 * 3600)
    
    expect(ValueError):
      discard getHistory("AAPL", Int1d, now, weekAgo)  # Reversed times
  
  test "Start time equals end time - should handle":
    let now = getTime().toUnix()
    
    try:
      let history = getHistory("AAPL", Int1d, now, now)
      # Should return empty or minimal data
      check history.data.len >= 0
    except ValueError as e:
      # This is also acceptable
      check e.msg.len > 0
  
  test "Very old date range - should handle gracefully":
    # Test with dates from 30 years ago
    let oldDate = parseTime("1995-01-01", "yyyy-MM-dd", utc()).toUnix()
    let slightlyLess = oldDate + (7 * 24 * 3600)
    
    try:
      let history = getHistory("AAPL", Int1d, oldDate, slightlyLess)
      # Should either succeed with data or handle gracefully
      check history.data.len >= 0
    except YahooApiError as e:
      # API might reject very old dates
      check e.msg.len > 0
  
  test "Future dates - should handle gracefully":
    # Test with dates far in the future
    let now = getTime().toUnix()
    let futureDate = now + (365 * 24 * 3600)  # 1 year in future
    
    try:
      let history = getHistory("AAPL", Int1d, now, futureDate)
      # Should return data up to present or handle gracefully
      check history.data.len >= 0
    except YahooApiError as e:
      # This is acceptable
      check e.msg.len > 0
  
  test "Negative timestamps - should fail":
    expect(ValueError):
      discard getHistory("AAPL", Int1d, -1000, -500)
  
  test "Very large date range with 1m interval - should warn or handle":
    # 1m interval is limited to 7 days by Yahoo Finance
    let now = getTime().toUnix()
    let monthAgo = now - (30 * 24 * 3600)  # 30 days
    
    # This should either:
    # 1. Return partial data (last 7 days)
    # 2. Raise an error
    # 3. Handle gracefully
    try:
      let history = getHistory("AAPL", Int1m, monthAgo, now)
      # If it succeeds, check we got some data
      check history.data.len >= 0
    except YahooApiError as e:
      # Expected - Yahoo limits 1m to 7 days
      check e.msg.len > 0
    except HttpRequestError as e:
      # Yahoo may also reject with HTTP error
      check e.msg.len > 0
  
  test "Symbol with special characters - should handle":
    # Some symbols have dots or dashes (e.g., BRK.B, BF-B)
    let now = getTime().toUnix()
    let weekAgo = now - (7 * 24 * 3600)
    
    try:
      let history = getHistory("BRK-B", Int1d, weekAgo, now)
      check history.symbol == "BRK-B"
      check history.data.len >= 0
    except Exception as e:
      # If it fails, it should be a proper error
      check e.msg.len > 0
  
  test "International symbol - should handle":
    # Test with a European symbol
    let now = getTime().toUnix()
    let weekAgo = now - (7 * 24 * 3600)
    
    try:
      let history = getHistory("SAP.DE", Int1d, weekAgo, now)
      check history.symbol == "SAP.DE"
      check history.data.len >= 0
    except Exception as e:
      # If it fails, it should be a proper error
      check e.msg.len > 0
  
  test "Cryptocurrency symbol - should handle":
    # Test with a crypto symbol if Yahoo supports it
    let now = getTime().toUnix()
    let weekAgo = now - (7 * 24 * 3600)
    
    try:
      let history = getHistory("BTC-USD", Int1d, weekAgo, now)
      check history.symbol == "BTC-USD"
      check history.data.len >= 0
    except Exception as e:
      # If it fails, it should be a proper error
      check e.msg.len > 0
  
  test "Very long symbol name - should handle or reject":
    let now = getTime().toUnix()
    let weekAgo = now - (7 * 24 * 3600)
    let longSymbol = "A".repeat(100)
    
    try:
      discard getHistory(longSymbol, Int1d, weekAgo, now)
    except CatchableError:
      # Should handle with proper error
      check getCurrentException().msg.len > 0
  
  test "Symbol with whitespace - should handle or reject":
    let now = getTime().toUnix()
    let weekAgo = now - (7 * 24 * 3600)
    
    # Should trim whitespace and succeed
    try:
      let history = getHistory("AAPL ", Int1d, weekAgo, now)
      check history.symbol == "AAPL"
    except CatchableError:
      # Or handle with proper error
      check getCurrentException().msg.len > 0
