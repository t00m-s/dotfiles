if status is-interactive
# Commands to run in interactive sessions can go here
end
if not type -q fisher
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    fisher install jorgebucaran/fisher 
    fisher install jorgebucaran/nvm.fish
    fisher install jorgebucaran/autopair.fish 
    fisher install PatrickF1/fzf.fish 
    fisher install givensuman/fish-eza 
    fisher install givensuman/fish-bat 
    fisher install icezyclon/zoxide.fish 
    fisher install paysonwallach/fish-you-should-use
end

fzf --fish | source
zoxide init fish | source
starship init fish | source
