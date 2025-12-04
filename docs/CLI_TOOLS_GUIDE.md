# CLI/TUI Tools Guide

Quick reference for modern CLI/TUI tools included in this dotfiles setup.

## Documentation & Viewing

### glow - Markdown Renderer

Render markdown files beautifully in the terminal.

**Aliases:** `mdcat`, `mdview`

```bash
# View a markdown file
glow README.md

# Pager mode
glow -p DOCUMENTATION.md
mdview DOCUMENTATION.md

# View from URL
glow https://raw.githubusercontent.com/user/repo/main/README.md

# View all markdown in directory
glow docs/
```

### tldr - Simplified Man Pages

Quick, practical examples for common commands.

```bash
# Get examples for a command
tldr git
tldr docker
tldr curl

# Update local cache
tldr --update
```

## Data Processing

### yq - YAML/TOML Processor

Process YAML and TOML files like jq does for JSON.

**Alias:** `yaml`

```bash
# Query YAML file
yq '.spec.containers[0].image' deployment.yaml

# Convert YAML to JSON
yq -o json '.' config.yaml

# Merge YAML files
yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' file1.yaml file2.yaml

# Update YAML in-place
yq -i '.version = "2.0"' config.yaml
```

### jless - Interactive JSON Viewer

Navigate and explore JSON data interactively.

**Alias:** `jv`

```bash
# View JSON file
jless data.json
cat large-file.json | jless

# View API response
curl https://api.github.com/users/octocat | jless

# Navigate with vim keybindings
# j/k - move up/down
# / - search
# q - quit
```

## HTTP & API Tools

### xh - Better HTTP Client

Simpler, more intuitive than curl.

**Alias:** `http`

```bash
# GET request
xh GET https://api.example.com/users

# POST JSON
xh POST https://api.example.com/users name=John email=john@example.com

# POST from file
xh POST https://api.example.com/data < payload.json

# Custom headers
xh GET https://api.example.com/protected Authorization:"Bearer token123"

# Form data
xh --form POST https://api.example.com/upload file@document.pdf

# Download file
xh GET https://example.com/file.zip --download
```

## Performance & Benchmarking

### hyperfine - Command Benchmarking

Statistical analysis of command execution times.

```bash
# Compare two commands
hyperfine 'rg pattern' 'grep -r pattern'

# Benchmark with warmup
hyperfine --warmup 3 'npm run build'

# Export results
hyperfine --export-markdown results.md 'command1' 'command2'

# Set number of runs
hyperfine --runs 10 'node script.js'

# Prepare command before each run
hyperfine --prepare 'rm -rf dist' 'npm run build'
```

## System Monitoring

### dust - Disk Usage

Visual tree view of disk usage.

**Alias:** `disk`

```bash
# View current directory
dust

# Specific directory
dust ~/Projects

# Show top N entries
dust -n 20

# Limit depth
dust -d 3

# Reverse sort (smallest first)
dust -r

# Filter by file type
dust -t d  # directories only
```

### procs - Process Viewer

Modern process viewer with colors and tree view.

**Alias:** `pls`

```bash
# List all processes
procs

# Filter by name
procs node
procs python

# Tree view
procs --tree

# Sort by CPU
procs --sortd cpu

# Sort by memory
procs --sortd mem

# Watch mode (like top)
procs --watch
```

## Database Tools

### lazysql - Database TUI

Terminal UI for database management.

**Supported databases:** PostgreSQL, MySQL, SQLite, MSSQL (via external tools), Redis (via external tools)

```bash
# Connect to PostgreSQL
lazysql -h localhost -u postgres -p 5432 -d mydb

# Connect to MySQL
lazysql -h localhost -u root -p 3306 -d mydb --driver mysql

# Connect to SQLite
lazysql --driver sqlite3 --database ./data.db

# Navigation:
# Tab - switch panels
# Enter - execute query
# Ctrl+r - refresh
# q - quit
```

**Note:** For MSSQL and Redis, you may need additional CLI tools or connection strings. Check lazysql documentation for details.

## Cloud Tools

### wrangler - Cloudflare Workers

Deploy and manage Cloudflare Workers.

```bash
# Initialize new worker
wrangler init my-worker

# Start dev server
wrangler dev

# Deploy to Cloudflare
wrangler deploy

# Tail logs
wrangler tail

# Deploy to environment
wrangler deploy --env production

# See full cheatsheet
navi --query "cloudflare"
```

