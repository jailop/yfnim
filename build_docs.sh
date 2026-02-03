#!/bin/bash
# Documentation Build Script for yfnim
# Generates API documentation and builds mkdocs site

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_SRC="$PROJECT_ROOT/docs_src"
DOCS_OUT="$PROJECT_ROOT/docs"
API_DIR="$DOCS_SRC/api"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  yfnim Documentation Builder${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check for required tools
check_tool() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}✗${NC} $1 not found"
        return 1
    else
        echo -e "${GREEN}✓${NC} $1 found"
        return 0
    fi
}

echo "Checking dependencies..."
MISSING=0

if ! check_tool nim; then
    echo "  Install: https://nim-lang.org/install.html"
    MISSING=1
fi

if ! check_tool mkdocs; then
    echo "  Install: pip install mkdocs-material"
    MISSING=1
fi

if [ $MISSING -eq 1 ]; then
    echo ""
    echo -e "${RED}Missing required tools. Please install them first.${NC}"
    exit 1
fi

echo ""

# Step 1: Generate API documentation from source code
echo -e "${YELLOW}Step 1:${NC} Generating API documentation from Nim source..."
echo ""

# Create API docs directory if it doesn't exist
mkdir -p "$API_DIR"

# Generate HTML documentation for main modules
echo "  Generating docs for core modules..."

nim doc \
    --project \
    --index:on \
    --git.url:https://codeberg.org/jailop/yfnim \
    --git.commit:main \
    --outdir:"$API_DIR" \
    src/yfnim.nim 2>&1 | grep -v "Hint:" || true

nim doc \
    --git.url:https://codeberg.org/jailop/yfnim \
    --git.commit:main \
    --outdir:"$API_DIR" \
    src/yfnim/types.nim 2>&1 | grep -v "Hint:" || true

nim doc \
    --git.url:https://codeberg.org/jailop/yfnim \
    --git.commit:main \
    --outdir:"$API_DIR" \
    src/yfnim/retriever.nim 2>&1 | grep -v "Hint:" || true

nim doc \
    --git.url:https://codeberg.org/jailop/yfnim \
    --git.commit:main \
    --outdir:"$API_DIR" \
    src/yfnim/quote_retriever.nim 2>&1 | grep -v "Hint:" || true

echo -e "${GREEN}✓${NC} API documentation generated"
echo ""

# Step 2: Generate CLI help documentation
echo -e "${YELLOW}Step 2:${NC} Generating CLI command help..."
echo ""

# Build yf if not already built
if [ ! -f "bin/yf" ]; then
    echo "  Building yf CLI tool..."
    nimble build -d:ssl --quiet 2>&1 | tail -1
fi

# Generate help text for each command
CLI_COMMANDS_DOC="$DOCS_SRC/cli/command-reference.md"

cat > "$CLI_COMMANDS_DOC" << 'HEADER'
# Command Reference

This page contains the complete reference for all yf CLI commands.

## Global Options

These options can be used with any command:

- `-f, --format=FORMAT` - Output format: table, csv, json, tsv, minimal (default: table)
- `-v, --verbose` - Show progress and informational messages
- `-n, --no-header` - Omit header row in output
- `--no-color` - Disable colored output
- `-p, --precision=N` - Decimal precision for prices (default: 2)
- `-d, --date-format=FORMAT` - Date format: iso, us, unix, full (default: iso)
- `-h, --help` - Show help for the command

## Commands

HEADER

# Generate help for each command
for cmd in history quote compare download dividends splits actions indicators screen; do
    echo "  Generating help for: $cmd"
    
    # Add command section
    cat >> "$CLI_COMMANDS_DOC" << EOF

### $cmd

\`\`\`
EOF
    
    # Get help text (suppress stderr)
    ./bin/yf "$cmd" --help 2>/dev/null >> "$CLI_COMMANDS_DOC" || true
    
    # Close code block
    echo '```' >> "$CLI_COMMANDS_DOC"
done

echo -e "${GREEN}✓${NC} CLI command reference generated"
echo ""

# Step 3: Update changelog with latest version info
echo -e "${YELLOW}Step 3:${NC} Checking changelog..."
if [ -f "CHANGELOG.md" ]; then
    cp CHANGELOG.md "$DOCS_SRC/changelog.md"
    echo -e "${GREEN}✓${NC} Changelog updated"
else
    echo -e "${YELLOW}⚠${NC} CHANGELOG.md not found, skipping"
fi
echo ""

# Step 4: Build mkdocs site
echo -e "${YELLOW}Step 4:${NC} Building mkdocs site..."
echo ""

if mkdocs build --clean 2>&1 | grep -v "INFO"; then
    echo ""
    echo -e "${GREEN}✓${NC} Documentation built successfully"
    echo ""
    echo -e "Output: ${BLUE}$DOCS_OUT${NC}"
else
    echo ""
    echo -e "${RED}✗${NC} mkdocs build failed"
    exit 1
fi

# Step 5: Summary
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Documentation build complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Generated files:"
echo "  • API docs:      $API_DIR/"
echo "  • CLI reference: $CLI_COMMANDS_DOC"
echo "  • Site output:   $DOCS_OUT/"
echo ""
echo "To preview the site locally:"
echo -e "  ${BLUE}mkdocs serve${NC}"
echo ""
echo "Then open: http://127.0.0.1:8000"
echo ""
