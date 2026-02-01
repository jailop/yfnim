## Configuration and Argument Parsing Module
##
## Handles command-line argument parsing and configuration using std/parseopt

import std/[os, strutils, parseopt, editdistance]
import types, utils


proc levenshteinDistance(s1, s2: string): int =
  ## Calculate Levenshtein distance between two strings
  let len1 = s1.len
  let len2 = s2.len
  
  if len1 == 0: return len2
  if len2 == 0: return len1
  
  var costs = newSeq[int](len2 + 1)
  for j in 0..len2:
    costs[j] = j
  
  for i in 1..len1:
    var lastCost = costs[0]
    costs[0] = i
    
    for j in 1..len2:
      let newCost = costs[j]
      if s1[i-1] == s2[j-1]:
        costs[j] = lastCost
      else:
        costs[j] = 1 + min(min(lastCost, costs[j]), costs[j-1])
      lastCost = newCost
  
  return costs[len2]


proc findSimilarCommand(cmd: string): string =
  ## Find the most similar valid command to suggest
  const validCommands = [
    ("history", @["hist", "h"]),
    ("quote", @["q"]),
    ("compare", @["comp", "c"]),
    ("screen", @["scr", "s"]),
    ("dividends", @["div", "d"]),
    ("splits", @["split"]),
    ("actions", @["act", "a"]),
    ("download", @["dl"]),
    ("indicators", @["ind", "i"]),
    ("help", @["--help", "-h"]),
    ("version", @["--version", "-v"])
  ]
  
  var bestMatch = ""
  var bestDistance = 999
  
  # Check all commands and their aliases
  for (mainCmd, aliases) in validCommands:
    # Check main command
    let dist = levenshteinDistance(cmd, mainCmd)
    if dist < bestDistance and dist <= 3:  # Max 3 edits away
      bestDistance = dist
      bestMatch = mainCmd
    
    # Check aliases
    for alias in aliases:
      let aliasDist = levenshteinDistance(cmd, alias)
      if aliasDist < bestDistance and aliasDist <= 2:
        bestDistance = aliasDist
        bestMatch = mainCmd
  
  return bestMatch


proc parseCommand*(): CommandType =
  ## Parse and return the command type from arguments
  ##
  ## Returns CmdHelp if no command or --help flag is present
  
  if paramCount() == 0:
    return CmdHelp
  
  let cmd = paramStr(1).toLower()
  
  # Check for help/version flags
  if cmd in ["--help", "-h", "help"]:
    return CmdHelp
  if cmd in ["--version", "-v", "version"]:
    return CmdVersion
  
  # Parse command
  case cmd
  of "history", "hist", "h":
    return CmdHistory
  of "quote", "q":
    return CmdQuote
  of "compare", "comp", "c":
    return CmdCompare
  of "screen", "scr", "s":
    return CmdScreen
  of "dividends", "div", "d":
    return CmdDividends
  of "splits", "split":
    return CmdSplits
  of "actions", "act", "a":
    return CmdActions
  of "download", "dl":
    return CmdDownload
  of "indicators", "ind", "i":
    return CmdIndicators
  else:
    # Try to find a similar command
    let suggestion = findSimilarCommand(cmd)
    if suggestion.len > 0:
      raise newException(CliError, "Unknown command: '" & cmd & "'. Did you mean '" & suggestion & "'?")
    else:
      raise newException(CliError, "Unknown command: '" & cmd & "'. Run 'yf help' for available commands.")


