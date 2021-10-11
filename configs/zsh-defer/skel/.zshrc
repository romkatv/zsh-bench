if [[ -z ${TMUX+X}${ZSH_SCRIPT+X}${ZSH_EXECUTION_STRING+X} ]]; then
  exec tmux
fi

function zcompile-many() {
  local f
  for f; do zcompile -R -- "$f".zwc "$f"; done
}

if [[ ! -e ~/zsh-defer ]]; then
  git clone --depth=1 https://github.com/romkatv/zsh-defer.git ~/zsh-defer
  zcompile-many ~/zsh-defer/zsh-defer.plugin.zsh
fi
if [[ ! -e ~/zsh-syntax-highlighting ]]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ~/zsh-syntax-highlighting
  zcompile-many ~/zsh-syntax-highlighting/{zsh-syntax-highlighting.zsh,highlighters/*/*.zsh}
fi
if [[ ! -e ~/zsh-autosuggestions ]]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git ~/zsh-autosuggestions
  zcompile-many ~/zsh-autosuggestions/{zsh-autosuggestions.zsh,src/**/*.zsh}
fi
if [[ ! -e ~/powerlevel10k ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
  make -C ~/powerlevel10k pkg
fi

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

autoload -Uz compinit
compinit

[[ ~/.zcompdump.zwc -nt ~/.zcompdump ]] || zcompile-many ~/.zcompdump
unfunction zcompile-many

ZSH_AUTOSUGGEST_MANUAL_REBIND=1

source ~/zsh-defer/zsh-defer.plugin.zsh
source ~/powerlevel10k/powerlevel10k.zsh-theme
source ~/.p10k.zsh

zsh-defer -a +pr source ~/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
zsh-defer -a +ms source ~/zsh-autosuggestions/zsh-autosuggestions.zsh
