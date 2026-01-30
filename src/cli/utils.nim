## CLI Utility Functions
##
## Common utility functions used across CLI commands

import std/[times, strutils, strformat, terminal]
import types
import ../yfnim/types as yfnimTypes

# ANSI color codes
const
  ColorReset* = "\e[0m"
  ColorRed* = "\e[31m"
  ColorGreen* = "\e[32m"
  ColorYellow* = "\e[33m"
  ColorBlue* = "\e[34m"
  ColorMagenta* = "\e[35m"
  ColorCyan* = "\e[36m"
  ColorGray* = "\e[90m"
  ColorBold* = "\e[1m"


proc colorize*(text: string, color: string, config: GlobalConfig): string =
  ## Add color to text if colorization is enabled
  if config.colorize and stdout.isatty:
    return color & text & ColorReset
  else:
    return text


proc errorMsg*(msg: string, config: GlobalConfig): string =
  ## Format error message
  colorize("Error: " & msg, ColorRed, config)


proc warningMsg*(msg: string, config: GlobalConfig): string =
  ## Format warning message
  colorize("Warning: " & msg, ColorYellow, config)


proc successMsg*(msg: string, config: GlobalConfig): string =
  ## Format success message
  colorize(msg, ColorGreen, config)


proc infoMsg*(msg: string, config: GlobalConfig): string =
  ## Format info message
  colorize(msg, ColorCyan, config)


proc debugMsg*(msg: string, config: GlobalConfig) =
  ## Print debug message if debug mode is enabled
  if config.debug:
    stderr.writeLine(colorize("[DEBUG] " & msg, ColorGray, config))


proc formatPrice*(price: float64, precision: int = 2): string =
  ## Format price with $ sign and proper decimal places
  "$" & formatFloat(price, ffDecimal, precision)


proc formatChange*(change: float64, precision: int = 2): string =
  ## Format price change with sign
  let sign = if change >= 0: "+" else: ""
  sign & formatFloat(change, ffDecimal, precision)


proc formatPercent*(pct: float64, precision: int = 2): string =
  ## Format percentage with sign and % symbol
  let sign = if pct >= 0: "+" else: ""
  sign & formatFloat(pct, ffDecimal, precision) & "%"


proc formatVolume*(volume: int64): string =
  ## Format volume with thousands separators
  if volume == 0:
    return "0"
  
  let volStr = $volume
  var output = ""
  var count = 0
  
  for i in countdown(volStr.len - 1, 0):
    if count > 0 and count mod 3 == 0:
      output = "," & output
    output = volStr[i] & output
    inc count
  
  return output


proc formatLargeNumber*(num: int64): string =
  ## Format large numbers in compact form (K, M, B, T)
  if num == 0:
    return "0"
  
  let absNum = abs(num).float64
  let sign = if num < 0: "-" else: ""
  
  if absNum >= 1_000_000_000_000.0:  # Trillions
    return &"{sign}{absNum / 1_000_000_000_000.0:.2f}T"
  elif absNum >= 1_000_000_000.0:  # Billions
    return &"{sign}{absNum / 1_000_000_000.0:.2f}B"
  elif absNum >= 1_000_000.0:  # Millions
    return &"{sign}{absNum / 1_000_000.0:.2f}M"
  elif absNum >= 1_000.0:  # Thousands
    return &"{sign}{absNum / 1_000.0:.2f}K"
  else:
    return $num


proc formatDate*(timestamp: int64, format: DateFormat): string =
  ## Format Unix timestamp according to specified format
  if timestamp == 0:
    return ""
  
  let dt = fromUnix(timestamp)
  
  case format
  of DateISO:
    return dt.format("yyyy-MM-dd")
  of DateUS:
    return dt.format("MM/dd/yyyy")
  of DateUnix:
    return $timestamp
  of DateFull:
    return dt.format("yyyy-MM-dd HH:mm:ss")


proc formatDateTime*(timestamp: int64, format: DateFormat): string =
  ## Format Unix timestamp with time component
  if timestamp == 0:
    return ""
  
  let dt = fromUnix(timestamp)
  
  case format
  of DateISO, DateUS:
    return dt.format("yyyy-MM-dd HH:mm:ss")
  of DateUnix:
    return $timestamp
  of DateFull:
    return dt.format("yyyy-MM-dd HH:mm:ss ZZZ")


