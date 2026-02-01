## Technical Indicators Module
##
## Pure computation module for calculating technical indicators from OHLCV data.
## No external dependencies - all calculations use standard mathematical formulas.

import std/[math, strformat]
import types

type
  IndicatorError* = object of CatchableError
  
  # Simple Moving Average result
  SMAResult* = object
    values*: seq[float64]     # SMA values (NaN for insufficient data)
    period*: int              # Period used
    
  # Exponential Moving Average result
  EMAResult* = object
    values*: seq[float64]
    period*: int
    
  # RSI result
  RSIResult* = object
    values*: seq[float64]     # RSI values (0-100)
    period*: int
    
  # MACD result
  MACDResult* = object
    macd*: seq[float64]       # MACD line
    signal*: seq[float64]     # Signal line
    histogram*: seq[float64]  # MACD - Signal
    fastPeriod*: int          # Default: 12
    slowPeriod*: int          # Default: 26
    signalPeriod*: int        # Default: 9
    
  # Bollinger Bands result
  BBResult* = object
    upper*: seq[float64]      # Upper band
    middle*: seq[float64]     # Middle band (SMA)
    lower*: seq[float64]      # Lower band
    period*: int
    stdDev*: float64          # Number of std deviations
    
  # ATR (Average True Range) result
  ATRResult* = object
    values*: seq[float64]
    period*: int
    
  # Stochastic result
  StochasticResult* = object
    k*: seq[float64]          # %K line
    d*: seq[float64]          # %D line (SMA of %K)
    period*: int
    smoothK*: int
    smoothD*: int

# Helper: Check if we have enough data
proc validatePeriod(dataLen: int, period: int, name: string) =
  if period < 1:
    raise newException(IndicatorError, fmt"{name}: period must be >= 1")
  if dataLen < period:
    raise newException(IndicatorError, 
      fmt"{name}: insufficient data (need {period}, have {dataLen})")


# ============================================================================
# MOVING AVERAGES
# ============================================================================

proc calculateSMA*(prices: seq[float64], period: int): SMAResult =
  ## Calculate Simple Moving Average
  ## 
  ## Args:
  ##   prices: Price series (typically close prices)
  ##   period: Number of periods for averaging
  ## 
  ## Returns:
  ##   SMAResult with values aligned to input prices
  ##   First (period-1) values will be NaN
  ## 
  ## Example:
  ##   let closes = history.data.mapIt(it.close)
  ##   let sma20 = calculateSMA(closes, 20)
  
  validatePeriod(prices.len, period, "SMA")
  
  result = SMAResult(period: period)
  result.values = newSeq[float64](prices.len)
  
  # First (period-1) values are NaN (insufficient data)
  for i in 0..<period-1:
    result.values[i] = NaN
  
  # Calculate SMA for remaining values
  for i in period-1..<prices.len:
    var sum = 0.0
    for j in i-period+1..i:
      sum += prices[j]
    result.values[i] = sum / period.float64


proc calculateEMA*(prices: seq[float64], period: int): EMAResult =
  ## Calculate Exponential Moving Average
  ## 
  ## EMA gives more weight to recent prices
  ## Multiplier = 2 / (period + 1)
  ## EMA = (Price - EMA_prev) * multiplier + EMA_prev
  
  validatePeriod(prices.len, period, "EMA")
  
  result = EMAResult(period: period)
  result.values = newSeq[float64](prices.len)
  
  let multiplier = 2.0 / (period.float64 + 1.0)
  
  # First (period-1) values are NaN
  for i in 0..<period-1:
    result.values[i] = NaN
  
  # Start with SMA as first EMA value
  var sum = 0.0
  for i in 0..<period:
    sum += prices[i]
  result.values[period-1] = sum / period.float64
  
  # Calculate EMA for remaining values
  for i in period..<prices.len:
    result.values[i] = (prices[i] - result.values[i-1]) * multiplier + result.values[i-1]


proc calculateWMA*(prices: seq[float64], period: int): seq[float64] =
  ## Calculate Weighted Moving Average
  ## Recent prices have linearly increasing weights
  
  validatePeriod(prices.len, period, "WMA")
  
  result = newSeq[float64](prices.len)
  let weightSum = period * (period + 1) div 2  # 1+2+3+...+period
  
  for i in 0..<period-1:
    result[i] = NaN
  
  for i in period-1..<prices.len:
    var weightedSum = 0.0
    for j in 0..<period:
      let weight = (j + 1).float64
      weightedSum += prices[i - period + 1 + j] * weight
    result[i] = weightedSum / weightSum.float64


