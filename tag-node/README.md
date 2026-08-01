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

## Precedence

A consumer that layers this repo on top of its own base typically lets that
base win name collisions. Files here that also exist in a common base
(`gitconfig`, `bashrc`, `profile`, `config/starship.toml`,
`config/tmux/tmux.conf`) may therefore not be linked at all. Prefer names the
base does not use.
