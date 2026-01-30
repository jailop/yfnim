## Output Formatters Module
##
## Provides multiple output formats for CLI data display:
## - Table: Human-readable aligned columns
## - CSV: Comma-separated values
## - JSON: JSON format
## - TSV: Tab-separated values
## - Minimal: Bare values for piping

import std/[strutils, json, times, tables, strformat]
import types, utils
import ../yfnim/[types as ytypes, quote_types]

# Forward declarations
type
  Formatter* = ref object of RootObj
    ## Base formatter type
    config*: GlobalConfig

# Formatter methods (to be overridden by specific formatters)
method formatHistory*(f: Formatter, history: ytypes.History): string {.base.} =
  ## Format historical OHLCV data
  raise newException(CliError, "formatHistory not implemented for this formatter")

method formatQuote*(f: Formatter, quote: Quote): string {.base.} =
  ## Format a single quote
  raise newException(CliError, "formatQuote not implemented for this formatter")

method formatQuotes*(f: Formatter, quotes: seq[Quote]): string {.base.} =
  ## Format multiple quotes
  raise newException(CliError, "formatQuotes not implemented for this formatter")


# ============================================================================
# Table Formatter - Human-readable aligned columns
# ============================================================================

type
  TableFormatter* = ref object of Formatter
    ## Formatter for human-readable tables with aligned columns

proc newTableFormatter*(config: GlobalConfig): TableFormatter =
  ## Create a new table formatter
  result = TableFormatter(config: config)

proc formatTableRow(values: seq[string], widths: seq[int], alignRight: seq[bool] = @[]): string =
  ## Format a single table row with aligned columns
  var parts: seq[string] = @[]
  for i, val in values:
    if i < widths.len:
      let width = widths[i]
      let aligned = if i < alignRight.len and alignRight[i]:
        alignRight(val, width)
      else:
        alignLeft(val, width)
      parts.add(aligned)
    else:
      parts.add(val)
  result = parts.join("  ")

proc formatTableSeparator(widths: seq[int]): string =
  ## Format a separator line for tables
  var parts: seq[string] = @[]
  for width in widths:
    parts.add(repeat("-", width))
  result = parts.join("  ")

method formatHistory*(f: TableFormatter, history: ytypes.History): string =
  ## Format historical data as a table
  if history.data.len == 0:
    return "No data available"
  
  var lines: seq[string] = @[]
  
  # Header
  if not f.config.noHeader:
    let headers = @["Date", "Open", "High", "Low", "Close", "Volume"]
    let widths = @[10, 10, 10, 10, 10, 15]
    let alignRight = @[false, true, true, true, true, true]
    lines.add(formatTableRow(headers, widths, alignRight))
    lines.add(formatTableSeparator(widths))
  
  # Data rows
  for record in history.data:
    let dateStr = formatDate(record.time, f.config.dateFormat)
    let openStr = formatPrice(record.open, f.config.precision)
    let highStr = formatPrice(record.high, f.config.precision)
    let lowStr = formatPrice(record.low, f.config.precision)
    let closeStr = formatPrice(record.close, f.config.precision)
    let volStr = formatVolume(record.volume)
    
    let values = @[dateStr, openStr, highStr, lowStr, closeStr, volStr]
    let widths = @[10, 10, 10, 10, 10, 15]
    let alignRight = @[false, true, true, true, true, true]
    lines.add(formatTableRow(values, widths, alignRight))
  
  result = lines.join("\n")

method formatQuote*(f: TableFormatter, quote: Quote): string =
  ## Format a single quote as a table
  result = f.formatQuotes(@[quote])

method formatQuotes*(f: TableFormatter, quotes: seq[Quote]): string =
  ## Format multiple quotes as a table
  if quotes.len == 0:
    return "No quotes available"
  
  var lines: seq[string] = @[]
  
  # Header
  if not f.config.noHeader:
    let headers = @["Symbol", "Price", "Change", "Change%", "Volume", "Market Cap"]
    let widths = @[8, 10, 10, 10, 15, 15]
    let alignRight = @[false, true, true, true, true, true]
    lines.add(formatTableRow(headers, widths, alignRight))
    lines.add(formatTableSeparator(widths))
  
  # Data rows
  for quote in quotes:
    let symStr = quote.symbol
    let priceStr = formatPrice(quote.regularMarketPrice, f.config.precision)
    let changeStr = colorize(formatChange(quote.regularMarketChange, f.config.precision),
                             if quote.regularMarketChange >= 0: ColorGreen else: ColorRed,
                             f.config)
    let changePctStr = colorize(formatPercent(quote.regularMarketChangePercent, f.config.precision),
                                if quote.regularMarketChangePercent >= 0: ColorGreen else: ColorRed,
                                f.config)
    let volStr = formatVolume(quote.regularMarketVolume)
    let mcapStr = formatLargeNumber(quote.marketCap)
    
    let values = @[symStr, priceStr, changeStr, changePctStr, volStr, mcapStr]
    let widths = @[8, 10, 10, 10, 15, 15]
    let alignRight = @[false, true, true, true, true, true]
    lines.add(formatTableRow(values, widths, alignRight))
  
  result = lines.join("\n")


