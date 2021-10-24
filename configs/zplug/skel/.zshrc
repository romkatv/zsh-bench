# If not in tmux, start tmux.
if [[ -z ${TMUX+X}${ZSH_SCRIPT+X}${ZSH_EXECUTION_STRING+X} ]]; then
  exec tmux
fi

# Install zplug.
if [[ ! -e ~/.zplug ]]; then
  git clone --depth=1 https://github.com/zplug/zplug.git ~/.zplug
  () {
    emulate -L zsh -o extended_glob
    local f
    for f in ~/.zplug/**/*.zsh(.) ~/.zplug/autoload/**/^*.zsh(.); do
      zcompile -R -- $f.zwc $f
    done
  }
fi

# Install plugins.
source ~/.zplug/init.zsh
zplug zsh-users/zsh-syntax-highlighting, depth:1
zplug zsh-users/zsh-autosuggestions, depth:1
zplug romkatv/powerlevel10k, as:theme, depth:1
zplug check || zplug install

# Activate Powerlevel10k Instant Prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Enable the "new" completion system (compsys).
autoload -Uz compinit && compinit
[[ ~/.zcompdump.zwc -nt ~/.zcompdump ]] || zcompile -R -- ~/.zcompdump{.zwc,}

ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Load plugins.
zplug load
source ~/.p10k.zsh
