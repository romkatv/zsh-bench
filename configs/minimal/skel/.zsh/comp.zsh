zstyle ':completion:*'               squeeze-slashes   yes
zstyle ':completion:*:paths'         accept-exact-dirs yes
zstyle ':completion:*'               single-ignored    show
zstyle ':completion:*:rm:*'          ignore-line       other
zstyle ':completion:*:kill:*'        ignore-line       other
zstyle ':completion:*:diff:*'        ignore-line       other
zstyle ':completion:*'               menu              yes select
zstyle ':completion:*:-tilde-:*'     tag-order         directory-stack named-directories users
zstyle ':completion:*:-subscript-:*' tag-order         'indexes parameters'
zstyle ':completion:*'               list-colors       ${${(s.:.)LS_COLORS}:#no=*}
zstyle ':completion:*'               matcher-list      'm:{a-z}={A-Z}'
zstyle ':completion:*:rm:*'          file-patterns     '*:all-files'
zstyle ':completion:*:functions'     ignored-patterns  '-*|_*'
zstyle ':completion:*:parameters'    ignored-patterns  '_*'

set -- $ZDOTDIR/.zcompdump
[[ (-r $1 || ! -e $1) && (-r $1.zwc || ! -e $1.zwc) ]] || command rm -f -- $1 $1.zwc
compinit -u -d $1
[[ $1.zwc -nt $1 ]] || zcompile -R -- $1.zwc $1
bashcompinit
