#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_TARGETS=()
NEW_TARGET=""

cleanup() {
  local target
  for target in "${TEMP_TARGETS[@]}"; do
    rm -rf "$target"
  done
}

new_target() {
  NEW_TARGET="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-install-test.XXXXXX")"
  TEMP_TARGETS+=("$NEW_TARGET")
}

assert_symlink() {
  local path="$1"

  if [ ! -L "$path" ]; then
    printf 'Expected a symlink: %s\n' "$path" >&2
    exit 1
  fi
}

assert_file_content() {
  local path="$1"
  local expected="$2"
  local actual

  actual="$(cat "$path")"
  if [ "$actual" != "$expected" ]; then
    printf 'Unexpected content in %s\n' "$path" >&2
    exit 1
  fi
}

if ! command -v stow >/dev/null 2>&1; then
  printf 'GNU Stow is required to run install tests.\n' >&2
  exit 1
fi

trap cleanup EXIT

printf 'Test: dry run does not change the target\n'
new_target
target="$NEW_TARGET"
"$DOTFILES_DIR/install.sh" --target "$target" --dry-run
if [ -n "$(find "$target" -mindepth 1 -print -quit)" ]; then
  printf 'Dry run created files in %s\n' "$target" >&2
  exit 1
fi

printf 'Test: isolated installation creates managed links\n'
new_target
target="$NEW_TARGET"
"$DOTFILES_DIR/install.sh" --target "$target" --no-tmux-plugins
assert_symlink "$target/.zshrc"
assert_symlink "$target/.tmux.conf"
assert_symlink "$target/.config/git"
assert_symlink "$target/.config/herdr"
assert_symlink "$target/.config/nvim"
assert_symlink "$target/.config/zsh/linux.zsh"

printf 'Test: dry run preserves conflicts\n'
new_target
target="$NEW_TARGET"
printf 'keep me\n' > "$target/.zshrc"
if "$DOTFILES_DIR/install.sh" --target "$target" --dry-run --backup-conflicts; then
  printf 'Expected Stow to report the conflict.\n' >&2
  exit 1
fi
assert_file_content "$target/.zshrc" 'keep me'
if [ -e "$target/.dotfiles-backups" ]; then
  printf 'Dry run created a backup directory.\n' >&2
  exit 1
fi

printf 'Test: backup conflicts preserves the original file\n'
new_target
target="$NEW_TARGET"
printf 'keep me\n' > "$target/.zshrc"
"$DOTFILES_DIR/install.sh" --target "$target" --backup-conflicts --no-tmux-plugins
assert_symlink "$target/.zshrc"
backup_file="$(find "$target/.dotfiles-backups" -type f -name .zshrc -print -quit)"
if [ -z "$backup_file" ]; then
  printf 'Expected the conflicting .zshrc to be backed up.\n' >&2
  exit 1
fi
assert_file_content "$backup_file" 'keep me'

printf 'Install tests passed.\n'
