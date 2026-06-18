{ pkgs, ... }:
{
  users.users."tommaso" = {
    isNormalUser = true;
    description = "Tommaso Soncin";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "video"
      "audio"
      "scanner"
      "lp"
      "gamemode"
    ];
    shell = pkgs.fish;
    initialPassword = "nixos";
  };
}
