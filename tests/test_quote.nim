import unittest
import std/[json, options, strutils]

# Include quote_types to access internal implementation
import yfnim/quote_types
import yfnim/quote_retriever

suite "QuoteType enum tests":
  
  test "parseQuoteType with valid strings":
    check parseQuoteType("EQUITY") == Equity
    check parseQuoteType("ETF") == ETF
    check parseQuoteType("MUTUALFUND") == Mutualfund
    check parseQuoteType("INDEX") == Index
    check parseQuoteType("CURRENCY") == Currency
    check parseQuoteType("CRYPTOCURRENCY") == Cryptocurrency
    check parseQuoteType("FUTURE") == Future
    check parseQuoteType("OPTION") == Option
  
  test "parseQuoteType with case variations":
    check parseQuoteType("equity") == Equity
    check parseQuoteType("Equity") == Equity
    check parseQuoteType("MUTUAL_FUND") == Mutualfund
  
  test "parseQuoteType with invalid string returns UnknownType":
    check parseQuoteType("INVALID") == UnknownType
    check parseQuoteType("") == UnknownType
    check parseQuoteType("STOCK") == UnknownType


suite "MarketState enum tests":
  
  test "parseMarketState with valid strings":
    check parseMarketState("PRE") == PreMarket
    check parseMarketState("REGULAR") == Regular
    check parseMarketState("POST") == Post
    check parseMarketState("CLOSED") == Closed
  
  test "parseMarketState with case variations":
    check parseMarketState("pre") == PreMarket
    check parseMarketState("PREPRE") == PreMarket
    check parseMarketState("PRE_MARKET") == PreMarket
    check parseMarketState("POST_MARKET") == Post
  
  test "parseMarketState with invalid string returns Unknown":
    check parseMarketState("INVALID") == Unknown
    check parseMarketState("") == Unknown


