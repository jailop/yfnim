## yf2 - Yahoo Finance CLI Tool (cligen version)
##
## This is a reimplementation of the yf CLI using cligen for argument parsing

import std/[strutils]
import cligen
import cli/types
import cli/utils
import cli/stdin_reader
import cli/config_builder
import cli/commands/[history, quote, compare, screen, actions, download, indicators]

const Version = "0.3.0"

# Global configuration passed to all commands
var globalConfig = newGlobalConfig()

proc history_cmd(
  symbol: string = "",
  interval: string = "1d",
  start: string = "",
  `end`: string = "",
  lookback: string = "7d",
  format: string = "table",
  verbose = false,
  no_header = false,
  no_color = false,
  precision: int = 2,
  date_format: string = "iso",
  read_stdin = false
) =
  ## Retrieve historical OHLCV data for a symbol
  
  # Get symbol from argument or stdin
  var finalSymbol = symbol
  if read_stdin and finalSymbol.len == 0:
    let stdinSymbols = readAndValidateSymbols()
    if stdinSymbols.len > 0:
      finalSymbol = stdinSymbols[0]
  
  if finalSymbol.len == 0:
    raise newException(CliError, "Symbol is required")
  
  # Build config from parameters
  let config = buildConfig(format, verbose, no_header, no_color, precision, date_format)
  
  # Build history options
  var options = newHistoryOptions()
  options.symbols = @[finalSymbol]
  options.interval = parseInterval(interval)
  options.startDate = start
  options.endDate = `end`
  options.lookback = lookback
  
  # Execute command
  try:
    executeHistory(config, options, finalSymbol)
  except CliError as e:
    stderr.writeLine("Error: " & e.msg)
    quit(1)
  except CatchableError as e:
    stderr.writeLine("Error: " & e.msg)
    quit(1)

proc quote_cmd(
  symbols: seq[string],
  metrics: string = "",
  format: string = "table",
  verbose = false,
  no_header = false,
  no_color = false,
  precision: int = 2,
  date_format: string = "iso",
  read_stdin = false
) =
  ## Get current quote data for one or more symbols
  
  # Get symbols - from args or stdin
  var finalSymbols = symbols
  if read_stdin:
    finalSymbols.add(readAndValidateSymbols())
  
  if finalSymbols.len == 0:
    stderr.writeLine("Error: At least one symbol is required")
    quit(1)
  
  # Build config
  var config = newGlobalConfig()
  config.verbose = verbose
  config.no_header = no_header
  config.colorize = not no_color
  config.precision = precision
  
  # Parse format
  case format.toLower()
  of "table": config.format = FormatTable
  of "csv": config.format = FormatCSV
  of "json": config.format = FormatJSON
  of "tsv": config.format = FormatTSV
  of "minimal": config.format = FormatMinimal
  else:
    raise newException(CliError, "Invalid format: " & format)
  
  # Parse date format
  case date_format.toLower()
  of "iso": config.date_format = DateISO
  of "us": config.date_format = DateUS
  of "unix": config.date_format = DateUnix
  of "full": config.date_format = DateFull
  else:
    raise newException(CliError, "Invalid date format: " & date_format)
  
  # Build options
  var options = newQuoteOptions()
  options.symbols = finalSymbols
  if metrics.len > 0:
    options.metrics = metrics.split(',')
  
  # Execute command
  try:
    executeQuote(config, options, finalSymbols)
  except CliError as e:
    stderr.writeLine("Error: " & e.msg)
    quit(1)
  except CatchableError as e:
    stderr.writeLine("Error: " & e.msg)
    quit(1)

