# Delete all existing keymaps and reset to the default state.
bindkey -d
bindkey -e

zle-expand() zle _expand_alias || zle .expand-word || true
zle -N zle-expand

for 1 in emacs viins vicmd; do
  # If NumLock is off, translate keys to make them appear the same as with NumLock on.
  bindkey -M $1 -s '^[OM'         '^M'      # enter
  bindkey -M $1 -s '^[OX'         '='
  bindkey -M $1 -s '^[Oj'         '*'
  bindkey -M $1 -s '^[Ok'         '+'
  bindkey -M $1 -s '^[Ol'         '+'
  bindkey -M $1 -s '^[Om'         '-'
  bindkey -M $1 -s '^[On'         '.'
  bindkey -M $1 -s '^[Oo'         '/'
  bindkey -M $1 -s '^[Op'         '0'
  bindkey -M $1 -s '^[Oq'         '1'
  bindkey -M $1 -s '^[Or'         '2'
  bindkey -M $1 -s '^[Os'         '3'
  bindkey -M $1 -s '^[Ot'         '4'
  bindkey -M $1 -s '^[Ou'         '5'
  bindkey -M $1 -s '^[Ov'         '6'
  bindkey -M $1 -s '^[Ow'         '7'
  bindkey -M $1 -s '^[Ox'         '8'
  bindkey -M $1 -s '^[Oy'         '9'

  # If someone switches our terminal to application mode (smkx), translate keys to make
  # them appear the same as in raw mode (rmkx).
  bindkey -M $1 -s '^[OA'         '^[[A'    # up
  bindkey -M $1 -s '^[OB'         '^[[B'    # down
  bindkey -M $1 -s '^[OD'         '^[[D'    # left
  bindkey -M $1 -s '^[OC'         '^[[C'    # right
  bindkey -M $1 -s '^[OH'         '^[[H'    # home
  bindkey -M $1 -s '^[OF'         '^[[F'    # end

  # TTY sends different key codes. Translate them to xterm equivalents.
  bindkey -M $1 -s '^[[1~'        '^[[H'    # home
  bindkey -M $1 -s '^[[4~'        '^[[F'    # end

  # Urxvt sends different key codes. Translate them to xterm equivalents.
  bindkey -M $1 -s '^[[7~'        '^[[H'    # home
  bindkey -M $1 -s '^[[8~'        '^[[F'    # end
  bindkey -M $1 -s '^[Oa'         '^[[1;5A' # ctrl+up
  bindkey -M $1 -s '^[Ob'         '^[[1;5B' # ctrl+down
  bindkey -M $1 -s '^[Od'         '^[[1;5D' # ctrl+left
  bindkey -M $1 -s '^[Oc'         '^[[1;5C' # ctrl+right
  bindkey -M $1 -s '^[[7\^'       '^[[1;5H' # ctrl+home
  bindkey -M $1 -s '^[[8\^'       '^[[1;5F' # ctrl+end
  bindkey -M $1 -s '^[[3\^'       '^[[3;5~' # ctrl+delete
  bindkey -M $1 -s '^[^[[A'       '^[[1;3A' # alt+up
  bindkey -M $1 -s '^[^[[B'       '^[[1;3B' # alt+down
  bindkey -M $1 -s '^[^[[D'       '^[[1;3D' # alt+left
  bindkey -M $1 -s '^[^[[C'       '^[[1;3C' # alt+right
  bindkey -M $1 -s '^[^[[7~'      '^[[1;3H' # alt+home
  bindkey -M $1 -s '^[^[[8~'      '^[[1;3F' # alt+end
  bindkey -M $1 -s '^[^[[3~'      '^[[3;3~' # alt+delete
  bindkey -M $1 -s '^[[a'         '^[[1;2A' # shift+up
  bindkey -M $1 -s '^[[b'         '^[[1;2B' # shift+down
  bindkey -M $1 -s '^[[d'         '^[[1;2D' # shift+left
  bindkey -M $1 -s '^[[c'         '^[[1;2C' # shift+right
  bindkey -M $1 -s '^[[7$'        '^[[1;2H' # shift+home
  bindkey -M $1 -s '^[[8$'        '^[[1;2F' # shift+end

  # Tmux sends different key codes. Translate them to xterm equivalents.
  bindkey -M $1 -s '^[[1~'        '^[[H'    # home
  bindkey -M $1 -s '^[[4~'        '^[[F'    # end
  bindkey -M $1 -s '^[^[[A'       '^[[1;3A' # alt+up
  bindkey -M $1 -s '^[^[[B'       '^[[1;3B' # alt+down
  bindkey -M $1 -s '^[^[[D'       '^[[1;3D' # alt+left
  bindkey -M $1 -s '^[^[[C'       '^[[1;3C' # alt+right
  bindkey -M $1 -s '^[^[[1~'      '^[[1;3H' # alt+home
  bindkey -M $1 -s '^[^[[4~'      '^[[1;3F' # alt+end
  bindkey -M $1 -s '^[^[[3~'      '^[[3;3~' # alt+delete

  # iTerm2 sends different key codes. Translate them to xterm equivalents.
  bindkey -M $1 -s '^[^[[A'       '^[[1;3A' # alt+up
  bindkey -M $1 -s '^[^[[B'       '^[[1;3B' # alt+down
  bindkey -M $1 -s '^[^[[D'       '^[[1;3D' # alt+left
  bindkey -M $1 -s '^[^[[C'       '^[[1;3C' # alt+right
  bindkey -M $1 -s '^[[1;9A'      '^[[1;3A' # alt+up
  bindkey -M $1 -s '^[[1;9B'      '^[[1;3B' # alt+down
  bindkey -M $1 -s '^[[1;9D'      '^[[1;3D' # alt+left
  bindkey -M $1 -s '^[[1;9C'      '^[[1;3C' # alt+right
  bindkey -M $1 -s '^[[1;9H'      '^[[1;3H' # alt+home
  bindkey -M $1 -s '^[[1;9F'      '^[[1;3F' # alt+end

  # Terminals on macOS don't treat Option as Alt by default.
  # Translate en_US Option+Key key codes to Alt+Key equivalents.
  bindkey -M $1 -s 'œ'            '^[q'     # alt+q
  bindkey -M $1 -s '∑'            '^[w'     # alt+w
  bindkey -M $1 -s '®'            '^[r'     # alt+r
  bindkey -M $1 -s '†'            '^[t'     # alt+t
  bindkey -M $1 -s 'ø'            '^[o'     # alt+o
  bindkey -M $1 -s 'π'            '^[p'     # alt+p
  bindkey -M $1 -s '“'            '^[['     # alt+[
  bindkey -M $1 -s '‘'            '^[]'     # alt+]
  bindkey -M $1 -s 'å'            '^[a'     # alt+a
  bindkey -M $1 -s 'ß'            '^[s'     # alt+s
  bindkey -M $1 -s '∂'            '^[d'     # alt+d
  bindkey -M $1 -s 'ƒ'            '^[f'     # alt+f
  bindkey -M $1 -s '©'            '^[g'     # alt+g
  bindkey -M $1 -s '˙'            '^[h'     # alt+h
  bindkey -M $1 -s '∆'            '^[j'     # alt+j
  bindkey -M $1 -s '˚'            '^[k'     # alt+k
  bindkey -M $1 -s '¬'            '^[l'     # alt+l
  bindkey -M $1 -s 'Ω'            '^[z'     # alt+z
  bindkey -M $1 -s '≈'            '^[x'     # alt+x
  bindkey -M $1 -s 'ç'            '^[c'     # alt+c
  bindkey -M $1 -s '√'            '^[v'     # alt+v
  bindkey -M $1 -s '∫'            '^[b'     # alt+b
  bindkey -M $1 -s 'µ'            '^[m'     # alt+m
  bindkey -M $1 -s '≤'            '^[,'     # alt+,
  bindkey -M $1 -s '≥'            '^[.'     # alt+.
  bindkey -M $1 -s '÷'            '^[/'     # alt+/
  bindkey -M $1 -s '«'            '^[\\'    # alt+\
  bindkey -M $1 -s 'Œ'            '^[Q'     # alt+Q
  bindkey -M $1 -s '„'            '^[W'     # alt+W
  bindkey -M $1 -s '´'            '^[E'     # alt+E
  bindkey -M $1 -s '‰'            '^[R'     # alt+R
  bindkey -M $1 -s 'ˇ'            '^[T'     # alt+T
  bindkey -M $1 -s 'Á'            '^[Y'     # alt+Y
  bindkey -M $1 -s '¨'            '^[U'     # alt+U
  bindkey -M $1 -s 'ˆ'            '^[I'     # alt+I
  bindkey -M $1 -s 'Ø'            '^[O'     # alt+O
  bindkey -M $1 -s '∏'            '^[P'     # alt+P
  bindkey -M $1 -s 'Å'            '^[A'     # alt+A
  bindkey -M $1 -s 'Í'            '^[S'     # alt+S
  bindkey -M $1 -s 'Î'            '^[D'     # alt+D
  bindkey -M $1 -s 'Ï'            '^[F'     # alt+F
  bindkey -M $1 -s '˝'            '^[G'     # alt+G
  bindkey -M $1 -s 'Ó'            '^[H'     # alt+H
  bindkey -M $1 -s 'Ô'            '^[J'     # alt+J
  bindkey -M $1 -s '\357\243\277' '^[K'     # alt+K
  bindkey -M $1 -s 'Ò'            '^[L'     # alt+L
  bindkey -M $1 -s '¸'            '^[Z'     # alt+Z
  bindkey -M $1 -s '˛'            '^[X'     # alt+X
  bindkey -M $1 -s 'Ç'            '^[C'     # alt+C
  bindkey -M $1 -s '◊'            '^[V'     # alt+V
  bindkey -M $1 -s 'ı'            '^[B'     # alt+B
  bindkey -M $1 -s '˜'            '^[N'     # alt+N
  bindkey -M $1 -s 'Â'            '^[M'     # alt+M
