## Yahoo Finance Data Types Module
##
## This module defines the core data structures for the yfnim library.
##
## **Core Types:**
## - `Interval`_: Enum representing time intervals (1m, 1h, 1d, etc.)
## - `HistoryRecord`_: Single OHLCV data point with timestamp
## - `History`_: Time series of OHLCV data for a symbol
## - `DividendAction`_: Dividend payment information
## - `SplitAction`_: Stock split information
## - `CorporateAction`_: Combined dividends and splits
##
## **Key Functions:**
## - `newHistory`_: Create empty History object
## - `len`_: Get number of records
## - `append`_: Add record to history
## - `toJson`_: Export to JSON string
## - `fromJson`_: Import from JSON string
## - `parseInterval`_: Convert string to Interval enum
##
## **Example:**
##
## .. code-block:: nim
##   import yfnim/types
##   
##   # Create new history
##   var history = newHistory("AAPL", Int1d)
##   
##   # Add a record
##   let record = HistoryRecord(
##     time: 1609459200,
##     open: 132.43,
##     high: 133.61,
##     low: 131.72,
##     close: 133.52,
##     volume: 99116616
##   )
##   history.append(record)
##   
##   # Export to JSON
##   let jsonStr = history.toJson()
##   
##   # Import from JSON
##   let loaded = fromJson(jsonStr)
##

import std/json
import std/strutils
import std/times

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
  
  DividendAction* = object
    ## Dividend payment information
    date*: DateTime  ## Dividend payment date
    amount*: float64 ## Dividend amount per share
  
  SplitAction* = object
    ## Stock split information
    date*: DateTime  ## Split date
    numerator*: int  ## Split numerator (e.g., 7 in 7:1 split)
    denominator*: int ## Split denominator (e.g., 1 in 7:1 split)
    splitRatio*: string ## String representation (e.g., "7:1")
  
  CorporateAction* = object
    ## Combined dividends and splits for a symbol
    dividends*: seq[DividendAction] ## Dividend history
    splits*: seq[SplitAction]       ## Split history


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


proc toJson*(dividend: DividendAction): JsonNode =
  ## Converts a DividendAction to JSON
  result = %*{
    "date": dividend.date.format("yyyy-MM-dd"),
    "amount": dividend.amount
  }


proc toJson*(split: SplitAction): JsonNode =
  ## Converts a SplitAction to JSON
  result = %*{
    "date": split.date.format("yyyy-MM-dd"),
    "numerator": split.numerator,
    "denominator": split.denominator,
    "splitRatio": split.splitRatio
  }


proc toJson*(actions: CorporateAction): JsonNode =
  ## Converts a CorporateAction to JSON
  var divsArray = newJArray()
  for dividend in actions.dividends:
    divsArray.add(dividend.toJson())
  
  var splitsArray = newJArray()
  for split in actions.splits:
    splitsArray.add(split.toJson())
  
  result = %*{
    "dividends": divsArray,
    "splits": splitsArray
  }
