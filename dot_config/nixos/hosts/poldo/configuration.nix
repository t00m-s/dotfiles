{
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/boot.nix
    ../../modules/useful.nix
    ../../modules/user.nix
    ../../modules/i18n.nix
    ../../modules/gaming.nix
    ../../modules/nvidia.nix
    ../../modules/sddm.nix
    ../../modules/hyprland.nix
    ../../modules/audio.nix
    ../../modules/networking.nix
    ../../modules/browser.nix
    ../../modules/laptop.nix
    ../../modules/print.nix
    ../../modules/dev.nix
    ../../modules/ld.nix
    ../../modules/nvim.nix
    ../../modules/python.nix
    ../../modules/optimization.nix
    ../../modules/fonts.nix
    ../../modules/keyring.nix
    ../../modules/vpn.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    builders-use-substitutes = true;
    always-allow-substitutes = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  system.stateVersion = "26.05";
}
