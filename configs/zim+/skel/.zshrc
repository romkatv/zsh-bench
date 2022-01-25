# If not in tmux, start tmux.
if [[ -z ${TMUX+X}${ZSH_SCRIPT+X}${ZSH_EXECUTION_STRING+X} ]]; then
  exec tmux
fi

ZIM_HOME=~/.zim
zstyle ':zim:zmodule' use 'degit'
if [[ ! -e $ZIM_HOME/zimfw.zsh ]]; then
  # Download zimfw script if missing.
  curl -fsSLo $ZIM_HOME/zimfw.zsh --create-dirs \
    https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi
if [[ ! $ZIM_HOME/init.zsh -nt ~/.zimrc ]]; then
  # Install missing modules and update $ZIM_HOME/init.zsh.
  source $ZIM_HOME/zimfw.zsh init
fi

# Activate Powerlevel10k Instant Prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Load plugins.
source $ZIM_HOME/init.zsh

source ~/.p10k.zsh
