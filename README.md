# Dotfiles

A clean `stow`-based setup with shared defaults and OS-specific overrides.

## Structure

- `zsh`: shared shell setup with `oh-my-zsh`, `oh-my-posh`, and common aliases
- `tmux`: main portable tmux configuration
- `herdr`: Herdr keybindings aligned with tmux
- `git`: shared Git configuration with `git-delta` as the diff pager
- `nvim`: LazyVim with minimal overrides
- `mac`: macOS extras such as `Brewfile`, iTerm2, and zsh settings
- `linux`: Linux-specific zsh settings

## Installation

`install.sh` applies the Stow packages `git`, `zsh`, `tmux`, `nvim`, `herdr`, and the current OS package (`mac` or `linux`) to a target directory. By default, the target is your home directory and the mode is `--restow`.

The script prints the selected target and packages, applies Stow, optionally installs tmux plugins, and ends with any manual follow-up it detects. `stow` is the only command required to apply the links; `zsh`, `tmux`, `nvim`, and `fzf` are needed to use their corresponding configuration.

## First installation

Review the proposed links before changing your home directory:

```bash
./install.sh --dry-run
```

If the preview has no unexpected conflicts, apply the configuration:

```bash
./install.sh
```

If you already have a file that conflicts with a managed path, preview first, then run with backups enabled. Existing conflicting files are moved to `~/.dotfiles-backups/<timestamp>/` before Stow creates links.

```bash
./install.sh --dry-run --backup-conflicts
./install.sh --backup-conflicts
```

`--dry-run` never moves files; with `--backup-conflicts` it reports the Stow conflict, then the second command creates the backup and applies the links.

## OS selection and target

The OS is detected automatically. Pass `mac` or `linux` only when you need to force a package selection:

```bash
./install.sh mac
./install.sh linux
```

Use `--target` to install into an isolated directory instead of your home directory. Create the target first, and disable tmux plugins to keep the test offline and self-contained:

```bash
mkdir -p /tmp/dotfiles-test
./install.sh --target /tmp/dotfiles-test --no-tmux-plugins
```

## Options

| Option | Effect |
| --- | --- |
| `mac` / `linux` | Force the OS-specific package instead of detecting it. |
| `--target DIR` | Apply links under `DIR` instead of `$HOME`. |
| `--stow` | Create links without first restowing existing managed links. |
| `--restow` | Reapply managed links. This is the default mode. |
| `--delete` | Remove links managed by these packages; it does not remove TPM or installed software. |
| `--dry-run` | Preview the Stow operation without changing files. It skips backups, dependency installation, TPM, and Brewfile installation. |
| `--backup-conflicts` | Move conflicting existing files into a timestamped `.dotfiles-backups` directory before applying links. Ignored during `--dry-run`. |
| `--install-missing` | Install base packages using Homebrew on macOS, or `apt`, `dnf`, or `pacman` on Linux. Homebrew itself must already be installed. |
| `--bundle` | On macOS, run `brew bundle --file mac/Brewfile` after Stow. |
| `--no-tmux-plugins` | Skip cloning TPM and installing the plugins from `.tmux.conf`. |
| `--yes` | Pass non-interactive confirmation to `apt`, `dnf`, or `pacman` when used with `--install-missing`. |

Run `./install.sh --help` for the command synopsis and short examples.

## Common workflows

**New Linux machine with missing dependencies**

```bash
./install.sh --install-missing --backup-conflicts
```

**macOS with the optional Brewfile applications and fonts**

```bash
./install.sh mac --install-missing --bundle --backup-conflicts
```

**Update links after changing this repository**

```bash
./install.sh --dry-run
./install.sh --restow
```

**Remove only this repository's Stow-managed links**

```bash
./install.sh --delete
```

## tmux plugins and Brewfile

On normal non-delete runs, the script clones [TPM](https://github.com/tmux-plugins/tpm) to `~/.tmux/plugins/tpm` when needed and runs its plugin installer. Use `--no-tmux-plugins` when testing or when you do not want a network operation.

`--bundle` is macOS-only and installs the formulas, casks, fonts, and applications declared in `mac/Brewfile`. It does not remove programs that are absent from the Brewfile.

## Notes

- `~/.zshrc` is shared and loads `~/.config/zsh/macos.zsh` or `~/.config/zsh/linux.zsh`.
- `tmux` is unified into a single config.
- `tmux` installs TPM and its plugins automatically unless you use `--no-tmux-plugins`. If that step fails, the config falls back to a simple status bar.
- `nvim` keeps LazyVim and only overrides the `jk` mapping to leave insert mode.
