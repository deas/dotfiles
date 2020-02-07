PATH="$PATH:$HOME/.local/bin"

# PATH="$PATH:$HOME/.rvm/bin"

# which kubectl > /dev/null && source <(kubectl completion zsh)
# which helm > /dev/null && source <(helm completion zsh)
# which oc >/dev/null && source <(oc completion zsh)
# which jx >/dev/null && source <(jx completion zsh)
# which kubeadm >/dev/null && source <(kubeadm completion zsh)


# source "$HOME/.../kube-ps1/kube-ps1.sh"
# [ -f "/usr/share/zsh/vendor-completions/_awscli" ] && source "/usr/share/zsh/vendor-completions/_awscli"

KREW_ROOT=$HOME/.krew

if [ -d $KREW_ROOT ] ; then
    PATH="$PATH:${KREW_ROOT}/bin"
fi


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
#export SDKMAN_DIR="$HOME/.sdkman"
#[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

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