proc compare_cmd(
  symbols: seq[string],
  metrics: string = "",
  format: string = "table",
  verbose = false,
  no_header = false,
  no_color = false,
  precision: int = 2,
  date_format: string = "iso",
  read_stdin = false
) =
  ## Compare multiple stocks side-by-side
  
  # Get symbols - from args or stdin
  var finalSymbols = symbols
  if read_stdin:
    finalSymbols.add(readAndValidateSymbols())
  
  if finalSymbols.len < 2:
    stderr.writeLine("Error: At least two symbols are required for comparison")
    quit(1)
  
  # Build config
  var config = newGlobalConfig()
  config.verbose = verbose
  config.no_header = no_header
  config.colorize = not no_color
  config.precision = precision
  
  # Parse format
  case format.toLower()
  of "table": config.format = FormatTable
  of "csv": config.format = FormatCSV
  of "json": config.format = FormatJSON
  of "tsv": config.format = FormatTSV
  of "minimal": config.format = FormatMinimal
  else:
    raise newException(CliError, "Invalid format: " & format)
  
  # Parse date format
  case date_format.toLower()
  of "iso": config.date_format = DateISO
  of "us": config.date_format = DateUS
  of "unix": config.date_format = DateUnix
  of "full": config.date_format = DateFull
  else:
    raise newException(CliError, "Invalid date format: " & date_format)
  
  # Build options
  var options = newCompareOptions()
  options.symbols = finalSymbols
  if metrics.len > 0:
    options.metrics = metrics.split(',')
  
  # Execute command
  try:
    executeCompare(config, options, finalSymbols)
  except CliError as e:
    stderr.writeLine("Error: " & e.msg)
    quit(1)
  except CatchableError as e:
    stderr.writeLine("Error: " & e.msg)
    quit(1)

proc download_cmd(
  symbols: seq[string],
  interval: string = "1d",
  start: string = "",
  `end`: string = "",
  lookback: string = "7d",
  format: string = "table",
  verbose = false,
  no_header = false,
  no_color = false,
  precision: int = 2,
  date_format: string = "iso",
  read_stdin = false
) =
  ## Batch download historical data for multiple symbols
  
  # Get symbols - from args or stdin
  var finalSymbols = symbols
  if read_stdin:
    finalSymbols.add(readAndValidateSymbols())
  
  if finalSymbols.len == 0:
    stderr.writeLine("Error: At least one symbol is required")
    quit(1)
  
  # Build config
  var config = newGlobalConfig()
  config.verbose = verbose
  config.no_header = no_header
  config.colorize = not no_color
  config.precision = precision
  
  # Parse format
  case format.toLower()
  of "table": config.format = FormatTable
  of "csv": config.format = FormatCSV
  of "json": config.format = FormatJSON
  of "tsv": config.format = FormatTSV
  else:
    raise newException(CliError, "Invalid format: " & format)
  
  # Parse date format
  case date_format.toLower()
  of "iso": config.date_format = DateISO
  of "us": config.date_format = DateUS
  of "unix": config.date_format = DateUnix
  of "full": config.date_format = DateFull
  else:
    raise newException(CliError, "Invalid date format: " & date_format)
  
  # Build options
  var options = newHistoryOptions()
  options.symbols = finalSymbols
  options.interval = parseInterval(interval)
  options.startDate = start
  options.endDate = `end`
  options.lookback = lookback
  
  # Execute command
  try:
    executeDownload(config, options)
  except CliError as e:
    stderr.writeLine("Error: " & e.msg)
    quit(1)
  except CatchableError as e:
    stderr.writeLine("Error: " & e.msg)
    quit(1)

