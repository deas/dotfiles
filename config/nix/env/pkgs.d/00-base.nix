# Universal layer — every machine with nix gets these. Anything that needs a
# graphical session, or is useless on a headless node, belongs in a tag layer
# instead (tag-desktop/, tag-node/, tag-user-<login>/, same pkgs.d path).
pkgs: with pkgs; [
  cloc
]
