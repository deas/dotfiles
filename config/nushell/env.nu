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

$env.DOCKER_BUILDKIT = 1 

# Agent should be started by desktop only (-> .config/autostart)
#
# https://www.nushell.sh/cookbook/ssh_agent.html
#
# ssh-agent -c
#     | lines
#     | first 2
#     | parse "setenv {name} {value};"
#     | transpose -r
#     | into record
#     | load-env

# How do we test whether file is executable?
if ( ("/usr/bin/ksshaskpass" | path type) == "file") {
    $env.SSH_ASKPASS = "/usr/bin/ksshaskpass"
}

# Mostly from misc-common.zsh
# TODO: Anything missing from /etc/profile.d?
# TODO: How do we fix/recover with ssh-agent (forwarding)
# SSH_AGENT_PID=2679456
# SSH_AUTH_SOCK=/tmp/ssh-XXXXXXM3XK4Z/agent.2679454
# SSH_CLIENT=...
# SSH_CONNECTION=...
# SSH_TTY=/dev/pts/7
# TODO: Does prepend to path give us the order we expect?
# TODO: Basic sdkman support
# TODO: direnv dotenv json .env | from json | load-env # (no hygiene!) # https://github.com/enerdgumen/nu_plugin_dotenv
# TODO: .envrc/nix

# /home/deas/.sdkman/candidates/

# # if ((not $env.HOME + "/.nix-profile/bin" in $env.PATH) and ("/nix/var/nix/profiles/default" | path exists) ) {
# if ( $env.HOME + "/.sdkman/candidates" | path exists ) {
#     $env.HOME + "/.sdkman/candidates" | ls | each { |e| echo $e} 
# #    $env.PATH = ($env.PATH | split row (char esep) | prepend ($env.HOME + "/.nix-profile/bin" ) | prepend "/nix/var/nix/profiles/default/bin")
# }

# # Harmonize with Crostini
# # https://clojure.org/reference/deps_and_cli
# if [ -n "$XDG_CONFIG_HOME" ] ; then
#     export CLJ_CONFIG=$HOME/.clojure
# fi

if (not 'XDG_CONFIG_HOME' in $env) {
    $env.CLJ_CONFIG = $env.HOME + "/.clojure"
}

def setup-path [path: string] {
    if ((not $path in $env.PATH) and ($path | path exists) ) {
        return ($env.PATH | split row (char esep) | prepend ($path) )
    }
    return $env.PATH
    # let dir = ([
    #     ($env.PWD | str substring 0..($home | str length) | str replace $home "~"),
    #     ($env.PWD | str substring ($home | str length)..)
    # ] | str join)
    # $path_segment | str replace --all (char path_sep) $"($separator_color)/($path_color)"
}

# condition needs to cover both cases - login shell or not should probably
# make a function here


$env.GEM_HOME = $env.HOME + "/gems"

$env.PATH = (setup-path ($env.HOME + "/go"))
$env.PATH = (setup-path ($env.HOME + "/.local/bin"))
$env.PATH = (setup-path ($env.HOME + "/bin"))
$env.PATH = (setup-path ($env.HOME + "/.babashka/bbin/bin"))
$env.PATH = (setup-path ($env.HOME + "/.crc/bin/oc"))
$env.PATH = (setup-path ($env.HOME + "/.krew/bin"))
$env.PATH = (setup-path ($env.HOME + "/.cargo/bin"))
$env.PATH = (setup-path ($env.GEM_HOME + "/bin"))

let sdk_candidates = $env.HOME + "/.sdkman/candidates"

if ($sdk_candidates | path exists) {
    let paths = ls $sdk_candidates |
     each { |it| $it.name + "/current/bin"} |
     filter {|it| $it | path exists }
     $env.PATH = ($env.PATH | split row (char esep) | prepend $paths)
}

# if ((not $env.HOME + "/go" in $env.PATH) and ($env.HOME + "/go" | path exists) ) {
#     $env.PATH = ($env.PATH | split row (char esep) | prepend ($env.HOME + "/go") )
# }

# if ((not $env.HOME + "/.local/bin" in $env.PATH) and ($env.HOME + "/.local/bin" | path exists) ) {
#     $env.PATH = ($env.PATH | split row (char esep) | prepend ($env.HOME + "/.local/bin") )
# }
# 
# if ((not $env.HOME + "/bin" in $env.PATH) and ($env.HOME + "/bin" | path exists) ) {
#     $env.PATH = ($env.PATH | split row (char esep) | prepend ($env.HOME + "/bin") )
# }

# if ($env.HOME + "/.poetry/bin" | path exists ) {
#     $env.PATH = ($env.PATH | split row (char esep) | prepend ($env.HOME + "/.poetry/bin") )
# }

# if ((not $env.HOME + "/.babashka/bbin/bin" in $env.PATH) and ($env.HOME + "/.babashka/bbin/bin" | path exists) ) {
#     $env.PATH = ($env.PATH | split row (char esep) | prepend ($env.HOME + "/.babashka/bbin/bin") )
# }
# 
# if ((not $env.HOME + "/.crc/bin/oc" in $env.PATH) and ($env.HOME + "/.crc/bin/oc" | path exists) ) {
#     $env.PATH = ($env.PATH | split row (char esep) | prepend ($env.HOME + "/.crc/bin/oc") )
# }
# 
# if ((not $env.HOME + "/.krew/bin" in $env.PATH) and ($env.HOME + "/.krew/bin" | path exists) ) {
#     $env.PATH = ($env.PATH | split row (char esep) | prepend ($env.HOME + "/.krew/bin") )
# }
# 
# if ((not $env.HOME + "/.cargo/bin" in $env.PATH) and ($env.HOME + "/.cargo/bin" | path exists) ) {
#     $env.PATH = ($env.PATH | split row (char esep) | prepend ($env.HOME + "/.cargo/bin") )
# }


# TODO: nvm posix based: https://dev.to/vaibhavdn/using-fnm-with-nushell-3kh1 appears to be best alternative unless we use nix
if ((not $env.HOME + "/.local/share/fnm" in $env.PATH) and ($env.HOME + "/.local/share/fnm" | path exists) ) {
    $env.PATH = ($env.PATH | split row (char esep) | prepend ($env.HOME + "/.local/share/fnm") )
    load-env (fnm env --shell bash
        | lines
        | str replace 'export ' ''
        | str replace -a '"' ''
        | split column =
        | rename name value
        | where name != "FNM_ARCH" and name != "PATH"
        | reduce -f {} {|it, acc| $acc | upsert $it.name $it.value }
    )

    $env.PATH = ($env.PATH
        | split row (char esep)
        | prepend $"($env.FNM_MULTISHELL_PATH)/bin"
    )
}

if ((not $env.HOME + "/.nix-profile/bin" in $env.PATH) and ("/nix/var/nix/profiles/default" | path exists) ) {
    $env.NIX_PROFILES = "/nix/var/nix/profiles/default /home/deas/.nix-profile"
    $env.NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt"
    $env.PATH = ($env.PATH | split row (char esep) | prepend ($env.HOME + "/.nix-profile/bin" ) | prepend "/nix/var/nix/profiles/default/bin")
}

# $env.GEM_HOME = $env.HOME + "/gems"
# 
# if ((not $env.GEM_HOME + "/bin" in $env.PATH) and ($env.GEM_HOME + "/bin" | path exists) ) {
#     $env.PATH = ($env.PATH | split row (char esep) | prepend ($env.GEM_HOME + "/bin") )
# }

# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')
# $env.ATUIN_CONFIG_DIR = $env.HOME + "/.config/atuin-nu"