proc dividends_cmd(
  symbol: string,
  start: string = "",
  `end`: string = "",
  lookback: string = "max",
  format: string = "table",
  verbose = false,
  no_header = false,
  no_color = false,
  precision: int = 2,
  date_format: string = "iso"
) =
  ## Retrieve dividend history for a symbol
  
  # Build config
  var config = newGlobalConfig()
  config.verbose = verbose
  config.no_header = no_header
  config.colorize = not no_color
  config.precision = precision
  
  # Parse format
  case format.toLower()
  of "table": config.format = FormatTable
  of "csv": config.format = FormatCSV
  of "json": config.format = FormatJSON
  of "tsv": config.format = FormatTSV
  else:
    raise newException(CliError, "Invalid format: " & format)
  
  # Parse date format
  case date_format.toLower()
  of "iso": config.date_format = DateISO
  of "us": config.date_format = DateUS
  of "unix": config.date_format = DateUnix
  of "full": config.date_format = DateFull
  else:
    raise newException(CliError, "Invalid date format: " & date_format)
  
  # Build options
  var options = newActionsOptions()
  options.symbol = symbol
  options.startDate = start
  options.endDate = `end`
  options.lookback = lookback
  
  # Execute command
  try:
    executeDividends(config, options)
  except CliError as e:
    stderr.writeLine("Error: " & e.msg)
    quit(1)
  except CatchableError as e:
    stderr.writeLine("Error: " & e.msg)
    quit(1)

proc splits_cmd(
  symbol: string,
  start: string = "",
  `end`: string = "",
  lookback: string = "max",
  format: string = "table",
  verbose = false,
  no_header = false,
  no_color = false,
  precision: int = 2,
  date_format: string = "iso"
) =
  ## Retrieve stock split history for a symbol
  
  # Build config
  var config = newGlobalConfig()
  config.verbose = verbose
  config.no_header = no_header
  config.colorize = not no_color
  config.precision = precision
  
  # Parse format
  case format.toLower()
  of "table": config.format = FormatTable
  of "csv": config.format = FormatCSV
  of "json": config.format = FormatJSON
  of "tsv": config.format = FormatTSV
  else:
    raise newException(CliError, "Invalid format: " & format)
  
  # Parse date format
  case date_format.toLower()
  of "iso": config.date_format = DateISO
  of "us": config.date_format = DateUS
  of "unix": config.date_format = DateUnix
  of "full": config.date_format = DateFull
  else:
    raise newException(CliError, "Invalid date format: " & date_format)
  
  # Build options
  var options = newActionsOptions()
  options.symbol = symbol
  options.startDate = start
  options.endDate = `end`
  options.lookback = lookback
  
  # Execute command
  try:
    executeSplits(config, options)
  except CliError as e:
    stderr.writeLine("Error: " & e.msg)
    quit(1)
  except CatchableError as e:
    stderr.writeLine("Error: " & e.msg)
    quit(1)

proc actions_cmd(
  symbol: string,
  start: string = "",
  `end`: string = "",
  lookback: string = "max",
  format: string = "table",
  verbose = false,
  no_header = false,
  no_color = false,
  precision: int = 2,
  date_format: string = "iso"
) =
  ## Retrieve all corporate actions (dividends + splits)
  
  # Build config
  var config = newGlobalConfig()
  config.verbose = verbose
  config.no_header = no_header
  config.colorize = not no_color
  config.precision = precision
  
  # Parse format
  case format.toLower()
  of "table": config.format = FormatTable
  of "csv": config.format = FormatCSV
  of "json": config.format = FormatJSON
  of "tsv": config.format = FormatTSV
  else:
    raise newException(CliError, "Invalid format: " & format)
  
  # Parse date format
  case date_format.toLower()
  of "iso": config.date_format = DateISO
  of "us": config.date_format = DateUS
  of "unix": config.date_format = DateUnix
  of "full": config.date_format = DateFull
  else:
    raise newException(CliError, "Invalid date format: " & date_format)
  
  # Build options
  var options = newActionsOptions()
  options.symbol = symbol
  options.startDate = start
  options.endDate = `end`
  options.lookback = lookback
  
  # Execute command
  try:
    executeActions(config, options)
  except CliError as e:
    stderr.writeLine("Error: " & e.msg)
    quit(1)
  except CatchableError as e:
    stderr.writeLine("Error: " & e.msg)
    quit(1)

