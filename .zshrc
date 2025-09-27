export EDITOR=nvim
export ZSH="$HOME/.oh-my-zsh"
export PATH=$PATH:~/.cargo/bin/
export PATH=$PATH:~/.local/bin/
export PATH=$PATH:~/bin/

ZSH_THEME="robbyrussell"

plugins=(
    git
    sudo
    web-search
    archlinux
    copyfile
    copybuffer
    dirhistory
    wd
    docker
)

# fzf bindings
source $ZSH/oh-my-zsh.sh
source <(fzf --zsh)

# history config
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory


# aliases to stuff
alias ls='eza -a --icons=never'
alias ll='eza -al --icons=never'
alias lt='eza -a --tree --level=1 --icons=never'
alias shutdown='systemctl poweroff'
# this is weird, but it let's me use traditional vim for `sudo vim` so i can copy/paste correctly
alias vi='vim'
alias vim='$EDITOR'

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin:/usr/local/go/bin

# bind home and end to jump to beginning/end of line
bindkey '\e[H' beginning-of-line
bindkey '\e[F' end-of-line

export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="/usr/bin:$PATH"

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export SYSTEMD_EDITOR=nvim

# mount/unmount extra btrfs volume
mount-pstorage() {
    mkdir -p ~/pstorage
    sudo mount -t btrfs -o subvol=@pstorage,noatime,compress=zstd /dev/nvme0n1p2 ~/pstorage && \
    sudo chown $(id -u):$(id -g) ~/pstorage && \
    echo "Mounted pstorage"
}

umount-pstorage() {
    if mountpoint -q ~/pstorage; then
        sudo umount ~/pstorage && rmdir ~/pstorage && echo "Unmounted and removed pstorage"
    else
        echo "Not mounted"
    fi
}

# print the fancy arch fastfetch when we open
if [[ $(tty) == *"pts"* ]]; then
    fastfetch
fi
