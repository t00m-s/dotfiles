{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    obsidian
    vesktop
    signal-desktop
  ];
}
