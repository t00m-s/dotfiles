{ config, pkgs, ... }:

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

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
}
