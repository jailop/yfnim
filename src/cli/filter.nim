## Expression Parser for Custom Screening
##
## Parses and evaluates custom filter expressions for stock screening.
## Supports simple comparison expressions with boolean operators.
##
## Example expressions:
##   pe < 20
##   pe < 20 and yield > 2
##   price > 100 and volume > 1000000
##   (pe < 15 or pb < 2) and yield > 3

import std/[strutils, sequtils, tables, options]
import ../yfnim/quote_types

type
  TokenKind* = enum
    TokNumber
    TokIdentifier
    TokOperator     # <, >, <=, >=, =, !=
    TokAnd
    TokOr
    TokLParen
    TokRParen
    TokEOF
  
  Token* = object
    kind*: TokenKind
    value*: string
  
  ExprNodeKind* = enum
    NodeNumber
    NodeIdentifier
    NodeComparison
    NodeAnd
    NodeOr
  
  ExprNode* = ref object
    case kind*: ExprNodeKind
    of NodeNumber:
      numValue*: float64
    of NodeIdentifier:
      idValue*: string
    of NodeComparison:
      op*: string
      left*, right*: ExprNode
    of NodeAnd, NodeOr:
      leftExpr*, rightExpr*: ExprNode
  
  ParseError* = object of CatchableError

proc tokenize*(expr: string): seq[Token] =
  ## Tokenize expression string
  result = @[]
  var i = 0
  
  while i < expr.len:
    let c = expr[i]
    
    # Skip whitespace
    if c in Whitespace:
      i.inc
      continue
    
    # Numbers (including negative)
    if c.isDigit or c == '.' or (c == '-' and i + 1 < expr.len and expr[i + 1].isDigit):
      var numStr = ""
      if c == '-':
        numStr.add(c)
        i.inc
      while i < expr.len and (expr[i].isDigit or expr[i] == '.'):
        numStr.add(expr[i])
        i.inc
      result.add(Token(kind: TokNumber, value: numStr))
      continue
    
    # Identifiers
    if c.isAlphaAscii:
      var idStr = ""
      while i < expr.len and (expr[i].isAlphaAscii or expr[i].isDigit or expr[i] == '_'):
        idStr.add(expr[i])
        i.inc
      
      # Check for keywords
      case idStr.toLower()
      of "and":
        result.add(Token(kind: TokAnd, value: "and"))
      of "or":
        result.add(Token(kind: TokOr, value: "or"))
      else:
        result.add(Token(kind: TokIdentifier, value: idStr.toLower()))
      continue
    
    # Operators
    if c == '<':
      if i + 1 < expr.len and expr[i + 1] == '=':
        result.add(Token(kind: TokOperator, value: "<="))
        i += 2
      else:
        result.add(Token(kind: TokOperator, value: "<"))
        i.inc
      continue
    
    if c == '>':
      if i + 1 < expr.len and expr[i + 1] == '=':
        result.add(Token(kind: TokOperator, value: ">="))
        i += 2
      else:
        result.add(Token(kind: TokOperator, value: ">"))
        i.inc
      continue
    
    if c == '=':
      if i + 1 < expr.len and expr[i + 1] == '=':
        result.add(Token(kind: TokOperator, value: "="))
        i += 2
      else:
        result.add(Token(kind: TokOperator, value: "="))
        i.inc
      continue
    
    if c == '!':
      if i + 1 < expr.len and expr[i + 1] == '=':
        result.add(Token(kind: TokOperator, value: "!="))
        i += 2
      else:
        raise newException(ParseError, "Unexpected character: " & c)
      continue
    
    # Parentheses
    if c == '(':
      result.add(Token(kind: TokLParen, value: "("))
      i.inc
      continue
    
    if c == ')':
      result.add(Token(kind: TokRParen, value: ")"))
      i.inc
      continue
    
    # Unknown character
    raise newException(ParseError, "Unexpected character: " & c)
  
  result.add(Token(kind: TokEOF, value: ""))

