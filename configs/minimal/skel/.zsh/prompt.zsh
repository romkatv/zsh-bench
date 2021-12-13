PS1='%(#.%F{1}.%F{5})%n%f'
if [[ -r /proc/1/cpuset(#qN-.) && $(</proc/1/cpuset) == /docker/* ]]; then
  PS1+='@%F{3}%m%f'
  RPS1='in %F{2}docker%f'
elif [[ -n $SSH_CONNECTION ]]; then
  PS1+='@%F{3}%m%f'
  RPS1='via %F{2}ssh%f'
fi
PS1+=' %B%F{4}%~%f%b %F{%(?.2.1)}%#%f '

PROMPT_EOL_MARK='%K{red} %k'
ZLE_RPROMPT_INDENT=0
