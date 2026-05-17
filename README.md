# Dotfiles

A clean `stow`-based setup with shared defaults and OS-specific overrides.

## Structure

- `zsh`: shared shell setup with `oh-my-zsh`, `oh-my-posh`, and common aliases
- `tmux`: main portable tmux configuration
- `nvim`: LazyVim with minimal overrides
- `mac`: macOS extras such as `Brewfile`, iTerm2, and zsh settings
- `linux`: Linux-specific zsh settings

## Installation

The installer shows step-by-step status output, keeps terminal messages readable, and ends with a summary of any recommended manual follow-up.

Minimum requirements: `stow`, `zsh`, `tmux`, `nvim`, and `fzf`.

```bash
./install.sh
```

This detects the current OS and applies:

```bash
stow -R zsh tmux nvim mac
```

or on Linux:

```bash
stow -R zsh tmux nvim linux
```

You can also force it explicitly:

```bash
./install.sh mac
./install.sh linux
```

Useful options:

```bash
./install.sh --stow
./install.sh --restow
./install.sh --delete
./install.sh --install-missing
./install.sh --backup-conflicts
./install.sh --no-tmux-plugins
./install.sh --yes
./install.sh --target /ruta/de/prueba
```

If base dependencies are missing, you can ask the script to install them:

```bash
./install.sh --install-missing
```

On macOS, this uses Homebrew to install `stow`, `zsh`, `tmux`, `neovim`, and `fzf`.
On Linux, it tries `apt`, `dnf`, or `pacman`, depending on what is available.

If you also want to install the stack defined in `mac/Brewfile`:

```bash
./install.sh mac --install-missing --bundle
```

If you already have files in `HOME` that would conflict with `stow`, you can back them up automatically before linking:

```bash
./install.sh --backup-conflicts
```

By default, the script also tries to:

- clone TPM into `~/.tmux/plugins/tpm` if it is missing
- install the plugins declared in `~/.tmux.conf`
- show a final summary with recommended manual follow-up steps

If you do not want that step:

```bash
./install.sh --no-tmux-plugins
```

## Notes

- `~/.zshrc` is shared and loads `~/.config/zsh/macos.zsh` or `~/.config/zsh/linux.zsh`.
- `tmux` is unified into a single config.
- `tmux` installs TPM and its plugins automatically unless you use `--no-tmux-plugins`. If that step fails, the config falls back to a simple status bar.
- `nvim` keeps LazyVim and only overrides the `jk` mapping to leave insert mode.
- On macOS, if you want to install the `Brewfile` packages later:

```bash
./install.sh mac --bundle
```
