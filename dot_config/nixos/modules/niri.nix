{ config, pkgs, ... }:

{
  # 1. Window Manager
  programs.niri.enable = true;

  # 2. Display Manager (GDM plays beautifully with modern Wayland sessions)
  # services.displaymanager.gdm = {
  #   enable = true;
  # };

  services.displayManager.sddm = {
    enable = true;

    # Enables experimental Wayland support
    wayland.enable = true;
  };
  # 3. Ghostty Terminal Installation
  environment.systemPackages = [ pkgs.ghostty ];

  # 4. Fonts and Emojis Setup
  fonts.packages = with pkgs; [
    # Modern individual package format
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono

    # Emoji Support
    noto-fonts-color-emoji
    twemoji-color-font
  ];

  # Direct system to look at emojis properly
  fonts.fontconfig.defaultFonts = {
    monospace = [ "FiraCode Nerd Font" "Noto Color Emoji" ];
    sansSerif = [ "Noto Sans" "Noto Color Emoji" ];
    serif = [ "Noto Serif" "Noto Color Emoji" ];
  };
}
