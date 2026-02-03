## Config File Loader
##
## Loads configuration from ~/.yfrc or ~/.config/yf/config
## Supports simple key=value format

import std/[os, strutils, tables, parseutils]
import types

type
  FileConfig* = object
    format*: string
    precision*: int
    colorize*: bool
    dateFormat*: string
    cacheEnabled*: bool
    cacheTtl*: int64
    quiet*: bool

proc defaultFileConfig*(): FileConfig =
  ## Return default file configuration
  result = FileConfig(
    format: "table",
    precision: 2,
    colorize: true,
    dateFormat: "YYYY-MM-DD",
    cacheEnabled: true,
    cacheTtl: 300,  # 5 minutes
    quiet: false
  )

proc parseBool(s: string): bool =
  ## Parse boolean value from string
  case s.toLower()
  of "true", "yes", "1", "on":
    result = true
  of "false", "no", "0", "off":
    result = false
  else:
    result = false

proc parseConfigLine(line: string, config: var FileConfig) =
  ## Parse a single config line (key=value format)
  let trimmed = line.strip()
  
  # Skip empty lines and comments
  if trimmed.len == 0 or trimmed.startsWith("#"):
    return
  
  # Parse key=value
  let parts = trimmed.split('=', maxsplit=1)
  if parts.len != 2:
    return
  
  let key = parts[0].strip().toLower()
  let value = parts[1].strip()
  
  case key
  of "format":
    config.format = value
  of "precision":
    try:
      config.precision = parseInt(value)
    except ValueError:
      discard
  of "colorize", "color", "colors":
    config.colorize = parseBool(value)
  of "date_format", "dateformat":
    config.dateFormat = value
  of "cache", "cache_enabled":
    config.cacheEnabled = parseBool(value)
  of "cache_ttl", "cachettl":
    try:
      config.cacheTtl = parseInt(value).int64
    except ValueError:
      discard
  of "verbose":
    config.verbose = parseBool(value)
  else:
    discard  # Unknown key, ignore

proc loadConfigFile*(): FileConfig =
  ## Load configuration from file
  ##
  ## Searches for config in the following order:
  ## 1. ~/.yfrc
  ## 2. ~/.config/yf/config
  ## 3. $XDG_CONFIG_HOME/yf/config
  ##
  ## Returns default config if no file found
  
  result = defaultFileConfig()
  
  var configPaths: seq[string] = @[]
  
  # Add config file paths in priority order
  let homeDir = getHomeDir()
  configPaths.add(homeDir / ".yfrc")
  configPaths.add(homeDir / ".config" / "yf" / "config")
  
  # Check XDG_CONFIG_HOME
  let xdgConfig = getEnv("XDG_CONFIG_HOME")
  if xdgConfig.len > 0:
    configPaths.add(xdgConfig / "yf" / "config")
  
  # Find first existing config file
  var configPath = ""
  for path in configPaths:
    if fileExists(path):
      configPath = path
      break
  
  # If no config file found, return defaults
  if configPath.len == 0:
    return result
  
  # Read and parse config file
  try:
    let content = readFile(configPath)
    for line in content.splitLines():
      parseConfigLine(line, result)
  except IOError:
    # If file can't be read, just use defaults
    discard

proc applyFileConfig*(config: var GlobalConfig, fileConfig: FileConfig) =
  ## Apply file configuration to global config
  ## Only applies settings that weren't explicitly set on command line
  
  # For now, we'll assume command line always takes precedence
  # A more sophisticated approach would track which options were set via CLI
  
  # Apply file config as defaults
  if config.precision == 2:  # If still at default
    config.precision = fileConfig.precision
  
  if config.dateFormat == "YYYY-MM-DD":  # If still at default
    config.dateFormat = fileConfig.dateFormat
