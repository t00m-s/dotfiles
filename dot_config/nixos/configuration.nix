# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./modules
    ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Select internationalisation properties.
  time.timeZone = "Europe/Rome";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
  };

  # Configure console keymap
  console.keyMap = "us-acentos";

  # Don't forget to set a decent password with ‘passwd’.
  users.users."tommaso" = {
    isNormalUser = true;
    description = "Tommaso Soncin";
    extraGroups = [ "networkmanager" "wheel" "docker" "video" "audio" "scanner" "lp" ];
    shell = pkgs.fish;
    initialPassword = "nixos";
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05"; # Did you read the comment?

}
