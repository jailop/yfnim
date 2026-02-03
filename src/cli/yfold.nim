import std/[os]
import types, config, utils
import commands/[history, quote, compare, screen, actions, download, indicators]

const
  Version = "0.2.0"
  ProgramName = "yf"

proc printVersion() =
  ## Print version information
  echo ProgramName & " version " & Version

proc printMainHelp() =
  ## Print main help message with all commands and global options
  echo """
yf - Yahoo Finance CLI Tool

USAGE:
    yf [OPTIONS] <COMMAND> [ARGS]

COMMANDS:
    history     Retrieve historical OHLCV data for a symbol
    quote       Get current quote data for one or more symbols
    compare     Compare multiple stocks side-by-side
    screen      Screen multiple stocks based on criteria
    dividends   Retrieve dividend history for a symbol
    splits      Retrieve stock split history for a symbol
    actions     Retrieve all corporate actions (dividends + splits)
    download    Batch download historical data for multiple symbols
    indicators  Calculate technical indicators for a symbol
    help        Show this help message
    version     Show version information

GLOBAL OPTIONS:
    -f, --format <format>       Output format (table, csv, json, tsv, minimal) [default: table]
    -v, --verbose               Show progress and informational messages
    --no-header                 Omit header row in output
    --no-color                  Disable colored output
    -p, --precision <n>         Decimal precision for prices [default: 2]
    --date-format <format>      Date format (iso, us, unix, full) [default: iso]
"""

proc printHistoryHelp() =
  ## Print help for the history command
  echo """
yf history - Retrieve historical OHLCV data

USAGE:
    yf [GLOBAL_OPTIONS] history <SYMBOL> [OPTIONS]

ARGUMENTS:
    <SYMBOL>    Stock symbol to retrieve (e.g., AAPL, MSFT)

OPTIONS:
    --interval <interval>       Data interval (1d, 1wk, 1mo) [default: 1d]
    --start <date>              Start date (YYYY-MM-DD or unix timestamp)
    --end <date>                End date (YYYY-MM-DD, unix timestamp, or 'today')
    --lookback <period>         Lookback period (e.g., 30d, 3mo, 1y)
    -h, --help                  Show this help message

DATE FORMATS:
    YYYY-MM-DD      Standard ISO format (e.g., 2024-01-15)
    unix            Unix timestamp (e.g., 1705276800)
    today           Current date
    yesterday       Previous day

PERIOD FORMATS:
    <n>d            Days (e.g., 7d, 30d)
    <n>w            Weeks (e.g., 2w)
    <n>mo           Months (e.g., 3mo, 6mo)
    <n>y            Years (e.g., 1y, 5y)

EXAMPLES:
    # Last 30 days of data
    yf history AAPL --lookback 30d

    # Specific date range
    yf history AAPL --start 2024-01-01 --end 2024-12-31

    # Weekly data for 1 year
    yf history AAPL --lookback 1y --interval 1wk

    # Export to CSV
    yf history AAPL --lookback 90d --format csv > data.csv
"""

proc printQuoteHelp() =
  ## Print help for the quote command
  echo """
yf quote - Get current quote data

USAGE:
    yf [GLOBAL_OPTIONS] quote <SYMBOL> [<SYMBOL>...] [OPTIONS]

ARGUMENTS:
    <SYMBOL>...     One or more stock symbols (e.g., AAPL MSFT GOOGL)

OPTIONS:
    --metrics <list>    Comma-separated metrics to display
                        [default: symbol,price,change,changepct,volume]
    --refresh           Include real-time refresh data
    -h, --help          Show this help message

AVAILABLE METRICS:
    Basic: symbol, name, price, open, high, low, close
    Change: change, changepct, prevclose
    Volume: volume, avgvolume
    Market: marketcap, shares
    Valuation: pe, eps, forwardpe
    Dividends: dividend, yield
    52-Week: week52high, week52low
    Time: markettime, quotetime

EXAMPLES:
    # Basic quote
    yf quote AAPL

    # Multiple symbols
    yf quote AAPL MSFT GOOGL

    # Custom metrics
    yf quote AAPL --metrics symbol,price,pe,marketcap

    # JSON output for scripting
    yf quote AAPL --format json

    # Get just the price (for piping)
    yf quote AAPL --format minimal | awk '{print $2}'
"""

