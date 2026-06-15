{ config, pkgs, inputs, ... }:

{
  # 1. Window Manager
  programs.niri.enable = true;

  # 2. Display Manager (GDM plays beautifully with modern Wayland sessions)
  # services.displayManager.gdm = {
  #   enable = true;
  # };
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };
  security.polkit.enable = true; # polkit
  services.gnome.gnome-keyring.enable = true; # secret service
  services.displayManager.sddm = {
    theme = "sddm-astronaut-theme";
    extraPackages = [ pkgs.sddm-astronaut ];
    enable = true;
    wayland.enable = true;
  };

  # 3. Ghostty Terminal Installation
  environment.systemPackages = with pkgs; [
    ghostty
    xwayland-satellite
    fuzzel
    inputs.noctalia.packages.${stdenv.hostPlatform.system}.default
    playerctl
    brightnessctl
    hypridle
  ];
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk # Added for fallback UI elements
      xdg-desktop-portal-wlr
    ];
    config.common.default = [ "gnome" "gtk" "wlr" ];
  };

  # 4. Fonts and Emojis Setup
  fonts.packages = with pkgs; [
    # Modern individual package format
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono

    # Base Fonts (CRITICAL: Firefox needs these if they are set as defaults)
    noto-fonts
    
    # Emoji Support
    noto-fonts-color-emoji
    twemoji-color-font
  ];

  # Direct system to look at emojis properly
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "FiraCode Nerd Font" "JetBrainsMono Nerd Font" "Noto Color Emoji" ];
      sansSerif = [ "Noto Sans" "Noto Color Emoji" ];
      serif     = [ "Noto Serif" "Noto Color Emoji" ];
      emoji     = [ "Noto Color Emoji" ];
    };
  };
}
