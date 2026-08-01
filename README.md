
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
cd $HOME
env RCRC=$HOME/dotfiles/rcrc rcup
```

Profiles (rcm tags)
------------
The repo serves two kinds of machine. rcm's tag directories pick which:

| Where | Selected by | Gets |
| --- | --- | --- |
| untagged root | always | universal config — git, shell-agnostic CLI tooling, `bin/`, editors |
| `tag-desktop/` | `TAGS="desktop"` (this repo's `rcrc`) | omarchy/Hyprland GUI, workstation-only rc files and helpers |
| `tag-node/` | `TAGS="node"` (consumer's own rcrc) | headless server additions |
| `host-batman/`, `host-robin/` | hostname | per-machine overrides — orthogonal to tags |

The desktops source this repo's `rcrc`, which sets `TAGS="desktop"`, and so see
exactly what they always have.

Headless consumers — servers and provisioned user accounts — never source this
`rcrc`. Their configuration-management layer clones this repo out of band and
renders its own, pinning `DOTFILES_DIRS` at the clone and selecting
`TAGS="node"`, so they get the untagged root plus `tag-node/`. See
[`tag-node/README.md`](tag-node/README.md).

**Adding config:** default to the untagged root. Move it under `tag-desktop/`
only if it needs a GUI/session, or would be useless or harmful on a server.

misc
------------
- [Powerline fonts](https://github.com/powerline/fonts)
- [Setting up Windows Subsystem for Linux with zsh + oh-my-zsh + ConEmu](https://blog.joaograssi.com/windows-subsystem-for-linux-with-oh-my-zsh-conemu/)
- [Powerline fonts in crostini](https://www.reddit.com/r/Crostini/comments/9blkjv/powerline_fonts_in_the_crostini_terminal/)
- [zplug](https://github.com/zplug/zplug) appears to have a forkbomb issue on WSL
- [git submodule cheats](https://devconnected.com/how-to-add-and-update-git-submodules/)
