## yf - Yahoo Finance CLI Tool
##
## This is the main entry point for the yf command-line tool.
## The actual implementation is in cli/yf.nim

# Import the CLI module which contains main()
import cli/yf as cli_yf

# Call main from the CLI module when this is the main module
when isMainModule:
  cli_yf.main()