proc printCompareHelp() =
  ## Print help for the compare command
  echo """
yf compare - Compare multiple stocks side-by-side

USAGE:
    yf [GLOBAL_OPTIONS] compare <SYMBOL> <SYMBOL> [<SYMBOL>...] [OPTIONS]

ARGUMENTS:
    <SYMBOL>...     Two or more stock symbols to compare

OPTIONS:
    --metrics <list>    Comma-separated metrics to compare
                        [default: price,change,changepct,volume,marketcap,pe]
    -h, --help          Show this help message

EXAMPLES:
    # Compare tech stocks
    yf compare AAPL MSFT GOOGL

    # Compare with custom metrics
    yf compare AAPL MSFT --metrics price,pe,eps,yield

    # Export comparison to CSV
    yf compare AAPL MSFT GOOGL --format csv > comparison.csv
"""

proc printScreenHelp() =
  ## Print help for the screen command
  echo """
yf screen - Screen stocks based on criteria

USAGE:
    yf [GLOBAL_OPTIONS] screen <SYMBOL>... [OPTIONS]

ARGUMENTS:
    <SYMBOL>...     Stock symbols to screen

OPTIONS:
    --criteria <type>   Screening criteria preset (value, growth, dividend, momentum, custom)
    --where <expr>      Custom filter expression (for custom criteria)
    -h, --help          Show this help message

CRITERIA PRESETS:
    value       Value stocks (low P/E, high dividend yield)
    growth      Growth stocks (high revenue growth, strong momentum)
    dividend    Dividend stocks (high yield, consistent payouts)
    momentum    Momentum stocks (strong price momentum, volume)
    custom      Use --where for custom filtering

EXAMPLES:
    # Screen for value stocks
    yf screen AAPL MSFT GOOGL KO PEP --criteria value

    # Screen for dividend stocks
    cat symbols.txt | xargs yf screen --criteria dividend

    # Custom filter (Phase 4 feature)
    yf screen AAPL MSFT --criteria custom --where "pe < 20 and yield > 2"
"""

proc printDividendsHelp() =
  ## Print help for the dividends command
  echo """
yf dividends - Retrieve dividend history

USAGE:
    yf [GLOBAL_OPTIONS] dividends <SYMBOL> [OPTIONS]

ARGUMENTS:
    <SYMBOL>    Stock symbol to retrieve (e.g., AAPL, MSFT)

OPTIONS:
    --start <date>              Start date (YYYY-MM-DD or unix timestamp)
    --end <date>                End date (YYYY-MM-DD, unix timestamp, or 'today')
    --lookback <period>         Lookback period (e.g., 1y, 5y, max) [default: max]
    -h, --help                  Show this help message

EXAMPLES:
    # Get all dividend history
    yf dividends AAPL

    # Get dividends for last 5 years
    yf dividends AAPL --lookback 5y

    # Export to CSV
    yf dividends MSFT --format csv > msft_dividends.csv

    # Get dividends for specific date range
    yf dividends JNJ --start 2020-01-01 --end 2023-12-31
"""

proc printSplitsHelp() =
  ## Print help for the splits command
  echo """
yf splits - Retrieve stock split history

USAGE:
    yf [GLOBAL_OPTIONS] splits <SYMBOL> [OPTIONS]

ARGUMENTS:
    <SYMBOL>    Stock symbol to retrieve (e.g., AAPL, TSLA)

OPTIONS:
    --start <date>              Start date (YYYY-MM-DD or unix timestamp)
    --end <date>                End date (YYYY-MM-DD, unix timestamp, or 'today')
    --lookback <period>         Lookback period (e.g., 1y, 5y, max) [default: max]
    -h, --help                  Show this help message

EXAMPLES:
    # Get all split history
    yf splits AAPL

    # Get splits for last 10 years
    yf splits TSLA --lookback 10y

    # Export to JSON
    yf splits NVDA --format json > nvda_splits.json
"""

