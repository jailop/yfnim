# yfnim Examples

This directory contains example programs demonstrating various features of the yfnim library.

## Running Examples

All examples require SSL support and need to reference the source directory. Compile and run with:

```bash
nim c -d:ssl -p:src -r examples/example_name.nim
```

Or from the examples directory:

```bash
cd examples
nim c -d:ssl -p:../src -r example_name.nim
```

## Available Examples

### 1. basic_usage.nim

**Purpose**: Simple introduction to the library  
**Demonstrates**:
- Fetching daily historical data
- Accessing OHLCV fields
- Displaying timestamps and prices

**Run**:
```bash
nim c -d:ssl -p:src -r examples/basic_usage.nim
```

### 2. multiple_symbols.nim

**Purpose**: Fetch data for multiple stocks  
**Demonstrates**:
- Iterating through multiple symbols
- Calculating statistics (average, min, max)
- Error handling for each symbol
- Rate limiting (respectful delays between requests)

**Run**:
```bash
nim c -d:ssl -p:src -r examples/multiple_symbols.nim
```

### 3. json_export.nim

**Purpose**: Save and load data using JSON  
**Demonstrates**:
- Exporting History to JSON file
- Importing History from JSON file
- Data integrity verification
- File I/O operations

**Run**:
```bash
nim c -d:ssl -p:src -r examples/json_export.nim
```

### 4. error_handling.nim

**Purpose**: Comprehensive error handling patterns  
**Demonstrates**:
- Handling different exception types
- Input validation errors (ValueError)
- Network errors (HttpRequestError)
- API errors (YahooApiError)
- Edge cases (invalid symbols, date ranges, etc.)

**Run**:
```bash
nim c -d:ssl -p:src -r examples/error_handling.nim
```

### 5. data_analysis.nim

**Purpose**: Basic technical analysis  
**Demonstrates**:
- Calculating Simple Moving Averages (SMA)
- Volatility calculation (standard deviation)
- Trend detection
- Finding high/low prices
- Volume analysis

**Run**:
```bash
nim c -d:ssl -p:src -r examples/data_analysis.nim
```

**Note**: This is a basic example. For production use, consider specialized technical analysis libraries.

### 6. intraday_analysis.nim

**Purpose**: Working with high-frequency intraday data  
**Demonstrates**:
- Fetching 1m, 5m, 15m interval data
- Analyzing intraday price action
- Finding volatile bars
- Displaying recent bars
- Understanding intraday data limitations

**Run**:
```bash
nim c -d:ssl -p:src -r examples/intraday_analysis.nim
```

**Note**: Intraday data availability is limited:
- 1m interval: Last 7 days maximum
- 5m/15m/30m: Last 60 days approximately
- 1h: Last 730 days approximately

## Tips for Using Examples

### Rate Limiting

Yahoo Finance doesn't publish official rate limits, but it's good practice to:
- Add delays between requests (1-2 seconds)
- Avoid excessive requests in short periods
- Cache data when possible

Example:
```nim
import std/os

for symbol in symbols:
  let history = getHistory(symbol, Int1d, startTime, endTime)
  # ... process data ...
  sleep(1000)  # 1 second delay
```

### Error Handling Pattern

Always wrap API calls in try-except blocks:

```nim
try:
  let history = getHistory("AAPL", Int1d, startTime, endTime)
  # ... use data ...
except ValueError as e:
  echo "Invalid input: ", e.msg
except HttpRequestError as e:
  echo "Network error: ", e.msg
except YahooApiError as e:
  echo "API error: ", e.msg
```

### Market Hours

Keep in mind:
- Intraday data is most relevant during market hours
- Data availability varies by market (US, European, Asian)
- Weekend and holiday data may be sparse or missing

### Data Quality

Yahoo Finance data may have:
- Missing values (represented as NaN)
- Occasional gaps in intraday data
- Delays in real-time data (typically 15-20 minutes)

## Building Your Own Applications

Use these examples as templates:

1. Start with `basic_usage.nim` to understand the fundamentals
2. Add error handling from `error_handling.nim`
3. Implement your specific logic (analysis, export, etc.)
4. Test with various symbols and date ranges
5. Add rate limiting and caching as needed

## Further Reading

- Main documentation: `../README.md`
- API reference: Generate with `nim doc ../src/yfnim.nim`
- Test suite: See `../tests/` for comprehensive examples

## Support

If you have questions or find issues:
- Check the main README.md
- Review the test suite for usage patterns
- Report issues on GitHub
