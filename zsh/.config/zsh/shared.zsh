case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

case ":$PATH:" in
  *":$HOME/bin:"*) ;;
  *) export PATH="$PATH:$HOME/bin" ;;
esac

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

if command -v lsd >/dev/null 2>&1; then
  alias ls='lsd --color=auto'
  alias la='lsd -a'
  alias ll='lsd -alFh'
  alias l='lsd'
  alias l.="lsd -A | egrep '^\.'"
else
  alias ls='ls --color=auto'
  alias la='ls -a'
  alias ll='ls -alFh'
  alias l='ls'
fi

alias yta-aac='yt-dlp --extract-audio --audio-format aac'
alias yta-best='yt-dlp --extract-audio --audio-format best'
alias yta-flac='yt-dlp --extract-audio --audio-format flac'
alias yta-mp3='yt-dlp --extract-audio --audio-format mp3'
alias ytv-best="yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' --merge-output-format mp4"

gcop() {
  git log \
    --color=always \
    --format="%C(cyan)%h %C(blue)%ar%C(auto)%d %C(yellow)%s%+b %C(black)%ae" "$@" |
    fzf -i -e +s \
      --reverse \
      --tiebreak=index \
      --no-multi \
      --ansi \
      --preview="git show --color=always {1} | if command -v delta >/dev/null 2>&1; then delta --line-numbers; else cat; fi" \
      --header "ctrl-j/k: navigate  ctrl-u/d: page  enter: view  ctrl-y: copy hash" \
      --bind 'ctrl-j:down,ctrl-k:up,ctrl-u:half-page-up,ctrl-d:half-page-down' \
      --bind "enter:execute(git show --color=always {1} | if command -v delta >/dev/null 2>&1; then delta --line-numbers; else cat; fi | less -R)" \
      --bind "ctrl-y:execute-silent(if command -v pbcopy >/dev/null 2>&1; then printf '%s\\n' {1} | pbcopy; elif command -v xclip >/dev/null 2>&1; then printf '%s\\n' {1} | xclip -selection clipboard; elif command -v wl-copy >/dev/null 2>&1; then printf '%s\\n' {1} | wl-copy; fi)"
}
