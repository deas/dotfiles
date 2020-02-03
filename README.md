
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
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
```

misc
------------
- [Setting up Windows Subsystem for Linux with zsh + oh-my-zsh + ConEmu](https://blog.joaograssi.com/windows-subsystem-for-linux-with-oh-my-zsh-conemu/)
-  [zplug](https://github.com/zplug/zplug) appears to have a forkbomb issue on WSL 
