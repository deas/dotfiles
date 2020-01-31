#alias e='emacsclient -t'
#alias ec='emacsclient -c'
#alias vim='emacsclient -t'
#alias vi='emacsclient -t'

alias nbstrip_jq="jq --indent 1 \
    '(.cells[] | select(has(\"outputs\")) | .outputs) = []  \
    | (.cells[] | select(has(\"execution_count\")) | .execution_count) = null  \
    | .metadata = {\"language_info\": {\"name\": \"python\", \"pygments_lexer\": \"ipython3\"}} \
    | .cells[].metadata = {} \
    '"

crtoolbox=$HOME/work/projects/contentreich/contentreich-toolbox

export SSH_ASKPASS="/usr/bin/ksshaskpass"
export GEM_HOME="$HOME/gems"
export KUBECONFIG=$HOME/.kube/config-ba-b:$HOME/.kube/config_k3s:$HOME/.kube/config-mt
export PATH=$PATH:$HOME/bin:$HOME/go/bin:$HOME/.jx/bin:$HOME/.linkerd2/bin:$HOME/.fabric8/bin:$HOME/.krew/bin:$HOME/.cargo/bin:$HOME/gems/bin:$HOME/work/projects/contentreich/contentreich-toolbox/bin:$HOME/work/projects/contentreich/contentreich-toolbox/src/main/resources

# https://askubuntu.com/questions/910821/programs-installed-via-snap-not-showing-up-in-launcher
# emulate sh -c 'source /etc/profile.d/apps-bin-path.sh'

which helm >/dev/null && source <(helm completion zsh)
# source <(minikube completion zsh)
# source <(kubeadm completion zsh)
which oc >/dev/null && source <(oc completion zsh)
# source "$HOME/.oh-my-zsh/custom/jx.zsh"
# source "$HOME/work/projects/3rd-party/kube-ps1/kube-ps1.sh"
# source "/usr/share/zsh/vendor-completions/_awscli"

# Does not kick in here - need in in .zshrc
# PROMPT='$(kube_ps1)'$PROMPT

# source <(jx completion zsh)

# [ -f $HOME/work/projects/3rd-party/kubectl-aliases/.kubectl_aliases ] && source $HOME/work/projects/3rd-party/kubectl-aliases/.kubectl_aliases

# function kubectl() { echo "+ kubectl $@"; command kubectl $@; }

# export WASMER_DIR="$HOME/.wasmer"
# [ -s "$WASMER_DIR/wasmer.sh" ] && source "$WASMER_DIR/wasmer.sh"  # This loads wasmer

