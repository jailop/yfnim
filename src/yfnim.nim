## Yahoo Finance Data Retriever Library
##
## A lightweight, pure-Nim library for retrieving stock market data 
## from Yahoo Finance. Fetch historical OHLCV (Open, High, Low, Close, Volume) data
## and real-time/delayed quote information with a simple, type-safe API.
##
## **Features:**
## - Historical OHLCV data at multiple time intervals (1m, 5m, 15m, 30m, 1h, 1d, 1wk, 1mo)
## - Real-time/delayed quote data with price, volume, and market statistics
## - Type-safe API with comprehensive error handling
## - JSON serialization/deserialization
## - Zero external dependencies (Nim stdlib only)
##
## **Installation:**
##   nimble install yfnim
##
## **Compilation:**
##   nim c -d:ssl your_program.nim
##
## **Quick Start - Historical Data:**
## 
## .. code-block:: nim
##   import yfnim
##   import std/times
##   
##   # Fetch last 7 days of daily data
##   let now = getTime().toUnix()
##   let weekAgo = now - (7 * 24 * 3600)
##   let history = getHistory("AAPL", Int1d, weekAgo, now)
##   
##   # Display results
##   echo "Retrieved ", history.len, " records for ", history.symbol
##   for record in history.data:
##     echo "Time: ", record.time, " Close: $", record.close
##
## **Quick Start - Quote Data:**
##
## .. code-block:: nim
##   import yfnim/quote_retriever
##   
##   # Get current quote
##   let quote = getQuote("AAPL")
##   echo "Price: $", quote.regularMarketPrice
##   echo "Change: ", quote.regularMarketChangePercent, "%"
##   
##   # Get multiple quotes
##   let quotes = getQuotes(@["AAPL", "MSFT", "GOOGL"])
##   for q in quotes:
##     echo q.symbol, ": $", q.regularMarketPrice
##
## **Error Handling:**
##
## .. code-block:: nim
##   try:
##     let history = getHistory("AAPL", Int1d, startTime, endTime)
##   except ValueError as e:
##     echo "Invalid input: ", e.msg
##   except HttpRequestError as e:
##     echo "Network error: ", e.msg
##   except YahooApiError as e:
##     echo "API error: ", e.msg
##
## **Available Intervals:**
## - Int1m: 1 minute (limited to 7 days history)
## - Int5m: 5 minutes
## - Int15m: 15 minutes
## - Int30m: 30 minutes
## - Int1h: 1 hour
## - Int1d: 1 day
## - Int1wk: 1 week
## - Int1mo: 1 month
##
## **See also:**
## - `types module<yfnim/types.html>`_ for historical data structures
## - `retriever module<yfnim/retriever.html>`_ for historical data API
## - `urlbuilder module<yfnim/urlbuilder.html>`_ for URL construction
## - `quote_types module<yfnim/quote_types.html>`_ for quote data structures
## - `quote_retriever module<yfnim/quote_retriever.html>`_ for quote data API
##

# Historical data modules
import yfnim/types
import yfnim/urlbuilder
import yfnim/retriever

# Quote data modules
import yfnim/quote_types
import yfnim/quote_retriever

# Export all public APIs
export types
export urlbuilder
export retriever
export quote_types
export quote_retriever
