#!/bin/zsh

setopt PROMPT_SUBST
autoload -U add-zsh-hook

typeset -gA DEVPROMPT

DEVPROMPT[prefix]='['
DEVPROMPT[suffix]=']'
DEVPROMPT[seperator]='-'
DEVPROMPT[icon]='%F{blue}'
DEVPROMPT[text]='%F{green}'
DEVPROMPT[default]='%F{red}'

add-zsh-hook precmd __devprompt_precmd

function __devprompt_precmd {
	DEVPROMPT_PROMPT=''
	[[ -n $VIRTUAL_ENV ]] && \
		DEVPROMPT_PROMPT+="${DEVPROMPT[seperator]}${DEVPROMPT[prefix]}${DEVPROMPT[icon]}%B ${DEVPROMPT[text]}${VIRTUAL_ENV##*/}%b${DEVPROMPT[default]}${DEVPROMPT[suffix]}"
	[[ -n $ROCK_ENV_NAME ]] && \
		DEVPROMPT_PROMPT+="${DEVPROMPT[seperator]}${DEVPROMPT[prefix]}${DEVPROMPT[icon]}%B ${DEVPROMPT[text]}${ROCK_ENV_NAME}%b${DEVPROMPT[default]}${DEVPROMPT[suffix]}"
	[[ -n $RBENV_VERSION ]] && \
			DEVPROMPT_PROMPT+="${DEVPROMPT[seperator]}${DEVPROMPT[prefix]}${DEVPROMPT[icon]}%B ${DEVPROMPT[text]}${RBENV_VERSION}%b${DEVPROMPT[default]}${DEVPROMPT[suffix]}"
}
