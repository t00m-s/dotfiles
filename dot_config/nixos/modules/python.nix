{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ uv python3Packages.dbus-python ];
}
