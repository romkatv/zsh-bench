# If not in tmux, start tmux.
if [[ -z ${TMUX+X}${ZSH_SCRIPT+X}${ZSH_EXECUTION_STRING+X} ]]; then
  exec tmux
fi

# Build ~/.zsh_plugins.zsh from ~/.zsh_plugins.txt unless the former is newer.
if [[ ! ~/.zsh_plugins.zsh -nt ~/.zsh_plugins.txt ]]; then
  # Clone antidote if it's missing.
  if [[ ! -e ~/.antidote ]]; then
    git clone --depth=1 https://github.com/mattmc3/antidote.git ~/.antidote
  fi
  # Build ~/.zsh_plugins.txt in a subshell.
  (
    source ~/.antidote/antidote.zsh
    antidote bundle <~/.zsh_plugins.txt >~/.zsh_plugins.zsh
  )
fi

# Activate Powerlevel10k Instant Prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Enable the "new" completion system (compsys).
autoload -Uz compinit
compinit
if [[ ! ~/.zcompdump.zwc -nt ~/.zcompdump ]]; then
  zcompile -R -- ~/.zcompdump.zwc ~/.zcompdump
fi

ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Load plugins.
source ~/.zsh_plugins.zsh
source ~/.p10k.zsh