# ============================================================================
# MOMENTUM INDICATORS
# ============================================================================

proc calculateRSI*(prices: seq[float64], period: int = 14): RSIResult =
  ## Calculate Relative Strength Index (0-100)
  ## 
  ## RSI measures magnitude of recent price changes
  ## RSI > 70: overbought, RSI < 30: oversold
  ## 
  ## Formula:
  ##   RS = Average Gain / Average Loss
  ##   RSI = 100 - (100 / (1 + RS))
  
  validatePeriod(prices.len, period + 1, "RSI")  # Need period+1 for price changes
  
  result = RSIResult(period: period)
  result.values = newSeq[float64](prices.len)
  
  # Calculate price changes
  var gains = newSeq[float64](prices.len - 1)
  var losses = newSeq[float64](prices.len - 1)
  
  for i in 1..<prices.len:
    let change = prices[i] - prices[i-1]
    if change > 0:
      gains[i-1] = change
      losses[i-1] = 0.0
    else:
      gains[i-1] = 0.0
      losses[i-1] = abs(change)
  
  # First 'period' values are NaN
  for i in 0..period:
    result.values[i] = NaN
  
  # Calculate first average gain/loss (SMA)
  var avgGain = 0.0
  var avgLoss = 0.0
  for i in 0..<period:
    avgGain += gains[i]
    avgLoss += losses[i]
  avgGain /= period.float64
  avgLoss /= period.float64
  
  # Calculate first RSI
  let rs = if avgLoss == 0.0: 100.0 else: avgGain / avgLoss
  result.values[period] = 100.0 - (100.0 / (1.0 + rs))
  
  # Calculate RSI for remaining values (using smoothed averages)
  for i in period+1..<prices.len:
    avgGain = (avgGain * (period - 1).float64 + gains[i-1]) / period.float64
    avgLoss = (avgLoss * (period - 1).float64 + losses[i-1]) / period.float64
    
    let rs = if avgLoss == 0.0: 100.0 else: avgGain / avgLoss
    result.values[i] = 100.0 - (100.0 / (1.0 + rs))


proc calculateStochastic*(bars: seq[HistoryRecord], period: int = 14, 
                         smoothK: int = 3, smoothD: int = 3): StochasticResult =
  ## Calculate Stochastic Oscillator (%K and %D)
  ## 
  ## %K = (Close - LowestLow) / (HighestHigh - LowestLow) * 100
  ## %D = SMA of %K
  ## 
  ## Values range 0-100, > 80 overbought, < 20 oversold
  
  validatePeriod(bars.len, period, "Stochastic")
  
  result = StochasticResult(period: period, smoothK: smoothK, smoothD: smoothD)
  var rawK = newSeq[float64](bars.len)
  
  # Calculate raw %K
  for i in 0..<period-1:
    rawK[i] = NaN
  
  for i in period-1..<bars.len:
    var lowestLow = bars[i - period + 1].low
    var highestHigh = bars[i - period + 1].high
    
    for j in i-period+2..i:
      lowestLow = min(lowestLow, bars[j].low)
      highestHigh = max(highestHigh, bars[j].high)
    
    let range = highestHigh - lowestLow
    if range == 0.0:
      rawK[i] = 50.0  # Midpoint when no range
    else:
      rawK[i] = (bars[i].close - lowestLow) / range * 100.0
  
  # Smooth %K
  result.k = calculateSMA(rawK, smoothK).values
  
  # Calculate %D (SMA of %K)
  result.d = calculateSMA(result.k, smoothD).values


proc calculateROC*(prices: seq[float64], period: int = 12): seq[float64] =
  ## Calculate Rate of Change
  ## 
  ## ROC = (Price - Price_n_periods_ago) / Price_n_periods_ago * 100
  
  validatePeriod(prices.len, period + 1, "ROC")
  
  result = newSeq[float64](prices.len)
  
  for i in 0..<period:
    result[i] = NaN
  
  for i in period..<prices.len:
    let oldPrice = prices[i - period]
    if oldPrice != 0.0:
      result[i] = (prices[i] - oldPrice) / oldPrice * 100.0
    else:
      result[i] = NaN


# ============================================================================
# TREND INDICATORS
# ============================================================================

