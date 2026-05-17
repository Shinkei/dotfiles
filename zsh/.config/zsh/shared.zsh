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
      --preview="echo {} | grep -o '[a-f0-9]\\{7\\}' | head -1 | xargs -I % sh -c 'git show --color=always % | delta --line-numbers'" \
      --header "enter: view ctrl-y: copy hash" \
      --bind "enter:execute(echo {} | grep -o '[a-f0-9]\\{7\\}' | head -1 | xargs -I % sh -c 'git show --color=always % | delta --line-numbers | less -R')" \
      --bind "ctrl-y:execute-silent(echo {} | grep -o '[a-f0-9]\\{7\\}' | head -1 | sh -c 'if command -v pbcopy >/dev/null 2>&1; then pbcopy; elif command -v xclip >/dev/null 2>&1; then xclip -selection clipboard; elif command -v wl-copy >/dev/null 2>&1; then wl-copy; else cat >/dev/null; fi')"
}
