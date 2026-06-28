{ pkgs, ... }:
{
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };

  nix.settings.system-features = [
    "nixos-test"
    "benchmark"
    "big-parallel"
    "kvm"
    "gccarch-znver4"
  ];

  # nixpkgs.hostPlatform = {
  # gcc.arch = "znver4";
  # gcc.tune = "znver4";
  # system = "x86_64-linux";
  # };

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  services.scx = {
    enable = true;
    package = pkgs.scx.rustscheds;
    scheduler = "scx_bpfland";
    extraArgs = [ ];
  };
}
