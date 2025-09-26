{ config, lib, pkgs, ... }:

# Intel CPU + NVIDIA 显卡配置模板
{
  boot = {
    kernelModules = [ "kvm-intel" "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
    kernelParams = [
      "mitigations=off"
      "preempt=full"
      "threadirqs"
      "transparent_hugepage=always"
      "hugepagesz=1G"
      "elevator=deadline"
      "scsi_mod.use_blk_mq=1"
      "nvidia-drm.modeset=1"
    ];
  };

  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true;
    
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = [ pkgs.linuxPackages.nvidia_x11 ];
    };
    
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = false;
    };
  };

  services = {
    thermald.enable = true;
    lm_sensors.enable = true;
  };

  environment.variables = {
    LIBVA_DRIVER_NAME = "nvidia";
    VDPAU_DRIVER = "nvidia";
    MESA_GL_VERSION_OVERRIDE = "4.5";
    MESA_GLSL_VERSION_OVERRIDE = "450";
  };
}
