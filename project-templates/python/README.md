# Python Project Template

This template provides a complete Python development environment using devbox.

## Tools Included

- **python@3.12** - Python programming language
- **poetry** - Modern Python dependency management
- **pip** - Python package installer
- **virtualenv** - Virtual environment management
- **ruff** - Extremely fast Python linter and formatter
- **mypy** - Static type checker
- **pytest** - Testing framework

## Quick Start

1. Copy `devbox.json` to your Python project root
2. Run `devbox shell` to enter the environment
3. Virtual environment will be automatically created and activated

## Usage

### Enter the development shell
```bash
devbox shell
```

### Run scripts

#### Poetry workflow
```bash
# Install dependencies from pyproject.toml
devbox run install

# Run tests
devbox run test

# Lint code
devbox run lint

# Format code
devbox run format

# Type check
devbox run typecheck
```

#### Pip workflow
```bash
# Install from requirements.txt
devbox run install-pip

# Run tests
devbox run test
```

### Manual commands in shell
```bash
devbox shell

# Poetry commands
poetry add requests
poetry add --group dev pytest
poetry run python main.py

# Pip commands
pip install requests
pip freeze > requirements.txt

# Testing
pytest
pytest -v
pytest tests/test_specific.py

# Linting and formatting
ruff check .
ruff format .
mypy .
```

## Project Setup

### New project with Poetry
```bash
devbox shell
poetry init
poetry add <package-name>
poetry install
```

### Existing project with Poetry
```bash
devbox shell
poetry install
```

### Existing project with pip
```bash
devbox shell
pip install -r requirements.txt
```

## Virtual Environment

The virtual environment is automatically created in `.venv/` and activated when you enter the devbox shell.

Add to `.gitignore`:
```
.venv/
__pycache__/
*.pyc
.pytest_cache/
.mypy_cache/
.ruff_cache/
```

## Customization

Edit `devbox.json` to:
- Change Python version (e.g., `python311`, `python313`)
- Add additional packages (e.g., `black`, `ipython`, `jupyter`)
- Modify scripts for your workflow

Search for packages at: https://www.nixhub.io (Devbox package search)
