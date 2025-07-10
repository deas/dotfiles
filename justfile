# Beware of current working directory! Defaults to directory of justfile.
# e.g. : just -d . -f ~/.justfile repomix
# TODO: We likely want to introduce home dir setup via just. We may want to introduce a dedicated justfile for that

help:
  @just --list

# git sync
git-sync:
  git pull
  git submodule update --init --recursive

# rcm sync
rcm-sync:
  env RCRC=$HOME/dotfiles/rcrc rcup


# Create a repomix output file
[no-cd]
repomix:
  repomix 
