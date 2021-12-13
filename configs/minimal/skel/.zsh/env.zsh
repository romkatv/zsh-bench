typeset -gxUT INFOPATH infopath
typeset -gxU PATH path FPATH fpath MANPATH manpath

export LESS='-iRFXMx4'
[[ -v commands[less] ]] && export PAGER=less

export LS_COLORS='fi=00:mi=00:mh=00:ln=01;36:or=01;31:di=01;34:ow=04;01;34:st=34:tw=04;34:'
LS_COLORS+='pi=01;33:so=01;33:do=01;33:bd=01;33:cd=01;33:su=01;35:sg=01;35:ca=01;35:ex=01;32'
if (( terminfo[colors] >= 256 )); then
  LS_COLORS+=':no=38;5;248'
else
  LS_COLORS+=':no=1;30'
fi

export TREE_COLORS=${LS_COLORS//04;}
export LSCOLORS='ExGxDxDxCxDxDxFxFxexEx'

set -- ${commands[lesspipe]:-${commands[lesspipe.sh]}}
(( $# )) && export LESSOPEN="| /usr/bin/env ${(q)1} %s 2>/dev/null"