### gcloud - Google Cloud Platform

Manage GCP resources (minimal install - gcloud CLI only).

```bash
# Initialize
gcloud init

# Set project
gcloud config set project my-project

# List compute instances
gcloud compute instances list

# SSH into instance
gcloud compute ssh instance-name

# Deploy Cloud Run
gcloud run deploy service-name --image gcr.io/project/image

# See full cheatsheet
navi --query "gcp"
```

## Tips & Tricks

### Combining Tools

```bash
# Benchmark different JSON processors
hyperfine 'cat data.json | jq .' 'cat data.json | jless'

# Find largest directories in nix store
dust -n 10 /nix/store

# View API response with better tools
xh GET https://api.github.com/users/octocat | jless

# Process YAML and view as JSON
yq -o json '.' deployment.yaml | jless

# Pretty print YAML from API
xh GET https://api.example.com/config | yq -P

# Check which processes use most memory
procs --sortd mem | head -10
```

### Integration with Existing Tools

```bash
# Use with ripgrep and glow
rg "TODO" --files-with-matches | xargs glow

# Use with fd and dust
fd -t d | xargs -I {} dust {}

# HTTP testing in scripts
if xh GET https://api.example.com/health --check-status; then
    echo "API is healthy"
fi

# Benchmark nix builds
hyperfine --warmup 1 'nix build .#homeConfigurations.chrisloidolt.activationPackage'
```

### Alias Quick Reference

All aliases are defined in `home/programs/zsh.nix`:

- `mdcat` → `glow` - Render markdown
- `mdview` → `glow -p` - Markdown in pager mode
- `yaml` → `yq` - YAML queries
- `jv` → `jless` - Interactive JSON viewer
- `disk` → `dust` - Disk usage
- `pls` → `procs` - Process list
- `http` → `xh` - HTTP requests

## Learning More

- `tldr <command>` - Quick examples for any command
- `<command> --help` - Full documentation
- `navi` - Interactive cheatsheet browser
- `navi --query <topic>` - Search cheatsheets
- Check `configs/navi/cheats/` for custom cheatsheets

## Available Cheatsheets

Navigate to cheatsheets with `navi`:

- `dev.cheat` - Development tools and utilities
- `docker.cheat` - Docker commands
- `git.cheat` - Git workflows
- `cloudflare.cheat` - Cloudflare Workers with wrangler
- `gcp.cheat` - Google Cloud Platform
- `nix.cheat` - Nix and Home Manager
- `system.cheat` - System administration
- `network.cheat` - Networking tools

## Tool Comparison

### Why these tools over traditional ones?

| Traditional | Modern Tool | Why? |
|-------------|-------------|------|
| `grep` | `ripgrep` | 10-100x faster, better defaults |
| `find` | `fd` | Simpler syntax, respects .gitignore |
| `cat` | `bat` | Syntax highlighting, git integration |
| `ls` | `eza` | Colors, icons, git status |
| `cd` | `zoxide` | Jump to frequent directories |
| `du` | `dust` | Visual tree, easier to read |
| `ps` | `procs` | Colored output, better filtering |
| `curl` | `xh` | Simpler syntax for APIs |
| `time` | `hyperfine` | Statistical analysis |
| `man` | `tldr` | Quick examples first |

## Project Templates

Use the Cloudflare Workers template for quick project setup:

```bash
# Copy template
cp -r ~/dotfiles/project-templates/cloudflare my-worker
cd my-worker

# Start devbox environment
devbox shell

# Initialize and develop
devbox run init
devbox run dev
```

See `project-templates/cloudflare/README.md` for full details.

## Troubleshooting

### Tool not found after installation

```bash
# Rebuild home-manager
hm

# Check if tool is in PATH
which glow
which xh

# Verify package is in packages.nix
cat ~/dotfiles/home/packages.nix | grep glow
```

### Alias not working

```bash
# Reload shell
source ~/.zshrc

# Or start new shell
exec zsh

# Check alias definition
alias | grep mdcat
```

### Performance issues

```bash
# Check disk space (nix store can grow large)
disk /nix/store

# Clean old generations
nix-collect-garbage -d

# Check system resources
btop
```

## Additional Resources

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Package Search](https://search.nixos.org/packages)
- [Modern Unix Tools](https://github.com/ibraheemdev/modern-unix)
- Main README: `~/dotfiles/README.md`
- Setup guide: `~/dotfiles/docs/SETUP.md`
