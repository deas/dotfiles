# Headless-node layer — merged on top of pkgs.d/00-base.nix by the flake's
# fragment glob. Empty on purpose: it is the seam, kept so the layering is
# visible rather than discovered when it is first needed.
pkgs: with pkgs; [
]
