if command -v brew >/dev/null 2>&1; then
  eval "$("$(command -v brew)" shellenv)"
fi

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