suite "Quote type tests":
  
  test "newQuote creates valid Quote":
    let quote = newQuote("AAPL")
    check quote.symbol == "AAPL"
    check quote.currency == "USD"
    check quote.tradeable == false
    check quote.trailingPE.isNone
    check quote.dividendRate.isNone
  
  test "Quote to JSON":
    var quote = newQuote("AAPL")
    quote.regularMarketPrice = 150.25
    quote.marketCap = 2500000000000
    quote.shortName = "Apple Inc."
    quote.quoteType = Equity
    quote.marketState = Regular
    
    let jsonNode = quote.toJson()
    check jsonNode["symbol"].getStr() == "AAPL"
    check jsonNode["regularMarketPrice"].getFloat() == 150.25
    check jsonNode["marketCap"].getInt() == 2500000000000
    check jsonNode["shortName"].getStr() == "Apple Inc."
    check jsonNode["quoteType"].getStr() in ["Equity", "EQUITY"]
    check jsonNode["marketState"].getStr() in ["Regular", "REGULAR"]
  
  test "Quote to JSON with Option fields":
    var quote = newQuote("AAPL")
    quote.trailingPE = some(25.5)
    quote.dividendYield = some(0.0125)
    quote.forwardPE = none(float64)
    
    let jsonNode = quote.toJson()
    check jsonNode.hasKey("trailingPE")
    check jsonNode["trailingPE"].getFloat() == 25.5
    check jsonNode.hasKey("dividendYield")
    check jsonNode["dividendYield"].getFloat() == 0.0125
    check not jsonNode.hasKey("forwardPE")
  
  test "Quote from JSON with complete data":
    let jsonStr = """
    {
      "symbol": "AAPL",
      "shortName": "Apple Inc.",
      "longName": "Apple Inc.",
      "quoteType": "EQUITY",
      "currency": "USD",
      "exchange": "NMS",
      "exchangeTimezoneShortName": "EST",
      "regularMarketPrice": 150.25,
      "regularMarketTime": 1704398400,
      "regularMarketChange": 2.5,
      "regularMarketChangePercent": 1.69,
      "regularMarketOpen": 148.0,
      "regularMarketDayHigh": 151.0,
      "regularMarketDayLow": 147.5,
      "regularMarketVolume": 50000000,
      "regularMarketPreviousClose": 147.75,
      "bid": 150.20,
      "ask": 150.30,
      "bidSize": 100,
      "askSize": 200,
      "fiftyTwoWeekLow": 125.0,
      "fiftyTwoWeekHigh": 180.0,
      "fiftyTwoWeekChangePercent": 15.5,
      "fiftyDayAverage": 145.0,
      "fiftyDayAverageChange": 5.25,
      "fiftyDayAverageChangePercent": 3.62,
      "twoHundredDayAverage": 140.0,
      "twoHundredDayAverageChange": 10.25,
      "twoHundredDayAverageChangePercent": 7.32,
      "averageDailyVolume3Month": 45000000,
      "averageDailyVolume10Day": 48000000,
      "marketCap": 2500000000000,
      "sharesOutstanding": 16000000000,
      "trailingPE": 25.5,
      "forwardPE": 22.3,
      "priceToBook": 35.2,
      "bookValue": 4.27,
      "epsTrailingTwelveMonths": 5.89,
      "epsForward": 6.73,
      "epsCurrentYear": 6.50,
      "dividendRate": 0.96,
      "dividendYield": 0.0064,
      "exDividendDate": 1704312000,
      "trailingAnnualDividendRate": 0.92,
      "trailingAnnualDividendYield": 0.0062,
      "marketState": "REGULAR",
      "tradeable": true,
      "triggerable": true
    }
    """
    
    let jsonNode = parseJson(jsonStr)
    let quote = fromJson(jsonNode, Quote)
    
    check quote.symbol == "AAPL"
    check quote.shortName == "Apple Inc."
    check quote.quoteType == Equity
    check quote.currency == "USD"
    check quote.regularMarketPrice == 150.25
    check quote.regularMarketVolume == 50000000
    check quote.marketCap == 2500000000000
    check quote.bid == 150.20
    check quote.ask == 150.30
    check quote.fiftyTwoWeekLow == 125.0
    check quote.fiftyTwoWeekHigh == 180.0
    check quote.marketState == Regular
    check quote.tradeable == true
    
    # Check Option fields
    check quote.trailingPE.isSome
    check quote.trailingPE.get() == 25.5
    check quote.forwardPE.isSome
    check quote.forwardPE.get() == 22.3
    check quote.dividendYield.isSome
    check quote.dividendYield.get() == 0.0064
  
  test "Quote from JSON with null values":
    let jsonStr = """
    {
      "symbol": "TEST",
      "shortName": "Test Co",
      "longName": "Test Company",
      "quoteType": "EQUITY",
      "currency": "USD",
      "exchange": "NMS",
      "exchangeTimezoneShortName": "EST",
      "regularMarketPrice": 100.0,
      "regularMarketTime": 1704398400,
      "regularMarketChange": 0.0,
      "regularMarketChangePercent": 0.0,
      "regularMarketOpen": 100.0,
      "regularMarketDayHigh": 101.0,
      "regularMarketDayLow": 99.0,
      "regularMarketVolume": 1000000,
      "regularMarketPreviousClose": 100.0,
      "bid": 0.0,
      "ask": 0.0,
      "bidSize": 0,
      "askSize": 0,
      "fiftyTwoWeekLow": 80.0,
      "fiftyTwoWeekHigh": 120.0,
      "fiftyTwoWeekChangePercent": 0.0,
      "fiftyDayAverage": 100.0,
      "fiftyDayAverageChange": 0.0,
      "fiftyDayAverageChangePercent": 0.0,
      "twoHundredDayAverage": 100.0,
      "twoHundredDayAverageChange": 0.0,
      "twoHundredDayAverageChangePercent": 0.0,
      "averageDailyVolume3Month": 1000000,
      "averageDailyVolume10Day": 1000000,
      "marketCap": 1000000000,
      "sharesOutstanding": 10000000,
      "trailingPE": null,
      "forwardPE": null,
      "priceToBook": null,
      "bookValue": null,
      "epsTrailingTwelveMonths": null,
      "epsForward": null,
      "epsCurrentYear": null,
      "dividendRate": null,
      "dividendYield": null,
      "exDividendDate": null,
      "trailingAnnualDividendRate": null,
      "trailingAnnualDividendYield": null,
      "marketState": "CLOSED",
      "tradeable": false,
      "triggerable": false
    }
    """
    
    let jsonNode = parseJson(jsonStr)
    let quote = fromJson(jsonNode, Quote)
    
    check quote.symbol == "TEST"
    check quote.regularMarketPrice == 100.0
    check quote.marketState == Closed
    
    # All Option fields should be None
    check quote.trailingPE.isNone
    check quote.forwardPE.isNone
    check quote.priceToBook.isNone
    check quote.dividendRate.isNone
    check quote.dividendYield.isNone
    check quote.exDividendDate.isNone
  
  test "Quote JSON round-trip":
    var quote = newQuote("MSFT")
    quote.regularMarketPrice = 350.75
    quote.marketCap = 2600000000000
    quote.trailingPE = some(28.3)
    quote.dividendYield = some(0.0082)
    quote.marketState = Regular
    quote.quoteType = Equity
    quote.tradeable = true
    
    let jsonNode = quote.toJson()
    let loadedQuote = fromJson(jsonNode, Quote)
    
    check loadedQuote.symbol == quote.symbol
    check loadedQuote.regularMarketPrice == quote.regularMarketPrice
    check loadedQuote.marketCap == quote.marketCap
    check loadedQuote.trailingPE.isSome
    check loadedQuote.trailingPE.get() == quote.trailingPE.get()
    check loadedQuote.marketState == quote.marketState
    check loadedQuote.tradeable == quote.tradeable


