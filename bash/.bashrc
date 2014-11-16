#
# ~/.bashrc
#
#__________________________________________________
# Enable tab completion
source /usr/share/git/completion/git-completion.bash

# colors!
green="\[\033[0;92m\]"
cyan="\[\033[0;96m\]"
blue="\[\033[0;94m\]"
reset="\[\033[0m\]"

# Change command prompt
source /usr/share/git/completion/git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1
# '\u' adds the name of the current user to the prompt
# '\$(__git_ps1)' adds git-related stuff
# '\W' adds the name of the current directory
export PS1="$blue\u$green\$(__git_ps1)$cyan \W $ $reset"

