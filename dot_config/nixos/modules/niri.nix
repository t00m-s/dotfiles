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
}
