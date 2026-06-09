{ config, pkgs, ... }:

{
  # 1. Allow unfree packages (proprietary NVIDIA drivers require this)
  nixpkgs.config.allowUnfree = true;

  # 2. Enable hardware-accelerated graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Required for Steam / 32-bit gaming structures
    extraPackages = with pkgs; [
      rocmPackages.clr # For ROCm/OpenCL support on the Ryzen iGPU
      libva-vdpau-driver
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      libva-vdpau-driver
      libvdpau-va-gl
    ];
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

      nvidiaBusId = "PCI:1@0:0:0";
      amdgpuBusId = "PCI:6@0:0:0";
    };
  };
  # Boot related stuff for nvidia gpus
  boot.kernelParams = [ "nvidia.NVreg_TemporaryFilePath=/var/tmp" ];
  boot.blacklistedKernelModules = [ "nouveau" ];
  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia # Great CLI task monitor for both AMD and NVIDIA GPUs
    vulkan-tools # Provides 'vulkaninfo' and 'vkcube' to test acceleration
    libva-utils # Provides 'vainfo' to verify video hardware acceleration
  ];
}
