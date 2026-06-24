{ pkgs, ... }:

{
  powerManagement.enable = true;
  services.auto-cpufreq.enable = true;
  services.upower.enable = true;

  # --- OMEN Fan Control Systemd Service & Prerequisites ---

  # 1. Automatically load ec_sys module with write support for register access
  boot.kernelModules = [ "ec_sys" ];
  boot.extraModprobeConfig = ''
    options ec_sys write_support=1
  '';

  # 2. Add uv to the system packages so it's globally accessible
  environment.systemPackages = [ pkgs.uv ];

  # 3. Background service setup running your local script via 'uv run'
  systemd.services.omen-fan = {
    description = "HP Omen Fan Control Daemon (Python via uv)";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];

    # Injecting execution environment paths for uv sandbox isolation
    path = with pkgs; [ uv ];

    serviceConfig = {
      Type = "simple";

      # Pointing directly to your development path
      WorkingDirectory = "/home/tommaso/Projects/omen-fan";
      ExecStart = "${pkgs.uv}/bin/uv run /home/tommaso/Projects/omen-fan/omen-fand.py";

      Restart = "always";
      RestartSec = "5s";
      User = "root"; # Essential for editing hardware EC registers

      # Explicitly allocating persistent cache locations for uv inside systemd's sandbox
      # Environment = [
      #   "CACHE_DIR=/var/cache/omen-fan"
      #   "XDG_CACHE_HOME=/var/cache/omen-fan"
      # ];
      # StateDirectory = "omen-fan";
      # CacheDirectory = "omen-fan";
    };
  };
}
