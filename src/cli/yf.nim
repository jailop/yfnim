## Main CLI entry point for yfnim
## 
## This module provides the main program entry point, help system,
## and command routing for the yf command-line tool.

import std/[os, strutils]
import types, config, utils
import commands/[history, quote, compare, screen]

const
  Version = "0.1.0"
  ProgramName = "yf"

proc printVersion() =
  ## Print version information
  echo ProgramName & " version " & Version
  echo "Yahoo Finance data retriever for Nim"
  echo "https://github.com/yourusername/yfnim"

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
    help        Show this help message
    version     Show version information

GLOBAL OPTIONS:
    -f, --format <format>       Output format (table, csv, json, tsv, minimal) [default: table]
    -q, --quiet                 Suppress informational messages
    --no-header                 Omit header row in output
    --no-color                  Disable colored output
    -p, --precision <n>         Decimal precision for prices [default: 2]
    --date-format <format>      Date format (iso, us, unix, full) [default: iso]
    --debug                     Enable debug output

EXAMPLES:
    # Get 30 days of historical data
    yf history AAPL --lookback 30d

    # Get quotes for multiple symbols
    yf quote AAPL MSFT GOOGL

    # Compare stocks in CSV format
    yf compare AAPL MSFT --format csv

    # Screen stocks for value criteria
    yf screen AAPL MSFT GOOGL --criteria value

    # Export data to file
    yf history AAPL --lookback 1y --format csv > aapl_history.csv

    # Use in a pipeline
    yf quote AAPL --format minimal | awk '{print $5}'

For detailed help on a specific command, use:
    yf <command> --help
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
  
  except CliError as e:
    printError(e.msg, config)
    echo ""
    echo "Run 'yf help' for usage information."
    quit(1)
  
  except Exception as e:
    printError("Unexpected error: " & e.msg, config)
    if config.debug:
      echo ""
      echo "Stack trace:"
      echo getStackTrace(e)
    quit(2)

# Run main program
when isMainModule:
  main()
