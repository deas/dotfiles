# echo foobar
# which kubectl > /dev/null && source <(kubectl completion zsh)
# echo bar
# which helm > /dev/null && source <(helm completion zsh)
KREW_ROOT=$HOME/.krew

if [ -d $KREW_ROOT ] ; then
    PATH="$PATH:${KREW_ROOT}/bin"
fi  