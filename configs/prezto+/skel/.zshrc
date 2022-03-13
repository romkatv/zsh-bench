if [[ -z ${TMUX+X}${ZSH_SCRIPT+X}${ZSH_EXECUTION_STRING+X} ]]; then
  exec tmux
fi

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load and initialize the completion system.
autoload -Uz compinit && compinit
if [[ ! ~/.zcompdump.zwc -nt ~/.zcompdump ]]; then
  zcompile ~/.zcompdump
fi

ZSH_AUTOSUGGEST_MANUAL_REBIND=1
source ~/.p10k.zsh
