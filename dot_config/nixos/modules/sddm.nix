{ pkgs, ... }:
{

  services.displayManager.sddm = {
    enable = true;
    theme = "catppuccin-frappe-mauve";
    package = pkgs.kdePackages.sddm;
    wayland.enable = true;
  };

  environment.systemPackages = [
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

  security.pam.services.sddm.enableGnomeKeyring = true;
}
