{ config, pkgs, ... }:

{
  # 1. Allow unfree packages (proprietary NVIDIA drivers require this)
  nixpkgs.config.allowUnfree = true;

  # 2. Enable hardware-accelerated graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Required for Steam / 32-bit gaming structures
  };

  # 3. Inform the system to load the NVIDIA driver
  services.xserver.videoDrivers = [ "nvidia" ];

  # 4. NVIDIA Hardware Configuration
  hardware.nvidia = {
    # Modesetting is STRICTLY required for Wayland compositors like Niri
    modesetting.enable = true;

    # Power management (experimental, can cause sleep/suspend stabilization issues)
    powerManagement.enable = true;
    powerManagement.finegrained = true;

    # Use the NVIDIA open-source kernel module (not Nouveau). 
    # Only supports Turing architectures or newer (GTX 16xx, RTX 20xx+).
    # Toggle to true if your card supports it, otherwise keep false.
    open = true;

    # Enable the nvidia-settings control panel
    nvidiaSettings = true;

    # Select the standard stable driver payload
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # 5. Hybrid Graphics Configuration (Optimus PRIME)
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true; # Adds 'nvidia-offload' script to your shell path
      };

      # ⚠️ CRITICAL STEP: You must replace these placeholder values 
      # with your machine's exact PCI Bus IDs. See instructions below.
      # nvidiaBusId = "PCI:1:0:0";

      # Uncomment ONLY the one matching your system CPU:
      # intelBusId = "PCI:0:2:0";
      # amdgpuBusId = "PCI:5:0:0";
    };
  };
  # Boot related stuff for nvidia gpus
  boot.kernelParams = [ "nvidia.NVreg_TemporaryFilePath=/var/tmp" ];
  boot.blacklistedKernelModules = [ "nouveau" ];
}
