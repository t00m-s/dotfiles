{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    eza # Modern ls replacement
    lazygit # TUI Git manager
    lazydocker # TUI Docker manager
    fzf # Fuzzy Finder
    ripgrep # Lightning-fast grep
    bat # Syntax-highlighted cat
    htop # System monitor
    neovim
    fish
    chezmoi
    vim
    nixfmt
    wget
    git
    tree-sitter
    gcc
    darkman
    starship
    zoxide
    tmux
    delta
    fastfetch
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.fish = {
    enable = true;
  };

  # Prevents fish from being the truly default shell; but runs immmediatly after bash
  programs.bash = {
    interactiveShellInit = ''
      # "check if parent process is not fish" && "make nested shells work properly"
      if grep -qv fish /proc/$PPID/comm && [[ $SHLVL == [12] ]]; then
          # set $SHELL for better integration with programs like nix shell, tmux, etc.
          SHELL=${pkgs.fish}/bin/fish exec fish
      fi
    '';
  };

}
