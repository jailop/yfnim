## Configuration and Argument Parsing Module
##
## Handles command-line argument parsing and configuration using std/parseopt

import std/[os, strutils, parseopt]
import types, utils


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
  else:
    raise newException(CliError, "Unknown command: " & cmd)


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
        of "minimal", "min": config.format = FormatMinimal
        else:
          raise newException(CliError, "Invalid format: " & p.val & 
                            ". Valid options: table, csv, json, tsv, minimal")
      
      of "quiet", "q":
        config.quiet = true
      
      of "no-header":
        config.noHeader = true
      
      of "no-color", "no-colour":
        config.colorize = false
      
      of "precision", "p":
        if p.val.len == 0:
          raise newException(CliError, "--precision requires a value")
        try:
          config.precision = parseInt(p.val)
          if config.precision < 0 or config.precision > 10:
            raise newException(CliError, "Precision must be between 0 and 10")
        except ValueError:
          raise newException(CliError, "Invalid precision value: " & p.val)
      
      of "date-format":
        if p.val.len == 0:
          raise newException(CliError, "--date-format requires a value")
        case p.val.toLower()
        of "iso": config.dateFormat = DateISO
        of "us": config.dateFormat = DateUS
        of "unix": config.dateFormat = DateUnix
        of "full": config.dateFormat = DateFull
        else:
          raise newException(CliError, "Invalid date format: " & p.val & 
                            ". Valid options: iso, us, unix, full")
      
      of "debug":
        config.debug = true
      
      of "refresh":
        config.refresh = true
      
      of "help", "h", "version", "v":
        # These are handled separately
        return
      
      else:
        # Unknown global option, stop parsing globals
        return
    
    of cmdArgument:
      # Hit a positional argument, stop parsing globals
      return
    
    of cmdEnd:
      return
    
    # Get next option
    next(p)


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
      # Positional argument - symbol
      options.symbols.add(p.key.toUpperAscii())
    
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
          raise newException(CliError, "Invalid criteria: " & p.val & 
                            ". Valid options: value, growth, dividend, momentum, custom")
      
      of "where", "w":
        if p.val.len == 0:
          raise newException(CliError, "--where requires a value")
        options.whereClause = p.val
        options.criteria = CriteriaCustom
      
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
