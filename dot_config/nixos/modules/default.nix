{ config, pkgs, ... }:

{
  imports = [
    ./boot.nix
    ./useful.nix
    ./gaming.nix
    ./nvidia.nix
    ./niri.nix
    ./audio.nix
    ./networking.nix
    ./browser.nix
    ./laptop.nix
    ./print.nix
    ./dev.nix
    ./ld.nix
    ./nvim.nix
    ./python.nix
    ./optimization.nix
  ];
}
