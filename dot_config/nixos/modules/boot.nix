{ ... }:
{
  boot.loader.limine.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # USE WHEN NOT ON VM
  # boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-linux-cachyos-bore-lto-zen4
}
