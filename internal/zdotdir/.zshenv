setopt no_rcs

if (( ${+_ZB_ORIG_ZDOTDIR} )); then
  export ZDOTDIR=$_ZB_ORIG_ZDOTDIR
  unset _ZB_ORIG_ZDOTDIR
else
  unset ZDOTDIR
fi

zmodload zsh/datetime

typeset +x -gF _ZB_START_TIME_SEC _ZB_FIRST_PROMPT_LAG_MS _ZB_FIRST_COMMAND_LAG_MS \
               _ZB_COMMAND_LAG_MS _ZB_INPUT_LAG_MS

function -zb-sleep-until() {
  local -F deadline=$1
  while (( EPOCHREALTIME < deadline )) :
}

function -zb-precmd() {
  if (( ${+_ZB_FIRST_PROMPT_LAG_MS} )); then
    -zb-sleep-until '_ZB_START_TIME_SEC + 1e-3 * _ZB_FIRST_PROMPT_LAG_MS'
    unset _ZB_FIRST_PROMPT_LAG_MS
  else
    -zb-sleep-until 'EPOCHREALTIME + 1e-3 * _ZB_COMMAND_LAG_MS'
  fi
}

function -zb-preexec() {
  -zb-sleep-until '_ZB_START_TIME_SEC + 1e-3 * _ZB_FIRST_COMMAND_LAG_MS'
  typeset -g preexec_functions=(${(@)preexec_functions:#-zb-preexec})
}

function -zb-pre-redraw() {
  (( PENDING || KEYS_QUEUED_COUNT )) || -zb-sleep-until 'EPOCHREALTIME + 1e-3 * _ZB_INPUT_LAG_MS'
}

zle -N -- zle-line-pre-redraw -zb-pre-redraw
typeset -g precmd_functions=(-zb-precmd)
typeset -g preexec_functions=(-zb-preexec)
