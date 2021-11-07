#!/bin/zsh
autoload -Uz zplug
zplug gitstatus
zplug async
(($+functions[gitstatus_check])) || return
(($+functions[async_init])) || return
autoload -U add-zsh-hook
add-zsh-hook precmd _git_prompt_precmd
add-zsh-hook zshexit _git_prompt_worker_shutdown

typeset -gA GITSTATUS
typeset -g  GITSTATUS_PROMPT
typeset -gi GITSTATUS_PROMPT_LEN

GITSTATUS[clean]='%F{green}' 	# green foreground
GITSTATUS[changed]='%F{cyan}'		# cyan forground
GITSTATUS[modified]='%F{blue}'  	# yellow foreground
GITSTATUS[seperator]='%F{magenta}'	# seperator
GITSTATUS[untracked]='%F{cyan}'   	# blue foreground
GITSTATUS[conflicted]='%F{red}'  	# red foreground

GITSTATUS[default]='%F{red}'
GITSTATUS[seperator]='-'
GITSTATUS[prefix]='['
GITSTATUS[suffix]=']'

function _git_prompt_update_async {
	emulate -L zsh
	# Call gitstatus_query asynchronously
	local \
		VCS_STATUS_ACTION VCS_STATUS_COMMIT \
		VCS_STATUS_COMMITS_AHEAD VCS_STATUS_COMMITS_BEHIND \
		VCS_STATUS_HAS_CONFLICTED VCS_STATUS_HAS_STAGED \
		VCS_STATUS_HAS_UNSTAGED VCS_STATUS_HAS_UNTRACKED \
		VCS_STATUS_INDEX_SIZE VCS_STATUS_LOCAL_BRANCH \
		VCS_STATUS_NUM_ASSUME_UNCHANGED VCS_STATUS_NUM_CONFLICTED \
		VCS_STATUS_NUM_SKIP_WORKTREE VCS_STATUS_NUM_STAGED \
		VCS_STATUS_NUM_STAGED_DELETED VCS_STATUS_NUM_STAGED_NEW \
		VCS_STATUS_NUM_UNSTAGED VCS_STATUS_NUM_UNSTAGED_DELETED \
		VCS_STATUS_NUM_UNTRACKED VCS_STATUS_PUSH_COMMITS_AHEAD \
		VCS_STATUS_PUSH_COMMITS_BEHIND VCS_STATUS_PUSH_REMOTE_NAME \
		VCS_STATUS_PUSH_REMOTE_URL VCS_STATUS_REMOTE_BRANCH \
		VCS_STATUS_REMOTE_NAME VCS_STATUS_REMOTE_URL \
		VCS_STATUS_RESULT VCS_STATUS_STASHES \
		VCS_STATUS_TAG VCS_STATUS_WORKDIR
	gitstatus_check "gitstatus$$" || gitstatus_start -s -1 -u -1 -c -1 -d -1 "gitstatus$$"
	gitstatus_query "gitstatus$$" || return 1
	[[ $VCS_STATUS_RESULT == 'ok-sync' ]] || return 0  # not a git repo
	local head stat where  # branch name, tag or commit

	head="%B${GITSTATUS[clean]}"
	if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
		case $VCS_STATUS_LOCAL_BRANCH in
			(pr/*) head+='';;
			(*) head+='';;
		esac
	    head+=' '
		where=$VCS_STATUS_LOCAL_BRANCH
	elif [[ -n $VCS_STATUS_TAG ]]; then
		head+=' '
		where=$VCS_STATUS_TAG
	else
		head+=' '
		where=${VCS_STATUS_COMMIT[1,8]}
	fi

	(( $#where > 32 )) && where[13,-13]="…"  # truncate long branch names and tags
	head+="${where//\%/%%}%b"             # escape %

	# ⇣42 if behind the remote.
	(( VCS_STATUS_COMMITS_BEHIND )) && stat+="${GITSTATUS[changed]}%B⇣%b${VCS_STATUS_COMMITS_BEHIND}"

	# ⇡42 if ahead of the remote; no leading space if also behind the remote: ⇣42⇡42.
	(( VCS_STATUS_COMMITS_AHEAD  )) && stat+="${GITSTATUS[changed]}%B⇡%b${VCS_STATUS_COMMITS_AHEAD}"

	# ⇠42 if behind the push remote.
	(( VCS_STATUS_PUSH_COMMITS_BEHIND )) && stat+="${GITSTATUS[changed]}%B⇠%b${VCS_STATUS_PUSH_COMMITS_BEHIND}"
	# ⇢42 if ahead of the push remote; no leading space if also behind: ⇠42⇢42.
	(( VCS_STATUS_PUSH_COMMITS_AHEAD  )) && stat+="${GITSTATUS[changed]}%B⇢%b${VCS_STATUS_PUSH_COMMITS_AHEAD}"
	((
		  VCS_STATUS_COMMITS_BEHIND
		+ VCS_STATUS_COMMITS_AHEAD
		+ VCS_STATUS_PUSH_COMMITS_BEHIND
		+ VCS_STATUS_PUSH_COMMITS_AHEAD
	)) && {
		stat+="%B:%b${GITSTATUS[clean]}"
	}
	# *42 if have stashes.
	(( VCS_STATUS_STASHES        	  )) && stat+="${GITSTATUS[clean]}%B☰%b ${VCS_STATUS_STASHES}%f"
	((
			VCS_STATUS_NUM_CONFLICTED
		+	VCS_STATUS_NUM_STAGED
		+	VCS_STATUS_NUM_UNSTAGED
		+	VCS_STATUS_NUM_UNTRACKED
	)) && {
		# ~42 if have merge conflicts.
		(( VCS_STATUS_NUM_CONFLICTED )) && stat+="${GITSTATUS[conflicted]}%B~%b${VCS_STATUS_NUM_CONFLICTED}%f"

		# +42 if have staged changes.
		(( VCS_STATUS_NUM_STAGED     )) && stat+="${GITSTATUS[modified]}%B+%b${VCS_STATUS_NUM_STAGED}%f"

		# !42 if have unstaged changes.
		(( VCS_STATUS_NUM_UNSTAGED   )) && stat+="${GITSTATUS[modified]}%B!%b${VCS_STATUS_NUM_UNSTAGED}%f"

		# ?42 if have untracked files. It's really a question mark, your font isn't broken.
		(( VCS_STATUS_NUM_UNTRACKED  )) && stat+="${GITSTATUS[untracked]}%B?%b${VCS_STATUS_NUM_UNTRACKED}%f"

		# 'merge' if the repo is in an unusual state.
		[[ -n $VCS_STATUS_ACTION     ]] && head+="${GITSTATUS[conflicted]}:✘"
	}
	printf '%s' "${GITSTATUS[seperator]}${GITSTATUS[prefix]}${head}${stat:+:$stat}${GITSTATUS[default]}${GITSTATUS[suffix]}"
}

function _git_prompt_update {
	[[ $1 != _git_prompt_update_async ]] && return
	if [[ "$GITSTATUS_PROMPT" != "$3" ]];then
		emulate -L zsh
		GITSTATUS_PROMPT="$3"
		GITSTATUS_PROMPT_LEN="${(m)#${${GITSTATUS_PROMPT//\%\%/x}//\%(f|<->F)}}"
		# The length of GITSTATUS_PROMPT after removing %f and %F.
		(($6==0)) && zle && zle reset-prompt
	fi
}

function _git_prompt_worker_shutdown {
	async_stop_worker "gitworker$$" 2>/dev/null
}

function _git_prompt_worker_restart {
	_git_prompt_worker_shutdown
	async_start_worker "gitworker$$" -n
	async_register_callback "gitworker$$" _git_prompt_update
}

function _git_prompt_precmd {
	[[ $PWD =~ ^/run/user/[[:digit:]]*/gvfs/ ]] && return 0
	async_flush_jobs "gitworker$$"  2>/dev/null || _git_prompt_worker_restart
	async_worker_eval "gitworker$$" cd "$PWD"
	async_job "gitworker$$" _git_prompt_update_async
}