proc indicators_cmd(
  symbol: string,
  interval: string = "1d",
  start: string = "",
  `end`: string = "",
  lookback: string = "1y",
  sma: seq[int] = @[],
  ema: seq[int] = @[],
  wma: seq[int] = @[],
  rsi: int = 0,
  macd = false,
  stochastic = false,
  bb: int = 0,
  atr: int = 0,
  adx: int = 0,
  obv = false,
  vwap = false,
  all = false,
  verbose = false,
  no_color = false,
  precision: int = 2,
  date_format: string = "iso"
) =
  ## Calculate technical indicators for a symbol
  
  # Build config
  var config = newGlobalConfig()
  config.verbose = verbose
  config.colorize = not no_color
  config.precision = precision
  
  # Parse date format
  case date_format.toLower()
  of "iso": config.date_format = DateISO
  of "us": config.date_format = DateUS
  of "unix": config.date_format = DateUnix
  of "full": config.date_format = DateFull
  else:
    raise newException(CliError, "Invalid date format: " & date_format)
  
  # Build options
  var options = newIndicatorsOptions()
  options.symbol = symbol
  options.interval = parseInterval(interval)
  options.startDate = start
  options.endDate = `end`
  options.lookback = lookback
  options.sma = sma
  options.ema = ema
  options.wma = wma
  options.rsi = rsi
  options.macd = macd
  options.stochastic = stochastic
  options.bb = bb
  options.atr = atr
  options.adx = adx
  options.obv = obv
  options.vwap = vwap
  options.all = all
  
  # Execute command
  try:
    executeIndicators(config, options)
  except CliError as e:
    stderr.writeLine("Error: " & e.msg)
    quit(1)
  except CatchableError as e:
    stderr.writeLine("Error: " & e.msg)
    quit(1)

proc screen_cmd(
  symbols: seq[string],
  criteria: string = "value",
  where: string = "",
  format: string = "table",
  verbose = false,
  no_header = false,
  no_color = false,
  precision: int = 2,
  date_format: string = "iso",
  read_stdin = false
) =
  ## Screen multiple stocks based on criteria
  
  # Get symbols - from args or stdin
  var finalSymbols = symbols
  if read_stdin:
    finalSymbols.add(readAndValidateSymbols())
  
  if finalSymbols.len == 0:
    stderr.writeLine("Error: At least one symbol is required")
    quit(1)
  
  # Build config
  var config = newGlobalConfig()
  config.verbose = verbose
  config.no_header = no_header
  config.colorize = not no_color
  config.precision = precision
  
  # Parse format
  case format.toLower()
  of "table": config.format = FormatTable
  of "csv": config.format = FormatCSV
  of "json": config.format = FormatJSON
  of "tsv": config.format = FormatTSV
  of "minimal": config.format = FormatMinimal
  else:
    raise newException(CliError, "Invalid format: " & format)
  
  # Parse date format
  case date_format.toLower()
  of "iso": config.date_format = DateISO
  of "us": config.date_format = DateUS
  of "unix": config.date_format = DateUnix
  of "full": config.date_format = DateFull
  else:
    raise newException(CliError, "Invalid date format: " & date_format)
  
  # Build options
  var options = newScreenOptions()
  options.symbols = symbols
  options.whereClause = where
  
  # Parse criteria
  case criteria.toLower()
  of "value": options.criteria = CriteriaValue
  of "growth": options.criteria = CriteriaGrowth
  of "dividend": options.criteria = CriteriaDividend
  of "momentum": options.criteria = CriteriaMomentum
  of "custom": options.criteria = CriteriaCustom
  else:
    raise newException(CliError, "Invalid criteria: " & criteria)
  
  # Execute command
  try:
    executeScreen(config, options, symbols)
  except CliError as e:
    stderr.writeLine("Error: " & e.msg)
    quit(1)
  except CatchableError as e:
    stderr.writeLine("Error: " & e.msg)
    quit(1)

