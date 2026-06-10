{ ... }:
{
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 3d";
  };

  # READD when not on VM
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
  nixpkgs.overlays = [
    (final: prev: {
      # We intercept the default mkDerivation layout
      stdenv = prev.stdenv.override (old: {
        extraAttrs = (old.extraAttrs or { }) // {
          # Inject Zen 4 flags directly into the compiler environment
          NIX_CFLAGS_COMPILE = (old.extraAttrs.NIX_CFLAGS_COMPILE or "") + " -march=znver4 -mtune=znver4 -O3";
        };
      });
    })
  ];
}
