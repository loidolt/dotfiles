# Go Project Template

This template provides a complete Go development environment using devbox.

## Tools Included

- **go@1.22** - Go programming language
- **gopls** - Go Language Server Protocol implementation
- **gotools** - Additional Go development tools
- **golangci-lint** - Fast Go linters runner
- **delve (dlv)** - Go debugger

## Quick Start

1. Copy `devbox.json` to your Go project root
2. Run `devbox shell` to enter the environment
3. All tools will be available in your PATH

## Usage

### Enter the development shell
```bash
devbox shell
```

### Run scripts
```bash
# Run tests
devbox run test

# Build the project
devbox run build

# Run linter
devbox run lint

# Format code
devbox run fmt

# Tidy dependencies
devbox run tidy
```

### Environment Variables

The following environment variables are automatically set:
- `GOPATH=$PWD/.devbox/go` - Local Go workspace
- `GO111MODULE=on` - Enable Go modules

## Project Setup

```bash
# Initialize a new Go module
devbox shell
go mod init github.com/username/project

# Install dependencies
go get ./...

# Run your application
go run main.go
```

## Customization

Edit `devbox.json` to:
- Change Go version (e.g., `go@1.21`, `go@1.23`)
- Add additional tools (e.g., `migrate`, `air`, `mockgen`)
- Modify scripts for your workflow

Search for packages at: https://www.nixhub.io (Devbox package search)
