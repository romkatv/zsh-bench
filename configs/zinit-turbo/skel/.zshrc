if [[ -z ${TMUX+X}${ZSH_SCRIPT+X}${ZSH_EXECUTION_STRING+X} ]]; then
  exec tmux
fi

if [[ ! -e ~/.zinit/bin ]]; then
  git clone --depth=1 https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
fi

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ~/.zinit/bin/zinit.zsh

ZSH_AUTOSUGGEST_MANUAL_REBIND=1

zinit ice depth"1" wait lucid; zinit light zsh-users/zsh-syntax-highlighting
zinit ice depth"1" wait lucid; zinit light zsh-users/zsh-autosuggestions
zinit ice depth"1"           ; zinit light romkatv/powerlevel10k

source ~/.p10k.zsh

autoload -Uz compinit
compinit
zinit cdreplay -q
