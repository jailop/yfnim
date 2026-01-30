# Basic integration tests for yfnim library
#
# To run these tests, simply execute `nimble test`.

import unittest
import std/strutils
import yfnim

suite "Basic yfnim functionality":
  test "can create History":
    let history = newHistory("AAPL", Int1d)
    check history.symbol == "AAPL"
    check history.interval == Int1d
    check history.len == 0
  
  test "can build Yahoo URL":
    let url = buildYahooUrl("AAPL", Int1m, 1609459200, 1609545600)
    check "query2.finance.yahoo.com" in url
    check "AAPL" in url
    check "interval=1m" in url
    check "period1=1609459200" in url
    check "period2=1609545600" in url
