# Installation Guide - yf CLI Tool

This guide covers how to install the `yf` command-line tool.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation Methods](#installation-methods)
- [Verifying Installation](#verifying-installation)
- [Troubleshooting](#troubleshooting)
- [Updating](#updating)
- [Uninstallation](#uninstallation)

## Prerequisites

### Required

**Nim Compiler**

You need Nim version 2.2.6 or later.

Check if Nim is installed:
```bash
nim --version
```

If Nim is not installed, visit https://nim-lang.org/install.html

**Nimble Package Manager**

Nimble is included with Nim. Verify it's available:
```bash
nimble --version
```

**SSL Support**

The tool requires SSL/TLS support for HTTPS connections to Yahoo Finance.

On Linux:
```bash
# Ubuntu/Debian
sudo apt-get install libssl-dev

# Fedora/RHEL
sudo dnf install openssl-devel

# Arch Linux
sudo pacman -S openssl
```

On macOS:
```bash
# OpenSSL is usually pre-installed
# If needed, install via Homebrew:
brew install openssl
```

On Windows:
- SSL support is typically included with the Nim installer

## Installation Methods

### Method 1: From Nimble (Recommended - Not Yet Available)

Once published to the Nimble package registry:

```bash
nimble install yfnim
```

This will download, compile, and install the `yf` binary to your system.

**Note:** The package is not yet published to the Nimble registry. Use Method 2 or 3 instead.

### Method 2: From Source (Current Method)

Clone the repository and build:

```bash
# Clone the repository
git clone https://github.com/yourusername/yfnim.git
cd yfnim

# Build the CLI tool
nimble build -d:ssl

# The binary will be in: bin/yf
```

Then either:

**Option A:** Add `bin/` to your PATH:
```bash
export PATH="$PWD/bin:$PATH"

# To make permanent, add to your ~/.bashrc or ~/.zshrc:
echo 'export PATH="/path/to/yfnim/bin:$PATH"' >> ~/.bashrc
```

**Option B:** Copy the binary to a system directory:
```bash
sudo cp bin/yf /usr/local/bin/
```

**Option C:** Create a symlink:
```bash
sudo ln -s "$PWD/bin/yf" /usr/local/bin/yf
```

### Method 3: Direct Installation with Nimble

From the cloned repository:

```bash
cd yfnim
nimble install
```

This installs the `yf` binary to `~/.nimble/bin/`.

Make sure `~/.nimble/bin` is in your PATH:
```bash
export PATH="$HOME/.nimble/bin:$PATH"

# Add to ~/.bashrc or ~/.zshrc to make permanent
echo 'export PATH="$HOME/.nimble/bin:$PATH"' >> ~/.bashrc
```

## Verifying Installation

Test that `yf` is installed and accessible:

```bash
# Check if command is found
which yf

# Run the tool (should show usage help)
yf

# Get a simple quote to verify it works
yf quote AAPL
```

If successful, you should see Apple's current stock price and market data.

## Build Options

### Development Build

For development and testing:
```bash
nimble build -d:ssl
```

### Release Build

For production use with optimizations:
```bash
nimble build -d:ssl -d:release
```

This produces a faster, optimized binary.

### Custom Build Location

To install to a specific directory:
```bash
nim c -d:ssl --out:/custom/path/yf src/cli/yf.nim
```

## Troubleshooting

### "yf: command not found"

**Cause:** The `yf` binary is not in your PATH.

**Solution:**
1. Find where `yf` is installed:
   ```bash
   find ~ -name yf -type f 2>/dev/null
   ```

2. Add that directory to your PATH or copy `yf` to `/usr/local/bin/`

### "Error: undeclared identifier: 'newHttpClient'"

**Cause:** The binary was not compiled with SSL support.

**Solution:** Rebuild with the `-d:ssl` flag:
```bash
nimble build -d:ssl
```

### "could not load: libssl.so"

**Cause:** OpenSSL development libraries are not installed.

**Solution:**
```bash
# Ubuntu/Debian
sudo apt-get install libssl-dev

# Fedora/RHEL
sudo dnf install openssl-devel
```

Then rebuild:
```bash
nimble build -d:ssl
```

### Build Fails with "Error: cannot open file"

**Cause:** Missing source files or wrong directory.

**Solution:** Make sure you're in the `yfnim` repository root directory and all source files are present:
```bash
ls src/cli/yf.nim  # Should exist
```

### Permission Denied

**Cause:** Trying to copy to a system directory without proper permissions.

**Solution:** Use `sudo`:
```bash
sudo cp bin/yf /usr/local/bin/
```

Or install to a user-writable location like `~/.local/bin/`:
```bash
mkdir -p ~/.local/bin
cp bin/yf ~/.local/bin/
export PATH="$HOME/.local/bin:$PATH"
```

## Updating

### From Source

```bash
cd yfnim
git pull
nimble build -d:ssl
```

If you installed via `nimble install`, run:
```bash
nimble install --force
```

### From Nimble (When Available)

```bash
nimble refresh
nimble install yfnim
```

## Uninstallation

### If Installed via Nimble

```bash
nimble uninstall yfnim
```

### If Built from Source

Remove the binary:
```bash
# If copied to /usr/local/bin
sudo rm /usr/local/bin/yf

# If symlinked
sudo rm /usr/local/bin/yf

# If using ~/.nimble/bin
rm ~/.nimble/bin/yf
```

Remove the source directory:
```bash
rm -rf /path/to/yfnim
```

## Platform-Specific Notes

### Linux

Installation should work on all major distributions. Make sure you have the development tools installed:

```bash
# Ubuntu/Debian
sudo apt-get install build-essential libssl-dev

# Fedora/RHEL
sudo dnf groupinstall "Development Tools"
sudo dnf install openssl-devel
```

### macOS

The tool should work on macOS 10.13 (High Sierra) and later. If you encounter SSL issues:

```bash
brew install openssl
export DYLD_LIBRARY_PATH="/usr/local/opt/openssl/lib:$DYLD_LIBRARY_PATH"
```

### Windows

Building on Windows requires:
1. Install Nim from https://nim-lang.org/install_windows.html
2. Use a compatible compiler (MinGW recommended)
3. Build from command prompt or PowerShell:
   ```powershell
   nimble build -d:ssl
   ```

The resulting `yf.exe` will be in the `bin` directory.

## Next Steps

After installation:

1. **[Quick Start Guide](quick-start.md)** - Learn basic commands in 5 minutes
2. **[Commands Reference](commands.md)** - Complete command documentation
3. **[Example Scripts](../../examples/cli/)** - Working example scripts

## Getting Help

If you encounter issues:

1. Check the [Troubleshooting](#troubleshooting) section above
2. Search existing issues: https://github.com/yourusername/yfnim/issues
3. Open a new issue with:
   - Your operating system and version
   - Nim version (`nim --version`)
   - Full error message
   - Steps to reproduce

## Configuration

The `yf` tool works out of the box without configuration. However, you can create a configuration file for commonly used options (feature in development).

Default behavior:
- Output format: table
- Caching: enabled (in-memory, 5-minute TTL)
- No configuration file required
