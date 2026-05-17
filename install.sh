#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${HOME}"
MODE="restow"
OS=""
INSTALL_MISSING=0
INSTALL_BUNDLE=0
ASSUME_YES=0
BACKUP_CONFLICTS=0
BACKUP_ROOT=""
INSTALL_TMUX_PLUGINS=1
MANUAL_STEPS=()

if [ -t 1 ]; then
  COLOR_RESET=$'\033[0m'
  COLOR_BOLD=$'\033[1m'
  COLOR_DIM=$'\033[2m'
  COLOR_RED=$'\033[31m'
  COLOR_GREEN=$'\033[32m'
  COLOR_YELLOW=$'\033[33m'
  COLOR_BLUE=$'\033[34m'
else
  COLOR_RESET=""
  COLOR_BOLD=""
  COLOR_DIM=""
  COLOR_RED=""
  COLOR_GREEN=""
  COLOR_YELLOW=""
  COLOR_BLUE=""
fi

usage() {
  cat <<'EOF'
Usage:
  ./install.sh [mac|linux] [--target DIR] [--stow|--restow|--delete] [--install-missing] [--bundle] [--backup-conflicts] [--no-tmux-plugins] [--yes]

Examples:
  ./install.sh
  ./install.sh mac
  ./install.sh --backup-conflicts
  ./install.sh mac --install-missing --bundle
  ./install.sh linux --target /tmp/dotfiles-test
EOF
}

detect_os() {
  case "$(uname -s)" in
    Darwin) echo "mac" ;;
    Linux) echo "linux" ;;
    *)
      echo "Unsupported OS: $(uname -s)" >&2
      exit 1
      ;;
  esac
}

print_header() {
  printf "\n%s🛠️  %s%s\n" "$COLOR_BOLD$COLOR_BLUE" "$1" "$COLOR_RESET"
}

print_step() {
  printf "%s➡️  %s%s\n" "$COLOR_BLUE" "$1" "$COLOR_RESET"
}

print_ok() {
  printf "%s✅ %s%s\n" "$COLOR_GREEN" "$1" "$COLOR_RESET"
}

print_warn() {
  printf "%s⚠️  %s%s\n" "$COLOR_YELLOW" "$1" "$COLOR_RESET"
}

print_error() {
  printf "%s❌ %s%s\n" "$COLOR_RED" "$1" "$COLOR_RESET" >&2
}

print_note() {
  printf "%sℹ️  %s%s\n" "$COLOR_DIM" "$1" "$COLOR_RESET"
}

add_manual_step() {
  MANUAL_STEPS+=("$1")
}

print_summary() {
  print_header "Installation summary"
  print_ok "Mode: $MODE"
  print_ok "Target: $TARGET"
  print_ok "Packages: ${packages[*]}"

  if [ -n "$BACKUP_ROOT" ] && [ -d "$BACKUP_ROOT" ]; then
    print_note "Backups saved in $BACKUP_ROOT"
  fi

  if [ "${#MANUAL_STEPS[@]}" -eq 0 ]; then
    print_ok "No manual follow-up required."
    return 0
  fi

  echo
  print_warn "Manual follow-up:"
  local step
  for step in "${MANUAL_STEPS[@]}"; do
    printf "  %s•%s %s\n" "$COLOR_YELLOW" "$COLOR_RESET" "$step"
  done
}

has_command() {
  command -v "$1" >/dev/null 2>&1
}

run_as_root() {
  if [ "${EUID}" -eq 0 ]; then
    "$@"
  elif has_command sudo; then
    sudo "$@"
  else
    print_error "This step requires root privileges and sudo is not installed: $*"
    exit 1
  fi
}

install_with_brew() {
  local missing=()
  local formula

  for formula in "$@"; do
    if ! brew list --formula "$formula" >/dev/null 2>&1; then
      missing+=("$formula")
    fi
  done

  if [ "${#missing[@]}" -eq 0 ]; then
    print_ok "Required Homebrew packages are already installed."
    return 0
  fi

  print_step "Installing missing Homebrew packages: ${missing[*]}"
  brew install "${missing[@]}"
  print_ok "Homebrew packages installed."
}

