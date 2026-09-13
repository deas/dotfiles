
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

Packages (mise and nix)
------------
Two package planes, both declared here, both layered by the same rcm tags. A
machine gets the union of the layers its profile resolves — which is why a tool
is added by dropping a *fragment* in the right directory, never by running an
imperative install that only this machine remembers.

| | Where it is declared | Materialize | Remove |
| --- | --- | --- | --- |
| **mise** — exact-version toolchains, language runtimes, agent CLIs | `mise.toml`, `config/mise/conf.d/*.toml`, `tag-*/config/mise/conf.d/*.toml` | `mise install` | drop the line **and** `mise uninstall <tool> --all` |
| **nix** — the self-service long tail from nixpkgs | `config/nix/env/pkgs.d/*.nix` + the same path under `tag-*/` | `just nix-sync` | drop the line → `just nix-sync` |

**The removal column is the real difference.** mise does not own its set, so a
deleted line only stops *activating* a tool that stays on disk. The nix env is
one `buildEnv` in a single profile entry, so a sync adds and removes together —
and `nix profile rollback` undoes a step.

A nix fragment is a function from `pkgs` to a package list, and its filename is
its layer:

```nix
# tag-node/config/nix/env/pkgs.d/50-node.nix
pkgs: with pkgs; [
  cloc
]
```

Keep filenames distinct per layer — two layers with the same name means one
wins rather than both merging. `just nix-sync` prints which layers it resolved.

Three things about the nix plane that are not obvious, all of them mechanical:

- **`config/nix/env/flake.nix` and `flake.lock` are excluded from rcm** (see
  `rcrc`). They are the env's source, not dotfiles: `just nix-sync` copies them,
  with the fragments rcm composed, into `~/.local/state/dotfiles/nix-env` and
  installs from there. nix resolves a symlink found inside its store copy of a
  flake *against that copy*, so a linked `flake.nix` fails with
  `path '/nix/store/...-source/home/...' does not exist`.
- **`flake.lock` is the pin** and belongs in a commit — it is what makes two
  machines resolve the same packages. Bump it deliberately with `just
  nix-update`, never as a side effect of a sync.
- **`nix-sync` is not chained into `rcm-sync`.** `rcm-sync` has to stay fast and
  non-interactive for provisioning; this one builds and fetches. On a fresh
  machine run it after `just rcm-sync` — the same second step `mise install`
  needs. A machine without nix skips cleanly.

nix is a per-node grant, not a given: a server has it only where the
provisioning layer installed the daemon and put the account in `nix-users`.

misc
------------
- Markdown → PDF: `md2pdf` (`local/bin/md2pdf`, `md2pdf -h`) — pandoc plus
  either headless Chromium (default) or typst via `-e typst`, no LaTeX engine.
  Styled by `config/md2pdf/print.css` and `print.typ`, which a project
  overrides by keeping its own `docs/print.css` or `docs/print.typ`. The
  script's header records what each engine was measured to produce
- [Powerline fonts](https://github.com/powerline/fonts)
- [Setting up Windows Subsystem for Linux with zsh + oh-my-zsh + ConEmu](https://blog.joaograssi.com/windows-subsystem-for-linux-with-oh-my-zsh-conemu/)
- [Powerline fonts in crostini](https://www.reddit.com/r/Crostini/comments/9blkjv/powerline_fonts_in_the_crostini_terminal/)
- [zplug](https://github.com/zplug/zplug) appears to have a forkbomb issue on WSL
- [git submodule cheats](https://devconnected.com/how-to-add-and-update-git-submodules/)
