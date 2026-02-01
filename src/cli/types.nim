## CLI Types Module
##
## Defines types and enums used across the CLI tool

import std/tables
import ../yfnim/types  # For Interval enum

type
  OutputFormat* = enum
    ## Output format for data display
    FormatTable = "table"       ## Human-readable table (default)
    FormatCSV = "csv"           ## Comma-separated values
    FormatJSON = "json"         ## JSON format
    FormatTSV = "tsv"           ## Tab-separated values
    FormatMinimal = "minimal"   ## Minimal output for piping
  
  DateFormat* = enum
    ## Date/time display format
    DateISO = "iso"             ## ISO 8601: YYYY-MM-DD
    DateUS = "us"               ## US format: MM/DD/YYYY
    DateUnix = "unix"           ## Unix timestamp
    DateFull = "full"           ## Full date and time
  
  GlobalConfig* = object
    ## Global configuration shared across all commands
    format*: OutputFormat       ## Output format
    quiet*: bool                ## Suppress progress messages
    noHeader*: bool             ## Omit header row
    colorize*: bool             ## Use colors in output
    precision*: int             ## Decimal places for prices (default: 2)
    dateFormat*: DateFormat     ## Date output format
    debug*: bool                ## Debug mode with verbose output
    refresh*: bool              ## Force refresh, bypass cache
    cacheEnabled*: bool         ## Enable caching
    cacheTtl*: int64            ## Cache TTL in seconds
  
  HistoryOptions* = object
    ## Options specific to history command
    interval*: Interval         ## Time interval
    startDate*: string          ## Start date (YYYY-MM-DD or Unix timestamp)
    endDate*: string            ## End date (YYYY-MM-DD or Unix timestamp)
    lookback*: string           ## Lookback period (e.g., "7d", "1m", "3mo")
    symbols*: seq[string]       ## Stock symbols to query
  
  QuoteOptions* = object
    ## Options specific to quote command
    symbols*: seq[string]       ## Stock symbols to query
    metrics*: seq[string]       ## Specific fields to show
    refresh*: int               ## Auto-refresh interval in seconds (0 = no refresh)
  
  CompareOptions* = object
    ## Options specific to compare command
    symbols*: seq[string]       ## Stock symbols to compare
    metrics*: seq[string]       ## Specific fields to compare
  
  ScreenCriteria* = enum
    ## Predefined screening criteria
    CriteriaValue = "value"         ## Value stocks: low P/E, decent dividend
    CriteriaGrowth = "growth"       ## Growth stocks: strong performance
    CriteriaDividend = "dividend"   ## High dividend yield stocks
    CriteriaMomentum = "momentum"   ## Near 52-week highs
    CriteriaCustom = "custom"       ## Custom criteria from --where
  
  ScreenOptions* = object
    ## Options specific to screen command
    symbols*: seq[string]       ## Stock symbols to screen
    criteria*: ScreenCriteria   ## Screening criteria
    whereClause*: string        ## Custom screening expression
  
  ActionsOptions* = object
    ## Options specific to dividends/splits/actions commands
    symbol*: string             ## Stock symbol to query
    startDate*: string          ## Start date (YYYY-MM-DD or Unix timestamp)
    endDate*: string            ## End date (YYYY-MM-DD or Unix timestamp)
    lookback*: string           ## Lookback period (e.g., "1y", "5y", "max")
  
  IndicatorsOptions* = object
    ## Options specific to indicators command
    symbol*: string             ## Stock symbol to query
    startDate*: string          ## Start date for historical data
    endDate*: string            ## End date for historical data
    lookback*: string           ## Lookback period (default: 1y)
    interval*: Interval         ## Data interval (default: 1d)
    sma*: seq[int]              ## SMA periods (e.g., @[20, 50, 200])
    ema*: seq[int]              ## EMA periods (e.g., @[12, 26])
    wma*: seq[int]              ## WMA periods
    rsi*: int                   ## RSI period (0 = disabled)
    macd*: bool                 ## Calculate MACD
    stochastic*: bool           ## Calculate Stochastic
    bb*: int                    ## Bollinger Bands period (0 = disabled)
    bbStdDev*: float64          ## Bollinger Bands std dev multiplier
    atr*: int                   ## ATR period (0 = disabled)
    adx*: int                   ## ADX period (0 = disabled)
    obv*: bool                  ## Calculate OBV
    vwap*: bool                 ## Calculate VWAP
    all*: bool                  ## Calculate all indicators with defaults
  
  CommandType* = enum
    ## CLI commands
    CmdHistory = "history"
    CmdQuote = "quote"
    CmdCompare = "compare"
    CmdScreen = "screen"
    CmdDividends = "dividends"
    CmdSplits = "splits"
    CmdActions = "actions"
    CmdDownload = "download"
    CmdIndicators = "indicators"
    CmdHelp = "help"
    CmdVersion = "version"
  
  CliError* = object of CatchableError
    ## Exception for CLI-specific errors


# Default values
proc newGlobalConfig*(): GlobalConfig =
  ## Create a GlobalConfig with default values
  GlobalConfig(
    format: FormatTable,
    quiet: false,
    noHeader: false,
    colorize: true,
    precision: 2,
    dateFormat: DateISO,
    debug: false,
    refresh: false,
    cacheEnabled: true,
    cacheTtl: 300  # 5 minutes
  )


proc newHistoryOptions*(): HistoryOptions =
  ## Create a HistoryOptions with default values
  HistoryOptions(
    interval: Int1d,
    startDate: "",
    endDate: "",
    lookback: "7d",
    symbols: @[]
  )


proc newQuoteOptions*(): QuoteOptions =
  ## Create a QuoteOptions with default values
  QuoteOptions(
    symbols: @[],
    metrics: @[],
    refresh: 0
  )


proc newCompareOptions*(): CompareOptions =
  ## Create a CompareOptions with default values
  CompareOptions(
    symbols: @[],
    metrics: @[]
  )


proc newScreenOptions*(): ScreenOptions =
  ## Create a ScreenOptions with default values
  ScreenOptions(
    symbols: @[],
    criteria: CriteriaValue,
    whereClause: ""
  )


proc newActionsOptions*(): ActionsOptions =
  ## Create an ActionsOptions with default values
  ActionsOptions(
    symbol: "",
    startDate: "",
    endDate: "",
    lookback: "max"
  )


proc newIndicatorsOptions*(): IndicatorsOptions =
  ## Create an IndicatorsOptions with default values
  IndicatorsOptions(
    symbol: "",
    startDate: "",
    endDate: "",
    lookback: "1y",
    interval: Int1d,
    sma: @[],
    ema: @[],
    wma: @[],
    rsi: 0,
    macd: false,
    stochastic: false,
    bb: 0,
    bbStdDev: 2.0,
    atr: 0,
    adx: 0,
    obv: false,
    vwap: false,
    all: false
  )
