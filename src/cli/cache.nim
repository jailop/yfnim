## Cache Module for CLI
##
## Provides caching functionality to reduce API calls and improve performance.
## Caches are stored in ~/.cache/yfnim/ with TTL support.

import std/[tables, times, os, json, strutils, hashes, options]
import ../yfnim/[types as ytypes, quote_types]
import types

type
  CacheEntry[T] = object
    data: T
    timestamp: int64
  
  Cache* = ref object
    enabled*: bool
    ttl*: int64  # Time to live in seconds
    cacheDir*: string
    historyCache: Table[string, CacheEntry[History]]
    quoteCache: Table[string, CacheEntry[Quote]]

proc hash(interval: Interval): Hash =
  ## Hash function for Interval enum
  result = hash(ord(interval))

proc newCache*(enabled: bool = true, ttl: int64 = 300): Cache =
  ## Create new cache instance
  ##
  ## Args:
  ##   enabled: Whether caching is enabled
  ##   ttl: Time to live in seconds (default: 5 minutes)
  result = Cache(
    enabled: enabled,
    ttl: ttl,
    cacheDir: getHomeDir() / ".cache" / "yfnim",
    historyCache: initTable[string, CacheEntry[History]](),
    quoteCache: initTable[string, CacheEntry[Quote]]()
  )
  
  # Create cache directory if it doesn't exist
  if enabled and not dirExists(result.cacheDir):
    createDir(result.cacheDir)

proc makeCacheKey(symbol: string, interval: Interval, startTime: int64, endTime: int64): string =
  ## Create cache key for history data
  result = symbol & "_" & $interval & "_" & $startTime & "_" & $endTime

proc makeCacheKey(symbol: string): string =
  ## Create cache key for quote data
  result = symbol

proc isExpired(entry: CacheEntry, ttl: int64): bool =
  ## Check if cache entry is expired
  let now = getTime().toUnix()
  result = (now - entry.timestamp) > ttl

proc getCachedHistory*(cache: Cache, symbol: string, interval: Interval, startTime: int64, endTime: int64): Option[History] =
  ## Get cached history data if available and not expired
  if not cache.enabled:
    return none(History)
  
  let key = makeCacheKey(symbol, interval, startTime, endTime)
  if cache.historyCache.hasKey(key):
    let entry = cache.historyCache[key]
    if not entry.isExpired(cache.ttl):
      return some(entry.data)
    else:
      # Remove expired entry
      cache.historyCache.del(key)
  
  return none(History)

proc setCachedHistory*(cache: Cache, symbol: string, interval: Interval, startTime: int64, endTime: int64, history: History) =
  ## Store history data in cache
  if not cache.enabled:
    return
  
  let key = makeCacheKey(symbol, interval, startTime, endTime)
  cache.historyCache[key] = CacheEntry[History](
    data: history,
    timestamp: getTime().toUnix()
  )

proc getCachedQuote*(cache: Cache, symbol: string): Option[Quote] =
  ## Get cached quote data if available and not expired
  if not cache.enabled:
    return none(Quote)
  
  let key = makeCacheKey(symbol)
  if cache.quoteCache.hasKey(key):
    let entry = cache.quoteCache[key]
    if not entry.isExpired(cache.ttl):
      return some(entry.data)
    else:
      # Remove expired entry
      cache.quoteCache.del(key)
  
  return none(Quote)

proc setCachedQuote*(cache: Cache, symbol: string, quote: Quote) =
  ## Store quote data in cache
  if not cache.enabled:
    return
  
  let key = makeCacheKey(symbol)
  cache.quoteCache[key] = CacheEntry[Quote](
    data: quote,
    timestamp: getTime().toUnix()
  )

proc clearCache*(cache: Cache) =
  ## Clear all cached data
  cache.historyCache.clear()
  cache.quoteCache.clear()

proc getCacheStats*(cache: Cache): tuple[historyCount: int, quoteCount: int] =
  ## Get cache statistics
  result = (
    historyCount: cache.historyCache.len,
    quoteCount: cache.quoteCache.len
  )
