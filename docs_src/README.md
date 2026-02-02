# MkDocs Documentation

This directory contains the source files for yfnim's documentation, built with [MkDocs](https://www.mkdocs.org/) and the [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) theme.

## Quick Start

### 1. Install Dependencies

```bash
pip install -r requirements-docs.txt
```

Or install globally:

```bash
pip install mkdocs mkdocs-material pymdown-extensions mkdocs-minify-plugin
```

### 2. Preview Documentation

Start a local development server:

```bash
mkdocs serve
```

Or use the build script:

```bash
./scripts/build-docs.sh serve
```

Then visit http://127.0.0.1:8000 in your browser.

### 3. Build Documentation

Generate static HTML files:

```bash
mkdocs build
```

Or use the build script:

```bash
./scripts/build-docs.sh build
```

The built documentation will be in the `docs/` directory.

## Documentation Structure

```
docs_src/
├── index.md              # Home page
├── getting-started.md    # Getting started overview
├── installation.md       # Installation guide
├── changelog.md          # Changelog
├── license.md            # License information
├── api/
│   └── index.md         # API reference
├── library/
│   ├── getting-started.md
│   ├── historical-data.md
│   └── quote-data.md
└── cli/
    ├── installation.md
    ├── quick-start.md
    ├── commands.md
    └── screening.md
```

## Build Script

The `scripts/build-docs.sh` script provides convenient commands:

```bash
# Build static documentation
./scripts/build-docs.sh build

# Start development server
./scripts/build-docs.sh serve

# Deploy to GitHub Pages (if configured)
./scripts/build-docs.sh deploy

# Clean build artifacts
./scripts/build-docs.sh clean
```

## Configuration

The documentation is configured in `mkdocs.yml` at the project root.

### Key Settings

- **Theme**: Material for MkDocs
- **Source Directory**: `docs_src/`
- **Output Directory**: `docs/`
- **Site URL**: https://codeberg.org/jailop/yfnim

## Features

- 📱 **Responsive design** - Works on mobile, tablet, and desktop
- 🌓 **Dark mode** - Automatic light/dark theme switching
- 🔍 **Search** - Full-text search across all documentation
- 📊 **Code highlighting** - Syntax highlighting for Nim and other languages
- 📋 **Copy buttons** - Easy code copying
- 🔗 **Deep linking** - Permanent links to sections
- 📱 **Mobile-friendly** - Optimized for all devices

## Writing Documentation

### Markdown Features

The documentation supports extended Markdown features via `pymdownx`:

#### Code Blocks

````markdown
```nim
import yfnim
let quote = getQuote("AAPL")
echo quote.regularMarketPrice
```
````

#### Admonitions

```markdown
!!! note "Important"
    This is an important note.

!!! warning
    This is a warning.

!!! tip
    This is a helpful tip.
```

#### Tabs

```markdown
=== "Ubuntu/Debian"

    ```bash
    sudo apt-get install libssl-dev
    ```

=== "macOS"

    ```bash
    brew install openssl
    ```
```

#### Tables

```markdown
| Command | Purpose |
|---------|---------|
| `quote` | Get quotes |
| `history` | Get historical data |
```

### Adding New Pages

1. Create a new `.md` file in `docs_src/` or appropriate subdirectory
2. Add the page to the `nav` section in `mkdocs.yml`
3. Test with `mkdocs serve`

## Deployment

### Manual Deployment

Build the docs:

```bash
mkdocs build
```

The static site will be in the `docs/` directory, ready to deploy to any web server.

### GitHub Pages

If you're using GitHub, you can deploy directly:

```bash
mkdocs gh-deploy
```

Or use the script:

```bash
./scripts/build-docs.sh deploy
```

### Other Hosting

The built `docs/` directory contains a complete static website. You can:

- Upload to any web server
- Deploy to Netlify, Vercel, or similar
- Serve with nginx, Apache, etc.

## Development

### Live Reload

When running `mkdocs serve`, the documentation auto-reloads when you save changes to any `.md` file.

### Checking Links

Make sure all internal links work:

```bash
mkdocs build --strict
```

This will fail if there are any broken links or references.

### Debugging

To see detailed build information:

```bash
mkdocs build --verbose
```

## Troubleshooting

### "mkdocs: command not found"

Install MkDocs:

```bash
pip install -r requirements-docs.txt
```

### Theme not found

Make sure Material for MkDocs is installed:

```bash
pip install mkdocs-material
```

### Changes not showing

1. Stop the dev server (Ctrl+C)
2. Clear the build: `./scripts/build-docs.sh clean`
3. Restart: `mkdocs serve`

## Resources

- [MkDocs Documentation](https://www.mkdocs.org/)
- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)
- [PyMdown Extensions](https://facelessuser.github.io/pymdown-extensions/)

## Contributing

When contributing to the documentation:

1. Write in clear, simple English
2. Use code examples liberally
3. Test all code examples
4. Preview changes with `mkdocs serve`
5. Ensure no broken links with `mkdocs build --strict`
6. Follow the existing style and structure
