# Dotfiles and rcm

This folder is a git dotfiles repository.

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

- The `config` folder correspondes to `~/.config` which is a hidden directory within your home directory that stores configuration files for various applications. It's a standard location for user-specific settings and preferences, adhering to the XDG Base Directory Specification.
- `config/hypr` is the configuration for the `Hyprland` dynamic tiling Wayland compositor. The file [hyprland.md](./hyprland.md) contains a brief hyprland introduction and references to comprehensive documentation. The Hyprland configuration files in `config/hypr` refer to files subfolders of `~/.local/share/omarchy`. These files are managed by another party and shared by many people. We do not change files in `~/.local/share/omarchy`. Instead, we override settings in our files in `config/hypr`.
