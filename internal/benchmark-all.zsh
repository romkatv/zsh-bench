#!/usr/bin/env zsh

emulate -L zsh -o err_return
setopt no_unset extended_glob typeset_silent no_multi_byte \
       prompt_percent no_prompt_subst warn_create_global pipe_fail

() {

local -r user=zsh-bench-user
local -r root_dir=${ZSH_SCRIPT:h:h}

zmodload zsh/zutil

local -a iters
zparseopts -D -K -F -- {i,-iters}:=iters

function cleanup() {
  userdel -rf $user 2>/dev/null || true
  rm -rf -- '' /tmp/*(ND)
}

cleanup

local cfg
for cfg; do
  {
    useradd -ms /bin/zsh $user
    cp -r -- ~/.terminfo /home/$user/
    cp -r -- $root_dir /home/$user/zsh-bench
    chown -R $user:$user /home/$user/{zsh-bench,.terminfo}
    local cmd=(
      'export LC_ALL='${(qqq)LC_ALL}
      'cd -q -- ~/zsh-bench/configs/'$cfg
      './setup'
      'cd -q'
      '~/zsh-bench/zsh-bench '${(j: :)${(@qqq)iters}})
    print -r -- "==> benchmarking $cfg ..."
    sudo -u $user zsh -fc ${(j: && :)cmd}
  } always {
    cleanup
  }
done

} "$@"
