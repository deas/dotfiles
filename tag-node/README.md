# tag-node — the headless / server profile

Files here are linked **only** when `TAGS` contains `node`. Nothing in this
directory reaches the desktop machines, which run `TAGS="desktop"`.

## Who selects it

Headless machines — servers and provisioned user accounts that get their
environment from a configuration-management layer rather than from this repo's
own `rcrc`. Such a consumer clones this repo out of band and renders a
dedicated rcrc pinned at the clone:

```sh
. <clone>/rcrc            # inherit this repo's EXCLUDES
EXCLUDES="$EXCLUDES .git justfile rcrc"
DOTFILES_DIRS="<clone>"
TAGS="node"
```

so it receives the **untagged root** of this repo plus this directory.

## What belongs here

Config that is wanted on a headless machine and is either useless or harmful on
a graphical workstation. Most personal config does **not** belong here — put it
in the untagged root so it applies everywhere.

Kept out of the untagged root because it must not reach a server:

- `tag-desktop/ssh/config` — its trusted-LAN `ForwardAgent yes` block is a
  workstation policy; a managed host gets its ssh policy from its own
  provisioning.
- `tag-desktop/local/bin/ansible-vault-pass` — a bare `echo "$ANSIBLE_PASSWORD"`
  would sit on `~/.local/bin` ahead of a managed host's real vault client.
- `tag-desktop/config/systemd/user/` — user units for desktop sessions and for
  services a managed host provisions itself.

## Overriding an untagged file

A tag directory does not only *add* files — within one `DOTFILES_DIRS` entry a
tagged file **wins** over the same path in the untagged root. That is the seam
for config that should exist everywhere but with different content per machine
kind.

`config/nvim/lazyvim.json` is the worked example. The untagged root carries the
workstation extras list (~45 entries: debuggers, JVM/.NET/Rust/Zig toolchains,
AI assistants, UI polish). Every one of those pulls plugins, and the `lang.*`
extras drive Mason to fetch language servers — a large network and disk
footprint that a headless machine has no use for. `tag-node/` therefore carries
its own `lazyvim.json` with the config-as-code subset: YAML, JSON, TOML,
Markdown, Ansible, Terraform, Docker, Nix, Python, plus `util.dot` for shell and
dotfile filetypes.

The non-`extras` keys (`install_version`, `news`, `version`) are kept identical
to the untagged file on purpose — LazyVim uses them to decide whether to re-run
its installer or re-show release notes.

Two things to know when editing either file:

- LazyVim **writes** `lazyvim.json` itself (`:LazyExtras`, and when it records
  news as seen). Since rcm links it, that write goes through the symlink and
  dirties this repo. Check `git status` after using `:LazyExtras`.
- `lazy-lock.json` is deliberately **not** tracked (see `config/nvim/.gitignore`).
  Plugin versions are therefore not pinned across machines; each one resolves to
  whatever the plugins' default branches point at when it first syncs.

## Precedence

A consumer that layers this repo on top of its own base typically lets that
base win name collisions. Files here that also exist in a common base
(`gitconfig`, `bashrc`, `profile`, `config/starship.toml`,
`config/tmux/tmux.conf`) may therefore not be linked at all. Prefer names the
base does not use.
