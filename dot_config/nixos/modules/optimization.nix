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
  # nixpkgs.overlays = [
  #   (final: prev: {
  #     # We intercept the default mkDerivation layout
  #     stdenv = prev.stdenv.override (old: {
  #       extraAttrs = (old.extraAttrs or { }) // {
  #         # Inject Zen 4 flags directly into the compiler environment
  #         NIX_CFLAGS_COMPILE = (old.extraAttrs.NIX_CFLAGS_COMPILE or "") + " -march=znver4 -mtune=znver4 -O3";
  #       };
  #     });
  #   })
  # ];

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-zen4;
  services.scx = {
    enable = true;
    package = pkgs.scx.rustscheds;
    scheduler = "scx_bpfland";
    extraArgs = [ ];
  };
}
