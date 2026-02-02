# Installation

This page covers installation for both the **library** and the **CLI tool**.

## Library Installation

### Using Nimble (Recommended)

```bash
nimble install yfnim
```

### From Source

```bash
git clone https://codeberg.org/jailop/yfnim.git
cd yfnim
nimble install
```

### Adding to Your Project

Add to your `.nimble` file:

```nim
requires "yfnim"
```

Or install directly:

```bash
nimble install yfnim
```

## CLI Tool Installation

See the detailed [CLI Installation Guide](cli/installation.md) for complete instructions.

### Quick Install (From Source)

```bash
git clone https://codeberg.org/jailop/yfnim.git
cd yfnim
nimble build -d:ssl
nimble install
```

This installs the `yf` command to `~/.nimble/bin/`.

### Verify Installation

```bash
# Check library
nim c -d:ssl -r -e:"import yfnim; echo \"Library OK\""

# Check CLI tool
yf quote AAPL
```

## Prerequisites

### Required

**Nim Compiler** - Version 2.2.6 or later

Check if Nim is installed:
```bash
nim --version
```

If not installed, visit [nim-lang.org/install.html](https://nim-lang.org/install.html)

**Nimble Package Manager**

Nimble comes with Nim. Verify:
```bash
nimble --version
```

### SSL Support

Yahoo Finance requires HTTPS. You need OpenSSL libraries:

=== "Ubuntu/Debian"

    ```bash
    sudo apt-get install libssl-dev
    ```

=== "Fedora/RHEL"

    ```bash
    sudo dnf install openssl-devel
    ```

=== "macOS"

    ```bash
    # Usually pre-installed
    # If needed:
    brew install openssl
    ```

=== "Windows"

    SSL support is included with the Nim installer.

### Compiling with SSL

Always compile with `-d:ssl`:

```bash
nim c -d:ssl your_program.nim
```

## Platform-Specific Notes

### Linux

Works on all major distributions. Install development tools:

```bash
# Ubuntu/Debian
sudo apt-get install build-essential libssl-dev

# Fedora/RHEL
sudo dnf groupinstall "Development Tools"
sudo dnf install openssl-devel
```

### macOS

Works on macOS 10.13 (High Sierra) and later.

### Windows

Building on Windows:

1. Install Nim from [nim-lang.org/install_windows.html](https://nim-lang.org/install_windows.html)
2. Use MinGW (recommended) or MSVC
3. Build from PowerShell or Command Prompt

## Next Steps

- **Library**: [Library Getting Started](library/getting-started.md)
- **CLI Tool**: [CLI Quick Start](cli/quick-start.md)
- **Examples**: Check the `examples/` directory in the repository
