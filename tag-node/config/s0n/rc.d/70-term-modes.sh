# shellcheck shell=bash
# shellcheck disable=SC2016 # literal escape-sequence text, $ is not an expansion
# Terminal-mode leak detector (diagnostic; TODO.md "find what leaves
# kitty-keyboard/mouse modes on over ssh").
#
# Symptom it hunts: after some program exits, Ctrl+C prints `9;133u` and the
# scroll wheel prints escape codes. A TUI pushed the kitty keyboard protocol
# (`ESC[>Nu`) or enabled mouse tracking (`ESC[?1000h`…`1006h`) and never undid
# it: it crashed, was killed, or its ssh link dropped.
#
# At each prompt this asks the terminal for its state: kitty flags (`ESC[?u`),
# and DECRQM for each mouse mode (`ESC[?1000$p`). It ends with DA1 (`ESC[c`),
# which every terminal answers, so the reply always has a known end (`c`). If
# anything is still on, it appends the previous command, its exit status and
# the raw reply to ~/.cache/term-modes.log, then switches the modes off. So it
# also fixes the symptom one prompt late.
#
# Inside tmux, tmux answers for the current pane. That is the scope we want.
#
# A terminal that answers nothing (an agent's pty, a dumb console) would make
# every prompt wait out the timeout. The first silent timeout disables the
# detector for the rest of that shell.
#
# 70-: after the prompt setup in 60-, before tirith's 90- hook (which wraps
# whatever is already in PROMPT_COMMAND/DEBUG). Remove this file once the
# culprit is found; it is a diagnostic, not permanent config.

case $- in *i*) ;; *) return 0 ;; esac
[ -t 0 ] && [ -t 1 ] || return 0
case ${TERM:-dumb} in dumb | unknown) return 0 ;; esac

_term_modes_check() {
  local st=$? reply last
  [ -n "${_TERM_MODES_OFF:-}" ] && return "$st"
  printf '\e[?u\e[?1000$p\e[?1002$p\e[?1003$p\e[?1006$p\e[c' >/dev/tty
  # -d c puts the tty in cbreak mode, so the reply is read unechoed and without
  # a newline. The DA1 reply is the only one containing a `c`.
  if ! IFS= read -rs -d c -t 0.5 reply </dev/tty; then
    if [ -z "$reply" ]; then
      _TERM_MODES_OFF=1 # terminal does not answer: stop asking
      return "$st"
    fi
  fi
  case $reply in
  *'[?'[1-9]*u* | *'1000;1$y'* | *'1002;1$y'* | *'1003;1$y'* | *'1006;1$y'*)
    # `history 1`, not `fc -ln -1`: inside PROMPT_COMMAND here fc lags by one
    # entry (verified on h0, bash + tirith). Strip the "  123  " number prefix.
    # A space-prefixed command is not in history (HISTCONTROL=ignoreboth), so
    # it would be logged as the command before it.
    last=$(HISTTIMEFORMAT='' builtin history 1 2>/dev/null)
    last=${last#"${last%%[![:space:]]*}"}
    last=${last#"${last%%[![:digit:]]*}"}
    last=${last#"${last%%[![:space:]]*}"}
    mkdir -p "$HOME/.cache"
    printf '%s %s tty=%s tmux=%s status=%s after: %s | %q\n' \
      "$(date +%FT%T)" "$(uname -n)" "${SSH_TTY:-local}" "${TMUX_PANE:--}" \
      "$st" "${last:-?}" "$reply" >>"$HOME/.cache/term-modes.log"
    # Pop kitty flags (a few times: pushes can nest), mouse modes off.
    printf '\e[<u\e[<u\e[<u\e[<u\e[?1000l\e[?1002l\e[?1003l\e[?1006l' >/dev/tty
    # Say so, once, above the prompt: which modes, and which command.
    local modes='' m
    case $reply in *'[?'[1-9]*u*) modes='kitty-keys' ;; esac
    for m in 1000 1002 1003 1006; do
      case $reply in *"$m;1\$y"*) modes="${modes:+$modes,}mouse-$m" ;; esac
    done
    last=${last//[[:cntrl:]]/?} # never echo raw control bytes back
    [ "${#last}" -gt 60 ] && last="${last:0:57}..."
    printf '\e[33mterm-modes: `%s` left %s on (status %s); reset, logged to ~/.cache/term-modes.log\e[0m\n' \
      "${last:-?}" "$modes" "$st" >/dev/tty
    ;;
  esac
  return "$st"
}

# Prepend, so $? is still the user's command's status when we read it. bash 5.1+
# allows PROMPT_COMMAND to be an array (tirith and starship append to it here),
# so keep whichever form it already has.
if [[ "$(declare -p PROMPT_COMMAND 2>/dev/null)" == "declare -a"* ]]; then
  PROMPT_COMMAND=(_term_modes_check "${PROMPT_COMMAND[@]}")
else
  # shellcheck disable=SC2128,SC2178 # string form: this branch only runs when it is not an array
  PROMPT_COMMAND="_term_modes_check${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
fi
