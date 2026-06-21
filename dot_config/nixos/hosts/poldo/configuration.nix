{
  self,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    "${self}/modules/boot.nix"
    "${self}/modules/useful.nix"
    "${self}/modules/user.nix"
    "${self}/modules/i18n.nix"
    "${self}/modules/gaming.nix"
    "${self}/modules/nvidia.nix"
    "${self}/modules/niri.nix"
    "${self}/modules/hyprland.nix"
    "${self}/modules/audio.nix"
    "${self}/modules/networking.nix"
    "${self}/modules/browser.nix"
    "${self}/modules/laptop.nix"
    "${self}/modules/print.nix"
    "${self}/modules/dev.nix"
    "${self}/modules/ld.nix"
    "${self}/modules/nvim.nix"
    "${self}/modules/python.nix"
    "${self}/modules/optimization.nix"
    "${self}/modules/fonts.nix"
    "${self}/modules/keyring.nix"
    "${self}/modules/vpn.nix"
  ];
  nixpkgs.overlays = import "${self}/overlays/cachyos-kernel.nix" inputs;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05";
}
