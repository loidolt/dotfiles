# Node.js Project Template

This template provides a complete Node.js development environment using devbox.

## Tools Included

- **nodejs_22** - Node.js JavaScript runtime (latest LTS)
- **pnpm** - Fast, disk space efficient package manager
- **typescript** - TypeScript compiler
- **typescript-language-server** - TypeScript Language Server

## Quick Start

1. Copy `devbox.json` to your Node.js project root
2. Run `devbox shell` to enter the environment
3. All tools will be available in your PATH

## Usage

### Enter the development shell
```bash
devbox shell
```

### Run scripts
```bash
# Install dependencies
devbox run install

# Start development server
devbox run dev

# Build for production
devbox run build

# Run tests
devbox run test

# Lint code
devbox run lint

# Format code
devbox run format
```

### Manual commands in shell
```bash
devbox shell

# Package management
pnpm add <package>
pnpm add -D <dev-package>
pnpm install
pnpm update

# Run scripts from package.json
pnpm dev
pnpm build
pnpm test

# TypeScript
tsc --init
tsc
```

## Project Setup

### New TypeScript project
```bash
devbox shell
pnpm init
pnpm add -D typescript @types/node
npx tsc --init

# Create a simple file
cat > index.ts << 'EOF'
const message: string = "Hello, TypeScript!";
console.log(message);
EOF

# Run it
pnpm tsx index.ts
```

### Existing project
```bash
devbox shell
pnpm install
pnpm dev
```

## Example package.json scripts

Add these to your `package.json`:

```json
{
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "vitest",
    "lint": "eslint .",
    "format": "prettier --write ."
  }
}
```

## Recommended Dependencies

```bash
# For TypeScript development
pnpm add -D tsx vitest

# For web frameworks
pnpm add express
pnpm add -D @types/express

# Or for modern alternatives
pnpm add hono  # Lightweight web framework
pnpm add fastify  # Fast web framework
```

## Customization

Edit `devbox.json` to:
- Change Node.js version (e.g., `nodejs_20`, `nodejs_18`)
- Use npm or yarn instead of pnpm
- Add additional tools (e.g., `biome`, `eslint`)
- Modify scripts for your workflow

Search for packages at: https://search.nixos.org/packages
