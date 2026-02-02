# API Reference

The yfnim library provides a clean, type-safe API for accessing Yahoo Finance data.

## Generating API Documentation

The full API documentation is generated from the source code using Nim's built-in documentation generator.

### Generate Locally

```bash
nimble docs
```

This generates HTML documentation in the `docs/api/` directory.

### Browse Generated Docs

After running `nimble docs`, open `docs/api/yfnim.html` in your browser.

## Core Modules

### yfnim

The main module that exports all public APIs.

```nim
import yfnim
```

### yfnim/types

Core data types for historical data:

- `Interval` - Time interval enum (Int1m, Int5m, Int15m, Int30m, Int1h, Int1d, Int1wk, Int1mo)
- `HistoryRecord` - Single OHLCV bar
- `History` - Time series of OHLCV data

### yfnim/quote_types

Data types for quote/ticker data:

- `Quote` - Real-time quote information
- `QuoteError` - Quote-specific errors

### yfnim/retriever

Functions for retrieving historical data:

- `getHistory()` - Fetch historical OHLCV data
- `newHistory()` - Create empty history object

### yfnim/quote_retriever

Functions for retrieving quote data:

- `getQuote()` - Fetch single quote
- `getQuotes()` - Fetch multiple quotes concurrently

### yfnim/urlbuilder

Internal module for building Yahoo Finance URLs.

## Quick API Overview

### Historical Data

```nim
proc getHistory*(
  symbol: string,
  interval: Interval,
  startTime: int64,
  endTime: int64
): History
```

Fetch historical OHLCV data for a symbol.

**Parameters:**

- `symbol` - Stock symbol (e.g., "AAPL", "MSFT")
- `interval` - Time interval (Int1d, Int1h, etc.)
- `startTime` - Start time (Unix timestamp)
- `endTime` - End time (Unix timestamp)

**Returns:** `History` object with data

**Raises:** `ValueError`, `HttpRequestError`, `YahooApiError`

### Quote Data

```nim
proc getQuote*(symbol: string): Quote
```

Get current quote for a symbol.

**Parameters:**

- `symbol` - Stock symbol

**Returns:** `Quote` object

**Raises:** `QuoteError`, `HttpRequestError`

```nim
proc getQuotes*(symbols: seq[string]): seq[Quote]
```

Get quotes for multiple symbols (concurrent requests).

**Parameters:**

- `symbols` - Sequence of stock symbols

**Returns:** Sequence of `Quote` objects

## Type Reference

### Interval Enum

```nim
type Interval* = enum
  Int1m   # 1 minute
  Int5m   # 5 minutes
  Int15m  # 15 minutes
  Int30m  # 30 minutes
  Int1h   # 1 hour
  Int1d   # 1 day
  Int1wk  # 1 week
  Int1mo  # 1 month
```

### HistoryRecord

```nim
type HistoryRecord* = object
  date*: int64      # Unix timestamp
  open*: float64    # Opening price
  high*: float64    # Highest price
  low*: float64     # Lowest price
  close*: float64   # Closing price
  volume*: int64    # Trading volume
```

### History

```nim
type History* = object
  symbol*: string
  interval*: Interval
  data*: seq[HistoryRecord]
```

### Quote

```nim
type Quote* = object
  symbol*: string
  regularMarketPrice*: float64
  regularMarketChange*: float64
  regularMarketChangePercent*: float64
  regularMarketVolume*: int64
  # ... and many more fields
```

See generated documentation for complete field list.

## Error Types

### ValueError

Invalid input parameters (invalid symbol, invalid date range, etc.)

### HttpRequestError

Network or HTTP errors when contacting Yahoo Finance.

### JsonParsingError

Invalid JSON response from Yahoo Finance.

### YahooApiError

Yahoo Finance API returned an error (symbol not found, data unavailable, etc.)

### QuoteError

Quote-specific errors.

## Examples

See the [Library Getting Started](../library/getting-started.md) guide for detailed examples.

## Nim Documentation

For the complete, detailed API documentation with all fields and methods, generate the docs locally:

```bash
cd yfnim
nimble docs
```

Then open `docs/api/yfnim.html` in your browser.

## Links

- [Library Getting Started](../library/getting-started.md)
- [Historical Data Guide](../library/historical-data.md)
- [Quote Data Guide](../library/quote-data.md)
