# https://www.realjenius.com/2020/01/12/kde-neon-snap-apps-missing/
if [ -r "/etc/profile.d/apps-bin-path.sh" ] ; then
    emulate sh -c 'source /etc/profile.d/apps-bin-path.sh'
fi

if [ -d "$HOME/go" ] ; then
  PATH="$PATH:$HOME/go/bin"
fi

if [ -d "$HOME/.local/bin" ] ; then
  PATH="$PATH:$HOME/.local/bin"
fi

if [ -d "$HOME/bin" ] ; then
  PATH="$PATH:$HOME/bin"
fi

# Ruby
# if [ -d "$HOME/.rvm/bin" ] ; then
#   PATH="$PATH:$HOME/.rvm/bin"
# fi

export GEM_HOME="$HOME/gems"

if [ -d "$GEM_HOME/bin" ] ; then
  PATH="$PATH:$GEM_HOME/bin"
fi

# $HOME/.linkerd2/bin:$HOME/.fabric8/bin:$HOME/.krew/bin:$HOME/.cargo/bin

which helm > /dev/null && source <(helm completion zsh)
# which oc >/dev/null && source <(oc completion zsh)
which jx >/dev/null && source <(jx completion zsh)
# which kubeadm >/dev/null && source <(kubeadm completion zsh)


# source "$HOME/.../kube-ps1/kube-ps1.sh"
# [ -f "/usr/share/zsh/vendor-completions/_awscli" ] && source "/usr/share/zsh/vendor-completions/_awscli"

KREW_ROOT=$HOME/.krew

if [ -d "$KREW_ROOT" ] ; then
    PATH="$PATH:${KREW_ROOT}/bin"
fi

if [ -d "$HOME/.deno" ] ; then
  export DENO_INSTALL="$HOME/.deno"
  PATH="$DENO_INSTALL/bin:$PATH"
fi  

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
#export SDKMAN_DIR="$HOME/.sdkman"
#[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] ; then
  export SDKMAN_DIR="$HOME/.sdkman"
  source "${SDKMAN_DIR}/bin/sdkman-init.sh"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
# [[ -f $HOME/.config/yarn/global/node_modules/tabtab/.completions/serverless.zsh ]] && . $HOME/.config/yarn/global/node_modules/tabtab/.completions/serverless.zsh

# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
# [[ -f $HOME/.config/yarn/global/node_modules/tabtab/.completions/sls.zsh ]] && . $HOME/.config/yarn/global/node_modules/tabtab/.completions/sls.zsh

# tabtab source for slss package
# uninstall by removing these lines or running `tabtab uninstall slss`
# [[ -f $HOME/.nvm/versions/node/v11.11.0/lib/node_modules/serverless/node_modules/tabtab/.completions/slss.zsh ]] && . $HOME/.nvm/versions/node/v11.11.0/lib/node_modules/serverless/node_modules/tabtab/.completions/slss.zsh

# export WASMER_DIR="$HOME/.wasmer"
# [ -s "$WASMER_DIR/wasmer.sh" ] && source "$WASMER_DIR/wasmer.sh"


# autoload -U +X bashcompinit && bashcompinit
# complete -o nospace -C /usr/local/bin/terraform terraform