proc parseGlobalOptions*(config: var GlobalConfig, p: var OptParser) =
  ## Parse global options that can appear anywhere
  ## Modifies config in place
  
  while true:
    case p.kind
    of cmdLongOption, cmdShortOption:
      case p.key.toLower()
      of "format", "f":
        if p.val.len == 0:
          raise newException(CliError, "--format requires a value")
        case p.val.toLower()
        of "table": config.format = FormatTable
        of "csv": config.format = FormatCSV
        of "json": config.format = FormatJSON
        of "tsv": config.format = FormatTSV
        of "minimal": config.format = FormatMinimal
        else:
          raise newException(CliError, "Unknown format: " & p.val)
        next(p)
        return
      
      of "quiet", "q":
        config.quiet = true
        next(p)
        return
      
      of "no-header":
        config.noHeader = true
        next(p)
        return
      
      of "no-color", "no-colour":
        config.colorize = false
        next(p)
        return
      
      of "precision", "p":
        if p.val.len == 0:
          raise newException(CliError, "--precision requires a value")
        try:
          config.precision = parseInt(p.val)
        except ValueError:
          raise newException(CliError, "Invalid precision value: " & p.val)
        next(p)
        return
      
      of "date-format":
        if p.val.len == 0:
          raise newException(CliError, "--date-format requires a value")
        case p.val.toLower()
        of "iso": config.dateFormat = DateISO
        of "us": config.dateFormat = DateUS
        of "unix": config.dateFormat = DateUnix
        of "full": config.dateFormat = DateFull
        else:
          raise newException(CliError, "Unknown date format: " & p.val)
        next(p)
        return
      
      of "debug":
        config.debug = true
        next(p)
        return
      
      of "refresh":
        config.refresh = true
        next(p)
        return
      
      else:
        # Not a global option, return
        return
    
    else:
      return


proc parseHistoryArgs*(): tuple[config: GlobalConfig, options: HistoryOptions] =
  ## Parse arguments for history command
  var config = newGlobalConfig()
  var options = newHistoryOptions()
  
  # Start parsing from index 2 (after "yf history")
  var p = initOptParser(commandLineParams(), shortNoVal = {'q'}, longNoVal = @["quiet", "no-header", "no-color", "debug", "help", "refresh"])
  next(p)  # Initialize parser to first item
  
  # Skip to the command
  while p.kind != cmdEnd:
    if p.kind == cmdArgument and p.key.toLower() in ["history", "hist", "h"]:
      next(p)
      break
    next(p)
  
  # Parse options
  while p.kind != cmdEnd:
    case p.kind
    of cmdLongOption, cmdShortOption:
      case p.key.toLower()
      # Global options
      of "format", "f", "quiet", "q", "no-header", "no-color", "no-colour", "precision", "p", "date-format", "debug", "refresh":
        parseGlobalOptions(config, p)
        continue
      
      # Command-specific options
      of "interval", "i":
        if p.val.len == 0:
          raise newException(CliError, "--interval requires a value")
        options.interval = parseInterval(p.val)
      
      of "start", "s":
        if p.val.len == 0:
          raise newException(CliError, "--start requires a value")
        options.startDate = p.val
      
      of "end", "e":
        if p.val.len == 0:
          raise newException(CliError, "--end requires a value")
        options.endDate = p.val
      
      of "lookback", "l":
        if p.val.len == 0:
          raise newException(CliError, "--lookback requires a value")
        options.lookback = p.val
      
      of "help", "h":
        return (config, options)
      
      else:
        raise newException(CliError, "Unknown option: --" & p.key)
    
    of cmdArgument:
      # Positional argument - symbol (only one allowed for history command)
      if options.symbols.len == 0:
        options.symbols.add(p.key.toUpperAscii())
      else:
        raise newException(CliError, "Only one symbol allowed for history command")
    
    of cmdEnd:
      break
    
    next(p)
  
  return (config, options)


proc parseQuoteArgs*(): tuple[config: GlobalConfig, options: QuoteOptions] =
  ## Parse arguments for quote command
  var config = newGlobalConfig()
  var options = newQuoteOptions()
  
  var p = initOptParser(commandLineParams(), shortNoVal = {'q'}, longNoVal = @["quiet", "no-header", "no-color", "debug", "help", "refresh"])
  next(p)  # Initialize parser to first item
  
  # Skip to the command
  while p.kind != cmdEnd:
    if p.kind == cmdArgument and p.key.toLower() in ["quote", "q"]:
      next(p)
      break
    next(p)
  
  # Parse options
  while p.kind != cmdEnd:
    case p.kind
    of cmdLongOption, cmdShortOption:
      case p.key.toLower()
      # Global options
      of "format", "f", "quiet", "q", "no-header", "no-color", "no-colour", "precision", "p", "date-format", "debug", "refresh":
        parseGlobalOptions(config, p)
        continue
      
      # Command-specific options
      of "metrics", "m":
        if p.val.len == 0:
          raise newException(CliError, "--metrics requires a value")
        options.metrics = p.val.split(',')
      
      of "help", "h":
        return (config, options)
      
      else:
        raise newException(CliError, "Unknown option: --" & p.key)
    
    of cmdArgument:
      # Positional argument - symbol
      options.symbols.add(p.key.toUpperAscii())
    
    of cmdEnd:
      break
    
    next(p)
  
  return (config, options)


