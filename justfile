# Beware of current working directory! Defaults to directory of justfile.
# e.g. : just -d . -f ~/.justfile repomix
# TODO: We likely want to introduce home dir setup via just. We may want to introduce a dedicated justfile for that

help:
  @just --list

# Create a repomix output file
[no-cd]
repomix:
  repomix 
