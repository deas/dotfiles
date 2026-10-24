# Dotfiles and rcm

This folder is a git dotfiles repository.

## General Guidance

Use tools to work with files and folders.

## What is a dotfiles git repository?

A dotfiles git repository is a Git repository used to store and manage a user's configuration files (dotfiles). Dotfiles are files and directories on Unix-like systems that start with a dot (`.`), which makes them hidden by default in directory listings. They are used to control the behavior of various applications and shells. For example, `.bashrc` for the Bash shell, `.vimrc` for the Vim editor, and `.gitconfig` for Git.

By storing dotfiles in a Git repository, you can:

- **Track changes**: Keep a history of all the changes you make to your configurations.
- **Synchronize across multiple machines**: Easily keep your settings consistent across different computers.
- **Backup and restore**: Your configurations are backed up to a remote repository (like GitHub), so you can easily restore them on a new machine.
- **Share with others**: You can share your dotfiles with other people, and also learn from others' configurations.

## How is it used with thoughtbot/rcm?

`rcm` is a tool that helps you manage your dotfiles. It simplifies the process of getting your dotfiles from your dotfiles repository (typically `~/.dotfiles`) to the correct locations in your home directory. Instead of manually creating symbolic links for each file, `rcm` automates the process.

Here's a typical workflow:

1. **Installation**: Install `rcm` using a package manager (e.g., `brew install rcm` on macOS).
2. **Create a dotfiles directory**: Create a directory to store your dotfiles, for example, `~/.dotfiles`. This directory will be a Git repository.
3. **Add dotfiles to the repository**: Move your existing dotfiles into the `~/.dotfiles` directory using the `mkrc` command. For example, `mkrc .vimrc` will move your `~/.vimrc` to `~/.dotfiles/vimrc`.
4. **Create symbolic links**: The `rcup` command creates symbolic links from your dotfiles repository to your home directory. For example, `rcup` will create a symbolic link from `~/.dotfiles/vimrc` to `~/.vimrc`.
5. **List managed files**: The `lsrc` command lists all the files that are managed by `rcm`.
6. **Remove symbolic links**: The `rcdn` command removes all the symbolic links created by `rcup`.

`rcm` also has more advanced features like:

- **Host-specific files**: You can have different versions of a configuration file for different computers.
- **Tags**: You can "tag" certain dotfiles to be installed on systems where you need a particular setup.
- **Multiple dotfile directories**: You can manage dotfiles from several source directories.

## Structure

- **Profiles are rcm tags.** The untagged repo root is *universal* config,
  linked on every machine. `tag-desktop/` holds omarchy/Hyprland GUI and
  workstation-only files; `tag-node/` holds headless-server additions. This
  repo's `rcrc` picks the profile itself: `$RCM_PROFILE` if set, else
  `desktop` when `/etc/os-release` says omarchy, else `node`.
- **Per-user overlays are tags too**, layered most-specific-first (rcm gives a
  collision to the first tag listed): `tag-user-<login>-<profile>/` (this
  account on this kind of machine), then `tag-user-<login>/` (this account
  everywhere), then `tag-<profile>/`. The login comes from `id -un`; rcm skips
  any tier whose directory is absent.
- **Host dirs are orthogonal to tags.** `host-batman/` and `host-robin/` match
  `uname -n` and apply to every account on that machine. There is no tracked
  user+host tier; `~/dotfiles-local` (first in `DOTFILES_DIRS`, untracked)
  serves that role.
- When adding config, put it in the untagged root unless it needs a graphical
  session or would be useless or harmful on a headless node — see `README.md`
  and `tag-node/README.md`.
- **Packages are declared here, in two planes**, both layered by the same
  tags: `mise` (exact-version toolchains — `mise.toml`,
  `*/config/mise/conf.d/*.toml`, materialized by `mise install`) and `nix`
  (the nixpkgs long tail — `*/config/nix/env/pkgs.d/*.nix`, materialized by
  `just nix-sync`). Dropping a nix package removes it; dropping a mise tool
  only deactivates it. See `README.md` "Packages (mise and nix)" — and note
  `config/nix/env/flake.nix` is rcm-EXCLUDED on purpose.
- The `config` folder correspondes to `~/.config` which is a hidden directory within your home directory that stores configuration files for various applications. It's a standard location for user-specific settings and preferences, adhering to the XDG Base Directory Specification.
- `tag-desktop/config/hypr` is the configuration for the `Hyprland` dynamic tiling Wayland compositor. rcm soft-links `~/.config/hypr` to this folder on machines carrying the `desktop` tag. When assisting with Hyprland, use the official documentation at <https://wiki.hypr.land/>. Some configuration directives refer to files in
  subfolders of `~/.local/share/omarchy`. These files are managed by another party and shared by many people. We do not change files in `~/.local/share/omarchy`. Instead, we override settings in our files in `config/hypr`. When assisting with files in the `omarchy` folder, use the official documentation website at <https://manuals.omamix.org/2/the-omarchy-manual/>.

## Todo Processing

The repository's agent-actionable backlog lives in [`TODO.md`](./TODO.md),
which is the single source of truth. It is plain markdown in git — no external
tracker. Installed tooling that can reach a tracker (e.g. the Trello skill) is
not a reason to file dotfiles work there. Items move between three sections:
`Backlog`, `In progress`, `Done`.

Agents work **propose-only**: an agent may pick up and fully prepare a todo, but
a human reviews and approves before it is marked done. The loop:

1. **Pick** the highest-priority unblocked item from `Backlog` (prefer `P1`,
   then `P2`, then `P3`; untagged items are lowest). If priorities are equal,
   ask the human which to take. Skip items marked as needing a human decision.
2. **Claim** it: move the line to `In progress` and append an owner tag
   (e.g. `@claude`). Commit this move on a working branch off `master`.
3. **Implement** the change, following the conventions in this file. Keep the
   change surgical and scoped to the one item.
4. **Validate** by running the changed config and looking at it. The bar is the
   item's own **observable check**, written into the todo before the work
   starts. In practice: `just rcm-sync` (and `lsrc` to confirm what links where),
   then exercise the tool — e.g. for nvim, a start with empty `:messages` and
   `:checkhealth` for the touched plugin — and confirm `git status` shows no
   tracked file dirtied beyond the intended change.
   - **Name the profile you checked on.** Untagged config reaches both `desktop`
     and `node`; a check run on one says nothing about the other.
5. **Propose**: present the diff and what you actually observed — the command
   run, its output. Never "should work". **Stop here** — do not merge or move
   the item to `Done` yourself.
6. **Human approves**, merges, and moves the line to `Done` (changing `[ ]` to
   `[x]`). Only a human closes an item.

Rules:

- One item in `In progress` per agent at a time; finish or release before
  claiming another.
- Never edit the `Done` section except to add a freshly approved item.
- If work uncovers new tasks, add them to `Backlog` rather than expanding the
  scope of the current item.
- If an item is blocked, move it back to `Backlog` with a sub-bullet noting the
  blocker.
- If an item's observable check could not be run, say which one and leave the
  item open. A change that has not been looked at is not done.
