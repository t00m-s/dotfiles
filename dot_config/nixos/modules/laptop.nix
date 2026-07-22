{ pkgs, ... }:

{
  powerManagement.enable = true;
  services.auto-cpufreq.enable = true;
  services.upower.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        ControllerMode = "bredr"; # Fix frequent Bluetooth audio dropouts
        # Shows battery charge of connected devices on supported
        # Bluetooth adapters. Defaults to 'false'.
        Experimental = true;
        # When enabled other devices can connect faster to us, however
        # the tradeoff is increased power consumption. Defaults to
        # 'false'.
        FastConnectable = true;
      };
      Policy = {
        # Enable all controllers when they are found. This includes
        # adapters present on start as well as adapters that are plugged
        # in later on. Defaults to 'true'.
        AutoEnable = true;
      };
    };
  };

  boot.kernelModules = [ "ec_sys" ];
  boot.extraModprobeConfig = ''
    options ec_sys write_support=1 
  '';

  environment.systemPackages = with pkgs; [
    uv
  ];

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
  # services.udev.extraRules = ''
  #   KERNEL=="ec0", SUBSYSTEM=="ec", RUN+="${pkgs.bash}/bin/bash -c 'echo -n -e \\x31 | ${pkgs.coreutils}/bin/dd of=/sys/kernel/debug/ec/ec0/io bs=1 seek=149 count=1 conv=notrunc'"
  # '';

}
