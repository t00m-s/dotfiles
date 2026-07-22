{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    docker
    docker-compose
  ];
  virtualisation.docker = {
    enable = true;
    # Set up resource limits
    daemon.settings = {
      dns = [
        "1.1.1.1"
        "8.8.8.8"
      ];
      experimental = true;
      default-address-pools = [
        {
          base = "172.30.0.0/16";
          size = 24;
        }
      ];
    };
  };
  users.users.tommaso.extraGroups = [ "docker" ];
}
