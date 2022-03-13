# If not in tmux, start tmux.
if [[ -z ${TMUX+X}${ZSH_SCRIPT+X}${ZSH_EXECUTION_STRING+X} ]]; then
  exec tmux
fi

ZIM_HOME=~/.zim
zstyle ':zim:zmodule' use 'degit'
# Download zimfw plugin manager if missing.
if [[ ! -e $ZIM_HOME/zimfw.zsh ]]; then
  curl -fsSLo $ZIM_HOME/zimfw.zsh --create-dirs \
    https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi
# Install missing modules, and update $ZIM_HOME/init.zsh if missing or outdated.
if [[ ! $ZIM_HOME/init.zsh -nt ~/.zimrc ]]; then
  source $ZIM_HOME/zimfw.zsh init
fi

# Activate Powerlevel10k Instant Prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load and initialize the completion system.
autoload -Uz compinit && compinit
if [[ ! ~/.zcompdump.zwc -nt ~/.zcompdump ]]; then
  zcompile ~/.zcompdump
fi

ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Load plugins.
source $ZIM_HOME/init.zsh

source ~/.p10k.zsh
