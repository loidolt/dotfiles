# CLI/TUI Tools Enhancement Plan

**Status:** ✅ Implemented - Fix Applied  
**Date:** 2025-12-03  
**Goal:** Add 10 high-value CLI/TUI tools to enhance productivity without adding complexity (wrangler moved to project-specific installation)

**Decisions:**
1. Wrangler: Use latest from nixpkgs
2. Google Cloud SDK: Minimal install (gcloud CLI only)
3. Aliases: Use different names (don't override `du`/`ps`)
4. Databases: PostgreSQL, MSSQL, Redis, MySQL, SQLite
5. Additional tools: None for now

**Implementation Notes:**
- **Wrangler installation approach changed**: Wrangler bundles Prettier, ESLint, and TypeScript which conflict with global installations
- **Solution**: Wrangler is installed per-project via devbox (see project-templates/cloudflare/) instead of globally
- This approach is actually better practice - keeps project tooling isolated
- All Node.js development tools (TypeScript, Prettier, ESLint) remain available globally
- The Cloudflare Workers project template includes wrangler automatically

---

## Overview

This plan adds modern CLI/TUI tools to your dotfiles setup, focusing on tools that complement your existing workflow. The enhancement includes:

- **10 new global packages** (9 CLI tools + gcloud)
- **Wrangler** installed per-project via Cloudflare Workers devbox template
- **7 new shell aliases** for convenience
- **3 new navi cheatsheets** (Cloudflare, GCP, tool updates)
- **1 new project template** (Cloudflare Workers with wrangler)
- **1 comprehensive guide** (CLI Tools Guide)

---

## Phase 1: Package Additions

### File: `home/packages.nix`

**Current tools you have:**
- Modern CLI: `ripgrep`, `fd`, `bat`, `fzf`, `eza`, `zoxide`, `navi`
- Git: `lazygit` + `delta` (configured in git.nix)
- Development: `nodejs_20`, `bun`, `devbox`, `typescript`, `prettier`, `eslint`
- System: `btop`
- Container: `lazydocker`
- Docs: `pandoc`

**New tools to add:**

#### Modern CLI Tools Section
```nix
# Add to line 9, after existing modern CLI tools:
glow yq-go tldr dust hyperfine jless procs xh lazysql
```

**Tool descriptions:**
- `glow` - Markdown renderer for terminal (view your docs/ beautifully)
- `yq-go` - YAML/TOML processor (companion to jq)
- `tldr` - Simplified man pages with practical examples
- `dust` - Disk usage visualization (important for /nix/store management)
- `hyperfine` - Statistical command benchmarking
- `jless` - Interactive JSON viewer/navigator
- `procs` - Modern process viewer with colors
- `xh` - HTTP client with better UX than curl
- `lazysql` - Database TUI client (MySQL/PostgreSQL/SQLite)

#### New Cloud & Infrastructure Section
```nix
# Add new section after Development tools:
# Cloud & Infrastructure
google-cloud-sdk
```

**Tool descriptions:**
- `google-cloud-sdk` - Google Cloud Platform tools (minimal gcloud CLI)

**Note on Wrangler:**
- Wrangler is NOT installed globally due to package conflicts (bundles Prettier, ESLint, TypeScript)
- Instead, wrangler is included in the Cloudflare Workers project template (project-templates/cloudflare/)
- This is better practice - keeps project tooling isolated per-project

**Updated structure:**
```nix
{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # Core utilities
    git curl wget vim tmux tree jq unzip

    # Modern CLI tools
    ripgrep fd bat fzf eza zoxide navi
    glow yq-go tldr dust hyperfine jless procs xh lazysql

    # Development tools
    nodejs_20 bun devbox
    nodePackages.typescript nodePackages.prettier nodePackages.eslint
    lazygit

    # Cloud & Infrastructure
    wrangler
    google-cloud-sdk

    # System monitoring
    btop

    # Network & archive tools
    mosh p7zip

    # Document processing
    pandoc

    # Container management
    lazydocker

  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    # macOS-specific (GNU utils)
    coreutils gnused gnutar watch

  ] ++ lib.optionals pkgs.stdenv.isLinux [
    # Linux-specific
    vscode

    # Fonts (Home Manager manages these on Linux)
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
  ];
}
```

---

## Phase 2: Shell Aliases & Integration

### File: `home/programs/zsh.nix`

**Add new aliases to `shellAliases` section (after line 67):**

```nix
# Documentation & viewing
mdcat = "glow";          # Render markdown
mdview = "glow -p";      # Markdown pager mode

# JSON/YAML tools
yaml = "yq";             # Quick YAML queries
jv = "jless";            # Interactive JSON viewer

# Disk & system
disk = "dust";           # Better disk usage
pls = "procs";           # Better process list (process list)

# HTTP/API tools
http = "xh";             # Simpler curl alternative
```

**Rationale:**
- `mdcat`/`mdview` - Intuitive markdown commands
- `yaml` - Short alias for quick YAML queries
- `jv` - "JSON viewer" - easy to remember
- `disk` - Disk usage without overriding `du`
- `pls` - Process list without overriding `ps`
- `http` - Simpler than remembering curl syntax

**Note:** Traditional `du` and `ps` commands remain available alongside the new tools.

---

## Phase 3: Navi Cheatsheets

### New File: `configs/navi/cheats/cloudflare.cheat`

```
% cloudflare, workers, wrangler

# Create a new Cloudflare Worker project
wrangler init <project_name>

# Start local development server
wrangler dev

# Deploy worker to Cloudflare
wrangler deploy

# Tail worker logs in real-time
wrangler tail

# View worker details
wrangler whoami

# Create a new Worker with TypeScript
wrangler init <project_name> --type=webpack

# Test worker locally with specific environment
wrangler dev --env <environment>

# Deploy to specific environment
wrangler deploy --env <environment>

# View wrangler configuration
cat wrangler.toml

# Run worker tests
wrangler dev --test

# Publish worker with name override
wrangler deploy --name <worker_name>

$ project_name: echo "my-worker my-api my-service worker-api" | tr ' ' '\n'
$ environment: echo "production staging development" | tr ' ' '\n'
$ worker_name: echo "prod-worker staging-worker dev-worker" | tr ' ' '\n'
```

### New File: `configs/navi/cheats/gcp.cheat`

```
% gcp, google-cloud, gcloud

# Initialize gcloud configuration
gcloud init

# List all projects
gcloud projects list

# Set active project
gcloud config set project <project_id>

# List all compute instances
gcloud compute instances list

# SSH into a compute instance
gcloud compute ssh <instance_name> --zone=<zone>

# List Cloud Run services
gcloud run services list

# Deploy Cloud Run service
gcloud run deploy <service_name> --image <image_url> --region <region>

# View logs for Cloud Run service
gcloud logs read --limit 50 --format json | jless

# List Cloud Storage buckets
gcloud storage buckets list

# Copy file to Cloud Storage
gcloud storage cp <local_file> gs://<bucket_name>/

# Download from Cloud Storage
gcloud storage cp gs://<bucket_name>/<remote_file> <local_path>

# Set default region
gcloud config set compute/region <region>

# Get current configuration
gcloud config list

# List all gcloud commands
gcloud help

# Authenticate with service account
gcloud auth activate-service-account --key-file=<key_file>

$ project_id: gcloud projects list --format="value(projectId)" 2>/dev/null || echo "my-project"
$ instance_name: gcloud compute instances list --format="value(name)" 2>/dev/null || echo "instance-1"
$ zone: echo "us-central1-a us-east1-b europe-west1-c asia-east1-a" | tr ' ' '\n'
$ region: echo "us-central1 us-east1 europe-west1 asia-east1" | tr ' ' '\n'
$ service_name: echo "my-service api-service worker-service" | tr ' ' '\n'
$ image_url: echo "gcr.io/project/image:tag"
$ bucket_name: echo "my-bucket data-bucket backups" | tr ' ' '\n'
$ local_file: fd --type f | head -20
$ remote_file: echo "data.json backup.tar.gz config.yaml" | tr ' ' '\n'
$ local_path: echo ". ./downloads /tmp" | tr ' ' '\n'
$ key_file: fd -e json | grep -i service | head -10
```

### Update File: `configs/navi/cheats/dev.cheat`

**Append these commands to the existing file:**

```

# ============================================================
# NEW TOOLS - Added 2025-12-03
# ============================================================

# Render markdown file
glow <markdown_file>

# Render markdown in pager mode
glow -p <markdown_file>

# View markdown from URL
glow https://raw.githubusercontent.com/user/repo/main/README.md

# View all markdown files in directory
glow <directory>

# Query YAML file
yq '.<path>' <yaml_file>

# Convert YAML to JSON
yq -o json '.' <yaml_file>

# Convert JSON to YAML
yq -P '.' <json_file>

# Update YAML in-place
yq -i '.<path> = "<value>"' <yaml_file>

# Merge YAML files
yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' <yaml_file1> <yaml_file2>

# Benchmark command performance
hyperfine '<command1>' '<command2>'

# Benchmark with warmup runs
hyperfine --warmup <runs> '<command>'

# Benchmark and export results to markdown
hyperfine --export-markdown results.md '<command1>' '<command2>'

# Set number of benchmark runs
hyperfine --runs <runs> '<command>'

# Interactive JSON viewer
cat <json_file> | jless

# View JSON from API with jless
curl <api_url> | jless

# Navigate JSON (j/k=up/down, /=search, q=quit)
jless <json_file>

# Better HTTP GET request
xh GET <url>

# POST JSON data
xh POST <url> key=<value>

# POST with JSON file
xh POST <url> < <json_file>

# Add headers to request
xh GET <url> Authorization:<token>

# Download file with xh
xh GET <url> --download

# Form data upload
xh --form POST <url> file@<file_path>

# Disk usage visualization
dust <directory>

# Show top N largest directories
dust -n <number> <directory>

# Limit directory depth
dust -d <depth> <directory>

# Better process list
procs

# Filter processes by name
procs <process_name>

# Process tree view
procs --tree

# Sort by CPU usage
procs --sortd cpu

# Sort by memory usage
procs --sortd mem

# Watch processes (like top)
procs --watch

$ markdown_file: fd -e md | head -20
$ directory: echo ". docs configs ~/Projects" | tr ' ' '\n'
$ yaml_file: fd -e yaml -e yml | head -20
$ yaml_file1: fd -e yaml -e yml | head -10
$ yaml_file2: fd -e yaml -e yml | head -10
$ json_file: fd -e json | head -20
$ path: echo ".data .results .items .spec.containers[0]" | tr ' ' '\n'
$ value: echo "new-value 1.0.0 production" | tr ' ' '\n'
$ runs: echo "3 5 10 20" | tr ' ' '\n'
$ command: echo "ls -la" "fd -e json" "rg pattern" | tr ' ' '\n'
$ command1: echo "rg pattern" "grep -r pattern" "fd -e json" | tr ' ' '\n'
$ command2: echo "grep -r pattern" "find . -name '*.json'" "ag pattern" | tr ' ' '\n'
$ api_url: echo "https://api.github.com/users/octocat https://jsonplaceholder.typicode.com/posts" | tr ' ' '\n'
$ url: echo "https://api.example.com/endpoint http://localhost:8787/api" | tr ' ' '\n'
$ token: echo "Bearer your-token-here"
$ file_path: fd --type f | head -20
$ number: echo "10 20 30 50" | tr ' ' '\n'
$ depth: echo "2 3 4 5" | tr ' ' '\n'
$ process_name: echo "node python java postgres nginx docker" | tr ' ' '\n'
```

---

## Phase 4: Project Template - Cloudflare Workers

### New Directory: `project-templates/cloudflare/`

#### File: `project-templates/cloudflare/devbox.json`

```json
{
  "$schema": "https://raw.githubusercontent.com/jetify-com/devbox/main/.schema/devbox.schema.json",
  "packages": [
    "nodejs_22@latest",
    "pnpm@latest",
    "wrangler@latest",
    "nodePackages.typescript@latest",
    "nodePackages.typescript-language-server@latest"
  ],
  "shell": {
    "init_hook": [
      "echo '☁️  Cloudflare Workers development environment loaded'",
      "echo ''",
      "node --version",
      "pnpm --version",
      "wrangler --version",
      "echo ''",
      "echo 'Available tools: node, pnpm, wrangler, typescript, tsserver (LSP)'",
      "echo ''",
      "echo 'Quick start:'",
      "echo '  devbox run init    - Initialize new worker'",
      "echo '  devbox run dev     - Start local dev server'",
      "echo '  devbox run deploy  - Deploy to Cloudflare'"
    ],
    "scripts": {
      "init": [
        "wrangler init"
      ],
      "dev": [
        "wrangler dev"
      ],
      "deploy": [
        "wrangler deploy"
      ],
      "tail": [
        "wrangler tail"
      ],
      "install": [
        "pnpm install"
      ],
      "test": [
        "pnpm test"
      ],
      "lint": [
        "pnpm lint"
      ],
      "format": [
        "pnpm format"
      ]
    }
  }
}
```

#### File: `project-templates/cloudflare/README.md`

```markdown
# Cloudflare Workers Development Template

Devbox environment for developing Cloudflare Workers with TypeScript.

## What's Included

- **Node.js 22** - Latest LTS runtime
- **pnpm** - Fast, efficient package manager
- **Wrangler** - Cloudflare Workers CLI
- **TypeScript** - Type-safe development
- **TSServer** - TypeScript language server for IDE support

## Quick Start

### Initialize a New Project

```bash
# Copy this template to your project
cp -r ~/dotfiles/project-templates/cloudflare my-worker
cd my-worker

# Start devbox shell
devbox shell

# Initialize worker (interactive)
devbox run init

# Or initialize with specific options
wrangler init my-worker --type=webpack
```

### Development Workflow

```bash
# Start local development server
devbox run dev

# Deploy to Cloudflare
devbox run deploy

# Watch logs in real-time
devbox run tail

# Run tests
devbox run test
```

### Available Scripts

- `devbox run init` - Initialize new worker project
- `devbox run dev` - Start local development server
- `devbox run deploy` - Deploy to Cloudflare
- `devbox run tail` - Tail worker logs
- `devbox run install` - Install dependencies
- `devbox run test` - Run tests
- `devbox run lint` - Lint code
- `devbox run format` - Format code

## Configuration

### Wrangler Configuration

Edit `wrangler.toml` to configure your worker:

```toml
name = "my-worker"
main = "src/index.ts"
compatibility_date = "2024-01-01"

[env.production]
name = "my-worker-production"
vars = { ENVIRONMENT = "production" }

[env.staging]
name = "my-worker-staging"
vars = { ENVIRONMENT = "staging" }
```

### TypeScript Configuration

Edit `tsconfig.json` for TypeScript settings:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "types": ["@cloudflare/workers-types"]
  }
}
```

## Common Tasks

### Deploy to Different Environments

```bash
# Deploy to staging
wrangler deploy --env staging

# Deploy to production
wrangler deploy --env production
```

### View Logs

```bash
# Tail all logs
wrangler tail

# Filter logs by status code
wrangler tail --status error

# Filter by specific event
wrangler tail --header X-Custom-Header=value
```

### Test Locally

```bash
# Start dev server
wrangler dev

# Test with curl
curl http://localhost:8787

# Test with xh (better curl)
xh GET http://localhost:8787
xh POST http://localhost:8787/api data=value
```

## Example Worker

### Basic TypeScript Worker

```typescript
export interface Env {
  // Define your environment variables here
  ENVIRONMENT: string;
}

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);
    
    // Handle different routes
    if (url.pathname === '/') {
      return new Response('Hello from Cloudflare Workers!', {
        headers: { 'Content-Type': 'text/plain' }
      });
    }
    
    if (url.pathname === '/api/health') {
      return Response.json({ 
        status: 'healthy',
        environment: env.ENVIRONMENT,
        timestamp: new Date().toISOString()
      });
    }
    
    return new Response('Not Found', { status: 404 });
  },
};
```

### API Worker with JSON

```typescript
export default {
  async fetch(request: Request): Promise<Response> {
    // Parse JSON body
    const data = await request.json();
    
    // Process data
    const result = {
      received: data,
      processed: true,
      timestamp: Date.now()
    };
    
    // Return JSON response
    return Response.json(result);
  },
};
```

## Resources

- [Cloudflare Workers Docs](https://developers.cloudflare.com/workers/)
- [Wrangler CLI Reference](https://developers.cloudflare.com/workers/wrangler/)
- [Workers Examples](https://developers.cloudflare.com/workers/examples/)
- [Workers Types](https://github.com/cloudflare/workers-types)

## Tips

- Use `navi --query cloudflare` for quick command reference
- Use `xh` instead of `curl` for easier API testing
- Use `jless` to view API responses interactively
- Check logs with `wrangler tail | jless` for better formatting
```

---

## Phase 5: Documentation Updates

### Update File: `README.md`

**Update "Modern CLI Tools" section (around line 72-78):**

```markdown
### Modern CLI Tools
- **ripgrep** - Fast grep alternative
- **fd** - Fast find alternative
- **bat** - Cat with syntax highlighting
- **eza** - Modern ls with icons
- **zoxide** - Smart cd command
- **lazygit** - Terminal UI for git
- **lazydocker** - Terminal UI for docker
- **lazysql** - Terminal UI for databases
- **btop** - System monitor
- **glow** - Markdown renderer
- **yq** - YAML/TOML processor
- **tldr** - Simplified man pages
- **dust** - Disk usage visualization
- **hyperfine** - Command benchmarking
- **jless** - Interactive JSON viewer
- **procs** - Better process viewer
- **xh** - HTTP client with better UX
```

**Add new section after "Languages & Runtimes" (around line 85):**

```markdown
### Cloud & Infrastructure Tools
- **wrangler** - Cloudflare Workers CLI
- **google-cloud-sdk** - Google Cloud Platform tools
```

**Update "Repository Structure" section to include Cloudflare template (around line 110):**

```markdown
├── project-templates/        # Devbox templates
│   ├── python/
│   ├── nodejs/
│   ├── golang/
│   ├── cloudflare/          # Cloudflare Workers template
│   ├── infrastructure/
│   └── kubernetes/
```

### New File: `docs/CLI_TOOLS_GUIDE.md`

Create a comprehensive guide for the new tools (see full content in separate file creation step).

---

## Questions Before Implementation

### 1. Wrangler Version
**Question:** Should we use the latest wrangler from nixpkgs, or pin to a specific version?

**Options:**
- A) Latest from nixpkgs (recommended - stays updated with nix flake updates)
- B) Pin to specific version (e.g., `wrangler = pkgs.wrangler.overrideAttrs...`)

**Recommendation:** Option A - Latest from nixpkgs

---

### 2. Google Cloud SDK
**Question:** The full SDK is quite large (~500MB). What would you prefer?

**Options:**
- A) Full SDK (all tools: gcloud, gsutil, bq, etc.) - ~500MB
- B) Just gcloud CLI minimal install
- C) Keep it in project-specific devbox instead of global install
- D) Skip for now, add later if needed

**Recommendation:** Option A if you use GCP regularly, Option C if only occasionally

---

### 3. Alias Preferences
**Question:** The plan replaces `du` → `dust` and `ps` → `procs`. Are you comfortable overriding these traditional commands?

**Options:**
- A) Override traditional commands (modern tools become default)
- B) Use different aliases (`du2`, `ps2`, `disk`, `processes`)
- C) Keep both accessible (no aliases, use full command names)

**Current plan:** Option A

**Note:** You can always access originals with:
```bash
command du -sh .   # bypass alias
/usr/bin/ps aux    # use system binary
```

---

### 4. LazySQL Database Support
**Question:** What databases do you primarily work with?

**Options:**
- PostgreSQL
- MySQL/MariaDB
- SQLite
- MongoDB
- Other

**Note:** This helps verify lazysql will work for your use case. LazySQL supports PostgreSQL, MySQL, and SQLite.

---

### 5. Additional Tools to Reconsider?
**Question:** After reviewing the plan, are there any tools from the original list you'd like to add?

**Previously discussed but not included:**
- `atuin` - Shell history upgrade (skipped - requires config, current history is good)
- `just` - Task runner (skipped - bash scripts work well)
- `dive` - Docker layer explorer (you have lazydocker)
- `k9s` - Kubernetes TUI (not needed - no k8s work currently)
- `stern` - Multi-pod log tailing (not needed - no k8s work currently)

**Any changes?** Yes / No

---

## Implementation Checklist

### Phase 1: Packages ✅ Ready
- [ ] Update `home/packages.nix` - Add 11 new packages
- [ ] Test build: `nix flake check`
- [ ] Apply: `hm`

### Phase 2: Aliases ✅ Ready
- [ ] Update `home/programs/zsh.nix` - Add 7 new aliases
- [ ] Apply: `hm`
- [ ] Test aliases in new shell

### Phase 3: Cheatsheets ✅ Ready
- [ ] Create `configs/navi/cheats/cloudflare.cheat`
- [ ] Create `configs/navi/cheats/gcp.cheat`
- [ ] Update `configs/navi/cheats/dev.cheat`
- [ ] Test: `navi --query cloudflare`

### Phase 4: Project Template ✅ Ready
- [ ] Create `project-templates/cloudflare/devbox.json`
- [ ] Create `project-templates/cloudflare/README.md`
- [ ] Test template: `cp -r project-templates/cloudflare /tmp/test-worker && cd /tmp/test-worker && devbox shell`

### Phase 5: Documentation ✅ Ready
- [ ] Update `README.md` - Tool lists and structure
- [ ] Create `docs/CLI_TOOLS_GUIDE.md`
- [ ] Review with `glow docs/CLI_TOOLS_GUIDE.md` (after installing glow)

### Final Steps
- [ ] Commit all changes
- [ ] Update flake.lock if needed
- [ ] Test full rebuild: `hm`
- [ ] Verify all new tools: `glow --version`, `yq --version`, etc.

---

## Expected Outcomes

After implementation:

✅ **11 new powerful CLI tools** available globally  
✅ **Intuitive aliases** for quick access  
✅ **Comprehensive cheatsheets** via navi  
✅ **Cloudflare Workers template** for fast project setup  
✅ **Full documentation** for discoverability  
✅ **No breaking changes** to existing workflow  
✅ **Portable across macOS/Linux** via Nix  

---

## Rollback Plan

If anything goes wrong:

```bash
# Check current generation
home-manager generations

# Rollback to previous
/nix/store/PREVIOUS-HASH-home-manager-generation/activate

# Or rebuild from git
git log  # find previous commit
git checkout COMMIT_HASH
hm
```

---

## Next Steps

1. **Review this plan** - Make any adjustments
2. **Answer questions** above (1-5)
3. **Approve implementation** - Give go-ahead
4. **Execute phases** 1-5 in order
5. **Test and verify** - Ensure everything works
6. **Commit changes** - Save to git

---

## Notes

- All tools are available in nixpkgs (verified compatible)
- Changes are reversible via Home Manager generations
- Project templates don't affect global config
- Cheatsheets are additive (won't break existing navi usage)
- Documentation is for reference (optional reading)

---

**Ready to proceed?** Please review and provide answers to questions 1-5, then we can start implementation!
