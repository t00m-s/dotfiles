{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    eza
    lazygit
    lazydocker
    fzf
    ripgrep
    bat
    htop
    fish
    chezmoi
    (pkgs.btop.override {
      cudaSupport = true;
      rocmSupport = true;
    })
    vim
    nixfmt
    wget
    git
    gcc
    darkman
    starship
    zoxide
    tmux
    delta
    fastfetch
    unzip
    cmake
    pkg-config
    jetbrains.idea
  ];


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
