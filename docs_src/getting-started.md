# Getting Started with yfnim

yfnim provides both a library and CLI tool for accessing Yahoo Finance data. Choose your path:

## For Command-Line Users (CLI Tool)

If you want to access market data from the terminal:

**[CLI Quick Start Guide](cli/quick-start.md)**

- Install the `yf` command-line tool
- Learn basic commands
- Export data to CSV/JSON
- Screen stocks and analyze trends

```bash
# Get current quotes
yf quote AAPL MSFT GOOGL

# Get historical data
yf history AAPL --lookback 30d

# Screen stocks
yf screen AAPL MSFT --criteria value
```

## For Developers (Library)

If you want to integrate Yahoo Finance data into your Nim applications:

**[Library Getting Started Guide](library/getting-started.md)**

- Learn how to install and use the yfnim library
- Fetch historical OHLCV data
- Get real-time quotes
- Type-safe API with minimal dependencies

```nim
import yfnim
import std/times

let endTime = getTime().toUnix()
let startTime = endTime - (7 * 86400)
let history = getHistory("AAPL", Int1d, startTime, endTime)

echo "Retrieved ", history.data.len, " records"
```

## Installation

```bash
git clone https://codeberg.org/jailop/yfnim.git
cd yfnim
nimble build -d:ssl
nimble install
```

## What's Next?

- **Library Users**: Start with [Library Getting Started](library/getting-started.md)
- **CLI Users**: Start with [CLI Installation](cli/installation.md) then [CLI Quick Start](cli/quick-start.md)
- **Everyone**: Check out the [API Reference](api/index.md)

## Quick Links

- [Installation](installation.md)
- [Library Documentation](library/getting-started.md)
- [CLI Documentation](cli/quick-start.md)
- [API Reference](api/index.md)
- [Changelog](changelog.md)
