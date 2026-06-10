{ pkgs, ... }:
{
  boot.loader.limine.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Use latest kernel.
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-zen4;
}