when isMainModule:
  dispatchMulti(
    [history_cmd, cmdName = "history", 
     help = {
       "symbol": "Stock ticker symbol",
       "interval": "Data interval (1d, 1wk, 1mo)",
       "start": "Start date",
       "end": "End date",
       "lookback": "Lookback period",
       "format": "Output format",
       "verbose": "Show progress messages",
       "no_header": "Omit headers",
       "no_color": "Disable colors",
       "precision": "Decimal places",
       "date_format": "Date display format",
       "read_stdin": "Read symbol from stdin"
     }],
    [quote_cmd, cmdName = "quote",
     help = {
       "symbols": "Stock ticker symbols",
       "metrics": "Metrics to display",
       "format": "Output format",
       "verbose": "Show progress messages",
       "no_header": "Omit headers",
       "no_color": "Disable colors",
       "precision": "Decimal places",
       "date_format": "Date display format",
       "read_stdin": "Read symbols from stdin (cat list.txt | yf2 quote --read_stdin)"
     }],
    [compare_cmd, cmdName = "compare",
     help = {
       "symbols": "Stock symbols to compare",
       "metrics": "Metrics to compare",
       "format": "Output format",
       "verbose": "Show progress messages",
       "no_header": "Omit headers",
       "no_color": "Disable colors",
       "precision": "Decimal places",
       "date_format": "Date display format",
       "read_stdin": "Read symbols from stdin"
     }],
    [download_cmd, cmdName = "download",
     help = {
       "symbols": "Stock symbols to download",
       "interval": "Data interval",
       "start": "Start date",
       "end": "End date",
       "lookback": "Lookback period",
       "format": "Output format",
       "verbose": "Show progress messages",
       "no_header": "Omit headers",
       "no_color": "Disable colors",
       "precision": "Decimal places",
       "date_format": "Date display format",
       "read_stdin": "Read symbols from stdin"
     }],
    [dividends_cmd, cmdName = "dividends",
     help = {
       "symbol": "Stock ticker symbol",
       "start": "Start date",
       "end": "End date",
       "lookback": "Lookback period",
       "format": "Output format",
       "verbose": "Show progress messages",
       "no_header": "Omit headers",
       "no_color": "Disable colors",
       "precision": "Decimal places",
       "date_format": "Date display format"
     }],
    [splits_cmd, cmdName = "splits",
     help = {
       "symbol": "Stock ticker symbol",
       "start": "Start date",
       "end": "End date",
       "lookback": "Lookback period",
       "format": "Output format",
       "verbose": "Show progress messages",
       "no_header": "Omit headers",
       "no_color": "Disable colors",
       "precision": "Decimal places",
       "date_format": "Date display format"
     }],
    [actions_cmd, cmdName = "actions",
     help = {
       "symbol": "Stock ticker symbol",
       "start": "Start date",
       "end": "End date",
       "lookback": "Lookback period",
       "format": "Output format",
       "verbose": "Show progress messages",
       "no_header": "Omit headers",
       "no_color": "Disable colors",
       "precision": "Decimal places",
       "date_format": "Date display format"
     }],
    [indicators_cmd, cmdName = "indicators",
     help = {
       "symbol": "Stock ticker symbol",
       "interval": "Data interval",
       "start": "Start date",
       "end": "End date",
       "lookback": "Lookback period",
       "sma": "SMA periods",
       "ema": "EMA periods",
       "wma": "WMA periods",
       "rsi": "RSI period",
       "macd": "Calculate MACD",
       "stochastic": "Calculate Stochastic",
       "bb": "Bollinger Bands period",
       "atr": "ATR period",
       "adx": "ADX period",
       "obv": "Calculate OBV",
       "vwap": "Calculate VWAP",
       "all": "All indicators",
       "verbose": "Show progress messages",
       "no_color": "Disable colors",
       "precision": "Decimal places",
       "date_format": "Date display format"
     }],
    [screen_cmd, cmdName = "screen",
     help = {
       "symbols": "Stock symbols to screen",
       "criteria": "Screening criteria",
       "where": "Custom filter expression",
       "format": "Output format",
       "verbose": "Show progress messages",
       "no_header": "Omit headers",
       "no_color": "Disable colors",
       "precision": "Decimal places",
       "date_format": "Date display format",
       "read_stdin": "Read symbols from stdin"
     }]
  )
