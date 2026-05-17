if command -v pacman >/dev/null 2>&1; then
  alias cleanup='sudo pacman -Rns $(pacman -Qtdq)'
  alias pacmanup='sudo pacman -Syu && yay -Syua'
  alias pu='sudo pacman -Syu && yay -Syua'
fi
