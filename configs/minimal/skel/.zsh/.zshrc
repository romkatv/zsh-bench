emulate zsh
setopt autocd autopushd cbases extendedglob extendedhistory globdots globstarshort \
  histexpiredupsfirst histfindnodups histignoredups histignorespace histsavenodups \
  histverify interactivecomments magicequalsubst noautoremoveslash nobeep nobgnice \
  noflowcontrol nomultios nonotify rcquotes rmstarsilent sharehistory              \
  transientrprompt

: ${ZDOTDIR:=${${(%):-%N}:A:h}}

zmodload zsh/terminfo
autoload -Uz compinit bashcompinit zmv run-help ${^fpath}/run-help-^*.zwc(N:t)
[[ -v aliases[run-help] ]] && unalias run-help

HISTSIZE=1000000000
SAVEHIST=1000000000
HISTFILE=$ZDOTDIR/.zsh_history
[[ -e $HISTFILE || -n ${HISTFILE:t}(#qNU) ]] || HISTFILE+=.$EUID

DIRSTACKSIZE=1000
TIMEFMT='user=%U system=%S cpu=%P total=%*E'
zle_highlight=(paste:none)

source -- $ZDOTDIR/keys.zsh
source -- $ZDOTDIR/env.zsh
source -- $ZDOTDIR/comp.zsh
source -- $ZDOTDIR/prompt.zsh
source -- $ZDOTDIR/aliases.zsh
