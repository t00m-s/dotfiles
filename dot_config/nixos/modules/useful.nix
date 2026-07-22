{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    obsidian
    vesktop
    signal-desktop
    spotify
    (yazi.override {
      _7zz = _7zz-rar; # Support for RAR extraction
    })
    telegram-desktop
    nautilus
  ];
  services.gvfs.enable = true;
  services.udisks2.enable = true;
}
