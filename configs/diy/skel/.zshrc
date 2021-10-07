# If not in tmux, start tmux.
if [[ -z ${TMUX+X}${ZSH_SCRIPT+X}${ZSH_EXECUTION_STRING+X} ]]; then
  exec tmux
fi

# Enable the "new" completion system (compsys).
autoload -Uz compinit && compinit

# Enable syntax highlighting.
source ~/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Enable autosuggestions.
source ~/zsh-autosuggestions/zsh-autosuggestions.zsh

# Configure prompt to show the current working directory and git branch.
autoload -Uz vcs_info add-zsh-hook
add-zsh-hook precmd vcs_info
PS1='%~ $vcs_info_msg_0_'
setopt prompt_subst
