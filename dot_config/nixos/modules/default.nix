{ config, pkgs, ... }:

{
  imports = [
    ./niri.nix
    ./audio.nix
    ./networking.nix
    ./browser.nix
    ./laptop.nix
    ./print.nix
    ./dev.nix
    ./ld.nix
    ./nvim.nix
    ./optimization.nix
  ];
}