proc parseCompareArgs*(): tuple[config: GlobalConfig, options: CompareOptions] =
  ## Parse arguments for compare command
  var config = newGlobalConfig()
  var options = newCompareOptions()
  
  var p = initOptParser(commandLineParams(), shortNoVal = {'q'}, longNoVal = @["quiet", "no-header", "no-color", "debug", "help", "refresh"])
  next(p)  # Initialize parser to first item
  
  # Skip to the command
  while p.kind != cmdEnd:
    if p.kind == cmdArgument and p.key.toLower() in ["compare", "comp", "c"]:
      next(p)
      break
    next(p)
  
  # Parse options
  while p.kind != cmdEnd:
    case p.kind
    of cmdLongOption, cmdShortOption:
      case p.key.toLower()
      # Global options
      of "format", "f", "quiet", "q", "no-header", "no-color", "no-colour", "precision", "p", "date-format", "debug", "refresh":
        parseGlobalOptions(config, p)
        continue
      
      # Command-specific options
      of "metrics", "m":
        if p.val.len == 0:
          raise newException(CliError, "--metrics requires a value")
        options.metrics = p.val.split(',')
      
      of "help", "h":
        return (config, options)
      
      else:
        raise newException(CliError, "Unknown option: --" & p.key)
    
    of cmdArgument:
      # Positional argument - symbol
      options.symbols.add(p.key.toUpperAscii())
    
    of cmdEnd:
      break
    
    next(p)
  
  return (config, options)


proc parseScreenArgs*(): tuple[config: GlobalConfig, options: ScreenOptions] =
  ## Parse arguments for screen command
  var config = newGlobalConfig()
  var options = newScreenOptions()
  
  var p = initOptParser(commandLineParams(), shortNoVal = {'q'}, longNoVal = @["quiet", "no-header", "no-color", "debug", "help", "refresh"])
  next(p)  # Initialize parser to first item
  
  # Skip to the command
  while p.kind != cmdEnd:
    if p.kind == cmdArgument and p.key.toLower() in ["screen", "scr", "s"]:
      next(p)
      break
    next(p)
  
  # Parse options
  while p.kind != cmdEnd:
    case p.kind
    of cmdLongOption, cmdShortOption:
      case p.key.toLower()
      # Global options
      of "format", "f", "quiet", "q", "no-header", "no-color", "no-colour", "precision", "p", "date-format", "debug", "refresh":
        parseGlobalOptions(config, p)
        continue
      
      # Command-specific options
      of "criteria", "c":
        if p.val.len == 0:
          raise newException(CliError, "--criteria requires a value")
        case p.val.toLower()
        of "value": options.criteria = CriteriaValue
        of "growth": options.criteria = CriteriaGrowth
        of "dividend": options.criteria = CriteriaDividend
        of "momentum": options.criteria = CriteriaMomentum
        of "custom": options.criteria = CriteriaCustom
        else:
          raise newException(CliError, "Unknown criteria: " & p.val)
      
      of "where", "w":
        if p.val.len == 0:
          raise newException(CliError, "--where requires a value")
        options.whereClause = p.val
      
      of "help", "h":
        return (config, options)
      
      else:
        raise newException(CliError, "Unknown option: --" & p.key)
    
    of cmdArgument:
      # Positional argument - symbol
      options.symbols.add(p.key.toUpperAscii())
    
    of cmdEnd:
      break
    
    next(p)
  
  return (config, options)


