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
  ];
  services.udisks2.enable = true;
}