proc calculateMACD*(prices: seq[float64], fastPeriod: int = 12, 
                    slowPeriod: int = 26, signalPeriod: int = 9): MACDResult =
  ## Calculate MACD (Moving Average Convergence Divergence)
  ## 
  ## MACD Line = EMA(fast) - EMA(slow)
  ## Signal Line = EMA of MACD Line
  ## Histogram = MACD Line - Signal Line
  ## 
  ## Crossovers indicate buy/sell signals
  
  validatePeriod(prices.len, slowPeriod, "MACD")
  
  result = MACDResult(
    fastPeriod: fastPeriod,
    slowPeriod: slowPeriod,
    signalPeriod: signalPeriod
  )
  
  # Calculate fast and slow EMAs
  let fastEMA = calculateEMA(prices, fastPeriod).values
  let slowEMA = calculateEMA(prices, slowPeriod).values
  
  # Calculate MACD line
  result.macd = newSeq[float64](prices.len)
  for i in 0..<prices.len:
    if fastEMA[i].classify == fcNaN or slowEMA[i].classify == fcNaN:
      result.macd[i] = NaN
    else:
      result.macd[i] = fastEMA[i] - slowEMA[i]
  
  # Calculate signal line (EMA of MACD)
  # Need to handle NaN values in MACD first
  var macdNonNan = newSeq[float64]()
  var firstValidIdx = -1
  for i in 0..<result.macd.len:
    if result.macd[i].classify != fcNaN:
      if firstValidIdx == -1:
        firstValidIdx = i
      macdNonNan.add(result.macd[i])
  
  # Calculate signal on non-NaN MACD values
  if macdNonNan.len >= signalPeriod:
    let signalNonNan = calculateEMA(macdNonNan, signalPeriod).values
    
    result.signal = newSeq[float64](prices.len)
    for i in 0..<prices.len:
      result.signal[i] = NaN
    
    # Copy signal values back
    for i in 0..<signalNonNan.len:
      result.signal[firstValidIdx + i] = signalNonNan[i]
  else:
    result.signal = newSeq[float64](prices.len)
    for i in 0..<prices.len:
      result.signal[i] = NaN
  
  # Calculate histogram
  result.histogram = newSeq[float64](prices.len)
  for i in 0..<prices.len:
    if result.macd[i].classify == fcNaN or result.signal[i].classify == fcNaN:
      result.histogram[i] = NaN
    else:
      result.histogram[i] = result.macd[i] - result.signal[i]


proc calculateADX*(bars: seq[HistoryRecord], period: int = 14): seq[float64] =
  ## Calculate Average Directional Index (simplified)
  ## 
  ## ADX measures trend strength (not direction)
  ## ADX > 25: strong trend, ADX < 20: weak/no trend
  
  validatePeriod(bars.len, period + 1, "ADX")
  
  result = newSeq[float64](bars.len)
  
  # Calculate True Range and Directional Movement
  var tr = newSeq[float64](bars.len - 1)
  var plusDM = newSeq[float64](bars.len - 1)
  var minusDM = newSeq[float64](bars.len - 1)
  
  for i in 1..<bars.len:
    # True Range
    let high = bars[i].high
    let low = bars[i].low
    let prevClose = bars[i-1].close
    tr[i-1] = max(high - low, max(abs(high - prevClose), abs(low - prevClose)))
    
    # Directional Movement
    let upMove = high - bars[i-1].high
    let downMove = bars[i-1].low - low
    
    if upMove > downMove and upMove > 0:
      plusDM[i-1] = upMove
    else:
      plusDM[i-1] = 0.0
    
    if downMove > upMove and downMove > 0:
      minusDM[i-1] = downMove
    else:
      minusDM[i-1] = 0.0
  
  # Smooth with EMA
  let smoothTR = calculateEMA(tr, period).values
  let smoothPlusDM = calculateEMA(plusDM, period).values
  let smoothMinusDM = calculateEMA(minusDM, period).values
  
  # Calculate +DI, -DI, and DX
  for i in 0..period:
    result[i] = NaN
  
  var dxValues = newSeq[float64]()
  for i in period+1..<bars.len:
    let plusDI = if smoothTR[i-1] != 0.0: 100.0 * smoothPlusDM[i-1] / smoothTR[i-1] else: 0.0
    let minusDI = if smoothTR[i-1] != 0.0: 100.0 * smoothMinusDM[i-1] / smoothTR[i-1] else: 0.0
    
    let dx = if plusDI + minusDI != 0.0: 
               abs(plusDI - minusDI) / (plusDI + minusDI) * 100.0
             else: 0.0
    
    dxValues.add(dx)
  
  # ADX is EMA of DX
  if dxValues.len >= period:
    let adxValues = calculateEMA(dxValues, period).values
    for i in 0..<adxValues.len:
      result[period + 1 + i] = adxValues[i]