proc printActionsHelp() =
  ## Print help for the actions command
  echo """
yf actions - Retrieve all corporate actions (dividends + splits)

USAGE:
    yf [GLOBAL_OPTIONS] actions <SYMBOL> [OPTIONS]

ARGUMENTS:
    <SYMBOL>    Stock symbol to retrieve (e.g., AAPL, MSFT)

OPTIONS:
    --start <date>              Start date (YYYY-MM-DD or unix timestamp)
    --end <date>                End date (YYYY-MM-DD, unix timestamp, or 'today')
    --lookback <period>         Lookback period (e.g., 1y, 5y, max) [default: max]
    -h, --help                  Show this help message

EXAMPLES:
    # Get all corporate actions
    yf actions AAPL

    # Get actions for last 5 years
    yf actions MSFT --lookback 5y

    # Export to CSV
    yf actions GOOGL --format csv > googl_actions.csv
"""

proc printDownloadHelp() =
  ## Print help for the download command
  echo """
yf download - Batch download historical data for multiple symbols

USAGE:
    yf [GLOBAL_OPTIONS] download <SYMBOL>... [OPTIONS]

ARGUMENTS:
    <SYMBOL>...     Stock symbols to download (space or comma-separated)

OPTIONS:
    --interval <interval>       Data interval (1d, 1wk, 1mo) [default: 1d]
    --start <date>              Start date (YYYY-MM-DD or unix timestamp)
    --end <date>                End date (YYYY-MM-DD, unix timestamp, or 'today')
    --lookback <period>         Lookback period (e.g., 30d, 3mo, 1y)
    -h, --help                  Show this help message

EXAMPLES:
    # Download 30 days for multiple symbols
    yf download AAPL MSFT GOOGL --lookback 30d

    # Download with comma-separated symbols
    yf download AAPL,MSFT,GOOGL --lookback 1y

    # Export to CSV
    yf download AAPL MSFT --lookback 90d --format csv > data.csv

    # Download from file list
    cat symbols.txt | xargs yf download --lookback 1y
"""

proc printIndicatorsHelp() =
  ## Print help for the indicators command
  echo """
yf indicators - Calculate technical indicators

USAGE:
    yf [GLOBAL_OPTIONS] indicators <SYMBOL> [OPTIONS]

ARGUMENTS:
    <SYMBOL>    Stock symbol to analyze (e.g., AAPL, MSFT)

OPTIONS:
    --lookback <period>         Lookback period (e.g., 1y, 6mo) [default: 1y]
    --interval <interval>       Data interval (1d, 1wk, 1mo) [default: 1d]
    --start <date>              Start date (YYYY-MM-DD or unix timestamp)
    --end <date>                End date (YYYY-MM-DD, unix timestamp, or 'today')
    
    # Moving Averages
    --sma <periods>             Simple Moving Averages (e.g., 20,50,200)
    --ema <periods>             Exponential Moving Averages (e.g., 12,26)
    --wma <periods>             Weighted Moving Averages
    
    # Momentum Indicators
    --rsi [period]              Relative Strength Index [default: 14]
    --macd                      MACD indicator
    --stochastic                Stochastic Oscillator
    
    # Volatility Indicators
    --bb [period]               Bollinger Bands [default: 20]
    --atr [period]              Average True Range [default: 14]
    
    # Trend Indicators
    --adx [period]              Average Directional Index [default: 14]
    
    # Volume Indicators
    --obv                       On-Balance Volume
    --vwap                      Volume Weighted Average Price
    
    --all                       Calculate all indicators with defaults
    -h, --help                  Show this help message

EXAMPLES:
    # Calculate common moving averages
    yf indicators AAPL --sma 20,50,200

    # RSI and MACD for momentum analysis
    yf indicators AAPL --rsi --macd

    # Volatility analysis
    yf indicators AAPL --bb --atr

    # All indicators
    yf indicators AAPL --all

    # Custom lookback period
    yf indicators AAPL --all --lookback 6mo
"""