install_with_apt() {
  local packages=("$@")

  print_step "Installing missing apt packages: ${packages[*]}"
  run_as_root apt-get update
  if [ "$ASSUME_YES" -eq 1 ]; then
    run_as_root apt-get install -y "${packages[@]}"
  else
    run_as_root apt-get install "${packages[@]}"
  fi
  print_ok "apt packages installed."
}

install_with_dnf() {
  local packages=("$@")

  print_step "Installing missing dnf packages: ${packages[*]}"
  if [ "$ASSUME_YES" -eq 1 ]; then
    run_as_root dnf install -y "${packages[@]}"
  else
    run_as_root dnf install "${packages[@]}"
  fi
  print_ok "dnf packages installed."
}

install_with_pacman() {
  local packages=("$@")

  print_step "Installing missing pacman packages: ${packages[*]}"
  if [ "$ASSUME_YES" -eq 1 ]; then
    run_as_root pacman -Sy --needed --noconfirm "${packages[@]}"
  else
    run_as_root pacman -Sy --needed "${packages[@]}"
  fi
  print_ok "pacman packages installed."
}

install_missing_packages() {
  case "$OS" in
    mac)
      if ! has_command brew; then
        print_error "Homebrew is required to install missing packages automatically on macOS."
        print_note "Install it from https://brew.sh and rerun with --install-missing."
        exit 1
      fi
      install_with_brew stow zsh tmux neovim fzf
      ;;
    linux)
      if has_command apt-get; then
        install_with_apt stow zsh tmux neovim fzf
      elif has_command dnf; then
        install_with_dnf stow zsh tmux neovim fzf
      elif has_command pacman; then
        install_with_pacman gnu-stow zsh tmux neovim fzf
      else
        print_error "Automatic package installation is not supported for this Linux distribution."
        print_note "Install these packages manually and rerun: stow zsh tmux neovim fzf"
        exit 1
      fi
      ;;
  esac
}

install_optional_bundle() {
  local brewfile="$DOTFILES_DIR/mac/Brewfile"

  if [ "$OS" != "mac" ] || [ "$INSTALL_BUNDLE" -eq 0 ]; then
    return 0
  fi

  if ! has_command brew; then
    print_warn "Skipping Brewfile installation because Homebrew is not installed."
    return 0
  fi

  if [ ! -f "$brewfile" ]; then
    print_warn "Skipping Brewfile installation because $brewfile does not exist."
    return 0
  fi

  print_step "Installing macOS bundle from $brewfile"
  brew bundle --file "$brewfile"
  print_ok "Brewfile installation complete."
}

install_tmux_plugins() {
  local tpm_dir="$TARGET/.tmux/plugins/tpm"

  if [ "$INSTALL_TMUX_PLUGINS" -ne 1 ] || [ "$MODE" = "delete" ]; then
    return 0
  fi

  if ! has_command tmux; then
    print_warn "Skipping tmux plugin install because tmux is not installed."
    add_manual_step "Install tmux and rerun ./install.sh if you want TPM plugins."
    return 0
  fi

  if ! has_command git; then
    print_warn "Skipping tmux plugin install because git is not installed."
    add_manual_step "Install git and rerun ./install.sh to set up TPM plugins."
    return 0
  fi

  if [ ! -d "$tpm_dir" ]; then
    print_step "Cloning TPM into $tpm_dir"
    mkdir -p "$(dirname "$tpm_dir")"
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
    print_ok "TPM cloned."
  fi

  if [ -x "$tpm_dir/bin/install_plugins" ]; then
    print_step "Installing tmux plugins with TPM"
    TMUX_PLUGIN_MANAGER_PATH="$TARGET/.tmux/plugins" "$tpm_dir/bin/install_plugins"
    print_ok "tmux plugins installed."
  else
    print_warn "Skipping tmux plugin install because TPM is incomplete at $tpm_dir."
    add_manual_step "Remove $tpm_dir and rerun ./install.sh to reinstall TPM cleanly."
  fi
}

backup_conflict() {
  local target_path="$1"
  local relative_target="${target_path#$TARGET/}"
  local backup_path="$BACKUP_ROOT/$relative_target"

  mkdir -p "$(dirname "$backup_path")"
  mv "$target_path" "$backup_path"
  print_note "Backed up $target_path -> $backup_path"
}

