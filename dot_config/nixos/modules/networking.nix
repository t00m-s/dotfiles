{ ... }:

{
  # Network Management
  networking.networkmanager.enable = true;
  # Enables wireless support via wpa_supplicant.
  networking.wireless.enable = true;

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
  users.users."tommaso".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMIsbVlR6sfGXdq29GnS2YLcbMz+ilXaDgSB3l8IJSY3"
  ];
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
}
