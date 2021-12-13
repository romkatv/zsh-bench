set -- grep '--color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}'
if [[ -v commands[dircolors] ]]; then
  set -- $@ diff '--color=auto' ls '--color=auto'
else
  set -- $@ ls '-G'
fi
for 1 2; [[ ${1:c:A:t} == busybox* ]] || alias $1="$1 $2"

alias ls="${aliases[ls]:-ls} -A"
