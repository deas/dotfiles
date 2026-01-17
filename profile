# TODO: Who did this? Do we actually need it?
. "$HOME/.local/bin/env"


# Added by Toolbox App
export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/scripts"

# Added by LM Studio CLI (lms)
if [ -d "$HOME/.lmstudio/bin" ] ; then
    export PATH="$PATH:$HOME/.lmstudio/bin"
fi
# End of LM Studio CLI section

