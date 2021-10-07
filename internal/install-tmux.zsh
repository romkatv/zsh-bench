#!/usr/bin/env zsh

emulate -L zsh -o err_return
setopt no_unset extended_glob typeset_silent no_multi_byte \
       prompt_percent no_prompt_subst warn_create_global pipe_fail

() {

zmodload -F zsh/files b:{zf_mkdir,zf_rm,zf_ln}

cd /usr/local
curl -fsSL https://github.com/romkatv/tmux-bin/releases/download/v3.0.2/tmux-linux-x86_64.tar.gz |
  tar -xz

cd
curl -fsSL https://github.com/romkatv/terminfo/archive/v1.1.0.tar.gz | tar -xz

local src=(terminfo*)
(( $#src == 1 ))

local pat hex char
for pat in "[^A-Z]" "[A-Z]"; do
  for hex in $src/[[:xdigit:]][[:xdigit:]](:t); do
    printf -v char "\\x$hex"
    [[ $char == $~pat ]] || continue
    [[ -e ~/.terminfo/$hex ]] || zf_mkdir -p -- ~/.terminfo/$hex || return
    cp -- $src/$hex/* ~/.terminfo/$hex/ || return
    if [[ $char == [a-z] || ! ~/.terminfo/$char -ef ~/.terminfo/${(L)char}] ]]; then
      [[ -e ~/.terminfo/$char ]]                       ||
        zf_ln -s -- $hex ~/.terminfo/$char 2>/dev/null ||
        zf_mkdir -p -- ~/.terminfo/$char               ||
        return
      cp -- $src/$hex/* ~/.terminfo/$char/ || return
    fi
    zf_rm -rf -- $src/$hex || return
  done
done

zf_rm -rf -- $src

}
