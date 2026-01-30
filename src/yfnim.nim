## Yahoo Finance Data Retriever Library
##
## A Nim library for retrieving historical stock data from Yahoo Finance.
## Supports multiple time intervals: 1m, 5m, 15m, 30m, 1h, 1d, 1wk, 1mo.
##
## Example:
##   import yfnim
##   import times
##   
##   let now = getTime().toUnix()
##   let oneWeekAgo = now - (7 * 24 * 3600)
##   let history = getHistory("AAPL", Int1d, oneWeekAgo, now)
##   
##   echo "Retrieved ", history.len, " records for ", history.symbol
##   for i in 0..<min(5, history.len):
##     echo history.data[i]

import yfnim/types
import yfnim/urlbuilder
import yfnim/retriever

export types
export urlbuilder
export retriever
