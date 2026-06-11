{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    obsidian
    vesktop
    signal-desktop
    (yazi.override {
      _7zz = _7zz-rar; # Support for RAR extraction
    })
  ];
}
