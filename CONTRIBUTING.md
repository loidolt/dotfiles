# Contributing to Dotfiles

Thank you for your interest in contributing to this dotfiles repository! This guide will help you get started.

## Getting Started

1. **Fork the repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/dotfiles.git
   cd dotfiles
   ```

2. **Set up your user configuration**
   ```bash
   # Copy and customize the user configuration
   cp user.nix.example user.nix
   # Edit user.nix with your details
   ```

3. **Test your changes locally**
   ```bash
   # Validate the configuration
   make check
   make validate
   
   # Apply changes (in a safe way)
   make switch
   ```

## Development Workflow

### Making Changes

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Edit Nix files in `home/` or `configs/`
   - Update documentation as needed
   - Test your changes locally

3. **Validate your changes**
   ```bash
   # Check syntax and formatting
   make check
   
   # Run full validation
   make validate
   
   # Run health check
   make health
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add new tool to packages.nix"
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

### Nix Files
- Use 2-space indentation
- Align attribute lists where practical
- Add comments for non-obvious configurations
- Use `lib.mkIf` for conditional expressions

### Shell Scripts
- Follow the existing style in `scripts/lib/utils.sh`
- Use the provided utility functions (`info`, `success`, `error`, etc.)
- Add shellcheck directives when necessary

### Documentation
- Use Markdown for all documentation
- Keep README.md up to date
- Update CHANGELOG.md for significant changes

## Testing

### Local Testing

Before submitting a pull request:

1. **Syntax checking**
   ```bash
   make check  # Runs nix flake check
   ```

2. **Configuration validation**
   ```bash
   make validate  # Runs validate-nix.sh
   ```

3. **Health check**
   ```bash
   make health  # Runs health-check.sh
   ```

4. **Test on clean system** (optional but recommended)
   ```bash
   # In a VM or container:
   bash scripts/initial-setup.sh
   bash scripts/install-dotfiles.sh
   ```

### Platform Testing

Test on both platforms if possible:
- macOS (Intel and ARM)
- Linux (Ubuntu, Fedora, Arch)

## Areas of Contribution

### Welcome Contributions

- **New program configurations** in `home/programs/`
- **Additional project templates** in `project-templates/`
- **Navi cheatsheets** in `configs/navi/cheats/`
- **Bug fixes** and **performance improvements**
- **Documentation** improvements

### Examples

#### Adding a New Program

1. Create `home/programs/newtool.nix`:
   ```nix
   { pkgs, ... }:
   {
     programs.newtool = {
       enable = true;
       settings = {
         # Configuration options
       };
     };
   }
   ```

2. Import in `home/default.nix`:
   ```nix
   imports = [
     # ... existing imports
     ./programs/newtool.nix
   ];
   ```

3. Add to packages if needed:
   ```nix
   home.packages = with pkgs; [
     # ... existing packages
     newtool
   ];
   ```

#### Adding a Project Template

1. Create directory in `project-templates/`
2. Add `devbox.json` with project dependencies
3. Add `README.md` with usage instructions
4. Update main README.md template list

## Pre-commit Hooks

We use pre-commit hooks to maintain code quality:

```bash
# Install hooks
pre-commit install

# Run hooks manually
pre-commit run --all-files
```

The hooks check for:
- Nix formatting (`nixfmt`)
- Shell script linting (`shellcheck`)
- JSON/YAML formatting (`prettier`)
- Trailing whitespace
- Large files
- Commits to main/master

## Submitting Changes

1. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create a Pull Request**
   - Use a descriptive title
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