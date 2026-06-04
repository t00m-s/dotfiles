{ config, pkgs, ... }:

{
  # Printing via CUPS
  services.printing.enable = true;

  # Scanning via SANE
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ]; # Auto-discovers network scanners
  };
}
