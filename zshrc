source ~/.zplug/init.zsh

# Make sure to use double quotes
zplug "zsh-users/zsh-history-substring-search"

# Use the package as a command
# And accept glob patterns (e.g., brace, wildcard, ...)
# zplug "Jxck/dotfiles", as:command, use:"bin/{histuniq,color}"

# Can manage everything e.g., other person's zshrc
# zplug "tcnksm/docker-alias", use:zshrc

# Disable updates using the "frozen" tag
# zplug "k4rthik/git-cal", as:command, frozen:1

# Grab binaries from GitHub Releases
# and rename with the "rename-to:" tag
# zplug "junegunn/fzf-bin", \
#     from:gh-r, \
#     as:command, \
#     rename-to:fzf, \
#     use:"*darwin*amd64*"

# Supports oh-my-zsh plugins and the like
zplug "plugins/git",   from:oh-my-zsh
zplug "plugins/github",   from:oh-my-zsh
# git-flow
zplug "plugins/golang",   from:oh-my-zsh
zplug "plugins/jsontools",   from:oh-my-zsh
# vagrant
zplug "plugins/wp-cli",   from:oh-my-zsh
zplug "plugins/lein",   from:oh-my-zsh
zplug "plugins/mvn",   from:oh-my-zsh
zplug "plugins/gradle",   from:oh-my-zsh
# grails
zplug "plugins/npm",   from:oh-my-zsh
zplug "plugins/nvm",   from:oh-my-zsh
zplug "plugins/node",   from:oh-my-zsh
zplug "plugins/postgres",   from:oh-my-zsh
zplug "plugins/encode64",   from:oh-my-zsh
zplug "plugins/urltools",   from:oh-my-zsh
zplug "plugins/docker",   from:oh-my-zsh
zplug "plugins/docker-compose",   from:oh-my-zsh
zplug "plugins/pip",   from:oh-my-zsh
zplug "plugins/systemadmin",   from:oh-my-zsh
zplug "plugins/emoji",   from:oh-my-zsh
zplug "plugins/ubuntu",   from:oh-my-zsh
zplug "plugins/systemd",   from:oh-my-zsh
zplug "plugins/sudo",   from:oh-my-zsh
zplug "plugins/tmux",   from:oh-my-zsh
zplug "plugins/web-search",   from:oh-my-zsh
zplug "plugins/colored-man-pages",   from:oh-my-zsh
zplug "plugins/debian",   from:oh-my-zsh
zplug "plugins/react-native",   from:oh-my-zsh
# zplug "plugins/composer",   from:oh-my-zsh
zplug "plugins/python",   from:oh-my-zsh
zplug "plugins/virtualenv",   from:oh-my-zsh
zplug "plugins/httpie",   from:oh-my-zsh
zplug "plugins/yarn",   from:oh-my-zsh
zplug "plugins/kubectl",   from:oh-my-zsh
# zplug "plugins/aws",   from:oh-my-zsh
zplug "plugins/terraform",   from:oh-my-zsh
zplug "plugins/gem",   from:oh-my-zsh


# Also prezto
zplug "modules/prompt", from:prezto

# Load if "if" tag returns true
# zplug "lib/clipboard", from:oh-my-zsh, if:"[[ $OSTYPE == *darwin* ]]"

# Run a command after a plugin is installed/updated
# Provided, it requires to set the variable like the following:
# ZPLUG_SUDO_PASSWORD="********"
# zplug "jhawthorn/fzy", \
#     as:command, \
#     rename-to:fzy, \
#     hook-build:"make && sudo make install"

# Supports checking out a specific branch/tag/commit
# zplug "b4b4r07/enhancd", at:v1
# zplug "mollifier/anyframe", at:4c23cb60

# Can manage gist file just like other packages
# zplug "b4b4r07/79ee61f7c140c63d2786", \
#     from:gist, \
#     as:command, \
#     use:get_last_pane_path.sh

# Support bitbucket
# zplug "b4b4r07/hello_bitbucket", \
#     from:bitbucket, \
#     as:command, \
#     use:"*.sh"

# Rename a command with the string captured with `use` tag
# zplug "b4b4r07/httpstat", \
#     as:command, \
#     use:'(*).sh', \
#     rename-to:'$1'

# Group dependencies
# Load "emoji-cli" if "jq" is installed in this example
# zplug "stedolan/jq", \
#     from:gh-r, \
#     as:command, \
#     rename-to:jq
#     zplug "b4b4r07/emoji-cli", \
#     on:"stedolan/jq"
# # Note: To specify the order in which packages should be loaded, use the defer
# #       tag described in the next section

# Set the priority when loading
# e.g., zsh-syntax-highlighting must be loaded
# after executing compinit command and sourcing other plugins
# (If the defer tag is given 2 or above, run after compinit command)
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# Can manage local plugins
# zplug "~/.zsh/plugins", from:local

# Load theme file
# zplug 'dracula/zsh', as:theme

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load
#--verbose

if [ -d "$HOME/.zsh/configs" ] ; then
    find "$HOME/.zsh/configs" -name "*.zsh" | while read f
    do
	source "$f"
    done
fi
