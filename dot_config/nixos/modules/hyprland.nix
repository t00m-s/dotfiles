{ inputs, pkgs, ... }:
{

  services.displayManager.sddm = {
    enable = true;
    theme = "catppuccin-mocha-mauve";
    package = pkgs.kdePackages.sddm;
    wayland.enable = true;
  };
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config.common.default = [
      "gnome"
      "gtk"
    ];
  };
  security.polkit.enable = true;
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    AQ_DRM_DEVICES = "/dev/dri/amd-igpu:/dev/dri/nvidia-dgpu";
  };
  environment.systemPackages = with pkgs; [
    ghostty
    fuzzel
    inputs.noctalia.packages.${stdenv.hostPlatform.system}.default
    playerctl
    brightnessctl
    bibata-cursors
    grim
    slurp
    (pkgs.catppuccin-sddm.override {
      flavor = "frappe";
      accent = "mauve";
      clockEnabled = true;
      userIcon = true;
      # font = "Noto Sans";
      # fontSize = "9";
      # background = "${./wallpaper.png}";
      # loginBackground = true;
    })
  ];
}
