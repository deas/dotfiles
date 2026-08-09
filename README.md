
dotfiles on steroids
===================

... based on [rcm](https://github.com/thoughtbot/rcm), [thoughtbot dotfiles](https://github.com/thoughtbot/dotfiles)  and [antigen](https://github.com/zsh-users/antigen)



tl;dr install
------------
Clone (or fork):
```
git clone git://github.com/deas/dotfiles.git ~/dotfiles
cd dotfiles
git submodule update --init --recursive
just rcm-sync
```

`just rcm-sync` is the entrypoint everywhere — typed on a workstation, and run
by a configuration-management layer on a provisioned server. It is `rcup` with
this repo's `rcrc`, and once it has run, `~/.rcrc` is a link to that file, so a
bare `rcup` works too. Keep the recipe non-interactive; `just rcm-clean` is the
separate, prompting sweep for symlinks left dangling by a source that moved.

Profiles (rcm tags)
------------
The repo serves two kinds of machine. rcm's tag directories pick which:

| Where | Selected by | Gets |
| --- | --- | --- |
| untagged root | always | universal config — git, shell-agnostic CLI tooling, `bin/`, editors |
| `tag-desktop/` | `TAGS="desktop"` | omarchy/Hyprland GUI, workstation-only rc files and helpers |
| `tag-node/` | `TAGS="node"` | headless server additions |
| `host-batman/`, `host-robin/` | hostname | per-machine overrides — orthogonal to tags |

**The machine recognizes itself.** `rcrc` sets `TAGS` by reading
`/etc/os-release`: the workstations run Omarchy (`ID=omarchy`) and take
`desktop`; everything else takes `node`. Nothing per-user selects a profile, so
every account on a host resolves to the same one — including service and agent
accounts that never log in interactively.

The polarity is deliberate: desktop must be *proven*, and anything unrecognized
falls to `node`. A desktop mistaken for a node merely loses its GUI config,
whereas a node mistaken for a desktop would take `tag-desktop/`'s
`ForwardAgent` ssh config, its `ansible-vault-pass` shim and its user units.
See [`tag-node/README.md`](tag-node/README.md).

Override for a one-off or an odd machine — a headless box that is not Omarchy
but *is* your workstation, say:

```
RCM_PROFILE=desktop just rcm-sync
```

**Adding config:** default to the untagged root. Move it under `tag-desktop/`
only if it needs a GUI/session, or would be useless or harmful on a server.

misc
------------
- [Powerline fonts](https://github.com/powerline/fonts)
- [Setting up Windows Subsystem for Linux with zsh + oh-my-zsh + ConEmu](https://blog.joaograssi.com/windows-subsystem-for-linux-with-oh-my-zsh-conemu/)
- [Powerline fonts in crostini](https://www.reddit.com/r/Crostini/comments/9blkjv/powerline_fonts_in_the_crostini_terminal/)
- [zplug](https://github.com/zplug/zplug) appears to have a forkbomb issue on WSL
- [git submodule cheats](https://devconnected.com/how-to-add-and-update-git-submodules/)
