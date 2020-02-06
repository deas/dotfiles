# See last line "zprof"
# zmodload zsh/zprof
# setopt verbose
# setopt xtrace

# https://github.com/microsoft/WSL/issues/352
# Order matters
grep --quiet Microsoft /proc/version 2>/dev/null && [[ "$(umask)" == '000' ]] && umask 022

[ -e "$HOME/noscm.zsh" ] && source "$HOME/noscm.zsh"

source $HOME/.zsh/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

antigen bundle git
antigen bundle github
## git-flow
antigen bundle golang
antigen bundle jsontools
## vagrant
antigen bundle wp-cli
antigen bundle lein
antigen bundle mvn
antigen bundle gradle
antigen bundle npm
antigen bundle nvm
antigen bundle node
antigen bundle postgres
antigen bundle encode64
antigen bundle urltools
antigen bundle docker
antigen bundle docker-compose
antigen bundle pip
antigen bundle systemadmin
antigen bundle emoji
antigen bundle ubuntu
antigen bundle systemd
antigen bundle sudo
antigen bundle tmux
antigen bundle web-search
antigen bundle colored-man-page
antigen bundle debian
#antigen bundle react-native
# antigen bundle composer
antigen bundle python
antigen bundle virtualenv
antigen bundle httpie
antigen bundle yarn
antigen bundle kubectl
# antigen bundle aws
antigen bundle terraform
antigen bundle gem
antigen bundle z

antigen bundle zsh-users/zsh-history-substring-search
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle andrewferrier/fzf-z

# Load the theme.
# antigen theme agnoster
antigen theme robbyrussell

if [ -d "$HOME/.zsh/configs" ] ; then
    find "$HOME/.zsh/configs" -maxdepth 1 -name "*.zsh" | while read f
    do
	    source "$f"
    done
fi

# [ -e "$HOME/noscm.zsh" ] && source "$HOME/noscm.zsh"

# Tell Antigen that you're done.
antigen apply

# zprof
