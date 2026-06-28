{ ... }:

{
  # Network Management
  networking.networkmanager.enable = true;
  networking.hostName = "poldo";
  # Enables wireless support via wpa_supplicant.
  networking.wireless.enable = true;

  # Bluetooth Support
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = null;
      UseDns = true;
      MaxAuthTries = 3;
      PerSourcePenalties = "crash:3600s authfail:3600s max:86400s";
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
}
