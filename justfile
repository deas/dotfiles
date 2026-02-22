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
  cd "$HOME" && env RCRC="$HOME/dotfiles/rcrc" rcup -v
  find "$HOME" -maxdepth 3 -xtype l -ok rm {} \;

# Create a repomix output file
[no-cd]
repomix:
  repomix 

# Create automation entry in gnome-keyring
create-ks-secret key:
  secret-tool store --label="auto {{key}}" path "/automation/{{key}}"

# Deep merge all JSON files - make sure to quote the glob "*.json"
json-merge glob:
    jq -s 'reduce .[] as $item ({}; . * $item)' {{glob}}
