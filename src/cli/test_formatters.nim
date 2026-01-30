## Test formatters with sample data
##
## This is a simple test to verify all formatters work correctly

import std/[times, options, strutils]
import types, formatters, utils
import ../yfnim/[types as ytypes, quote_types]

# Create sample history data
proc createSampleHistory(): ytypes.History =
  result = ytypes.newHistory("AAPL", ytypes.Int1d)
  
  # Add some sample records (3 days of data)
  result.append(ytypes.HistoryRecord(
    time: 1704067200,  # 2024-01-01
    open: 185.50,
    high: 188.25,
    low: 184.75,
    close: 187.92,
    volume: 45678912
  ))
  
  result.append(ytypes.HistoryRecord(
    time: 1704153600,  # 2024-01-02
    open: 188.00,
    high: 190.50,
    low: 187.25,
    close: 189.75,
    volume: 52341234
  ))
  
  result.append(ytypes.HistoryRecord(
    time: 1704240000,  # 2024-01-03
    open: 189.80,
    high: 192.00,
    low: 189.00,
    close: 191.25,
    volume: 48912345
  ))

# Create sample quote data
proc createSampleQuotes(): seq[Quote] =
  result = @[
    Quote(
      symbol: "AAPL",
      shortName: "Apple Inc.",
      longName: "Apple Inc.",
      quoteType: Equity,
      currency: "USD",
      exchange: "NMS",
      exchangeTimezone: "America/New_York",
      regularMarketPrice: 191.25,
      regularMarketTime: 1704240000,
      regularMarketChange: 1.50,
      regularMarketChangePercent: 0.79,
      regularMarketOpen: 189.80,
      regularMarketDayHigh: 192.00,
      regularMarketDayLow: 189.00,
      regularMarketVolume: 48912345,
      regularMarketPreviousClose: 189.75,
      bid: 191.20,
      ask: 191.30,
      bidSize: 100,
      askSize: 200,
      fiftyTwoWeekLow: 124.17,
      fiftyTwoWeekHigh: 199.62,
      fiftyTwoWeekChangePercent: 54.02,
      fiftyDayAverage: 182.50,
      fiftyDayAverageChange: 8.75,
      fiftyDayAverageChangePercent: 4.79,
      twoHundredDayAverage: 175.25,
      twoHundredDayAverageChange: 16.00,
      twoHundredDayAverageChangePercent: 9.13,
      averageDailyVolume3Month: 52000000,
      averageDailyVolume10Day: 48000000,
      marketCap: 2950000000000'i64,
      sharesOutstanding: 15425000000'i64,
      trailingPE: some(29.5),
      forwardPE: some(27.3),
      priceToBook: some(45.2),
      bookValue: some(4.23),
      earningsPerShare: some(6.48),
      epsTrailingTwelveMonths: some(6.48),
      epsForward: some(7.01),
      epsCurrentYear: some(6.75),
      dividendRate: some(0.96),
      dividendYield: some(0.50),
      exDividendDate: some(1702512000'i64),
      trailingAnnualDividendRate: some(0.96),
      trailingAnnualDividendYield: some(0.50),
      marketState: Regular,
      tradeable: true,
      triggerable: true
    ),
    Quote(
      symbol: "MSFT",
      shortName: "Microsoft Corp.",
      longName: "Microsoft Corporation",
      quoteType: Equity,
      currency: "USD",
      exchange: "NMS",
      exchangeTimezone: "America/New_York",
      regularMarketPrice: 375.50,
      regularMarketTime: 1704240000,
      regularMarketChange: -2.25,
      regularMarketChangePercent: -0.60,
      regularMarketOpen: 377.00,
      regularMarketDayHigh: 378.50,
      regularMarketDayLow: 374.75,
      regularMarketVolume: 22456789,
      regularMarketPreviousClose: 377.75,
      bid: 375.45,
      ask: 375.55,
      bidSize: 150,
      askSize: 100,
      fiftyTwoWeekLow: 245.61,
      fiftyTwoWeekHigh: 384.30,
      fiftyTwoWeekChangePercent: 52.93,
      fiftyDayAverage: 365.20,
      fiftyDayAverageChange: 10.30,
      fiftyDayAverageChangePercent: 2.82,
      twoHundredDayAverage: 340.10,
      twoHundredDayAverageChange: 35.40,
      twoHundredDayAverageChangePercent: 10.41,
      averageDailyVolume3Month: 25000000,
      averageDailyVolume10Day: 23000000,
      marketCap: 2790000000000'i64,
      sharesOutstanding: 7430000000'i64,
      trailingPE: some(35.8),
      forwardPE: some(31.2),
      priceToBook: some(12.5),
      bookValue: some(30.02),
      earningsPerShare: some(10.49),
      epsTrailingTwelveMonths: some(10.49),
      epsForward: some(12.03),
      epsCurrentYear: some(11.25),
      dividendRate: some(2.72),
      dividendYield: some(0.72),
      exDividendDate: some(1702425600'i64),
      trailingAnnualDividendRate: some(2.72),
      trailingAnnualDividendYield: some(0.72),
      marketState: Regular,
      tradeable: true,
      triggerable: true
    )
  ]

proc testFormatters() =
  echo "=== Testing Formatters ==="
  echo ""
  
  let history = createSampleHistory()
  let quotes = createSampleQuotes()
  
  # Test with default config
  var config = newGlobalConfig()
  
  # Test Table Formatter
  echo "--- Table Format (History) ---"
  config.format = FormatTable
  var formatter = newFormatter(config)
  echo formatter.formatHistory(history)
  echo ""
  
  echo "--- Table Format (Quotes) ---"
  echo formatter.formatQuotes(quotes)
  echo ""
  
  # Test CSV Formatter
  echo "--- CSV Format (History) ---"
  config.format = FormatCSV
  formatter = newFormatter(config)
  echo formatter.formatHistory(history)
  echo ""
  
  echo "--- CSV Format (Quotes) ---"
  echo formatter.formatQuotes(quotes)
  echo ""
  
  # Test TSV Formatter
  echo "--- TSV Format (History) ---"
  config.format = FormatTSV
  formatter = newFormatter(config)
  echo formatter.formatHistory(history)
  echo ""
  
  echo "--- TSV Format (Quotes) ---"
  echo formatter.formatQuotes(quotes)
  echo ""
  
  # Test Minimal Formatter
  echo "--- Minimal Format (History) ---"
  config.format = FormatMinimal
  formatter = newFormatter(config)
  echo formatter.formatHistory(history)
  echo ""
  
  echo "--- Minimal Format (Quotes) ---"
  echo formatter.formatQuotes(quotes)
  echo ""
  
  # Test JSON Formatter (just show it works, output is long)
  echo "--- JSON Format (History) - First 10 lines ---"
  config.format = FormatJSON
  formatter = newFormatter(config)
  let jsonHistory = formatter.formatHistory(history)
  let jsonLines = jsonHistory.split("\n")
  for i in 0..min(9, jsonLines.high):
    echo jsonLines[i]
  echo "..."
  echo ""
  
  echo "All formatters tested successfully!"

when isMainModule:
  testFormatters()
