{ pkgs, ... }:
{
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  environment.systemPackages = with pkgs; [ seahorse ];
  environment.variables.XDG_RUNTIME_DIR = "/run/user/$UID"; # set the runtime directory
}
