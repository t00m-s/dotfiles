{ config, pkgs, ... }:

{
  imports = [
    ./niri.nix
    ./audio.nix
    ./networking.nix
    ./power.nix
    ./print.nix
    ./dev.nix
    ./ld.nix
    ./nvim.nix
  ];
}
