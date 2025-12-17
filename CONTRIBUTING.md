# Contributing to Dotfiles

Thank you for your interest in contributing to this dotfiles repository! This guide will help you get started.

## Getting Started

1. **Fork the repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/dotfiles.git
   cd dotfiles
   ```

2. **Set up your environment**
   ```bash
   # Install dotfiles
   ./install.sh
   
   # Test the setup
   ./scripts/health-check.sh
   ```

3. **Test your changes locally**
   ```bash
   # After making changes, restow packages
   cd ~/dotfiles/stow
   stow -R <package-name>
   
   # Or restow everything
   cd ~/dotfiles
   ./stow-all.sh
   ```

## Development Workflow

### Making Changes

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Edit configurations in `stow/`
   - Update package lists in `packages/`
   - Update documentation as needed
   - Test your changes locally

3. **Validate your changes**
   ```bash
   # Run health check
   ./scripts/health-check.sh
   
   # Test installation in clean environment (optional)
   # Use a VM or container to test from scratch
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add new tool to package list"
   ```

### Commit Message Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `style:` Code style changes (formatting, etc.)
- `refactor:` Code refactoring
- `test:` Adding or updating tests
- `chore:` Maintenance tasks

Examples:
```
feat: add fzf integration to zsh
fix: resolve configuration name mismatch in update.sh
docs: update installation instructions for ARM Macs
refactor: extract common shell utilities to lib/utils.sh
```

## Code Style

### Shell Scripts
- Follow the existing style in `scripts/lib/utils.sh`
- Use the provided utility functions (`info`, `success`, `error`, etc.)
- Use `set -euo pipefail` for safety
- Add comments for non-obvious logic
- Test scripts on both macOS and Linux when possible

### Configuration Files
- Use consistent indentation (2 spaces for YAML/JSON, 4 for Lua)
- Add comments explaining non-obvious settings
- Keep configurations minimal and well-documented

### Documentation
- Use Markdown for all documentation
- Keep README.md up to date
- Update CHANGELOG.md for significant changes
- Include examples in documentation

## Testing

### Local Testing

Before submitting a pull request:

1. **Run health check**
   ```bash
   ./scripts/health-check.sh
   ```

2. **Test package installation**
   ```bash
   ./packages/install.sh
   ```

3. **Verify stow operations**
   ```bash
   cd ~/dotfiles/stow
   stow -n -v <package>  # Dry run to preview changes
   stow -R <package>     # Restow to apply changes
   ```

4. **Test on clean system** (optional but recommended)
   ```bash
   # In a VM or container:
   git clone <your-fork>
   cd dotfiles
   ./install.sh
   ```

### Platform Testing

Test on both platforms if possible:
- macOS (Intel and ARM if available)
- Linux (Ubuntu, Fedora, or Arch)

## Areas of Contribution

### Welcome Contributions

- **New program configurations** in `stow/`
- **Additional project templates** in `project-templates/`
- **Package additions** to `packages/*.txt`
- **Bug fixes** and **performance improvements**
- **Documentation** improvements
- **Shell script improvements**

### Examples

#### Adding a New Stow Package

1. Create directory structure:
   ```bash
   mkdir -p stow/newtool/.config/newtool
   ```

2. Add configuration files:
   ```bash
   # Files in stow/newtool/ mirror your home directory structure
   stow/newtool/.config/newtool/config.toml
   ```

3. Stow the package:
   ```bash
   cd ~/dotfiles/stow
   stow newtool
   ```

#### Adding a Package

1. Edit appropriate package list:
   ```bash
   # For cross-platform: packages/common.txt
   echo "newtool" >> packages/common.txt
   
   # For macOS only: packages/macos.txt
   echo "newtool" >> packages/macos.txt
   ```

2. Install:
   ```bash
   ./packages/install.sh
   ```

#### Adding a Project Template

1. Create directory in `project-templates/`
2. Add `devbox.json` with project dependencies
3. Add `README.md` with usage instructions
4. Update main README.md template list

## Submitting Changes

1. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create a Pull Request**
   - Use a descriptive title following conventional commits
   - Reference any related issues
   - Include screenshots if applicable
   - Describe testing performed

3. **Address feedback**
   - Respond to reviewer comments
   - Make requested changes
   - Keep PR updated

## Getting Help

- **Issues**: Use GitHub Issues for bug reports and feature requests
- **Discussions**: Use GitHub Discussions for questions and ideas
- **Documentation**: Check README.md and existing issues first

## License

By contributing, you agree that your contributions will be licensed under the same license as the repository (see LICENSE file).

---

Thank you for contributing! 🎉