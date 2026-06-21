{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    AQ_DRM_DEVICES = "/dev/dri/amd-igpu:/dev/dri/nvidia-dgpu";
  };
  environment.systemPackages = with pkgs; [
    bibata-cursors
    grim
    slurp
  ];
}
