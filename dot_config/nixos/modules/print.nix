{ pkgs, ... }:

{
  # Printing via CUPS
  services.printing = {
    drivers = with pkgs; [
      epson-escpr
      epson-escpr2
    ];
    enable = true;
  };

  # Scanning via SANE
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ]; # Auto-discovers network scanners
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
