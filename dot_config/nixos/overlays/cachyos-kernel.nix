{ pkgs, inputs, ... }: {

  nixpkgs.hostPlatform = "x86_64-linux";

  nixpkgs.overlays = [
    inputs.nix-cachyos-kernel.overlays.pinned
  ];

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-zen4;
}
