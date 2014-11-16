#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]shinkei\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\$ '

#virtualEnvConfig
export WORKON_HOME=/home/shinkei/.virtualenvs
source /usr/bin/virtualenvwrapper.sh
PATH=/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl
#PATH="`ruby -e 'print Gem.user_dir'`/bin:$PATH"
#export GEM_HOME=$(ruby -e 'print Gem.user_dir')
#__________________________________________________
# Enable tab completion
source ~/git-completion.bash

# colors!
green="\[\033[0;92m\]"
cyan="\[\033[0;96m\]"
blue="\[\033[0;94m\]"
reset="\[\033[0m\]"

# Change command prompt
source ~/git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1
# '\u' adds the name of the current user to the prompt
# '\$(__git_ps1)' adds git-related stuff
# '\W' adds the name of the current directory
export PS1="$blue\u$green\$(__git_ps1)$cyan \W $ $reset"

