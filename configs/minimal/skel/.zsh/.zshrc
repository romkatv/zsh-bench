emulate zsh
setopt autocd autopushd cbases extendedglob extendedhistory globdots globstarshort \
  histexpiredupsfirst histfindnodups histignoredups histignorespace histsavenodups \
  histverify interactivecomments magicequalsubst noautoremoveslash nobeep nobgnice \
  noflowcontrol nomultios nonotify rcquotes rmstarsilent sharehistory              \
  transientrprompt

: ${ZDOTDIR:=~}

zle-expand() zle _expand_alias || zle .expand-word || true
zle -N zle-expand

() {
  # Delete all existing keymaps and reset to the default state.
  bindkey -d
  bindkey -e

  local keymap
  for keymap in emacs viins vicmd; do
    # If NumLock is off, translate keys to make them appear the same as with NumLock on.
    bindkey -M $keymap -s '^[OM'         '^M'      # enter
    bindkey -M $keymap -s '^[OX'         '='
    bindkey -M $keymap -s '^[Oj'         '*'
    bindkey -M $keymap -s '^[Ok'         '+'
    bindkey -M $keymap -s '^[Ol'         '+'
    bindkey -M $keymap -s '^[Om'         '-'
    bindkey -M $keymap -s '^[On'         '.'
    bindkey -M $keymap -s '^[Oo'         '/'
    bindkey -M $keymap -s '^[Op'         '0'
    bindkey -M $keymap -s '^[Oq'         '1'
    bindkey -M $keymap -s '^[Or'         '2'
    bindkey -M $keymap -s '^[Os'         '3'
    bindkey -M $keymap -s '^[Ot'         '4'
    bindkey -M $keymap -s '^[Ou'         '5'
    bindkey -M $keymap -s '^[Ov'         '6'
    bindkey -M $keymap -s '^[Ow'         '7'
    bindkey -M $keymap -s '^[Ox'         '8'
    bindkey -M $keymap -s '^[Oy'         '9'

    # If someone switches our terminal to application mode (smkx), translate keys to make
    # them appear the same as in raw mode (rmkx).
    bindkey -M $keymap -s '^[OA'         '^[[A'    # up
    bindkey -M $keymap -s '^[OB'         '^[[B'    # down
    bindkey -M $keymap -s '^[OD'         '^[[D'    # left
    bindkey -M $keymap -s '^[OC'         '^[[C'    # right
    bindkey -M $keymap -s '^[OH'         '^[[H'    # home
    bindkey -M $keymap -s '^[OF'         '^[[F'    # end

    # TTY sends different key codes. Translate them to xterm equivalents.
    bindkey -M $keymap -s '^[[1~'        '^[[H'    # home
    bindkey -M $keymap -s '^[[4~'        '^[[F'    # end

    # Urxvt sends different key codes. Translate them to xterm equivalents.
    bindkey -M $keymap -s '^[[7~'        '^[[H'    # home
    bindkey -M $keymap -s '^[[8~'        '^[[F'    # end
    bindkey -M $keymap -s '^[Oa'         '^[[1;5A' # ctrl+up
    bindkey -M $keymap -s '^[Ob'         '^[[1;5B' # ctrl+down
    bindkey -M $keymap -s '^[Od'         '^[[1;5D' # ctrl+left
    bindkey -M $keymap -s '^[Oc'         '^[[1;5C' # ctrl+right
    bindkey -M $keymap -s '^[[7\^'       '^[[1;5H' # ctrl+home
    bindkey -M $keymap -s '^[[8\^'       '^[[1;5F' # ctrl+end
    bindkey -M $keymap -s '^[[3\^'       '^[[3;5~' # ctrl+delete
    bindkey -M $keymap -s '^[^[[A'       '^[[1;3A' # alt+up
    bindkey -M $keymap -s '^[^[[B'       '^[[1;3B' # alt+down
    bindkey -M $keymap -s '^[^[[D'       '^[[1;3D' # alt+left
    bindkey -M $keymap -s '^[^[[C'       '^[[1;3C' # alt+right
    bindkey -M $keymap -s '^[^[[7~'      '^[[1;3H' # alt+home
    bindkey -M $keymap -s '^[^[[8~'      '^[[1;3F' # alt+end
    bindkey -M $keymap -s '^[^[[3~'      '^[[3;3~' # alt+delete
    bindkey -M $keymap -s '^[[a'         '^[[1;2A' # shift+up
    bindkey -M $keymap -s '^[[b'         '^[[1;2B' # shift+down
    bindkey -M $keymap -s '^[[d'         '^[[1;2D' # shift+left
    bindkey -M $keymap -s '^[[c'         '^[[1;2C' # shift+right
    bindkey -M $keymap -s '^[[7$'        '^[[1;2H' # shift+home
    bindkey -M $keymap -s '^[[8$'        '^[[1;2F' # shift+end

    # Tmux sends different key codes. Translate them to xterm equivalents.
    bindkey -M $keymap -s '^[[1~'        '^[[H'    # home
    bindkey -M $keymap -s '^[[4~'        '^[[F'    # end
    bindkey -M $keymap -s '^[^[[A'       '^[[1;3A' # alt+up
    bindkey -M $keymap -s '^[^[[B'       '^[[1;3B' # alt+down
    bindkey -M $keymap -s '^[^[[D'       '^[[1;3D' # alt+left
    bindkey -M $keymap -s '^[^[[C'       '^[[1;3C' # alt+right
    bindkey -M $keymap -s '^[^[[1~'      '^[[1;3H' # alt+home
    bindkey -M $keymap -s '^[^[[4~'      '^[[1;3F' # alt+end
    bindkey -M $keymap -s '^[^[[3~'      '^[[3;3~' # alt+delete

    # iTerm2 sends different key codes. Translate them to xterm equivalents.
    bindkey -M $keymap -s '^[^[[A'       '^[[1;3A' # alt+up
    bindkey -M $keymap -s '^[^[[B'       '^[[1;3B' # alt+down
    bindkey -M $keymap -s '^[^[[D'       '^[[1;3D' # alt+left
    bindkey -M $keymap -s '^[^[[C'       '^[[1;3C' # alt+right
    bindkey -M $keymap -s '^[[1;9A'      '^[[1;3A' # alt+up
    bindkey -M $keymap -s '^[[1;9B'      '^[[1;3B' # alt+down
    bindkey -M $keymap -s '^[[1;9D'      '^[[1;3D' # alt+left
    bindkey -M $keymap -s '^[[1;9C'      '^[[1;3C' # alt+right
    bindkey -M $keymap -s '^[[1;9H'      '^[[1;3H' # alt+home
    bindkey -M $keymap -s '^[[1;9F'      '^[[1;3F' # alt+end

    # Terminals on macOS don't treat Option as Alt by default.
    # Translate en_US Option+Key key codes to Alt+Key equivalents.
    bindkey -M $keymap -s 'œ'            '^[q'     # alt+q
    bindkey -M $keymap -s '∑'            '^[w'     # alt+w
    bindkey -M $keymap -s '®'            '^[r'     # alt+r
    bindkey -M $keymap -s '†'            '^[t'     # alt+t
    bindkey -M $keymap -s 'ø'            '^[o'     # alt+o
    bindkey -M $keymap -s 'π'            '^[p'     # alt+p
    bindkey -M $keymap -s '“'            '^[['     # alt+[
    bindkey -M $keymap -s '‘'            '^[]'     # alt+]
    bindkey -M $keymap -s 'å'            '^[a'     # alt+a
    bindkey -M $keymap -s 'ß'            '^[s'     # alt+s
    bindkey -M $keymap -s '∂'            '^[d'     # alt+d
    bindkey -M $keymap -s 'ƒ'            '^[f'     # alt+f
    bindkey -M $keymap -s '©'            '^[g'     # alt+g
    bindkey -M $keymap -s '˙'            '^[h'     # alt+h
    bindkey -M $keymap -s '∆'            '^[j'     # alt+j
    bindkey -M $keymap -s '˚'            '^[k'     # alt+k
    bindkey -M $keymap -s '¬'            '^[l'     # alt+l
    bindkey -M $keymap -s 'Ω'            '^[z'     # alt+z
    bindkey -M $keymap -s '≈'            '^[x'     # alt+x
    bindkey -M $keymap -s 'ç'            '^[c'     # alt+c
    bindkey -M $keymap -s '√'            '^[v'     # alt+v
    bindkey -M $keymap -s '∫'            '^[b'     # alt+b
    bindkey -M $keymap -s 'µ'            '^[m'     # alt+m
    bindkey -M $keymap -s '≤'            '^[,'     # alt+,
    bindkey -M $keymap -s '≥'            '^[.'     # alt+.
    bindkey -M $keymap -s '÷'            '^[/'     # alt+/
    bindkey -M $keymap -s '«'            '^[\\'    # alt+\
    bindkey -M $keymap -s 'Œ'            '^[Q'     # alt+Q
    bindkey -M $keymap -s '„'            '^[W'     # alt+W
    bindkey -M $keymap -s '´'            '^[E'     # alt+E
    bindkey -M $keymap -s '‰'            '^[R'     # alt+R
    bindkey -M $keymap -s 'ˇ'            '^[T'     # alt+T
    bindkey -M $keymap -s 'Á'            '^[Y'     # alt+Y
    bindkey -M $keymap -s '¨'            '^[U'     # alt+U
    bindkey -M $keymap -s 'ˆ'            '^[I'     # alt+I
    bindkey -M $keymap -s 'Ø'            '^[O'     # alt+O
    bindkey -M $keymap -s '∏'            '^[P'     # alt+P
    bindkey -M $keymap -s 'Å'            '^[A'     # alt+A
    bindkey -M $keymap -s 'Í'            '^[S'     # alt+S
    bindkey -M $keymap -s 'Î'            '^[D'     # alt+D
    bindkey -M $keymap -s 'Ï'            '^[F'     # alt+F
    bindkey -M $keymap -s '˝'            '^[G'     # alt+G
    bindkey -M $keymap -s 'Ó'            '^[H'     # alt+H
    bindkey -M $keymap -s 'Ô'            '^[J'     # alt+J
    bindkey -M $keymap -s '\357\243\277' '^[K'     # alt+K
    bindkey -M $keymap -s 'Ò'            '^[L'     # alt+L
    bindkey -M $keymap -s '¸'            '^[Z'     # alt+Z
    bindkey -M $keymap -s '˛'            '^[X'     # alt+X
    bindkey -M $keymap -s 'Ç'            '^[C'     # alt+C
    bindkey -M $keymap -s '◊'            '^[V'     # alt+V
    bindkey -M $keymap -s 'ı'            '^[B'     # alt+B
    bindkey -M $keymap -s '˜'            '^[N'     # alt+N
    bindkey -M $keymap -s 'Â'            '^[M'     # alt+M
  done

  for keymap in emacs viins; do
    bindkey -M $keymap '^[[1;5H' beginning-of-buffer-or-history # ctrl+home
    bindkey -M $keymap '^[[1;3H' beginning-of-buffer-or-history # alt+home
    bindkey -M $keymap '^[[1;5F' end-of-buffer-or-history       # ctrl+end
    bindkey -M $keymap '^[[1;3F' end-of-buffer-or-history       # alt+end
    bindkey -M $keymap '^[[3;5~' kill-word                      # ctrl+del
    bindkey -M $keymap '^[[3;3~' kill-word                      # alt+del
    bindkey -M $keymap '^[k'     backward-kill-line             # alt+k
    bindkey -M $keymap '^[K'     backward-kill-line             # alt+K
    bindkey -M $keymap '^[j'     kill-buffer                    # alt+j
    bindkey -M $keymap '^[J'     kill-buffer                    # alt+J
    bindkey -M $keymap '^[/'     redo                           # alt+/
    bindkey -M $keymap '^ '      zle-expand                     # ctrl+space
  done

  bindkey   -M emacs   '^[[3~'   delete-char                    # delete
  bindkey   -M viins   '^[[3~'   vi-delete-char                 # delete
  bindkey   -M emacs   '^[[H'    beginning-of-line              # home
  bindkey   -M viins   '^[[H'    vi-beginning-of-line           # home
  bindkey   -M emacs   '^[[F'    end-of-line                    # end
  bindkey   -M viins   '^[[F'    vi-end-of-line                 # end
  bindkey   -M emacs   '^[[1;3D' backward-word                  # alt+left
  bindkey   -M viins   '^[[1;3D' vi-backward-word               # alt+left
  bindkey   -M emacs   '^[[1;5D' backward-word                  # ctrl+left
  bindkey   -M viins   '^[[1;5D' vi-backward-word               # ctrl+left
  bindkey   -M emacs   '^[[1;3C' forward-word                   # alt+right
  bindkey   -M viins   '^[[1;3C' vi-forward-word                # alt+right
  bindkey   -M emacs   '^[[1;5C' forward-word                   # ctrl+right
  bindkey   -M viins   '^[[1;5C' vi-forward-word                # ctrl+right

  bindkey   -M viins   '^[d'     kill-word                      # alt+d
  bindkey   -M viins   '^[D'     kill-word                      # alt+D
  bindkey   -M viins   '^[^?'    vi-backward-kill-word          # alt+bs
  bindkey   -M viins   '^[^H'    vi-backward-kill-word          # ctrl+alt+bs
  bindkey   -M viins   '^_'      undo                           # ctrl+/
  bindkey   -M viins   '^Xu'     undo                           # ctrl+x u
  bindkey   -M viins   '^X^U'    undo                           # ctrl+x ctrl+u
  bindkey   -M viins   '^[h'     run-help                       # alt+h
  bindkey   -M viins   '^[H'     run-help                       # alt+H
  bindkey   -M viins   '^[b'     vi-backward-word               # alt+b
  bindkey   -M viins   '^[B'     vi-backward-word               # alt+B
  bindkey   -M viins   '^[f'     vi-forward-word                # alt+f
  bindkey   -M viins   '^[F'     vi-forward-word                # alt+F
}