proc printCommandHelp(cmd: CommandType) =
  ## Print help for a specific command
  case cmd
  of CmdHistory:
    printHistoryHelp()
  of CmdQuote:
    printQuoteHelp()
  of CmdCompare:
    printCompareHelp()
  of CmdScreen:
    printScreenHelp()
  of CmdDividends:
    printDividendsHelp()
  of CmdSplits:
    printSplitsHelp()
  of CmdActions:
    printActionsHelp()
  of CmdDownload:
    printDownloadHelp()
  of CmdIndicators:
    printIndicatorsHelp()
  of CmdHelp:
    printMainHelp()
  of CmdVersion:
    printVersion()

proc main*() =
  ## Main program entry point
  var config = newGlobalConfig()
  
  # Handle no arguments
  if paramCount() == 0:
    printMainHelp()
    quit(0)
  
  try:
    # Parse command
    let cmd = parseCommand()
    
    # Handle help and version commands immediately
    case cmd
    of CmdHelp:
      printMainHelp()
      quit(0)
    
    of CmdVersion:
      printVersion()
      quit(0)
    
    of CmdHistory:
      # Check for command-specific help
      for i in 1..paramCount():
        let arg = paramStr(i)
        if arg == "-h" or arg == "--help":
          printHistoryHelp()
          quit(0)
      runHistory()
    
    of CmdQuote:
      # Check for command-specific help
      for i in 1..paramCount():
        let arg = paramStr(i)
        if arg == "-h" or arg == "--help":
          printQuoteHelp()
          quit(0)
      runQuote()
    
    of CmdCompare:
      # Check for command-specific help
      for i in 1..paramCount():
        let arg = paramStr(i)
        if arg == "-h" or arg == "--help":
          printCompareHelp()
          quit(0)
      runCompare()
    
    of CmdScreen:
      # Check for command-specific help
      for i in 1..paramCount():
        let arg = paramStr(i)
        if arg == "-h" or arg == "--help":
          printScreenHelp()
          quit(0)
      runScreen()
    
    of CmdDividends:
      # Check for command-specific help
      for i in 1..paramCount():
        let arg = paramStr(i)
        if arg == "-h" or arg == "--help":
          printDividendsHelp()
          quit(0)
      runDividends()
    
    of CmdSplits:
      # Check for command-specific help
      for i in 1..paramCount():
        let arg = paramStr(i)
        if arg == "-h" or arg == "--help":
          printSplitsHelp()
          quit(0)
      runSplits()
    
    of CmdActions:
      # Check for command-specific help
      for i in 1..paramCount():
        let arg = paramStr(i)
        if arg == "-h" or arg == "--help":
          printActionsHelp()
          quit(0)
      runActions()
    
    of CmdDownload:
      # Check for command-specific help
      for i in 1..paramCount():
        let arg = paramStr(i)
        if arg == "-h" or arg == "--help":
          printDownloadHelp()
          quit(0)
      runDownload()
    
    of CmdIndicators:
      # Check for command-specific help
      for i in 1..paramCount():
        let arg = paramStr(i)
        if arg == "-h" or arg == "--help":
          printIndicatorsHelp()
          quit(0)
      runIndicators()
  
  except CliError as e:
    printError(e.msg, config)
    stderr.writeLine("")
    stderr.writeLine("Run 'yf help' for usage information.")
    quit(1)
  
  except Exception as e:
    printError("Unexpected error: " & e.msg, config)
    if config.verbose:
      stderr.writeLine("")
      stderr.writeLine("Stack trace:")
      stderr.writeLine(getStackTrace(e))
    quit(2)

# Run main program
when isMainModule:
  main()
