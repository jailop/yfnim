# Command Reference

This page contains the complete reference for all yf CLI commands.

## Global Options

These options can be used with any command:

- `-f, --format=FORMAT` - Output format: table, csv, json, tsv, minimal (default: table)
- `-v, --verbose` - Show progress and informational messages
- `-n, --no-header` - Omit header row in output
- `--no-color` - Disable colored output
- `-p, --precision=N` - Decimal precision for prices (default: 2)
- `-d, --date-format=FORMAT` - Date format: iso, us, unix, full (default: iso)
- `-h, --help` - Show help for the command

## Commands


### history

```
Usage:
  history [optional-params] 
Options:
  -h, --help                            print this cligen-erated help
  --help-syntax                         advanced: prepend,plurals,..
  -s=, --symbol=       string  ""       Stock ticker symbol
  -i=, --interval=     string  "1d"     Data interval (1d, 1wk, 1mo)
  --start=             string  ""       Start date
  -e=, --end=          string  ""       End date
  -l=, --lookback=     string  "7d"     Lookback period
  -f=, --format=       string  "table"  Output format
  -v, --verbose        bool    false    Show progress messages
  -n, --no_header      bool    false    Omit headers
  --no_color           bool    false    Disable colors
  -p=, --precision=    int     2        Decimal places
  -d=, --date_format=  string  "iso"    Date display format
  -r, --read_stdin     bool    false    Read symbol from stdin
```

### quote

```
Usage:
  quote [optional-params] Stock ticker symbols
Options:
  -h, --help                            print this cligen-erated help
  --help-syntax                         advanced: prepend,plurals,..
  -m=, --metrics=      string  ""       Metrics to display
  -f=, --format=       string  "table"  Output format
  -v, --verbose        bool    false    Show progress messages
  -n, --no_header      bool    false    Omit headers
  --no_color           bool    false    Disable colors
  -p=, --precision=    int     2        Decimal places
  -d=, --date_format=  string  "iso"    Date display format
  -r, --read_stdin     bool    false    Read symbols from stdin (cat list.txt | yf quote --read_stdin)
```

### compare

```
Usage:
  compare [optional-params] Stock symbols to compare
Options:
  -h, --help                            print this cligen-erated help
  --help-syntax                         advanced: prepend,plurals,..
  -m=, --metrics=      string  ""       Metrics to compare
  -f=, --format=       string  "table"  Output format
  -v, --verbose        bool    false    Show progress messages
  -n, --no_header      bool    false    Omit headers
  --no_color           bool    false    Disable colors
  -p=, --precision=    int     2        Decimal places
  -d=, --date_format=  string  "iso"    Date display format
  -r, --read_stdin     bool    false    Read symbols from stdin
```

### download

```
Usage:
  download [optional-params] Stock symbols to download
Options:
  -h, --help                            print this cligen-erated help
  --help-syntax                         advanced: prepend,plurals,..
  -i=, --interval=     string  "1d"     Data interval
  -s=, --start=        string  ""       Start date
  -e=, --end=          string  ""       End date
  -l=, --lookback=     string  "7d"     Lookback period
  -f=, --format=       string  "table"  Output format
  -v, --verbose        bool    false    Show progress messages
  -n, --no_header      bool    false    Omit headers
  --no_color           bool    false    Disable colors
  -p=, --precision=    int     2        Decimal places
  -d=, --date_format=  string  "iso"    Date display format
  -r, --read_stdin     bool    false    Read symbols from stdin
```

### dividends

```
Usage:
  dividends [REQUIRED,optional-params] 
Options:
  -h, --help                             print this cligen-erated help
  --help-syntax                          advanced: prepend,plurals,..
  -s=, --symbol=       string  REQUIRED  Stock ticker symbol
  --start=             string  ""        Start date
  -e=, --end=          string  ""        End date
  -l=, --lookback=     string  "max"     Lookback period
  -f=, --format=       string  "table"   Output format
  -v, --verbose        bool    false     Show progress messages
  -n, --no_header      bool    false     Omit headers
  --no_color           bool    false     Disable colors
  -p=, --precision=    int     2         Decimal places
  -d=, --date_format=  string  "iso"     Date display format
```

### splits

```
Usage:
  splits [REQUIRED,optional-params] 
Options:
  -h, --help                             print this cligen-erated help
  --help-syntax                          advanced: prepend,plurals,..
  -s=, --symbol=       string  REQUIRED  Stock ticker symbol
  --start=             string  ""        Start date
  -e=, --end=          string  ""        End date
  -l=, --lookback=     string  "max"     Lookback period
  -f=, --format=       string  "table"   Output format
  -v, --verbose        bool    false     Show progress messages
  -n, --no_header      bool    false     Omit headers
  --no_color           bool    false     Disable colors
  -p=, --precision=    int     2         Decimal places
  -d=, --date_format=  string  "iso"     Date display format
```

### actions

```
Usage:
  actions [REQUIRED,optional-params] 
Options:
  -h, --help                             print this cligen-erated help
  --help-syntax                          advanced: prepend,plurals,..
  -s=, --symbol=       string  REQUIRED  Stock ticker symbol
  --start=             string  ""        Start date
  -e=, --end=          string  ""        End date
  -l=, --lookback=     string  "max"     Lookback period
  -f=, --format=       string  "table"   Output format
  -v, --verbose        bool    false     Show progress messages
  -n, --no_header      bool    false     Omit headers
  --no_color           bool    false     Disable colors
  -p=, --precision=    int     2         Decimal places
  -d=, --date_format=  string  "iso"     Date display format
```

### indicators

```
Usage:
  indicators [REQUIRED,optional-params] 
Options:
  -h, --help                             print this cligen-erated help
  --help-syntax                          advanced: prepend,plurals,..
  -s=, --symbol=       string  REQUIRED  Stock ticker symbol
  -i=, --interval=     string  "1d"      Data interval
  --start=             string  ""        Start date
  -e=, --end=          string  ""        End date
  -l=, --lookback=     string  "1y"      Lookback period
  --sma=               ints    {}        SMA periods
  --ema=               ints    {}        EMA periods
  -w=, --wma=          ints    {}        WMA periods
  -r=, --rsi=          int     0         RSI period
  -m, --macd           bool    false     Calculate MACD
  --stochastic         bool    false     Calculate Stochastic
  -b=, --bb=           int     0         Bollinger Bands period
  -a=, --atr=          int     0         ATR period
  --adx=               int     0         ADX period
  -o, --obv            bool    false     Calculate OBV
  -v, --vwap           bool    false     Calculate VWAP
  --all                bool    false     All indicators
  --verbose            bool    false     Show progress messages
  -n, --no_color       bool    false     Disable colors
  -p=, --precision=    int     2         Decimal places
  -d=, --date_format=  string  "iso"     Date display format
```

### screen

```
Usage:
  screen [optional-params] Stock symbols to screen
Options:
  -h, --help                            print this cligen-erated help
  --help-syntax                         advanced: prepend,plurals,..
  -c=, --criteria=     string  "value"  Screening criteria
  -w=, --where=        string  ""       Custom filter expression
  -f=, --format=       string  "table"  Output format
  -v, --verbose        bool    false    Show progress messages
  -n, --no_header      bool    false    Omit headers
  --no_color           bool    false    Disable colors
  -p=, --precision=    int     2        Decimal places
  -d=, --date_format=  string  "iso"    Date display format
  -r, --read_stdin     bool    false    Read symbols from stdin
```
