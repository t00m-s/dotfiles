{ ... }:
{
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  # TODO: delete this in a week or something, when the
  # actual fix is deployed.
  # nixpkgs.overlays = [
  #   (final: prev: {
  #     openblas = prev.openblas.overrideAttrs (oldAttrs: {
  #       doCheck = false;
  #       checkTarget = "";
  #     });
  #   })
  # ];
  nixpkgs.config.packageOverrides = pkgs: {
    pkgsi686Linux = pkgs.pkgsi686Linux.appendOverlays [
      (final: prev: {
        openblas = prev.openblas.overrideAttrs (old: {
          doCheck = false;
          checkTarget = "";
        });
      })
    ];
  };
}
