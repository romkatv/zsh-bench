if [[ -z ${TMUX+X}${ZSH_SCRIPT+X}${ZSH_EXECUTION_STRING+X} ]]; then
  exec tmux
fi

if [[ ! -e ~/.zcomet/bin ]]; then
  git clone --depth=1 https://github.com/agkozak/zcomet.git ~/.zcomet/bin
fi

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ~/.zcomet/bin/zcomet.zsh

ZSH_AUTOSUGGEST_MANUAL_REBIND=1

zcomet load zsh-users/zsh-syntax-highlighting
zcomet load zsh-users/zsh-autosuggestions
zcomet load romkatv/powerlevel10k

zcomet compinit

source ~/.p10k.zsh