# ============================================================================
# VOLATILITY INDICATORS
# ============================================================================

proc calculateBollingerBands*(prices: seq[float64], period: int = 20, 
                              stdDev: float64 = 2.0): BBResult =
  ## Calculate Bollinger Bands
  ## 
  ## Middle Band = SMA(period)
  ## Upper Band = Middle + (stdDev * standard deviation)
  ## Lower Band = Middle - (stdDev * standard deviation)
  ## 
  ## Bands expand during volatility, contract during consolidation
  
  validatePeriod(prices.len, period, "Bollinger Bands")
  
  result = BBResult(period: period, stdDev: stdDev)
  
  # Calculate middle band (SMA)
  result.middle = calculateSMA(prices, period).values
  
  # Calculate standard deviation and bands
  result.upper = newSeq[float64](prices.len)
  result.lower = newSeq[float64](prices.len)
  
  for i in 0..<period-1:
    result.upper[i] = NaN
    result.lower[i] = NaN
  
  for i in period-1..<prices.len:
    # Calculate standard deviation for this window
    var sum = 0.0
    var sumSq = 0.0
    for j in i-period+1..i:
      sum += prices[j]
      sumSq += prices[j] * prices[j]
    
    let mean = sum / period.float64
    let variance = (sumSq / period.float64) - (mean * mean)
    let sd = sqrt(variance)
    
    result.upper[i] = result.middle[i] + (stdDev * sd)
    result.lower[i] = result.middle[i] - (stdDev * sd)


proc calculateATR*(bars: seq[HistoryRecord], period: int = 14): ATRResult =
  ## Calculate Average True Range
  ## 
  ## TR = max(high - low, |high - prevClose|, |low - prevClose|)
  ## ATR = EMA of TR
  ## 
  ## Measures volatility (not direction)
  
  validatePeriod(bars.len, period + 1, "ATR")
  
  result = ATRResult(period: period)
  
  # Calculate True Range for each bar
  var tr = newSeq[float64](bars.len)
  tr[0] = bars[0].high - bars[0].low  # First bar
  
  for i in 1..<bars.len:
    let high = bars[i].high
    let low = bars[i].low
    let prevClose = bars[i-1].close
    tr[i] = max(high - low, max(abs(high - prevClose), abs(low - prevClose)))
  
  # Calculate ATR (EMA of TR)
  result.values = calculateEMA(tr, period).values


# ============================================================================
# VOLUME INDICATORS
# ============================================================================

proc calculateOBV*(bars: seq[HistoryRecord]): seq[float64] =
  ## Calculate On-Balance Volume
  ## 
  ## OBV tracks cumulative volume based on price direction
  ## If close > prevClose: OBV += volume
  ## If close < prevClose: OBV -= volume
  ## If close == prevClose: OBV unchanged
  
  result = newSeq[float64](bars.len)
  result[0] = bars[0].volume.float64
  
  for i in 1..<bars.len:
    if bars[i].close > bars[i-1].close:
      result[i] = result[i-1] + bars[i].volume.float64
    elif bars[i].close < bars[i-1].close:
      result[i] = result[i-1] - bars[i].volume.float64
    else:
      result[i] = result[i-1]


proc calculateVWAP*(bars: seq[HistoryRecord]): seq[float64] =
  ## Calculate Volume Weighted Average Price
  ## 
  ## VWAP = Cumulative(typical price * volume) / Cumulative(volume)
  ## Typical Price = (High + Low + Close) / 3
  ## 
  ## Often resets daily (here we calculate cumulative)
  
  result = newSeq[float64](bars.len)
  var cumulativeTPV = 0.0  # Typical Price * Volume
  var cumulativeVolume = 0.0
  
  for i in 0..<bars.len:
    let typicalPrice = (bars[i].high + bars[i].low + bars[i].close) / 3.0
    cumulativeTPV += typicalPrice * bars[i].volume.float64
    cumulativeVolume += bars[i].volume.float64
    
    if cumulativeVolume != 0.0:
      result[i] = cumulativeTPV / cumulativeVolume
    else:
      result[i] = typicalPrice
