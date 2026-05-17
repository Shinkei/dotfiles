export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
export ZSH_THEME=""
export TERM="xterm-256color"
export EDITOR="nvim"
export VISUAL="nvim"

zstyle ':omz:update' mode auto

typeset -a plugins
plugins=(
  git
  yarn
  web-search
  jsontools
  node
  sudo
  tmux
  z
  docker
)

case "$(uname -s)" in
  Darwin)
    plugins+=(osx macports)
    ;;
esac

if [ -f "$ZSH/oh-my-zsh.sh" ]; then
  source "$ZSH/oh-my-zsh.sh"
fi

export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=1000000
export HISTFILESIZE=1000000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY

source_if_exists() {
  [ -f "$1" ] && source "$1"
}

source_first_existing() {
  local file
  for file in "$@"; do
    if [ -f "$file" ]; then
      source "$file"
      return 0
    fi
  done
  return 1
}

source_if_exists "$HOME/.config/zsh/shared.zsh"

case "$(uname -s)" in
  Darwin)
    source_if_exists "$HOME/.config/zsh/macos.zsh"
    ;;
  Linux)
    source_if_exists "$HOME/.config/zsh/linux.zsh"
    ;;
esac

source_first_existing \
  /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

source_first_existing \
  /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export NVM_DIR="$HOME/.nvm"
source_if_exists "$NVM_DIR/nvm.sh"
source_if_exists "$NVM_DIR/bash_completion"
source_first_existing \
  /opt/homebrew/opt/nvm/nvm.sh \
  /usr/local/opt/nvm/nvm.sh \
  /usr/share/nvm/init-nvm.sh

if command -v fzf >/dev/null 2>&1; then
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  else
    source_first_existing \
      /usr/share/doc/fzf/examples/completion.zsh \
      /opt/homebrew/opt/fzf/shell/completion.zsh \
      /usr/local/opt/fzf/shell/completion.zsh

    source_first_existing \
      /usr/share/doc/fzf/examples/key-bindings.zsh \
      /opt/homebrew/opt/fzf/shell/key-bindings.zsh \
      /usr/local/opt/fzf/shell/key-bindings.zsh
  fi
fi

if command -v oh-my-posh >/dev/null 2>&1; then
  if [ -f "$HOME/.config/oh-my-posh/shinkei.omp.json" ]; then
    eval "$(oh-my-posh init zsh --config "$HOME/.config/oh-my-posh/shinkei.omp.json")"
  elif [ -f /usr/share/oh-my-posh/themes/gruvbox.omp.json ]; then
    eval "$(oh-my-posh init zsh --config /usr/share/oh-my-posh/themes/gruvbox.omp.json)"
  elif [ -f /opt/homebrew/opt/oh-my-posh/themes/gruvbox.omp.json ]; then
    eval "$(oh-my-posh init zsh --config /opt/homebrew/opt/oh-my-posh/themes/gruvbox.omp.json)"
  elif [ -f /usr/local/opt/oh-my-posh/themes/gruvbox.omp.json ]; then
    eval "$(oh-my-posh init zsh --config /usr/local/opt/oh-my-posh/themes/gruvbox.omp.json)"
  else
    eval "$(oh-my-posh init zsh)"
  fi
fi

if [ -x "$(command -v tmux)" ] && [ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ] && [ -z "${TMUX:-}" ]; then
  tmux attach || tmux new-session
fi
