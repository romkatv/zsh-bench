hash -d z=~/.config/zsh g=~/Git

setopt HIST_FCNTL_LOCK HIST_IGNORE_ALL_DUPS SHARE_HISTORY TRANSIENT_RPROMPT \
       NO_CLOBBER INTERACTIVE_COMMENTS HASH_EXECUTABLES_ONLY EXTENDED_GLOB  \
       GLOB_STAR_SHORT NUMERIC_GLOB_SORT FLOW_CONTROL

if [[ ! -r ~g/zsh-snap/znap.zsh ]]; then
  git clone --depth 1 https://github.com/marlonrichert/zsh-snap.git ~g/zsh-snap
fi
source ~g/zsh-snap/znap.zsh

PS2=
RPS2='%F{11}%^%f'
PS1='%F{%(?,10,9)}%#%f '

: ${PAGER:=less}
READNULLCMD=$PAGER
ZLE_RPROMPT_INDENT=0

HISTFILE=~/.local/share/zsh/history
SAVEHIST=100000
HISTSIZE=120000

[[ -d $HISTFILE:h ]] || mkdir -p $HISTFILE:h

export -UT INFOPATH infopath
export -U PATH path FPATH fpath MANPATH manpath
path=(/home/linuxbrew/.linuxbrew/bin(N) $path)

if (( $+commands[brew] )) && znap eval brew-shellenv 'brew shellenv'; then
  fpath+=($HOMEBREW_PREFIX/share/zsh/site-functions(-/UN))
fi

autoload -Uz vcs_info zmv run-help ${^fpath}/run-help-^*.zwc(N:t)

chpwd() RPS1= && zle -I && print -P '\n%F{12}%~%f'

precmd() {
  local -i fd
  exec {fd}< <(vcs_info && print -r -- $vcs_info_msg_0_)
  zle -F $fd .vcs-info-handler
}

.vcs-info-handler() {
  IFS= read -ru $1 RPS1 && [[ $CONTEXT == start ]] && zle .reset-prompt
  zle -F $1
  exec {1}<&-
}

zstyle ':vcs_info:*' formats           '%c%u%F{14}%b%f'
zstyle ':vcs_info:*' actionformats     '%F{9}%a %c%u%F{14}%b%f'
zstyle ':vcs_info:*' stagedstr         '%F{12}+'
zstyle ':vcs_info:*' unstagedstr       '%F{11}*'
zstyle ':vcs_info:*' check-for-changes 'yes'

() {
 znap clone $@
 for 1; znap source $1
} marlonrichert/{zsh-autocomplete,zsh-edit,zsh-hist,zcolors} \
  zsh-users/{zsh-autosuggestions,zsh-syntax-highlighting}

znap eval zcolors zcolors

bindkey '^[q' push-line-or-edit
bindkey '^[v' describe-key-briefly

chpwd
znap prompt

(( $+aliases[run-help] )) && unalias run-help

alias %= \$=
alias zmv='zmv -Mv'
alias zcp='zmv -Cv'
alias zln='zmv -Lv'

alias -s {css,gradle,html,js,json,md,patch,properties,txt,xml,yml}=$PAGER
alias -s gz='gzip -l'
alias -s {log,out}='tail -F'