proc getQuoteField(quote: Quote, field: string): Option[float64] =
  ## Extract numeric field value from quote
  case field.toLower()
  of "price", "p":
    return some(quote.regularMarketPrice)
  of "change":
    return some(quote.regularMarketChange)
  of "changepercent", "changepct", "change%":
    return some(quote.regularMarketChangePercent)
  of "volume", "vol":
    return some(quote.regularMarketVolume.float64)
  of "marketcap", "mcap":
    return some(quote.marketCap.float64)
  of "pe":
    return quote.trailingPE
  of "forwardpe", "fpe":
    return quote.forwardPE
  of "pb", "pricetobook":
    return quote.priceToBook
  of "eps":
    return quote.earningsPerShare
  of "yield", "dividendyield", "dy":
    return quote.dividendYield
  of "52whigh":
    return some(quote.fiftyTwoWeekHigh)
  of "52wlow":
    return some(quote.fiftyTwoWeekLow)
  of "52wchange%", "52wchangepct":
    return some(quote.fiftyTwoWeekChangePercent)
  else:
    return none(float64)

proc evaluateComparison(left: float64, op: string, right: float64): bool =
  ## Evaluate a comparison expression
  case op
  of "<": return left < right
  of ">": return left > right
  of "<=": return left <= right
  of ">=": return left >= right
  of "=", "==": return abs(left - right) < 0.0001  # Float equality
  of "!=": return abs(left - right) >= 0.0001
  else:
    raise newException(ParseError, "Unknown operator: " & op)

proc parseComparison(tokens: seq[Token], pos: var int): ExprNode =
  ## Parse a comparison expression: identifier op number
  if pos >= tokens.len:
    raise newException(ParseError, "Unexpected end of expression")
  
  # Expect identifier
  if tokens[pos].kind != TokIdentifier:
    raise newException(ParseError, "Expected identifier, got: " & tokens[pos].value)
  
  let idNode = ExprNode(kind: NodeIdentifier, idValue: tokens[pos].value)
  pos.inc
  
  # Expect operator
  if pos >= tokens.len or tokens[pos].kind != TokOperator:
    raise newException(ParseError, "Expected operator")
  
  let opToken = tokens[pos]
  pos.inc
  
  # Expect number
  if pos >= tokens.len or tokens[pos].kind != TokNumber:
    raise newException(ParseError, "Expected number")
  
  let numNode = ExprNode(kind: NodeNumber, numValue: parseFloat(tokens[pos].value))
  pos.inc
  
  result = ExprNode(kind: NodeComparison, op: opToken.value, left: idNode, right: numNode)

proc parseExpression(tokens: seq[Token], pos: var int): ExprNode =
  ## Parse full expression with AND/OR operators
  var left = parseComparison(tokens, pos)
  
  while pos < tokens.len and tokens[pos].kind in {TokAnd, TokOr}:
    let isAnd = tokens[pos].kind == TokAnd
    pos.inc
    let right = parseComparison(tokens, pos)
    
    # Create new node with proper initialization
    if isAnd:
      let node = ExprNode(kind: NodeAnd)
      node.leftExpr = left
      node.rightExpr = right
      left = node
    else:
      let node = ExprNode(kind: NodeOr)
      node.leftExpr = left
      node.rightExpr = right
      left = node
  
  return left

proc evaluateExpression(node: ExprNode, quote: Quote): bool =
  ## Evaluate expression tree against a quote
  case node.kind
  of NodeComparison:
    # Get field value
    let leftField = getQuoteField(quote, node.left.idValue)
    if leftField.isNone:
      return false  # Field not available, doesn't match
    
    let leftValue = leftField.get()
    let rightValue = node.right.numValue
    
    return evaluateComparison(leftValue, node.op, rightValue)
  
  of NodeAnd:
    return evaluateExpression(node.leftExpr, quote) and evaluateExpression(node.rightExpr, quote)
  
  of NodeOr:
    return evaluateExpression(node.leftExpr, quote) or evaluateExpression(node.rightExpr, quote)
  
  else:
    raise newException(ParseError, "Invalid expression node")

proc evalFilter*(expr: string, quote: Quote): bool =
  ## Main entry point: evaluate filter expression against quote
  ##
  ## Example expressions:
  ##   "pe < 20"
  ##   "pe < 20 and yield > 2"
  ##   "price > 100 and volume > 1000000"
  
  if expr.len == 0:
    return true  # Empty expression matches all
  
  try:
    let tokens = tokenize(expr)
    var pos = 0
    let tree = parseExpression(tokens, pos)
    return evaluateExpression(tree, quote)
  except ParseError as e:
    raise newException(ParseError, "Filter parse error: " & e.msg)
