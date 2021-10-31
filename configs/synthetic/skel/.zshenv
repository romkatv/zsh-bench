zmodload zsh/datetime

typeset -gF _zb_start_time_sec=EPOCHREALTIME
typeset -gF ZB_FIRST_PROMPT_LAG_MS ZB_FIRST_COMMAND_LAG_MS ZB_COMMAND_LAG_MS ZB_INPUT_LAG_MS

setopt no_rcs

function -zb-sleep-until() {
  local -F deadline=$1
  while (( EPOCHREALTIME < deadline )) :
}

function -zb-precmd() {
  if [[ -v _zb_first_cmd_done ]]; then
    -zb-sleep-until 'EPOCHREALTIME + 1e-3 * ZB_COMMAND_LAG_MS'
  else
    -zb-sleep-until '_zb_start_time_sec + 1e-3 * ZB_FIRST_PROMPT_LAG_MS'
    typeset -gr _zb_first_cmd_done
  fi
}

function -zb-preexec() {
  -zb-sleep-until '_zb_start_time_sec + 1e-3 * ZB_FIRST_COMMAND_LAG_MS'
  typeset -g preexec_functions=(${(@)preexec_functions:#-zb-preexec})
}

function -zb-pre-redraw() {
  (( PENDING || KEYS_QUEUED_COUNT )) || -zb-sleep-until 'EPOCHREALTIME + 1e-3 * ZB_INPUT_LAG_MS'
}

zle -N -- zle-line-pre-redraw -zb-pre-redraw
typeset -g precmd_functions=(-zb-precmd)
typeset -g preexec_functions=(-zb-preexec)
