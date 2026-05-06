set fish_greeting
if set -q SSH_CONNECTION
    set -gx EDITOR vim
else
    set -gx EDITOR nvim
end

set -gx MANPAGER "nvim +Man!"
set -gx KUBE_EDITOR nvim
set -gx TERM xterm-256color
set -gx GNUPGHOME "$HOME/.private/.gpg"
set -gx DEBUGINFOD_URLS https://debuginfod.archlinux.org
set -gx DOCKER_HOST "unix://$XDG_RUNTIME_DIR/docker.sock"
fish_add_path "$HOME/.local/bin" "$HOME/.cargo/bin"