proc parseActionsArgs*(commandName: string): tuple[config: GlobalConfig, options: ActionsOptions] =
  ## Parse arguments for dividends/splits/actions commands
  ## 
  ## Args:
  ##   commandName: The command name ("dividends", "splits", or "actions")
  var config = newGlobalConfig()
  var options = newActionsOptions()
  
  var p = initOptParser(commandLineParams(), shortNoVal = {'q'}, longNoVal = @["quiet", "no-header", "no-color", "debug", "help", "refresh"])
  next(p)  # Initialize parser to first item
  
  # Skip to the command
  while p.kind != cmdEnd:
    if p.kind == cmdArgument and p.key.toLower() in [commandName, commandName[0..2]]:
      next(p)
      break
    next(p)
  
  # Parse options
  while p.kind != cmdEnd:
    case p.kind
    of cmdLongOption, cmdShortOption:
      case p.key.toLower()
      # Global options
      of "format", "f", "quiet", "q", "no-header", "no-color", "no-colour", "precision", "p", "date-format", "debug", "refresh":
        parseGlobalOptions(config, p)
        continue
      
      # Command-specific options
      of "start", "s":
        if p.val.len == 0:
          raise newException(CliError, "--start requires a value")
        options.startDate = p.val
      
      of "end", "e":
        if p.val.len == 0:
          raise newException(CliError, "--end requires a value")
        options.endDate = p.val
      
      of "lookback", "l":
        if p.val.len == 0:
          raise newException(CliError, "--lookback requires a value")
        options.lookback = p.val
      
      of "help", "h":
        return (config, options)
      
      else:
        raise newException(CliError, "Unknown option: --" & p.key)
    
    of cmdArgument:
      # Positional argument - symbol (only one allowed)
      if options.symbol.len == 0:
        options.symbol = p.key.toUpperAscii()
      else:
        raise newException(CliError, "Only one symbol allowed for " & commandName & " command")
    
    of cmdEnd:
      break
    
    next(p)
  
  return (config, options)


proc parseDownloadArgs*(): tuple[config: GlobalConfig, options: HistoryOptions] =
  ## Parse arguments for download command (batch historical data)
  ## Similar to history but accepts multiple symbols
  var config = newGlobalConfig()
  var options = newHistoryOptions()
  
  var p = initOptParser(commandLineParams(), shortNoVal = {'q'}, longNoVal = @["quiet", "no-header", "no-color", "debug", "help", "refresh"])
  next(p)  # Initialize parser to first item
  
  # Skip to the command
  while p.kind != cmdEnd:
    if p.kind == cmdArgument and p.key.toLower() in ["download", "dl"]:
      next(p)
      break
    next(p)
  
  # Parse options
  while p.kind != cmdEnd:
    case p.kind
    of cmdLongOption, cmdShortOption:
      case p.key.toLower()
      # Global options
      of "format", "f", "quiet", "q", "no-header", "no-color", "no-colour", "precision", "p", "date-format", "debug", "refresh":
        parseGlobalOptions(config, p)
        continue
      
      # Command-specific options
      of "interval", "i":
        if p.val.len == 0:
          raise newException(CliError, "--interval requires a value")
        options.interval = parseInterval(p.val)
      
      of "start", "s":
        if p.val.len == 0:
          raise newException(CliError, "--start requires a value")
        options.startDate = p.val
      
      of "end", "e":
        if p.val.len == 0:
          raise newException(CliError, "--end requires a value")
        options.endDate = p.val
      
      of "lookback", "l":
        if p.val.len == 0:
          raise newException(CliError, "--lookback requires a value")
        options.lookback = p.val
      
      of "help", "h":
        return (config, options)
      
      else:
        raise newException(CliError, "Unknown option: --" & p.key)
    
    of cmdArgument:
      # Positional argument - symbols (multiple allowed, comma or space-separated)
      let arg = p.key.toUpperAscii()
      if ',' in arg:
        # Comma-separated symbols
        for ticker in arg.split(','):
          let trimmed = ticker.strip()
          if trimmed.len > 0:
            options.symbols.add(trimmed)
      else:
        # Single symbol
        options.symbols.add(arg)
    
    of cmdEnd:
      break
    
    next(p)
  
  return (config, options)


