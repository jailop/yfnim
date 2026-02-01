## Batch Download Module
##
## Provides functionality to download historical data for multiple tickers

import std/[strformat, tables, times]
import types, retriever

type
  BatchError* = object of CatchableError
    ## Exception raised when batch download fails
  
  BatchResult* = object
    ## Result of batch download operation
    successful*: Table[string, History]  # ticker -> data
    failed*: Table[string, string]       # ticker -> error message


proc downloadBatch*(tickers: seq[string], interval: Interval, 
                    startTime: int64, endTime: int64): BatchResult =
  ## Download historical data for multiple tickers
  ## 
  ## This is a sequential implementation for v0.2.0 (simple and reliable)
  ## Future versions may add async/concurrent downloads for better performance
  ## 
  ## Args:
  ##   tickers: List of stock symbols (e.g., @["AAPL", "MSFT", "GOOGL"])
  ##   interval: Time interval (Int1m, Int1h, Int1d, etc.)
  ##   startTime: Start date as Unix timestamp
  ##   endTime: End date as Unix timestamp
  ## 
  ## Returns:
  ##   BatchResult with successful downloads and failures
  ## 
  ## Example:
  ##   let result = downloadBatch(@["AAPL", "MSFT", "GOOGL"], Int1d, start, end)
  ##   for ticker, history in result.successful:
  ##     echo fmt"{ticker}: {history.data.len} bars"
  ##   for ticker, error in result.failed:
  ##     echo fmt"{ticker}: Failed - {error}"
  
  result = BatchResult(
    successful: initTable[string, History](),
    failed: initTable[string, string]()
  )
  
  if tickers.len == 0:
    raise newException(BatchError, "No tickers provided")
  
  # Sequential implementation (simpler, no async complexity)
  # Progress indication writes to stderr to not interfere with data output
  var completed = 0
  let total = tickers.len
  
  for ticker in tickers:
    try:
      let history = getHistory(ticker, interval, startTime, endTime)
      result.successful[ticker] = history
      completed += 1
      
      # Progress indication (write to stderr)
      stderr.write(fmt"\rProgress: {completed}/{total} ({100*completed div total}%)    ")
      stderr.flushFile()
      
    except CatchableError as e:
      result.failed[ticker] = e.msg
      completed += 1
      stderr.write(fmt"\rProgress: {completed}/{total} ({100*completed div total}%)    ")
      stderr.flushFile()
  
  stderr.write("\n")
  stderr.flushFile()