zmodload zsh/terminfo
autoload -Uz compinit bashcompinit zmv run-help ${^fpath}/run-help-^*.zwc(N:t)
[[ -v aliases[run-help] ]] && unalias run-help

export LESS='-iRFXMx4'
[[ -v commands[less] ]] && export PAGER=less

() {
  (( $# )) && export LESSOPEN="| /usr/bin/env ${(q)1} %s 2>/dev/null"
} ${commands[lesspipe]:-${commands[lesspipe.sh]}}

export LS_COLORS='fi=00:mi=00:mh=00:ln=01;36:or=01;31:di=01;34:ow=04;01;34:st=34:tw=04;34:'
LS_COLORS+='pi=01;33:so=01;33:do=01;33:bd=01;33:cd=01;33:su=01;35:sg=01;35:ca=01;35:ex=01;32'
if (( terminfo[colors] >= 256 )); then
  LS_COLORS+=':no=38;5;248'
else
  LS_COLORS+=':no=1;30'
fi

export LSCOLORS='ExGxDxDxCxDxDxFxFxexEx'
export TREE_COLORS=${LS_COLORS//04;}

zstyle ':completion:*'               squeeze-slashes   yes
zstyle ':completion:*:paths'         accept-exact-dirs yes
zstyle ':completion:*'               single-ignored    show
zstyle ':completion:*:rm:*'          ignore-line       other
zstyle ':completion:*:kill:*'        ignore-line       other
zstyle ':completion:*:diff:*'        ignore-line       other
zstyle ':completion:*'               menu              yes select
zstyle ':completion:*:-tilde-:*'     tag-order         directory-stack named-directories users
zstyle ':completion:*:-subscript-:*' tag-order         'indexes parameters'
zstyle ':completion:*'               list-colors       ${(s.:.)LS_COLORS}
zstyle ':completion:*'               matcher-list      'm:{a-z}={A-Z}'
zstyle ':completion:*:rm:*'          file-patterns     '*:all-files'
zstyle ':completion:*:functions'     ignored-patterns  '-*|_*'
zstyle ':completion:*:parameters'    ignored-patterns  '_*'

() {
  compinit -u -d $1
  [[ $1.zwc -nt $1 ]] || zcompile -R -- $1.zwc $1
} $ZDOTDIR/.zcompdump.$EUID

bashcompinit

if [[ -z $ZDOTDIR(#qNU) && ! -e $ZDOTDIR/.zsh_history ]]; then
  HISTFILE=$ZDOTDIR/.zsh_history.$EUID
else
  HISTFILE=$ZDOTDIR/.zsh_history
fi
HISTSIZE=1000000000
SAVEHIST=1000000000

DIRSTACKSIZE=1000
ZLE_RPROMPT_INDENT=0
PROMPT_EOL_MARK='%K{red} %k'
TIMEFMT='user=%U system=%S cpu=%P total=%*E'
zle_highlight=(paste:none)

PS1='%(#.%F{1}.%F{5})%n%f'
if [[ -r /proc/1/cpuset(#qN-.) &&
      "$(</proc/1/cpuset)" == /docker/[[:xdigit:]](#c64) ]]; then
  PS1+='@%F{3}%m%f'
  RPS1='in %F{2}docker%f'
elif [[ -n $SSH_CONNECTION ]]; then
  PS1+='@%F{3}%m%f'
  RPS1='via %F{2}ssh%f'
fi
PS1+=' %B%F{4}%~%f%b %F{%(?.2.1)}%#%f '

() {
  local k v kv=(grep '--color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}')
  if [[ -v commands[dircolors] ]]; then
    kv+=(diff '--color=auto' ls '--color=auto')
  else
    kv+=(ls '-G')
  fi
  for k v in $kv; do
    [[ ${k:c:A:t} == busybox* ]] || alias $k="$k $v"
  done
}

alias ls="${aliases[ls]:-ls} -A"