suite "Quote URL building tests":
  
  test "buildQuoteUrl with single symbol":
    let url = buildQuoteUrl("AAPL")
    check url.contains("query2.finance.yahoo.com")
    check url.contains("v8/finance/chart")
    check url.contains("AAPL")
    check url.contains("interval=1d")
    check url.contains("range=1d")
  
  test "buildQuoteUrl with special characters in symbol":
    let url = buildQuoteUrl("BRK-B")
    check url.contains("BRK") or url.contains("BRK%2DB")
  
  test "buildQuoteUrl with empty symbol raises error":
    expect(ValueError):
      discard buildQuoteUrl("")



suite "Quote response parsing tests":
  
  test "parseQuoteResponse with valid chart response":
    let jsonStr = """
    {
      "chart": {
        "result": [
          {
            "meta": {
              "symbol": "AAPL",
              "shortName": "Apple Inc.",
              "longName": "Apple Inc.",
              "instrumentType": "EQUITY",
              "currency": "USD",
              "exchangeName": "NMS",
              "exchangeTimezoneName": "America/New_York",
              "regularMarketPrice": 150.0,
              "regularMarketTime": 1704398400,
              "regularMarketDayHigh": 152.0,
              "regularMarketDayLow": 148.0,
              "regularMarketVolume": 50000000,
              "chartPreviousClose": 149.0,
              "fiftyTwoWeekLow": 125.0,
              "fiftyTwoWeekHigh": 180.0,
              "fiftyDayAverage": 145.0,
              "twoHundredDayAverage": 140.0,
              "averageDailyVolume3Month": 55000000,
              "averageDailyVolume10Day": 52000000,
              "marketCap": 2500000000000,
              "sharesOutstanding": 16000000000
            }
          }
        ],
        "error": null
      }
    }
    """
    
    let quote = parseQuoteResponse(jsonStr)
    check quote.symbol == "AAPL"
    check quote.regularMarketPrice == 150.0
    check quote.currency == "USD"
    check quote.marketCap == 2500000000000
  
  test "parseQuoteResponse with missing optional fields":
    let jsonStr = """
    {
      "chart": {
        "result": [
          {
            "meta": {
              "symbol": "TEST",
              "currency": "USD",
              "regularMarketPrice": 100.0,
              "regularMarketTime": 1704398400
            }
          }
        ],
        "error": null
      }
    }
    """
    
    let quote = parseQuoteResponse(jsonStr)
    check quote.symbol == "TEST"
    check quote.regularMarketPrice == 100.0
  
  test "parseQuoteResponse with empty result raises error":
    let jsonStr = """
    {
      "chart": {
        "result": [],
        "error": null
      }
    }
    """
    
    expect(QuoteError):
      discard parseQuoteResponse(jsonStr)
  
  test "parseQuoteResponse with API error":
    let jsonStr = """
    {
      "chart": {
        "result": null,
        "error": "Invalid symbol"
      }
    }
    """
    
    expect(QuoteError):
      discard parseQuoteResponse(jsonStr)
  
  test "parseQuoteResponse with missing chart field raises error":
    let jsonStr = """
    {
      "error": "Something went wrong"
    }
    """
    
    expect(JsonParsingError):
      discard parseQuoteResponse(jsonStr)
  
  test "parseQuoteResponse with invalid JSON raises error":
    let jsonStr = "{ invalid json"
    
    expect(JsonParsingError):
      discard parseQuoteResponse(jsonStr)