# ============================================================================
# CSV Formatter - Comma-separated values
# ============================================================================

type
  CSVFormatter* = ref object of Formatter
    ## Formatter for CSV output

proc newCSVFormatter*(config: GlobalConfig): CSVFormatter =
  ## Create a new CSV formatter
  result = CSVFormatter(config: config)

proc escapeCSV(s: string): string =
  ## Escape a string for CSV output
  if s.contains(',') or s.contains('"') or s.contains('\n'):
    result = "\"" & s.replace("\"", "\"\"") & "\""
  else:
    result = s

method formatHistory*(f: CSVFormatter, history: ytypes.History): string =
  ## Format historical data as CSV
  if history.data.len == 0:
    return ""
  
  var lines: seq[string] = @[]
  
  # Header
  if not f.config.noHeader:
    lines.add("Date,Open,High,Low,Close,Volume")
  
  # Data rows
  for record in history.data:
    let dateStr = formatDate(record.time, f.config.dateFormat)
    let openStr = formatFloat(record.open, ffDecimal, f.config.precision)
    let highStr = formatFloat(record.high, ffDecimal, f.config.precision)
    let lowStr = formatFloat(record.low, ffDecimal, f.config.precision)
    let closeStr = formatFloat(record.close, ffDecimal, f.config.precision)
    let volStr = $record.volume
    
    lines.add(&"{dateStr},{openStr},{highStr},{lowStr},{closeStr},{volStr}")
  
  result = lines.join("\n")

method formatQuote*(f: CSVFormatter, quote: Quote): string =
  ## Format a single quote as CSV
  result = f.formatQuotes(@[quote])

method formatQuotes*(f: CSVFormatter, quotes: seq[Quote]): string =
  ## Format multiple quotes as CSV
  if quotes.len == 0:
    return ""
  
  var lines: seq[string] = @[]
  
  # Header
  if not f.config.noHeader:
    lines.add("Symbol,Price,Change,ChangePercent,Volume,MarketCap")
  
  # Data rows
  for quote in quotes:
    let symStr = escapeCSV(quote.symbol)
    let priceStr = formatFloat(quote.regularMarketPrice, ffDecimal, f.config.precision)
    let changeStr = formatFloat(quote.regularMarketChange, ffDecimal, f.config.precision)
    let changePctStr = formatFloat(quote.regularMarketChangePercent, ffDecimal, f.config.precision)
    let volStr = $quote.regularMarketVolume
    let mcapStr = $quote.marketCap
    
    lines.add(&"{symStr},{priceStr},{changeStr},{changePctStr},{volStr},{mcapStr}")
  
  result = lines.join("\n")


# ============================================================================
# JSON Formatter - JSON output
# ============================================================================

type
  JSONFormatter* = ref object of Formatter
    ## Formatter for JSON output

proc newJSONFormatter*(config: GlobalConfig): JSONFormatter =
  ## Create a new JSON formatter
  result = JSONFormatter(config: config)

method formatHistory*(f: JSONFormatter, history: ytypes.History): string =
  ## Format historical data as JSON
  let jsonNode = history.toJson()
  result = jsonNode.pretty()

method formatQuote*(f: JSONFormatter, quote: Quote): string =
  ## Format a single quote as JSON
  let jsonNode = quote.toJson()
  result = jsonNode.pretty()

method formatQuotes*(f: JSONFormatter, quotes: seq[Quote]): string =
  ## Format multiple quotes as JSON
  var jsonArray = newJArray()
  for quote in quotes:
    jsonArray.add(quote.toJson())
  result = jsonArray.pretty()


# ============================================================================
# TSV Formatter - Tab-separated values
# ============================================================================

type
  TSVFormatter* = ref object of Formatter
    ## Formatter for TSV output

proc newTSVFormatter*(config: GlobalConfig): TSVFormatter =
  ## Create a new TSV formatter
  result = TSVFormatter(config: config)

