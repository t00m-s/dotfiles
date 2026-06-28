{ pkgs, ... }:

{
  powerManagement.enable = true;
  services.auto-cpufreq.enable = true;
  services.upower.enable = true;

  boot.kernelModules = [ "ec_sys" ];
  boot.extraModprobeConfig = ''
    options ec_sys write_support=1
  '';

  environment.systemPackages = [ pkgs.uv ];

  systemd.services.omen-fan = {
    description = "HP Omen Fan Control Daemon (Python via uv)";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ uv ];
    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "/home/tommaso/Projects/omen-fan";
      ExecStart = "${pkgs.uv}/bin/uv run /home/tommaso/Projects/omen-fan/omen-fand.py";

      Restart = "always";
      RestartSec = "5s";
      User = "root";
    };
  };
}
