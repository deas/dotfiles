# Interactive bash config for s0n nodes — sourced from ~/.config/s0n/rc.d/.
#
# The node's ~/.bashrc is a seeded stub that sources every ~/.config/s0n/rc.d/*.sh
# in sort order and holds no configuration itself. That directory is shared:
#
#   10-s0n.sh    the node project's hooks — PATH, the forwarded-ssh-agent
#                warning, the opt-in keychain ssh-agent lifecycle
#   60-deas.sh   this file: everything that is taste rather than a hook
#   90-tirith.sh the pre-execution command gate, which MUST load last
#
# So `60-` is not decorative. Anything here that hooks PROMPT_COMMAND or the
# DEBUG trap (the prompt, fzf, zoxide, direnv) has to sit between those two:
# after PATH is set, before tirith installs the trap it trampolines.
#
# tag-node only. Workstations keep their own arrangement and never source this.

# --- history -----------------------------------------------------------------
# NOTE: ignoreboth is why tirith's TIRITH_BASH_PREEXEC_ENFORCE=1 cannot work on
# these nodes — it needs a trustworthy `history 1`. The gate stays warn-only.
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s histappend
shopt -s checkwinsize

# --- pagers, colors, aliases -------------------------------------------------
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -x /usr/bin/dircolors ]; then
  if [ -r ~/.dircolors ]; then
    eval "$(dircolors -b ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history | tail -n1 | sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# --- completion --------------------------------------------------------------
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# --- prompt ------------------------------------------------------------------
# starship owns PS1 and the window title when it is on PATH; a node without it
# keeps bash's default. The forwarded-ssh-agent warning is deliberately NOT here
# — 10-s0n.sh renders it into PROMPT_COMMAND so it survives whatever prompt is
# in use, including this one.
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

# --- fzf ---------------------------------------------------------------------
# CTRL-R history, CTRL-T files, ALT-C cd, fuzzy completion. The package ships the
# files but NOTHING auto-sources them — bash-completion only lazy-loads
# completions, never key bindings. `fzf --bash` (fzf >= 0.48) emits both; the
# success-guard keeps an older distro fzf (no --bash flag) on its defaults.
if command -v fzf >/dev/null 2>&1; then
  if _deas_fzf="$(fzf --bash 2>/dev/null)"; then
    eval "$_deas_fzf"
  fi
  unset _deas_fzf
fi

# --- zoxide ------------------------------------------------------------------
# `z <frag>` jumps to a frecent dir, `zi` picks interactively. Probe like fzf so
# a machine without it silently keeps plain `cd`.
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi

# --- direnv ------------------------------------------------------------------
# Probed, never installed by us: the node project's own env comes from mise, but
# third-party checkouts ship an `.envrc` and expect the hook, and an un-hooked
# direnv is worse than none — the repo silently runs with the wrong env. So
# initialize whatever direnv the machine already has. `direnv allow` stays
# interactive by design; that trust prompt is the tool.
#
# After starship/zoxide on purpose: the hook chains onto PROMPT_COMMAND and must
# see theirs already in place (upstream's "put it last" — within this file;
# tirith is later still, in its own fragment).
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi

# --- browser-harness ---------------------------------------------------------
# The browser is NOT on this node — it is the real, logged-in Chrome on whichever
# workstation is in use, published here by `browser-cdp-push` (tag-desktop) over
# an ssh -R. That command owns this file and deletes it when the tunnel drops, so
# a MISSING file means "no browser", never a stale endpoint.
#
# Sourced rather than set statically because the value is not stable: Chrome
# refuses --remote-debugging-port on a default profile (M136+), so the real
# profile is reachable only via the chrome://inspect toggle, which re-rolls both
# the port and the browser uuid on every launch. It is BU_CDP_WS and not
# BU_CDP_URL because Chrome also stopped serving /json/* on that profile (M147+),
# and BU_CDP_URL's fallback resolves the ws path from LOCAL profile dirs, which
# this node has none of.
#
# An explicit endpoint also disables the harness's local-Chrome machinery, which
# on a headless node would otherwise try to launch a browser with no display.
#
# GOTCHA: the daemon inherits the env of whatever first started it and keeps that
# endpoint for its lifetime. After the workstation's Chrome restarts, re-run the
# push, re-source this, then `browser-harness --reload`.
# An `if` rather than a `&&` chain: this is the last line of the fragment, and a
# bare test would leave $? at 1 whenever no browser is published.
if [ -r "$HOME/.cache/browser-cdp.env" ]; then
  . "$HOME/.cache/browser-cdp.env"
fi