proc parseInterval*(s: string): yfnimTypes.Interval =
  ## Parse interval string to Interval enum
  ##
  ## This is a wrapper around the library's parseInterval function
  ## with additional CLI-friendly error handling
  try:
    return yfnimTypes.parseInterval(s)
  except ValueError as e:
    raise newException(CliError, "Invalid interval: " & s & 
                       ". Valid options: 1m, 5m, 15m, 30m, 1h, 1d, 1wk, 1mo")


proc parseDateString*(dateStr: string): int64 =
  ## Parse date string to Unix timestamp
  ##
  ## Supports formats:
  ##   - YYYY-MM-DD
  ##   - Unix timestamp (numeric)
  ##   - Relative dates: "today", "yesterday"
  
  # Try parsing as Unix timestamp first
  try:
    let ts = parseBiggestInt(dateStr)
    if ts > 0:
      return ts
  except ValueError:
    discard
  
  # Handle relative dates
  case dateStr.toLower()
  of "today":
    return getTime().toUnix()
  of "yesterday":
    return getTime().toUnix() - 86400
  else:
    # Try parsing as date string
    try:
      let dt = parse(dateStr, "yyyy-MM-dd")
      return dt.toTime().toUnix()
    except TimeParseError:
      raise newException(CliError, "Invalid date format: " & dateStr & 
                         ". Use YYYY-MM-DD or Unix timestamp")


proc parseLookback*(lookback: string): tuple[startTime: int64, endTime: int64] =
  ## Parse lookback period string (e.g., "7d", "1m", "3mo", "1y")
  ## Returns (startTime, endTime) tuple
  
  let now = getTime().toUnix()
  var seconds: int64 = 0
  
  # Parse format: <number><unit>
  if lookback.len < 2:
    raise newException(CliError, "Invalid lookback format: " & lookback)
  
  let numPart = lookback[0 .. ^2]
  let unitPart = lookback[^1 .. ^1].toLower()
  
  var num: int
  try:
    num = parseInt(numPart)
  except ValueError:
    raise newException(CliError, "Invalid lookback number: " & numPart)
  
  case unitPart
  of "d":  # days
    seconds = num.int64 * 86400
  of "w":  # weeks
    seconds = num.int64 * 7 * 86400
  of "m":  # months (approximate as 30 days)
    seconds = num.int64 * 30 * 86400
  of "y":  # years (approximate as 365 days)
    seconds = num.int64 * 365 * 86400
  else:
    raise newException(CliError, "Invalid lookback unit: " & unitPart & 
                       ". Use d (days), w (weeks), m (months), or y (years)")
  
  return (startTime: now - seconds, endTime: now)


proc alignLeft*(s: string, width: int): string =
  ## Left-align string to specified width
  result = s
  while result.len < width:
    result.add(' ')


proc alignRight*(s: string, width: int): string =
  ## Right-align string to specified width
  result = spaces(max(0, width - s.len)) & s


proc truncate*(s: string, maxLen: int): string =
  ## Truncate string to maximum length, adding "..." if needed
  if s.len <= maxLen:
    return s
  elif maxLen <= 3:
    return s[0 ..< maxLen]
  else:
    return s[0 ..< maxLen - 3] & "..."


proc printError*(msg: string, config: GlobalConfig) =
  ## Print error message to stderr
  stderr.writeLine(errorMsg(msg, config))


proc printWarning*(msg: string, config: GlobalConfig) =
  ## Print warning message to stderr
  if not config.quiet:
    stderr.writeLine(warningMsg(msg, config))


proc printInfo*(msg: string, config: GlobalConfig) =
  ## Print info message to stderr
  if not config.quiet:
    stderr.writeLine(infoMsg(msg, config))


proc printSuccess*(msg: string, config: GlobalConfig) =
  ## Print success message to stderr
  if not config.quiet:
    stderr.writeLine(successMsg(msg, config))
