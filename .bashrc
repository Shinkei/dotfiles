#
# ~/.bashrc
#

# Set default editor
export EDITOR=/usr/bin/vim

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '
# >>> Added by cnchi installer
BROWSER=/usr/bin/chromium

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

# virtualenvwrapper setup
#export WORKON_HOME=$HOME/.virtualenvs
#export PROJECT_HOME=$HOME/.devel
#source /usr/bin/virtualenvwrapper.sh

# tabtab source for electron-forge package
# uninstall by removing these lines or running `tabtab uninstall electron-forge`
[ -f /home/jorge/.npm/_npx/13622/lib/node_modules/electron-forge/node_modules/tabtab/.completions/electron-forge.bash ] && . /home/jorge/.npm/_npx/13622/lib/node_modules/electron-forge/node_modules/tabtab/.completions/electron-forge.bash

# combine history 
shopt -s histappend
shopt -s histreedit
shopt -s histverify
HISTCONTROL='ignoreboth'
PROMPT_COMMAND="history -a;history -c;history -r; $PROMPT_COMMAND"

HISTSIZE=9999

# Avoid duplicate entries
export HISTCONTROL=ignoredups:erasedups 

powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
. /usr/lib/python3.7/site-packages/powerline/bindings/bash/powerline.sh

# esto lo puso la instalacion de nvm

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
source /usr/share/nvm/init-nvm.sh

# Alias y variables de halligan
export AWS_PROFILE=halligandev

alias halligandb='cd /mnt/veracrypt1/halligan/ && docker-compose up'
alias halliganserver='cd /mnt/veracrypt1/halligan/src/halligan && mvn spring-boot:run -Drun.profiles=dev'
alias halligangulp='cd /mnt/veracrypt1/halligan/src/halligan/rubix && node node_modules/gulp/bin/gulp.js'

