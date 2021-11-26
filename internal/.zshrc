emulate zsh
setopt autocd autopushd noautoremoveslash nobeep nobgnice cbases extendedglob \
       extendedhistory noflowcontrol globdots globstarshort                   \
       histexpiredupsfirst histfindnodups histignoredups histignorespace      \
       histsavenodups histverify interactivecomments magicequalsubst          \
       nomultios rcquotes rmstarsilent sharehistory transientrprompt          \
       typesetsilent

HISTFILE=~/.zsh_history
HISTSIZE=1000000000
SAVEHIST=1000000000

ZLE_RPROMPT_INDENT=0
PS1='%F{4}%~%f %F{%(?.2.1)}%#%f '
RPS1='%F{3}%n%f@%F{3}%m%f'
if [[ -r /proc/1/cpuset(#qN-.) &&
      "$(</proc/1/cpuset)" == /docker/[[:xdigit:]](#c64) ]]; then
  RPS1+=' in %F{3}docker%f'
fi

autoload -Uz compinit && compinit
zstyle ':completion:*' menu yes select
