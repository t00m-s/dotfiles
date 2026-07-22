{
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/boot.nix
    ../../modules/user.nix
    ../../modules/dev.nix
    ../../modules/i18n.nix
    ../../modules/networking.nix
    ../../modules/dev.nix
    ../../modules/ld.nix
    ../../modules/nvim.nix
    ../../modules/fonts.nix
    ../../modules/vpn.nix
    ../../modules/docker.nix
  ];

  networking.hostName = "erminio";
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