done

for 1 in emacs viins; do
  bindkey -M $1    '^[[1;5H' beginning-of-buffer-or-history # ctrl+home
  bindkey -M $1    '^[[1;3H' beginning-of-buffer-or-history # alt+home
  bindkey -M $1    '^[[1;5F' end-of-buffer-or-history       # ctrl+end
  bindkey -M $1    '^[[1;3F' end-of-buffer-or-history       # alt+end
  bindkey -M $1    '^[[3;5~' kill-word                      # ctrl+del
  bindkey -M $1    '^[[3;3~' kill-word                      # alt+del
  bindkey -M $1    '^[k'     backward-kill-line             # alt+k
  bindkey -M $1    '^[K'     backward-kill-line             # alt+K
  bindkey -M $1    '^[j'     kill-buffer                    # alt+j
  bindkey -M $1    '^[J'     kill-buffer                    # alt+J
  bindkey -M $1    '^[/'     redo                           # alt+/
  bindkey -M $1    '^ '      zle-expand                     # ctrl+space
done

bindkey   -M emacs '^[[3~'   delete-char                    # delete
bindkey   -M viins '^[[3~'   vi-delete-char                 # delete
bindkey   -M emacs '^[[H'    beginning-of-line              # home
bindkey   -M viins '^[[H'    vi-beginning-of-line           # home
bindkey   -M emacs '^[[F'    end-of-line                    # end
bindkey   -M viins '^[[F'    vi-end-of-line                 # end
bindkey   -M emacs '^[[1;3D' backward-word                  # alt+left
bindkey   -M viins '^[[1;3D' vi-backward-word               # alt+left
bindkey   -M emacs '^[[1;5D' backward-word                  # ctrl+left
bindkey   -M viins '^[[1;5D' vi-backward-word               # ctrl+left
bindkey   -M emacs '^[[1;3C' forward-word                   # alt+right
bindkey   -M viins '^[[1;3C' vi-forward-word                # alt+right
bindkey   -M emacs '^[[1;5C' forward-word                   # ctrl+right
bindkey   -M viins '^[[1;5C' vi-forward-word                # ctrl+right

bindkey   -M viins '^[d'     kill-word                      # alt+d
bindkey   -M viins '^[D'     kill-word                      # alt+D
bindkey   -M viins '^[^?'    vi-backward-kill-word          # alt+bs
bindkey   -M viins '^[^H'    vi-backward-kill-word          # ctrl+alt+bs
bindkey   -M viins '^_'      undo                           # ctrl+/
bindkey   -M viins '^Xu'     undo                           # ctrl+x u
bindkey   -M viins '^X^U'    undo                           # ctrl+x ctrl+u
bindkey   -M viins '^[h'     run-help                       # alt+h
bindkey   -M viins '^[H'     run-help                       # alt+H
bindkey   -M viins '^[b'     vi-backward-word               # alt+b
bindkey   -M viins '^[B'     vi-backward-word               # alt+B
bindkey   -M viins '^[f'     vi-forward-word                # alt+f
bindkey   -M viins '^[F'     vi-forward-word                # alt+F
