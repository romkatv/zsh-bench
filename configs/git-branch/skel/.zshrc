autoload -Uz vcs_info
precmd() vcs_info
PS1='%~$vcs_info_msg_0_ '
setopt prompt_subst
