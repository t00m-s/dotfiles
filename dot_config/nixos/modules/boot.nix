{ ... }:
{
  boot.loader.limine.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Use latest kernel.
  # boot.kernelPackages = pkgs.linuxPackages_latest;
}
