# User-scoped nix packages, declared here — the sibling of the mise tool set
# (config/mise/conf.d + mise.toml). This project owns WHICH packages; a node
# supplies only the nix binary and the group grant.
#
# The package list is deliberately NOT in this file: it is assembled from every
# `pkgs.d/*.nix` fragment. That indirection is what lets rcm's profile tags
# layer nix the way mise's conf.d fragments already layer — the untagged root
# for what every machine gets, `tag-node/`, `tag-desktop/` and
# `tag-user-<login>/` for the rest, and the first-listed DOTFILES_DIRS entry
# winning a name collision. Give each layer its own filename; same name, one
# layer wins.
#
# A fragment is a function from `pkgs` to a package list:
#
#     pkgs: with pkgs; [ cloc ]
#
# ONE buildEnv is the flake's default package, so a machine's whole set is a
# SINGLE profile entry: `just nix-sync` adds AND removes together (unlike mise,
# where a dropped line only deactivates), and `nix profile rollback` undoes a
# step. Versions come from the committed flake.lock; `just nix-update` is the
# deliberate upgrade path.
#
# THIS FILE IS NOT THE FLAKE THE PROFILE IS BUILT FROM. `just nix-sync` copies
# it, the lock and the rcm-composed fragments into a materialized build dir
# (~/.local/state/dotfiles/nix-env) and installs THAT. The reason is mechanical:
# rcm delivers files as absolute symlinks, and nix resolves a symlink found
# inside its store copy of the flake AGAINST THE COPY — so a symlinked
# flake.nix fails with "path '/nix/store/...-source/home/...' does not exist".
# Copying is also what keeps evaluation pure. rcrc EXCLUDES this file and the
# lock from rcm for the same reason: a symlink here would only be a trap.
{
  description = "user-scoped package env, declared in the dotfiles repo";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      fragmentDir = ./pkgs.d;
      fragmentNames = builtins.filter
        (name: builtins.match ".*\\.nix" name != null)
        (builtins.attrNames (builtins.readDir fragmentDir));
    in
    {
      packages = forAllSystems (pkgs: {
        default = pkgs.buildEnv {
          name = "user-env";
          paths = builtins.concatMap
            (name: import (fragmentDir + "/${name}") pkgs)
            fragmentNames;
        };
      });

      # Which layers this machine actually resolved — the debugging handle when
      # a package you declared is not on PATH:
      #   nix eval "path:$HOME/.local/state/dotfiles/nix-env#fragments"
      fragments = fragmentNames;
    };
}
