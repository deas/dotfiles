# See last line "zprof"
# zmodload zsh/zprof
# setopt verbose
# setopt xtrace

# https://github.com/microsoft/WSL/issues/352
# Order matters
grep --quiet Microsoft /proc/version 2>/dev/null && [[ "$(umask)" == '000' ]] && umask 022

[ -e "$HOME/noscm.zsh" ] && source "$HOME/noscm.zsh"

# which helm > /dev/null && source <(helm completion zsh)
# which kubectl > /dev/null && source <(kubectl completion zsh)
# which oc > /dev/null && source <(oc completion zsh)

source $HOME/.zsh/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

antigen bundles <<EOBUNDLES
  git
  github
  golang
  jsontools
  wp-cli
  lein
  mvn
  gradle
  npm
  nvm
  node
  postgres
  encode64
  urltools
  docker
  docker-compose
  pip
  systemadmin
  emoji
  ubuntu
  systemd
  sudo
  tmux
  web-search
  colored-man-page
  debian
  python
  virtualenv
  httpie
  yarn
  kubectl
  terraform
  gem
  z
  zsh-users/zsh-history-substring-search
  zsh-users/zsh-autosuggestions
  andrewferrier/fzf-z
  $HOME/.zsh/hacks
EOBUNDLES
# vagrant
# git-flow
#  react-native
#   composer
#   aws
# TODO: https://github.com/zsh-users/antigen/issues/701

# Load the theme.
# antigen theme agnoster
antigen theme robbyrussell

# PROMPT='$(kube_ps1)'$PROMPT

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
