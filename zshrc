# See last line "zprof"
# zmodload zsh/zprof
# setopt verbose
# setopt xtrace

# https://github.com/microsoft/WSL/issues/352
# Order matters

grep --quiet Microsoft /proc/version 2>/dev/null && [[ "$(umask)" == '000' ]] && umask 022

[ -e "$HOME/noscm.zsh" ] && source "$HOME/noscm.zsh"

ZSH=$HOME/.oh-my-zsh
# ZSH="$HOME/.antigen/bundles/robbyrussell/oh-my-zsh/"
# ZSH_THEME="robbyrussell"
ZSH_THEME="agnoster" # set by `omz`

# source $HOME/.zsh/antigen.zsh
# antigen use oh-my-zsh

# TODO: https://github.com/zsh-users/antigen/issues/701
#
# antigen bundles <<EOBUNDLES
plugins=(
  aws
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
  colored-man-pages
  debian
  python
#  virtualenv
  virtualenvwrapper
  poetry
  httpie
  yarn
  kubectl
  kube-ps1
  terraform
  gem
  z
  asdf
  extract
  gh
  autojump
  common-aliases
  alias-finder
  fzf
  zsh-autosuggestions
  rust
  ripgrep
  vscode
#  nix-zsh-completions
#  vi-mode
)
#  zsh-users/zsh-history-substring-search
#  zsh-users/zsh-autosuggestions
#  andrewferrier/fzf-z
#  $HOME/.zsh/hacks
# EOBUNDLES

# Conditionally append to array
# if ... ; then
#    plugins+=another-pugin
# fi
export WORKON_HOME=$HOME/.virtualenvs

fpath+=$HOME/.zsh/completion

source "$ZSH/oh-my-zsh.sh"

# ZSH_USERS_DIR=$HOME/.antigen/bundles/zsh-users
#
# if [ -d "$ZSH_USERS_DIR" ] ; then
#    source "${ZSH_USERS}_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
#    source "${ZSH_USERS}_DIR/zsh-history-substring-search/zsh-history-substring-search.zsh"
# fi
# source $ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# vagrant
# git-flow
#  react-native
#   composer
#   aws
# TODO: https://github.com/zsh-users/antigen/issues/701

# Load the theme.
# antigen theme agnoster
# antigen theme ${ZSH_THEME}

# PROMPT='$(kube_ps1)'$PROMPT

if [ -d "$HOME/.zsh/configs" ] ; then
    find "$HOME/.zsh/configs" -maxdepth 1 -name "*.zsh" | while read f
    do
	    source "$f"
    done
fi

# Tell Antigen that you're done.
# antigen apply

kubeoff

PROMPT=$PROMPT'$(kube_ps1)'

# zprof

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


eval "$(atuin init zsh)"
