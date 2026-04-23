if [[ -n "$SSH_CONNECTION" ]]; then
  export EDITOR="vim"
else
  export EDITOR="nvim"
fi
export MANPAGER="nvim +Man!"
export KUBE_EDITOR="nvim"
export TERM=xterm-256color
export GNUPGHOME="$HOME/.private/.gpg"
export DEBUGINFOD_URLS=https://debuginfod.archlinux.org
export PATH="$PATH:$HOME/.local/bin:$HOME/.cargo/bin"
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
