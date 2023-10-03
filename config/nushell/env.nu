# Nushell Environment Config File
#
# version = "0.84.0"

def create_left_prompt [] {
    mut home = ""
    try {
        if $nu.os-info.name == "windows" {
            $home = $env.USERPROFILE
        } else {
            $home = $env.HOME
        }
    }

    let dir = ([
        ($env.PWD | str substring 0..($home | str length) | str replace $home "~"),
        ($env.PWD | str substring ($home | str length)..)
    ] | str join)

    let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
    let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
    let path_segment = $"($path_color)($dir)"

    $path_segment | str replace --all (char path_sep) $"($separator_color)/($path_color)"
}

def create_right_prompt [] {
    # create a right prompt in magenta with green separators and am/pm underlined
    let time_segment = ([
        (ansi reset)
        (ansi magenta)
        (date now | format date '%Y/%m/%d %r')
    ] | str join | str replace --regex --all "([/:])" $"(ansi green)${1}(ansi magenta)" |
        str replace --regex --all "([AP]M)" $"(ansi magenta_underline)${1}")

    let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
        (ansi rb)
        ($env.LAST_EXIT_CODE)
    ] | str join)
    } else { "" }

    ([$last_exit_code, (char space), $time_segment] | str join)
}

# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = {|| create_left_prompt }
# $env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = {|| "> " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| ": " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "> " }
$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

# Directories to search for scripts when calling source or use
$env.NU_LIB_DIRS = [
    # ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
]

# Directories to search for plugin binaries when calling register
$env.NU_PLUGIN_DIRS = [
    # ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]

# https://www.nushell.sh/cookbook/ssh_agent.html

$env.DOCKER_BUILDKIT = 1 

$env.GEM_HOME = $env.HOME + "/gems"

ssh-agent -c
    | lines
    | first 2
    | parse "setenv {name} {value};"
    | transpose -r
    | into record
    | load-env

# TODO: Mostly from misc-common.zsh
# Tons of zsh completion

# # Harmonize with Crostini
# # https://clojure.org/reference/deps_and_cli
# if [ -n "$XDG_CONFIG_HOME" ] ; then
#     export CLJ_CONFIG=$HOME/.clojure
# fi

if (not 'XDG_CONFIG_HOME' in $env) {
    $env.CLJ_CONFIG = $env.PATH + "/.clojure"
}

if ($env.HOME + "/go" | path exists ) {
    $env.PATH = ($env.PATH | split row (char esep) | prepend ($env.HOME + "/go") )
}

if ($env.HOME + "/.local/bin" | path exists ) {
    $env.PATH = ($env.PATH | split row (char esep) | prepend ($env.HOME + "/.local/bin") )
}

if ($env.HOME + "/bin" | path exists ) {
    $env.PATH = ($env.PATH | split row (char esep) | prepend ($env.HOME + "/bin") )
}

# if ($env.HOME + "/.poetry/bin" | path exists ) {
#     $env.PATH = ($env.PATH | split row (char esep) | prepend ($env.HOME + "/.poetry/bin") )
# }

if ($env.HOME + "/.babashka/bbin/bin" | path exists ) {
    $env.PATH = ($env.PATH | split row (char esep) | prepend ($env.HOME + "/.babashka/bbin/bin") )
}

if ($env.HOME + "/.crc/bin/oc" | path exists ) {
    $env.PATH = ($env.PATH | split row (char esep) | prepend ($env.HOME + "/.crc/bin/oc") )
}

if ($env.HOME + "/.krew/bin" | path exists ) {
    $env.PATH = ($env.PATH | split row (char esep) | prepend ($env.HOME + "/.krew/bin") )
}

if ($env.GEM_HOME + "/bin" | path exists ) {
    $env.PATH = ($env.PATH | split row (char esep) | prepend ($env.GEM_HOME + "/bin") )
}

# Ruby
# if [ -d "$HOME/.rvm/bin" ] ; then
#   PATH="$PATH:$HOME/.rvm/bin"
# fi

# export GEM_HOME="$HOME/gems"

# if [ -d "$GEM_HOME/bin" ] ; then
#   PATH="$PATH:$GEM_HOME/bin"
# fi

# if [ -d "$HOME/go" ] ; then
#   PATH="$PATH:$HOME/go/bin"
# fi


# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')
# $env.ATUIN_CONFIG_DIR = $env.HOME + "/.config/atuin-nu"