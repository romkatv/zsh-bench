if [[ -z ${TMUX+X}${ZSH_SCRIPT+X}${ZSH_EXECUTION_STRING+X} ]]; then
  exec tmux
fi

if [[ ! -e ~/.zgenom ]]; then
  git clone --depth=1 https://github.com/jandamm/zgenom.git ~/.zgenom
fi

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSH_AUTOSUGGEST_MANUAL_REBIND=1

source ~/.zgenom/zgenom.zsh

if ! zgenom saved; then
  zgenom load zsh-users/zsh-syntax-highlighting
  zgenom load zsh-users/zsh-autosuggestions
  zgenom load romkatv/powerlevel10k powerlevel10k
  zgenom save
fi

source ~/.p10k.zsh
