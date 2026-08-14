# Repository Guidelines

## Project Structure & Module Organization

This repository contains portable, Stow-managed dotfiles rather than application source code:

- `zsh/`: shared `.zshrc`, shell helpers, and Oh My Posh theme.
- `tmux/`: the shared `.tmux.conf`.
- `herdr/`: Herdr configuration, mirrored under `.config/herdr/`.
- `nvim/`: LazyVim configuration and plugin lockfile.
- `git/`: Git configuration.
- `mac/` and `linux/`: operating-system-specific overrides; `mac/` also contains the Brewfile and iTerm2 preferences.
- `install.sh`: the primary installation and restow script.

There is no dedicated test suite or application build output in this repository.

## Build, Test, and Development Commands

Run the installer from the repository root:

```bash
./install.sh                 # Detect the current OS and restow all packages
./install.sh mac             # Force macOS package selection
./install.sh --target /tmp/dotfiles-test  # Test links in an isolated target
./install.sh --help          # List available options
```

Use `--backup-conflicts` before applying files that may already exist. Use `--no-tmux-plugins` when testing without network access. Validate shell syntax with `bash -n install.sh`; use `git diff --check` before committing.

## Coding Style & Naming Conventions

Keep shell scripts POSIX-aware where practical, use Bash functions and `set -euo pipefail` consistently with `install.sh`, and indent shell code with two spaces. Preserve Stow paths exactly: files intended for `~/.config/foo/bar` belong at `package/.config/foo/bar`. Use lowercase, descriptive package and configuration names. Keep comments focused on non-obvious behavior.

## Testing Guidelines

For configuration changes, run `./install.sh --target /tmp/dotfiles-test --no-tmux-plugins`, inspect the resulting symlinks, and remove the temporary target afterward. For Herdr changes, run `herdr config check` and `herdr server reload-config` after applying the package.

## Commit & Pull Request Guidelines

Existing commits use short, imperative or descriptive lowercase messages (for example, `update zshrc`). Follow that style and keep each commit focused. Pull requests should explain the affected package, target OS, commands used for validation, and any manual follow-up. Do not include secrets, machine-specific generated state, logs, sockets, or plugin caches.

## Configuration Safety

Review Stow conflicts before applying changes. Preserve existing user configuration by using `--backup-conflicts`; never overwrite unrelated files or commit personal paths and credentials.