proc parseIndicatorsArgs*(): tuple[config: GlobalConfig, options: IndicatorsOptions] =
  ## Parse arguments for indicators command
  var config = newGlobalConfig()
  var options = newIndicatorsOptions()
  
  var p = initOptParser(commandLineParams(), shortNoVal = {'q'}, longNoVal = @["quiet", "no-header", "no-color", "debug", "help", "refresh", "macd", "stochastic", "obv", "vwap", "all"])
  next(p)  # Initialize parser to first item
  
  # Skip to the command
  while p.kind != cmdEnd:
    if p.kind == cmdArgument and p.key.toLower() in ["indicators", "ind", "i"]:
      next(p)
      break
    next(p)
  
  # Parse options
  while p.kind != cmdEnd:
    case p.kind
    of cmdLongOption, cmdShortOption:
      case p.key.toLower()
      # Global options
      of "format", "f", "quiet", "q", "no-header", "no-color", "no-colour", "precision", "p", "date-format", "debug", "refresh":
        parseGlobalOptions(config, p)
        continue
      
      # Command-specific options
      of "interval":
        if p.val.len == 0:
          raise newException(CliError, "--interval requires a value")
        options.interval = parseInterval(p.val)
      
      of "start", "s":
        if p.val.len == 0:
          raise newException(CliError, "--start requires a value")
        options.startDate = p.val
      
      of "end", "e":
        if p.val.len == 0:
          raise newException(CliError, "--end requires a value")
        options.endDate = p.val
      
      of "lookback", "l":
        if p.val.len == 0:
          raise newException(CliError, "--lookback requires a value")
        options.lookback = p.val
      
      of "sma":
        if p.val.len > 0:
          for periodStr in p.val.split(','):
            try:
              options.sma.add(parseInt(periodStr.strip()))
            except ValueError:
              raise newException(CliError, "Invalid SMA period: " & periodStr)
        else:
          # No value = use defaults
          options.sma = @[20, 50, 200]
      
      of "ema":
        if p.val.len > 0:
          for periodStr in p.val.split(','):
            try:
              options.ema.add(parseInt(periodStr.strip()))
            except ValueError:
              raise newException(CliError, "Invalid EMA period: " & periodStr)
        else:
          # No value = use defaults
          options.ema = @[12, 26]
      
      of "wma":
        if p.val.len > 0:
          for periodStr in p.val.split(','):
            try:
              options.wma.add(parseInt(periodStr.strip()))
            except ValueError:
              raise newException(CliError, "Invalid WMA period: " & periodStr)
      
      of "rsi":
        if p.val.len > 0:
          try:
            options.rsi = parseInt(p.val)
          except ValueError:
            raise newException(CliError, "Invalid RSI period: " & p.val)
        else:
          options.rsi = 14  # Default
      
      of "macd":
        options.macd = true
      
      of "stochastic", "stoch":
        options.stochastic = true
      
      of "bb":
        if p.val.len > 0:
          try:
            options.bb = parseInt(p.val)
          except ValueError:
            raise newException(CliError, "Invalid BB period: " & p.val)
        else:
          options.bb = 20  # Default
      
      of "atr":
        if p.val.len > 0:
          try:
            options.atr = parseInt(p.val)
          except ValueError:
            raise newException(CliError, "Invalid ATR period: " & p.val)
        else:
          options.atr = 14  # Default
      
      of "adx":
        if p.val.len > 0:
          try:
            options.adx = parseInt(p.val)
          except ValueError:
            raise newException(CliError, "Invalid ADX period: " & p.val)
        else:
          options.adx = 14  # Default
      
      of "obv":
        options.obv = true
      
      of "vwap":
        options.vwap = true
      
      of "all":
        options.all = true
        # Enable all indicators with defaults
        options.sma = @[20, 50, 200]
        options.ema = @[12, 26]
        options.rsi = 14
        options.macd = true
        options.stochastic = true
        options.bb = 20
        options.atr = 14
        options.adx = 14
        options.obv = true
        options.vwap = true
      
      of "help", "h":
        return (config, options)
      
      else:
        raise newException(CliError, "Unknown option: --" & p.key)
    
    of cmdArgument:
      # Positional argument - symbol (only one allowed)
      if options.symbol.len == 0:
        options.symbol = p.key.toUpperAscii()
      else:
        raise newException(CliError, "Only one symbol allowed for indicators command")
    
    of cmdEnd:
      break
    
    next(p)
  
  return (config, options)
