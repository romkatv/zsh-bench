set -ue

printf '==> setting up a container for benchmarking ...\n'

aptget() {
  DEBIAN_FRONTEND=noninteractive DEBCONF_NOWARNINGS=yes \
    command apt-get                                     \
    -o DPkg::options::="--force-confdef"                \
    -o DPkg::options::="--force-confold"                \
    -qq "$@" >/dev/null
}

aptget update
aptget upgrade -y
aptget install -y curl git make ncurses-bin perl sudo util-linux zsh

starship="$(curl -fsSL https://starship.rs/install.sh)"
sh -c "$starship" sh -y >/dev/null

git config --system core.untrackedCache true

dir="$(dirname -- "$0")"
zsh -- "$dir"/install-tmux.zsh
zsh -- "$dir"/benchmark-all.zsh "$@"
