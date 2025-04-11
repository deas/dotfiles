# Beware of current working directory! Defaults to directory of justfile.
# e.g. : just -d . -f ~/.justfile repomix

# Create a repomix output file
[no-cd]
repomix:
  repomix 
