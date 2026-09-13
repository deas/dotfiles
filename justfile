# Beware of current working directory! Defaults to directory of justfile.
# e.g. : just -d . -f ~/.justfile repomix
# TODO: We likely want to introduce home dir setup via just. We may want to introduce a dedicated justfile for that

help:
  @just --list

# git sync
git-sync:
  git pull
  git submodule update --init --recursive

# rcm sync — the one entrypoint, on a workstation and on a provisioned node
# alike. The rcrc recognizes which. Keep it non-interactive: provisioning runs
# it with no tty, where a prompt is answered "no".
rcm-sync:
  cd "$HOME" && env RCRC="{{justfile_directory()}}/rcrc" rcup -v

# Remove dotfile symlinks left dangling by a source that moved or went away.
# Split out of rcm-sync because it prompts. Sweeps $HOME, so read each one.
rcm-clean:
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

# --- nix: user-scoped packages -----------------------------------------------
# The sibling of the mise tool set. The DECLARATION is config/nix/env: a flake
# plus pkgs.d/ fragments that rcm layers by the same tags as everything else,
# composing them into ~/.config/nix/env/pkgs.d. These recipes MATERIALIZE that
# into the user's default nix profile as one buildEnv entry, so dropping a
# package removes it.
#
# Why the build dir: rcm delivers files as absolute symlinks, and nix resolves
# a symlink found inside its store copy of a flake against THAT COPY, so a
# symlinked flake.nix fails ("path '/nix/store/...-source/home/...' does not
# exist"). So the recipe copies the flake, the lock and the composed fragments
# into ~/.local/state/dotfiles/nix-env and installs from there — real files,
# pure evaluation, rcm still the thing that decided which layers apply.
# Timestamps are preserved so an unchanged set re-resolves to the same flake.
#
# Deliberately NOT chained into rcm-sync: that recipe must stay fast and
# non-interactive for provisioning, and this one builds and fetches. Nix is a
# per-node grant, not a given — a machine without it skips cleanly.

# Materialize the declared nix package set into this user's profile
nix-sync:
  #!/usr/bin/env bash
  set -euo pipefail
  command -v nix >/dev/null || { echo "nix-sync: no nix on this machine — nothing to do"; exit 0; }
  src="{{justfile_directory()}}/config/nix/env"
  frags="$HOME/.config/nix/env/pkgs.d"
  build="$HOME/.local/state/dotfiles/nix-env"
  [ -d "$frags" ] || { echo "nix-sync: $frags missing — run 'just rcm-sync' first" >&2; exit 1; }
  rm -rf "$build"
  mkdir -p "$build/pkgs.d"
  cp -p "$src/flake.nix" "$src/flake.lock" "$build/"
  # -L dereferences rcm's symlinks into real files; -p keeps the source mtimes
  # so an unchanged declaration does not look like a new flake every run.
  cp -pL "$frags"/*.nix "$build/pkgs.d/"
  # Directory mtimes are what nix reads as the flake's lastModified, and mkdir
  # made them "now" — without this every run reports an upgrade to an identical
  # narHash. Stamp them from the newest declaration instead.
  newest="$(ls -t "$build/flake.nix" "$build/pkgs.d"/*.nix | head -n1)"
  touch -r "$newest" "$build/pkgs.d" "$build"
  # --no-write-lock-file: the lock is the repo's, bumped by `just nix-update`
  # alone, never as a side effect of a sync.
  ref="path:$build"
  element() { nix profile list --json | jq -r --arg url "$1" '.elements | to_entries[] | select(.value.originalUrl == $url) | .key' | head -n1; }
  # One-time migration: the env used to be provisioned to ~/.config/nix/env and
  # installed from there. That element can no longer upgrade (its flake is gone),
  # so it would pin stale packages on PATH forever. Undo with `nix profile rollback`.
  legacy="$(element "path:$HOME/.config/nix/env")"
  if [ -n "$legacy" ]; then
    echo "nix-sync: removing the superseded profile entry '$legacy' (was: ~/.config/nix/env)"
    nix profile remove "$legacy"
  fi
  name="$(element "$ref")"
  if [ -n "$name" ]; then
    nix profile upgrade --no-write-lock-file "$name"
  else
    nix profile install --no-write-lock-file "$ref"
  fi
  echo "nix-sync: layers applied: $(nix eval --json "$ref#fragments" | jq -r 'join(", ")')"

# Bump the nixpkgs pin (commit the lock), then materialize it
nix-update:
  # `path:` explicitly, never a bare path: this flake lives INSIDE a git repo,
  # and a bare path makes nix auto-detect git and see only TRACKED files — on a
  # fresh checkout of these files that is an error, and after an edit it would
  # read the committed version rather than the one in front of you.
  nix flake update --flake "path:{{justfile_directory()}}/config/nix/env"
  @just nix-sync
