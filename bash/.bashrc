#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

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

## Variables to export

# Variable to use workon and virtual enviroments with python
export WORKON_HOME=/home/shinkei/.virtualenvs
source /usr/bin/virtualenvwrapper.sh

#JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/java-8-jdk
export PATH=$PATH:/usr/lib/jvm/java-8-jdk/bin

#ANDROID_HOME
export ANDROID_HOME=/home/shinkei/Android/Sdk
export PATH=$PATH:/home/shinkei/Android/Sdk/tools:/home/shinkei/Android/Sdk/platform-tools

##Alias

alias cifrar='openssl aes-256-cbc -salt -a'
alias decifrar='openssl aes-256-cbc -d -a'

# combine history 
shopt -s histappend
shopt -s histreedit
shopt -s histverify
HISTCONTROL='ignoreboth'
PROMPT_COMMAND="history -a;history -c;history -r; $PROMPT_COMMAND"
