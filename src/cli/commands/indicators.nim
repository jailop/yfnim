## Indicators Command Implementation
##
## Calculate and display technical indicators for a symbol

import std/[strformat, math, strutils]
import ../[types, config, utils]
import ../../yfnim/[types as ytypes, retriever, indicators]

proc executeIndicators*(config: GlobalConfig, options: IndicatorsOptions) =
  ## Execute the indicators command
  ##
  ## Args:
  ##   config: Global configuration
  ##   options: Indicators-specific options
  
  # Validate symbol
  if options.symbol.len == 0:
    raise newException(CliError, "Symbol is required")
  
  # Show progress message unless quiet
  if config.verbose:
    printInfo(fmt"Calculating indicators for {options.symbol}...", config)
  
  try:
    # Get historical data
    var startTime: int64
    var endTime: int64
    
    if options.lookback.len > 0:
      let (startLb, endLb) = parseLookback(options.lookback)
      startTime = startLb
      endTime = endLb
    else:
      startTime = if options.startDate.len > 0:
        parseDateString(options.startDate)
      else:
        0'i64
      
      endTime = if options.endDate.len > 0:
        parseDateString(options.endDate)
      else:
        0'i64
    
    let history = getHistory(options.symbol, options.interval, startTime, endTime)
    
    if history.data.len == 0:
      raise newException(CliError, "No data available for " & options.symbol)
    
    # Extract close prices for indicators
    var closes = newSeq[float64](history.data.len)
    for i in 0..<history.data.len:
      closes[i] = history.data[i].close
    
    # Get latest price for reference
    let latestBar = history.data[^1]
    let latestPrice = latestBar.close
    
    # Print header
    if config.verbose:
      stderr.writeLine("")
      stderr.writeLine("═".repeat(70))
      stderr.writeLine(fmt"Technical Indicators: {options.symbol}")
      stderr.writeLine(fmt"Latest Price: ${latestPrice:.2f}  |  Data Points: {history.data.len}  |  Interval: {history.interval}")
      stderr.writeLine("═".repeat(70))
      stderr.writeLine("")
    
    # Calculate and display indicators
    var indicatorCount = 0
    
    # Moving Averages
    if options.sma.len > 0:
      echo "Moving Averages (SMA):"
      for period in options.sma:
        try:
          let sma = calculateSMA(closes, period)
          let latest = sma.values[^1]
          if latest.classify != fcNaN:
            let diff = latestPrice - latest
            let diffPct = (diff / latest) * 100.0
            let signal = if diff > 0: "▲" else: "▼"
            echo fmt"  SMA({period:>3}):  ${latest:>10.2f}   {signal} ${abs(diff):>6.2f} ({diffPct:>+6.2f}%)"
            indicatorCount += 1
        except IndicatorError as e:
          if config.verbose:
            printWarning(fmt"SMA({period}): {e.msg}", config)
      echo ""
    
    if options.ema.len > 0:
      echo "Exponential Moving Averages (EMA):"
      for period in options.ema:
        try:
          let ema = calculateEMA(closes, period)
          let latest = ema.values[^1]
          if latest.classify != fcNaN:
            let diff = latestPrice - latest
            let diffPct = (diff / latest) * 100.0
            let signal = if diff > 0: "▲" else: "▼"
            echo fmt"  EMA({period:>3}):  ${latest:>10.2f}   {signal} ${abs(diff):>6.2f} ({diffPct:>+6.2f}%)"
            indicatorCount += 1
        except IndicatorError as e:
          if config.verbose:
            printWarning(fmt"EMA({period}): {e.msg}", config)
      echo ""
    
    if options.wma.len > 0:
      echo "Weighted Moving Averages (WMA):"
      for period in options.wma:
        try:
          let wma = calculateWMA(closes, period)
          let latest = wma[^1]
          if latest.classify != fcNaN:
            let diff = latestPrice - latest
            let diffPct = (diff / latest) * 100.0
            let signal = if diff > 0: "▲" else: "▼"
            echo fmt"  WMA({period:>3}):  ${latest:>10.2f}   {signal} ${abs(diff):>6.2f} ({diffPct:>+6.2f}%)"
            indicatorCount += 1
        except IndicatorError as e:
          if config.verbose:
            printWarning(fmt"WMA({period}): {e.msg}", config)
      echo ""
    
    # Momentum Indicators
    if options.rsi > 0:
      try:
        let rsi = calculateRSI(closes, options.rsi)
        let latest = rsi.values[^1]
        if latest.classify != fcNaN:
          let signal = if latest > 70: "OVERBOUGHT ⚠️"
                      elif latest < 30: "OVERSOLD ⚠️"
                      else: "NEUTRAL"
          echo "Momentum:"
          echo fmt"  RSI({options.rsi}):    {latest:>10.2f}   [{signal}]"
          echo ""
          indicatorCount += 1
      except IndicatorError as e:
        if config.verbose:
          printWarning(fmt"RSI: {e.msg}", config)
    
    if options.macd:
      try:
        let macd = calculateMACD(closes)
        if macd.macd[^1].classify != fcNaN and macd.signal[^1].classify != fcNaN:
          echo "MACD:"
          echo fmt"  MACD Line:      {macd.macd[^1]:>10.4f}"
          echo fmt"  Signal Line:    {macd.signal[^1]:>10.4f}"
          echo fmt"  Histogram:      {macd.histogram[^1]:>10.4f}"
          
          # Determine signal
          let crossover = if macd.histogram[^1] > 0: "BULLISH 📈" 
                         else: "BEARISH 📉"
          echo fmt"  Signal:         {crossover}"
          echo ""
          indicatorCount += 1
      except IndicatorError as e:
        if config.verbose:
          printWarning(fmt"MACD: {e.msg}", config)
    
    if options.stochastic:
      try:
        let stoch = calculateStochastic(history.data, 14, 3, 3)
        if stoch.k[^1].classify != fcNaN:
          let signal = if stoch.k[^1] > 80: "OVERBOUGHT ⚠️"
                      elif stoch.k[^1] < 20: "OVERSOLD ⚠️"
                      else: "NEUTRAL"
          echo "Stochastic:"
          echo fmt"  %K:             {stoch.k[^1]:>10.2f}"
          echo fmt"  %D:             {stoch.d[^1]:>10.2f}"
          echo fmt"  Signal:         [{signal}]"
          echo ""
          indicatorCount += 1
      except IndicatorError as e:
        if config.verbose:
          printWarning(fmt"Stochastic: {e.msg}", config)
    
    # Volatility Indicators
    if options.bb > 0:
      try:
        let bb = calculateBollingerBands(closes, options.bb, options.bbStdDev)
        if bb.upper[^1].classify != fcNaN:
          # Calculate %B (position within bands)
          let bandwidth = bb.upper[^1] - bb.lower[^1]
          let pctB = ((latestPrice - bb.lower[^1]) / bandwidth) * 100.0
          
          let position = if pctB > 100: "Above Upper Band ⚠️"
                        elif pctB < 0: "Below Lower Band ⚠️"
                        elif pctB > 80: "Near Upper"
                        elif pctB < 20: "Near Lower"
                        else: "Middle"
          
          echo "Bollinger Bands:"
          echo fmt"  Upper Band:     ${bb.upper[^1]:>10.2f}"
          echo fmt"  Middle (SMA):   ${bb.middle[^1]:>10.2f}"
          echo fmt"  Lower Band:     ${bb.lower[^1]:>10.2f}"
          echo fmt"  Current Price:  ${latestPrice:>10.2f}"
          echo fmt"  Position (%B):  {pctB:>10.1f}%   [{position}]"
          echo ""
          indicatorCount += 1
      except IndicatorError as e:
        if config.verbose:
          printWarning(fmt"Bollinger Bands: {e.msg}", config)
    
    if options.atr > 0:
      try:
        let atr = calculateATR(history.data, options.atr)
        let latest = atr.values[^1]
        if latest.classify != fcNaN:
          let atrPct = (latest / latestPrice) * 100.0
          echo "Volatility:"
          echo fmt"  ATR({options.atr}):     ${latest:>10.4f}   ({atrPct:.2f}% of price)"
          echo ""
          indicatorCount += 1
      except IndicatorError as e:
        if config.verbose:
          printWarning(fmt"ATR: {e.msg}", config)
    
    if options.adx > 0:
      try:
        let adx = calculateADX(history.data, options.adx)
        let latest = adx[^1]
        if latest.classify != fcNaN:
          let trend = if latest > 25: "STRONG TREND 📊"
                     elif latest > 20: "Moderate Trend"
                     else: "Weak/No Trend"
          echo "Trend Strength:"
          echo fmt"  ADX({options.adx}):     {latest:>10.2f}   [{trend}]"
          echo ""
          indicatorCount += 1
      except IndicatorError as e:
        if config.verbose:
          printWarning(fmt"ADX: {e.msg}", config)
    
    # Volume Indicators
    if options.obv or options.vwap:
      echo "Volume:"
      
      if options.obv:
        try:
          let obv = calculateOBV(history.data)
          let latest = obv[^1]
          # Compare current OBV to average
          var avgObv = 0.0
          for val in obv:
            avgObv += val
          avgObv /= obv.len.float64
          
          let trend = if latest > avgObv: "Accumulation 📈" else: "Distribution 📉"
          echo fmt"  OBV:            {latest:>15.0f}   [{trend}]"
          indicatorCount += 1
        except IndicatorError as e:
          if config.verbose:
            printWarning(fmt"OBV: {e.msg}", config)
      
      if options.vwap:
        try:
          let vwap = calculateVWAP(history.data)
          let latest = vwap[^1]
          let diff = latestPrice - latest
          let signal = if diff > 0: "Above VWAP ▲" else: "Below VWAP ▼"
          echo fmt"  VWAP:           ${latest:>10.2f}   [{signal}]"
          indicatorCount += 1
        except IndicatorError as e:
          if config.verbose:
            printWarning(fmt"VWAP: {e.msg}", config)
      
      echo ""
    
    # Summary
    if config.verbose:
      stderr.writeLine("═".repeat(70))
      stderr.writeLine(fmt"Calculated {indicatorCount} indicators")
      stderr.writeLine("═".repeat(70))
    
    # If no indicators were requested, show hint
    if indicatorCount == 0:
      if config.verbose:
        stderr.writeLine("")
        stderr.writeLine("No indicators specified. Try:")
        stderr.writeLine("  --sma 20,50,200   # Simple moving averages")
        stderr.writeLine("  --ema 12,26       # Exponential moving averages")
        stderr.writeLine("  --rsi 14          # Relative Strength Index")
        stderr.writeLine("  --macd            # MACD indicator")
        stderr.writeLine("  --bb 20           # Bollinger Bands")
        stderr.writeLine("  --all             # All indicators with defaults")
        stderr.writeLine("")
        stderr.writeLine("Run 'yf indicators --help' for more options")
  
  except IndicatorError as e:
    raise newException(CliError, "Indicator calculation failed: " & e.msg)
  except YahooApiError as e:
    raise newException(CliError, "Failed to fetch data: " & e.msg)
  except CatchableError as e:
    raise newException(CliError, "Error: " & e.msg)


proc runIndicators*() =
  ## Parse arguments and execute indicators command
  let (config, options) = parseIndicatorsArgs()
  executeIndicators(config, options)
