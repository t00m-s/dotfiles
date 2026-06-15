{ pkgs, ... }:
{

  programs.steam = {
    enable = true; # Master switch, already covered in installation
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports for Source Dedicated Server hosting
    gamescopeSession.enable = true;
  };
  programs.gamemode = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    gamescope-wsi # HDR won't work without this
    protonup-ng
  ];

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };
  services.udev.extraRules = ''
  # Disable DS4 touchpad acting as mouse
  # USB
  ATTRS{name}=="Sony Interactive Entertainment Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
  # Bluetooth
  ATTRS{name}=="Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
'';
}
