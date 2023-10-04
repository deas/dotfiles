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

if [ -d "$HOME/.poetry/bin" ] ; then
  PATH="$PATH:$HOME/.poetry/bin"
fi

if [ -d "$HOME/.babashka/bbin/bin" ] ; then
  PATH="$PATH:$HOME/.babashka/bbin/bin"
fi

if [ -d "$HOME/.crc/bin/oc" ] ; then
  PATH="$PATH:$HOME/.crc/bin/oc"
fi

if [ -d "$HOME/.local/share/fnm" ] ; then
  PATH="$HOME/.local/share/fnm:$PATH"
  eval "`fnm env`"
fi

# Harmonize with Crostini
# https://clojure.org/reference/deps_and_cli
if [ -n "$XDG_CONFIG_HOME" ] ; then
    export CLJ_CONFIG=$HOME/.clojure
fi

# gcloud completion
[ -r "/usr/share/google-cloud-sdk/completion.zsh.inc" ] && source "/usr/share/google-cloud-sdk/completion.zsh.inc"

# azure-cli completion
# [ -r "/etc/bash_completion.d/azure-cli" ] && source /etc/bash_completion.d/azure-cli

# $HOME/.linkerd2/bin:$HOME/.fabric8/bin:$HOME/.krew/bin:$HOME/.cargo/bin
which helm > /dev/null && source <(helm completion zsh)
# which oc >/dev/null && source <(oc completion zsh)
# which jx >/dev/null && source <(jx completion zsh)
# which kubeadm >/dev/null && source <(kubeadm completion zsh)
which flux >/dev/null && source <(flux completion zsh; echo "compdef _flux flux")
which kustomize >/dev/null && source <(kustomize completion zsh; echo "compdef _kustomize kustomize")
# which lxc >/dev/null && source <(lxc completion zsh; echo "compdef _lxc lxc")
# which velero >/dev/null && source <(velero completion zsh; echo "compdef _velero velero")
# which eksctl >/dev/null && source <(eksctl completion zsh; echo "compdef _eksctl eksctl")
which kn >/dev/null && source <(kn completion zsh; echo "compdef _kn kn")
which oc >/dev/null && source <(oc completion zsh; echo "compdef _oc oc")
which argocd >/dev/null && source <(argocd completion zsh; echo "compdef _argocd argocd")
which argo >/dev/null && source <(argo completion zsh; echo "compdef _argo argo")
which istioctl >/dev/null && source <(istioctl completion zsh; echo "compdef _istioctl istioctl")
which starship >/dev/null && eval "$(starship init zsh)"

# Rust/Nix painful on ChromeOS: bash <(curl https://raw.githubusercontent.com/ellie/atuin/main/install.sh)
# Appears to conflict a bit with https://github.com/marlonrichert/zsh-autocomplete
which atuin >/dev/null && eval "$(atuin init zsh)"


# TODO: Needs api server?
# which tfctl >/dev/null && source <(tfctl completion zsh; echo "compdef _tfctl tfctl")

which clusterctl >/dev/null && source <(clusterctl completion zsh; echo "compdef _clusterctl clusterctl")
which kubebuilder >/dev/null && source <(kubebuilder completion zsh; echo "compdef _kubebuilder kubebuilder")
# Next one should probably come from ~/.zsh/completion (by _ convention)
which govc >/dev/null && source $HOME/.zsh/hacks/govc_bash_completion
# <(kubebuilder completion zsh; echo "compdef _kubebuilder kubebuilder")

which direnv >/dev/null && eval "$(direnv hook zsh)"

if which fdfind >/dev/null; then
    export FZF_DEFAULT_COMMAND='fdfind --type f'
fi
# https://askubuntu.com/questions/910821/programs-installed-via-snap-not-showing-up-in-launcher
[ -r "/etc/profile.d/apps-bin-path.sh" ] && emulate sh -c 'source /etc/profile.d/apps-bin-path.sh'

# source "$HOME/.../kube-ps1/kube-ps1.sh"
# [ -f "/usr/share/zsh/vendor-completions/_awscli" ] && source "/usr/share/zsh/vendor-completions/_awscli"

KREW_ROOT=$HOME/.krew

if [ -d "$KREW_ROOT" ] ; then
    PATH="$PATH:${KREW_ROOT}/bin"
fi

#if [ -d "$HOME/.deno" ] ; then
#  export DENO_INSTALL="$HOME/.deno"
#  PATH="$DENO_INSTALL/bin:$PATH"
#fi

if [ -f "$HOME/.asdf/asdf.sh" ] ; then
  source "$HOME/.asdf/asdf.sh"
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] ; then
  export SDKMAN_DIR="$HOME/.sdkman"
  # source "${SDKMAN_DIR}/bin/sdkman-init.sh"
  source "${HOME}/.sdkman/bin/sdkman-init.sh"
fi

[ -x "/usr/bin/ksshaskpass" ] && export SSH_ASKPASS="/usr/bin/ksshaskpass"

export GEM_HOME="$HOME/gems"

# Installer appears to expect this in $HOME/.zshrc
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"


export DOCKER_BUILDKIT=1

if [ -d /home/linuxbrew ] ; then
    export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew";
    export HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar";
    export HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew";
    export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin${PATH+:$PATH}";
    export MANPATH="/home/linuxbrew/.linuxbrew/share/man${MANPATH+:$MANPATH}:";
    export INFOPATH="/home/linuxbrew/.linuxbrew/share/info:${INFOPATH:-}";
fi

# https://emacsredux.com/blog/2020/07/16/running-emacs-with-systemd/
if systemctl --user is-active --quiet emacs.service ; then
    export EDITOR='emacsclient -t'
    export VISUAL='emacsclient -t'
    alias vi='emacsclient -t'
    alias vim='emacsclient -t'
fi

# jupyther notebook strip
alias nbstrip_jq="jq --indent 1 \
    '(.cells[] | select(has(\"outputs\")) | .outputs) = []  \
    | (.cells[] | select(has(\"execution_count\")) | .execution_count) = null  \
    | .metadata = {\"language_info\": {\"name\": \"python\", \"pygments_lexer\": \"ipython3\"}} \
    | .cells[].metadata = {} \
    '"

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

alias lastmod="find . -type f -exec stat --format '%Y :%y %n' \"{}\" \; | sort -nr | cut -d: -f2-"

alias gcurl='curl -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json"'
