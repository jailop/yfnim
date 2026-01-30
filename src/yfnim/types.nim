## Yahoo Finance Data Types Module
##
## This module defines the core data types for the yfnim library:
## - Interval: Enum for time intervals (1m, 1h, 1d, etc.)
## - HistoryRecord: Single OHLCV data point
## - History: Time series of OHLCV data
##

import std/json
import std/strutils

type
  Interval* = enum
    ## Time interval for historical data
    Int1m = "1m"    ## 1 minute
    Int5m = "5m"    ## 5 minutes
    Int15m = "15m"  ## 15 minutes
    Int30m = "30m"  ## 30 minutes
    Int1h = "1h"    ## 1 hour
    Int1d = "1d"    ## 1 day
    Int1wk = "1wk"  ## 1 week
    Int1mo = "1mo"  ## 1 month
  
  HistoryRecord* = object
    ## A single OHLCV (Open, High, Low, Close, Volume) data point
    time*: int64     ## Unix timestamp
    open*: float64   ## Opening price
    low*: float64    ## Low price
    high*: float64   ## High price
    close*: float64  ## Closing price
    volume*: int64   ## Trading volume
  
  History* = object
    ## Time series of OHLCV data for a symbol
    symbol*: string               ## Stock ticker symbol
    interval*: Interval           ## Time interval
    data*: seq[HistoryRecord]     ## Sequence of OHLCV records


proc newHistory*(symbol: string, interval: Interval): History =
  ## Creates a new empty History object
  ##
  ## Example:
  ##   let history = newHistory("AAPL", Int1d)
  result = History(
    symbol: symbol,
    interval: interval,
    data: @[]
  )


proc len*(history: History): int =
  ## Returns the number of records in the history
  ##
  ## Example:
  ##   echo history.len  # prints number of records
  result = history.data.len


proc append*(history: var History, record: HistoryRecord) =
  ## Appends a record to the history
  ##
  ## Example:
  ##   var hist = newHistory("AAPL", Int1d)
  ##   hist.append(HistoryRecord(time: 123456, open: 150.0, ...))
  history.data.add(record)


proc `$`*(record: HistoryRecord): string =
  ## String representation of a HistoryRecord for debugging
  result = "HistoryRecord(time: " & $record.time &
           ", open: " & $record.open &
           ", high: " & $record.high &
           ", low: " & $record.low &
           ", close: " & $record.close &
           ", volume: " & $record.volume & ")"


proc `$`*(history: History): string =
  ## String representation of a History object for debugging
  result = "History(symbol: " & history.symbol &
           ", interval: " & $history.interval &
           ", records: " & $history.len & ")"


proc toJson*(record: HistoryRecord): JsonNode =
  ## Converts a HistoryRecord to JSON
  result = %*{
    "time": record.time,
    "open": record.open,
    "high": record.high,
    "low": record.low,
    "close": record.close,
    "volume": record.volume
  }


proc toJson*(history: History): JsonNode =
  ## Converts a History object to JSON
  ##
  ## Example:
  ##   let json = history.toJson()
  ##   echo json.pretty()
  var dataArray = newJArray()
  for record in history.data:
    dataArray.add(record.toJson())
  
  result = %*{
    "symbol": history.symbol,
    "interval": $history.interval,
    "data": dataArray
  }


proc fromJson*(node: JsonNode, T: typedesc[HistoryRecord]): HistoryRecord =
  ## Parses a HistoryRecord from JSON
  result = HistoryRecord(
    time: node["time"].getInt(),
    open: node["open"].getFloat(),
    high: node["high"].getFloat(),
    low: node["low"].getFloat(),
    close: node["close"].getFloat(),
    volume: node["volume"].getInt()
  )


proc parseInterval*(s: string): Interval =
  ## Parses an interval string to Interval enum
  ##
  ## Raises ValueError if the string is not a valid interval
  case s.toLowerAscii()
  of "1m": Int1m
  of "5m": Int5m
  of "15m": Int15m
  of "30m": Int30m
  of "1h": Int1h
  of "1d": Int1d
  of "1wk": Int1wk
  of "1mo": Int1mo
  else:
    raise newException(ValueError, "Invalid interval: " & s)


proc fromJson*(node: JsonNode, T: typedesc[History]): History =
  ## Parses a History object from JSON
  ##
  ## Example:
  ##   let history = fromJson(jsonNode, History)
  result = History(
    symbol: node["symbol"].getStr(),
    interval: parseInterval(node["interval"].getStr()),
    data: @[]
  )
  
  for recordNode in node["data"]:
    result.data.add(fromJson(recordNode, HistoryRecord))
