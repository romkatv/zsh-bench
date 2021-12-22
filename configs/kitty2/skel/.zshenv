export KITTY_SHELL_INTEGRATION=enabled
export KITTY_ORIG_ZDOTDIR=~/zsh
export KITTY_INSTALLATION_DIR=~/kitty
export ZDOTDIR=~/kitty/shell-integration/zsh

source ~/kitty/shell-integration/zsh/.zshenv

typeset +x ZDOTDIR
setopt no_global_rcs