method formatHistory*(f: TSVFormatter, history: ytypes.History): string =
  ## Format historical data as TSV
  if history.data.len == 0:
    return ""
  
  var lines: seq[string] = @[]
  
  # Header
  if not f.config.noHeader:
    lines.add("Date\tOpen\tHigh\tLow\tClose\tVolume")
  
  # Data rows
  for record in history.data:
    let dateStr = formatDate(record.time, f.config.dateFormat)
    let openStr = formatFloat(record.open, ffDecimal, f.config.precision)
    let highStr = formatFloat(record.high, ffDecimal, f.config.precision)
    let lowStr = formatFloat(record.low, ffDecimal, f.config.precision)
    let closeStr = formatFloat(record.close, ffDecimal, f.config.precision)
    let volStr = $record.volume
    
    lines.add(&"{dateStr}\t{openStr}\t{highStr}\t{lowStr}\t{closeStr}\t{volStr}")
  
  result = lines.join("\n")

method formatQuote*(f: TSVFormatter, quote: Quote): string =
  ## Format a single quote as TSV
  result = f.formatQuotes(@[quote])

method formatQuotes*(f: TSVFormatter, quotes: seq[Quote]): string =
  ## Format multiple quotes as TSV
  if quotes.len == 0:
    return ""
  
  var lines: seq[string] = @[]
  
  # Header
  if not f.config.noHeader:
    lines.add("Symbol\tPrice\tChange\tChangePercent\tVolume\tMarketCap")
  
  # Data rows
  for quote in quotes:
    let symStr = quote.symbol
    let priceStr = formatFloat(quote.regularMarketPrice, ffDecimal, f.config.precision)
    let changeStr = formatFloat(quote.regularMarketChange, ffDecimal, f.config.precision)
    let changePctStr = formatFloat(quote.regularMarketChangePercent, ffDecimal, f.config.precision)
    let volStr = $quote.regularMarketVolume
    let mcapStr = $quote.marketCap
    
    lines.add(&"{symStr}\t{priceStr}\t{changeStr}\t{changePctStr}\t{volStr}\t{mcapStr}")
  
  result = lines.join("\n")


# ============================================================================
# Minimal Formatter - Bare values for piping
# ============================================================================

type
  MinimalFormatter* = ref object of Formatter
    ## Formatter for minimal output (space-separated, no headers)

proc newMinimalFormatter*(config: GlobalConfig): MinimalFormatter =
  ## Create a new minimal formatter
  result = MinimalFormatter(config: config)

method formatHistory*(f: MinimalFormatter, history: ytypes.History): string =
  ## Format historical data as minimal output
  if history.data.len == 0:
    return ""
  
  var lines: seq[string] = @[]
  
  # Data rows only (no header)
  for record in history.data:
    let dateStr = formatDate(record.time, f.config.dateFormat)
    let openStr = formatFloat(record.open, ffDecimal, f.config.precision)
    let highStr = formatFloat(record.high, ffDecimal, f.config.precision)
    let lowStr = formatFloat(record.low, ffDecimal, f.config.precision)
    let closeStr = formatFloat(record.close, ffDecimal, f.config.precision)
    let volStr = $record.volume
    
    lines.add(&"{dateStr} {openStr} {highStr} {lowStr} {closeStr} {volStr}")
  
  result = lines.join("\n")

method formatQuote*(f: MinimalFormatter, quote: Quote): string =
  ## Format a single quote as minimal output
  result = f.formatQuotes(@[quote])

method formatQuotes*(f: MinimalFormatter, quotes: seq[Quote]): string =
  ## Format multiple quotes as minimal output
  if quotes.len == 0:
    return ""
  
  var lines: seq[string] = @[]
  
  # Data rows only (no header)
  for quote in quotes:
    let symStr = quote.symbol
    let priceStr = formatFloat(quote.regularMarketPrice, ffDecimal, f.config.precision)
    let changeStr = formatFloat(quote.regularMarketChange, ffDecimal, f.config.precision)
    let changePctStr = formatFloat(quote.regularMarketChangePercent, ffDecimal, f.config.precision)
    let volStr = $quote.regularMarketVolume
    let mcapStr = $quote.marketCap
    
    lines.add(&"{symStr} {priceStr} {changeStr} {changePctStr} {volStr} {mcapStr}")
  
  result = lines.join("\n")


# ============================================================================
# Factory Function
# ============================================================================

proc newFormatter*(config: GlobalConfig): Formatter =
  ## Create a formatter based on the config's output format
  case config.format
  of FormatTable:
    result = newTableFormatter(config)
  of FormatCSV:
    result = newCSVFormatter(config)
  of FormatJSON:
    result = newJSONFormatter(config)
  of FormatTSV:
    result = newTSVFormatter(config)
  of FormatMinimal:
    result = newMinimalFormatter(config)
