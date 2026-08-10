
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
| `tag-user-<login>/` | login name | per-account additions — orthogonal to the profile |
| `host-batman/`, `host-robin/` | hostname | per-machine overrides — orthogonal to tags |

**The machine recognizes itself.** `rcrc` sets `TAGS` by reading
`/etc/os-release`: the workstations run Omarchy (`ID=omarchy`) and take
`desktop`; everything else takes `node`. Nothing per-user selects the *profile*,
so every account on a host resolves to the same one — including service and
agent accounts that never log in interactively.

**Per-user overlay.** On top of that profile, `rcrc` appends `user-$(id -un)`,
so an account named `sl0p` also picks up `tag-user-sl0p/` if that directory
exists — rcm skips a tag with no directory, so most accounts get nothing extra.
Use it for config that should follow one login onto every machine it has;
reach for `$HOME/dotfiles-user` instead (see `DOTFILES_DIRS` in `rcrc`) when the
divergence belongs to a single provisioned account rather than to you. Keep
`tag-user-*/` file paths disjoint from `tag-desktop/` and `tag-node/`: rcm
documents that host dirs beat tags and tags beat the untagged root, but not
which of two *tags* wins the same path.

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
