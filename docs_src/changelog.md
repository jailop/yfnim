# Changelog

All notable changes to yfnim will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2024

### Added

- New `dividends` command - Get dividend payment history
- New `splits` command - Get stock split history
- New `actions` command - Get all corporate actions (dividends + splits)
- New `indicators` command - Calculate technical indicators
- Technical analysis support:
  - SMA (Simple Moving Average)
  - EMA (Exponential Moving Average)
  - RSI (Relative Strength Index)
  - MACD (Moving Average Convergence Divergence)
  - Bollinger Bands
  - ATR (Average True Range)
  - And more...

### Changed

- Improved error handling and messages
- Enhanced documentation

## [0.1.0] - 2024

### Added

- First usable version
- Library for Yahoo Finance data retrieval
- CLI tool (`yf`) with basic commands:
  - `history` - Historical price data
  - `quote` - Current quotes
  - `compare` - Compare stocks
  - `screen` - Filter stocks
  - `download` - Batch download
- Support for multiple time intervals (1m, 5m, 15m, 30m, 1h, 1d, 1wk, 1mo)
- Multiple output formats (table, CSV, JSON, TSV, minimal)
- Stock screening with custom expressions
- In-memory caching
- Type-safe API
- JSON serialization support

### Features

- Historical OHLCV data retrieval
- Real-time/delayed quote data
- Unix-friendly command-line interface
- Works with standard Unix tools (pipes, grep, awk, etc.)

## [Unreleased]

### Planned

- Nimble package registry publication
- More technical indicators
- Configuration file support
- Watchlist management
- Historical data caching
- Rate limiting support

---

For a detailed list of changes, see the [git commit history](https://codeberg.org/jailop/yfnim/commits/branch/main).
