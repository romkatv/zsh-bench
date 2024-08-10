# If not in tmux, start tmux.
if [[ -z ${TMUX+X}${ZSH_SCRIPT+X}${ZSH_EXECUTION_STRING+X} ]]; then
  exec tmux
fi

# Activate Powerlevel10k Instant Prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ ! -e ~/.zgenom ]]; then
  git clone --depth=1 https://github.com/jandamm/zgenom.git ~/.zgenom
fi

source ~/.zgenom/zgenom.zsh

ZGEN_RESET_ON_CHANGE=(~/.zshrc)

if ! zgenom saved; then
  zgenom load romkatv/powerlevel10k powerlevel10k
  zgenom load zsh-users/zsh-syntax-highlighting
  zgenom load zsh-users/zsh-autosuggestions

  zgenom save
  zgenom compile ~/.zshrc
fi

ZSH_AUTOSUGGEST_MANUAL_REBIND=1

source ~/.p10k.zsh
