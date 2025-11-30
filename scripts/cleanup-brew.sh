#!/usr/bin/env bash

set -e

echo "🧹 Cleaning up project-specific Homebrew packages..."
echo "These will be managed per-project with devbox instead."
echo ""
echo "⚠️  This will uninstall project-specific tools from Homebrew."
echo "You can recreate these environments using devbox templates in project-templates/"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "📦 Removing language runtimes..."

# Language runtimes
brew uninstall --ignore-dependencies go 2>/dev/null || echo "  ✓ go already removed"
brew uninstall --ignore-dependencies deno 2>/dev/null || echo "  ✓ deno already removed"
brew uninstall --ignore-dependencies node@18 2>/dev/null || echo "  ✓ node@18 already removed"
brew uninstall --ignore-dependencies node@22 2>/dev/null || echo "  ✓ node@22 already removed"
brew uninstall --ignore-dependencies nvm 2>/dev/null || echo "  ✓ nvm already removed"
brew uninstall --ignore-dependencies php 2>/dev/null || echo "  ✓ php already removed"
brew uninstall --ignore-dependencies ruby 2>/dev/null || echo "  ✓ ruby already removed"
brew uninstall --ignore-dependencies openjdk 2>/dev/null || echo "  ✓ openjdk already removed"
brew uninstall --ignore-dependencies python@3.10 2>/dev/null || echo "  ✓ python@3.10 already removed"
brew uninstall --ignore-dependencies python@3.12 2>/dev/null || echo "  ✓ python@3.12 already removed"

echo ""
echo "☸️  Removing Kubernetes tools..."

# Kubernetes tools
brew uninstall kubernetes-cli 2>/dev/null || echo "  ✓ kubectl already removed"
brew uninstall k9s 2>/dev/null || echo "  ✓ k9s already removed"
brew uninstall argocd 2>/dev/null || echo "  ✓ argocd already removed"
brew uninstall grpcurl 2>/dev/null || echo "  ✓ grpcurl already removed"

echo ""
echo "🏗️  Removing infrastructure tools..."

# Infrastructure tools
brew uninstall ansible 2>/dev/null || echo "  ✓ ansible already removed"
brew uninstall ansible-lint 2>/dev/null || echo "  ✓ ansible-lint already removed"

echo ""
echo "🔧 Removing language-specific tools..."

# Language-specific tools
brew uninstall pnpm 2>/dev/null || echo "  ✓ pnpm already removed"
brew uninstall cocoapods 2>/dev/null || echo "  ✓ cocoapods already removed"
brew uninstall pipx 2>/dev/null || echo "  ✓ pipx already removed"
brew uninstall mypy 2>/dev/null || echo "  ✓ mypy already removed"
brew uninstall pytest 2>/dev/null || echo "  ✓ pytest already removed"
brew uninstall yamllint 2>/dev/null || echo "  ✓ yamllint already removed"

echo ""
echo "🧼 Cleaning up unused dependencies..."
brew autoremove

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Next steps:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Apply Nix configuration to install global tools:"
echo "   home-manager switch --flake ~/.config/home-manager"
echo ""
echo "2. For each project, copy the appropriate devbox template:"
echo "   cp ~/Documents/GitHub/dotfiles/project-templates/kubernetes/devbox.json ."
echo "   cp ~/Documents/GitHub/dotfiles/project-templates/golang/devbox.json ."
echo "   cp ~/Documents/GitHub/dotfiles/project-templates/python/devbox.json ."
echo "   cp ~/Documents/GitHub/dotfiles/project-templates/nodejs/devbox.json ."
echo "   cp ~/Documents/GitHub/dotfiles/project-templates/infrastructure/devbox.json ."
echo ""
echo "3. Enter project environment:"
echo "   devbox shell"
echo ""
echo "4. Available templates:"
echo "   - kubernetes    : kubectl, helm, k9s, argocd, grpcurl"
echo "   - golang        : go, gopls, golangci-lint, delve"
echo "   - python        : python, poetry, ruff, mypy, pytest"
echo "   - nodejs        : node, pnpm, typescript"
echo "   - infrastructure: ansible, terraform, packer, yamllint"
echo ""
echo "📖 See docs/PACKAGE_MANAGEMENT_GUIDE.md for detailed information"
echo ""
