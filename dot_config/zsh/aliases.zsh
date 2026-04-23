alias cat='bat'
alias rcat='\cat'
alias lg="lazygit"
alias ldo="lazydocker"
alias ls='eza $eza_params'
alias l='eza --git-ignore $eza_params'
alias ll='eza --all --header --long $eza_params'
alias llm='eza --all --header --long --sort=modified $eza_params'
alias la='eza -lbhHigUmuSa'
alias lx='eza -lbhHigUmuSa@'
alias lt='eza --tree $eza_params'
alias tree='eza --tree $eza_params'
alias cd="z"
alias p="python3"
alias g="git"
alias d="docker"
alias dc="docker compose"
alias dcu="docker compose up -d"
alias dcb="docker compose build"
alias dcd="docker compose down"
alias dps='docker ps --format "{{.ID}}  {{.Names}}"'
dsh() {
  if [ -n "$1" ]; then
    docker exec -it "$1" /bin/bash
  else
    echo "Usage: dsh <container-id>"
    return 1
  fi
}

fuck() {
  if [ -n "$1" ]; then
    killall -9 $1
  else
    echo "Usage: fuck <application>"
    return 1
  fi
}
alias rm="rm -i"
alias vi="nvim"
