## Unit tests for yfnim/types module

import unittest
import std/json
import std/strutils
import yfnim/types

suite "Interval enum tests":
  test "interval enum values":
    check $Int1m == "1m"
    check $Int5m == "5m"
    check $Int15m == "15m"
    check $Int30m == "30m"
    check $Int1h == "1h"
    check $Int1d == "1d"
    check $Int1wk == "1wk"
    check $Int1mo == "1mo"
  
  test "parseInterval with valid strings":
    check parseInterval("1m") == Int1m
    check parseInterval("5m") == Int5m
    check parseInterval("15m") == Int15m
    check parseInterval("30m") == Int30m
    check parseInterval("1h") == Int1h
    check parseInterval("1d") == Int1d
    check parseInterval("1wk") == Int1wk
    check parseInterval("1mo") == Int1mo
  
  test "parseInterval with uppercase strings":
    check parseInterval("1M") == Int1m
    check parseInterval("1H") == Int1h
    check parseInterval("1D") == Int1d
  
  test "parseInterval with invalid string raises ValueError":
    expect(ValueError):
      discard parseInterval("invalid")
    expect(ValueError):
      discard parseInterval("2d")


suite "HistoryRecord tests":
  test "create HistoryRecord":
    let record = HistoryRecord(
      time: 1609459200,
      open: 150.0,
      high: 155.0,
      low: 149.0,
      close: 154.0,
      volume: 1000000
    )
    
    check record.time == 1609459200
    check record.open == 150.0
    check record.high == 155.0
    check record.low == 149.0
    check record.close == 154.0
    check record.volume == 1000000
  
  test "HistoryRecord to string":
    let record = HistoryRecord(
      time: 123456,
      open: 100.0,
      high: 105.0,
      low: 99.0,
      close: 102.0,
      volume: 500000
    )
    let str = $record
    check "time: 123456" in str
    check "open: 100.0" in str
    check "close: 102.0" in str
  
  test "HistoryRecord to JSON":
    let record = HistoryRecord(
      time: 1609459200,
      open: 150.0,
      high: 155.0,
      low: 149.0,
      close: 154.0,
      volume: 1000000
    )
    
    let json = record.toJson()
    check json["time"].getInt() == 1609459200
    check json["open"].getFloat() == 150.0
    check json["high"].getFloat() == 155.0
    check json["low"].getFloat() == 149.0
    check json["close"].getFloat() == 154.0
    check json["volume"].getInt() == 1000000
  
  test "HistoryRecord from JSON":
    let json = %*{
      "time": 1609459200,
      "open": 150.0,
      "high": 155.0,
      "low": 149.0,
      "close": 154.0,
      "volume": 1000000
    }
    
    let record = fromJson(json, HistoryRecord)
    check record.time == 1609459200
    check record.open == 150.0
    check record.high == 155.0
    check record.low == 149.0
    check record.close == 154.0
    check record.volume == 1000000


suite "History tests":
  test "create new History":
    let history = newHistory("AAPL", Int1d)
    check history.symbol == "AAPL"
    check history.interval == Int1d
    check history.len == 0
  
  test "History length":
    var history = newHistory("MSFT", Int1h)
    check history.len == 0
    
    history.append(HistoryRecord(time: 1, open: 100.0, high: 101.0, low: 99.0, close: 100.5, volume: 1000))
    check history.len == 1
    
    history.append(HistoryRecord(time: 2, open: 100.5, high: 102.0, low: 100.0, close: 101.5, volume: 1500))
    check history.len == 2
  
  test "append records to History":
    var history = newHistory("GOOGL", Int1m)
    
    let record1 = HistoryRecord(
      time: 1609459200,
      open: 150.0,
      high: 155.0,
      low: 149.0,
      close: 154.0,
      volume: 1000000
    )
    
    let record2 = HistoryRecord(
      time: 1609459260,
      open: 154.0,
      high: 156.0,
      low: 153.0,
      close: 155.5,
      volume: 1200000
    )
    
    history.append(record1)
    history.append(record2)
    
    check history.len == 2
    check history.data[0].time == 1609459200
    check history.data[1].time == 1609459260
    check history.data[0].close == 154.0
    check history.data[1].close == 155.5
  
  test "History to string":
    let history = newHistory("TSLA", Int1d)
    let str = $history
    check "TSLA" in str
    check "1d" in str
    check "records: 0" in str
  
  test "History with data to string":
    var history = newHistory("AMZN", Int1h)
    history.append(HistoryRecord(time: 1, open: 100.0, high: 101.0, low: 99.0, close: 100.5, volume: 1000))
    history.append(HistoryRecord(time: 2, open: 100.5, high: 102.0, low: 100.0, close: 101.5, volume: 1500))
    
    let str = $history
    check "AMZN" in str
    check "1h" in str
    check "records: 2" in str
  
  test "History to JSON":
    var history = newHistory("AAPL", Int1d)
    history.append(HistoryRecord(
      time: 1609459200,
      open: 150.0,
      high: 155.0,
      low: 149.0,
      close: 154.0,
      volume: 1000000
    ))
    
    let json = history.toJson()
    check json["symbol"].getStr() == "AAPL"
    check json["interval"].getStr() == "1d"
    check json["data"].len == 1
    check json["data"][0]["time"].getInt() == 1609459200
    check json["data"][0]["close"].getFloat() == 154.0
  
  test "History from JSON":
    let json = %*{
      "symbol": "MSFT",
      "interval": "1h",
      "data": [
        {
          "time": 1609459200,
          "open": 150.0,
          "high": 155.0,
          "low": 149.0,
          "close": 154.0,
          "volume": 1000000
        },
        {
          "time": 1609462800,
          "open": 154.0,
          "high": 156.0,
          "low": 153.0,
          "close": 155.5,
          "volume": 1200000
        }
      ]
    }
    
    let history = fromJson(json, History)
    check history.symbol == "MSFT"
    check history.interval == Int1h
    check history.len == 2
    check history.data[0].time == 1609459200
    check history.data[1].time == 1609462800
    check history.data[0].close == 154.0
    check history.data[1].close == 155.5
  
  test "History JSON round-trip":
    var original = newHistory("GOOGL", Int1d)
    original.append(HistoryRecord(time: 1, open: 100.0, high: 101.0, low: 99.0, close: 100.5, volume: 1000))
    original.append(HistoryRecord(time: 2, open: 100.5, high: 102.0, low: 100.0, close: 101.5, volume: 1500))
    
    let json = original.toJson()
    let restored = fromJson(json, History)
    
    check restored.symbol == original.symbol
    check restored.interval == original.interval
    check restored.len == original.len
    check restored.data[0].time == original.data[0].time
    check restored.data[1].close == original.data[1].close
