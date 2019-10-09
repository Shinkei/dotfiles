export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# git autocomplete
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion || {
    # if not found in /usr/local/etc, try the brew --prefix location
    [ -f "$(brew --prefix)/etc/bash_completion.d/git-completion.bash" ] && \
        . $(brew --prefix)/etc/bash_completion.d/git-completion.bash
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#Powerline
powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
source /usr/local/lib/python3.7/site-packages/powerline/bindings/bash/powerline.sh

# Alias
alias pra='pm2 reload all'
alias pk='pm2 kill'
alias psd='pm2 start pm2-development.yml'

# variable to load the configuration for the JTI project (this is a file on the config folder)
export HOST=jorge
export JEST_PUPPETEER_CONFIG='./end-to-end/jest-puppeteer.config.js'
