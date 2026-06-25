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
  nixpkgs.overlays = [
    (final: prev: {
      openblas = prev.openblas.overrideAttrs (oldAttrs: {
        doCheck = false;
        checkTarget = "";
      });
    })
  ];
}