backup_stow_conflicts() {
  local package
  local package_dir
  local rel_path
  local source_path
  local target_path

  BACKUP_ROOT="$TARGET/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"

  for package in "${packages[@]}"; do
    package_dir="$DOTFILES_DIR/$package"

    while IFS= read -r rel_path; do
      source_path="$package_dir/$rel_path"
      target_path="$TARGET/$rel_path"

      if [ -d "$source_path" ]; then
        continue
      fi

      if [ ! -e "$target_path" ] && [ ! -L "$target_path" ]; then
        continue
      fi

      if [ -L "$target_path" ]; then
        if [ "$(realpath "$target_path")" = "$(realpath "$source_path")" ]; then
          continue
        fi
      fi

      backup_conflict "$target_path"
    done < <(cd "$package_dir" && find . -mindepth 1 | sed 's#^\./##' | sort)
  done

  if [ -d "$BACKUP_ROOT" ]; then
    print_ok "Conflict backups stored in $BACKUP_ROOT"
  fi
}

while [ $# -gt 0 ]; do
  case "$1" in
    mac|linux)
      OS="$1"
      ;;
    --target)
      shift
      TARGET="${1:?missing target path}"
      ;;
    --stow)
      MODE="stow"
      ;;
    --restow)
      MODE="restow"
      ;;
    --delete)
      MODE="delete"
      ;;
    --install-missing)
      INSTALL_MISSING=1
      ;;
    --bundle)
      INSTALL_BUNDLE=1
      ;;
    --yes)
      ASSUME_YES=1
      ;;
    --backup-conflicts)
      BACKUP_CONFLICTS=1
      ;;
    --no-tmux-plugins)
      INSTALL_TMUX_PLUGINS=0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      print_error "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
  shift
done

if [ -z "$OS" ]; then
  OS="$(detect_os)"
fi

if [ "$INSTALL_MISSING" -eq 1 ]; then
  print_header "Bootstrap dependencies"
  install_missing_packages
fi

if ! has_command stow; then
  print_error "stow is required but not installed."
  print_note "Rerun with --install-missing to bootstrap required packages automatically."
  exit 1
fi

packages=(zsh tmux nvim "$OS")
stow_args=(-d "$DOTFILES_DIR" -t "$TARGET")

case "$MODE" in
  stow)
    ;;
  restow)
    stow_args=(-R "${stow_args[@]}")
    ;;
  delete)
    stow_args=(-D "${stow_args[@]}")
    ;;
esac

print_note "Mode: $MODE"
print_note "Target: $TARGET"
print_note "Packages: ${packages[*]}"

if [ "$BACKUP_CONFLICTS" -eq 1 ] && [ "$MODE" != "delete" ]; then
  print_header "Backup conflicts"
  backup_stow_conflicts
fi

print_header "Apply dotfiles"
print_step "Running stow ${stow_args[*]} ${packages[*]}"
stow "${stow_args[@]}" "${packages[@]}"
print_ok "Dotfiles applied."

print_header "tmux plugins"
install_tmux_plugins

if [ "$MODE" != "delete" ]; then
  print_header "Optional bundle"
  install_optional_bundle
fi

if [ "$OS" = "mac" ] && [ "$MODE" != "delete" ] && [ "$INSTALL_BUNDLE" -eq 0 ]; then
  add_manual_step "Run ./install.sh mac --bundle if you also want apps, fonts, and casks from mac/Brewfile."
fi

if [ "$MODE" != "delete" ] && [ "$TARGET" = "$HOME" ] && [ -n "${SHELL:-}" ] && [ "$(basename "$SHELL")" != "zsh" ] && has_command zsh; then
  add_manual_step "Set zsh as your default shell: chsh -s \"$(command -v zsh)\""
fi

if [ "$MODE" != "delete" ] && [ "$TARGET" = "$HOME" ] && [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
  add_manual_step "Install Oh My Zsh if you want the shared OMZ plugins loaded by ~/.zshrc."
fi

if [ "$MODE" != "delete" ] && [ "$TARGET" = "$HOME" ] && [ -z "${TMUX:-}" ] && has_command tmux; then
  add_manual_step "Open a new tmux session or run: tmux source-file ~/.tmux.conf"
fi

if [ "$MODE" != "delete" ] && [ "$TARGET" = "$HOME" ]; then
  add_manual_step "Open a new terminal or run: source ~/.zshrc"
fi

print_summary
