{ config, lib, pkgs, ... }:

# Intel CPU + Intel 集成显卡配置模板
{
  boot = {
    kernelModules = [ "kvm-intel" ];
    kernelParams = [
      "mitigations=off"
      "preempt=full"
      "threadirqs"
      "transparent_hugepage=always"
      "hugepagesz=1G"
      "elevator=deadline"
      "scsi_mod.use_blk_mq=1"
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
      extraPackages = [ pkgs.mesa.drivers ];
    };
  };

  services = {
    thermald.enable = true;
    lm_sensors.enable = true;
  };

  environment.variables = {
    LIBVA_DRIVER_NAME = "i965";
    VDPAU_DRIVER = "va_gl";
    MESA_GL_VERSION_OVERRIDE = "4.5";
    MESA_GLSL_VERSION_OVERRIDE = "450";
  };
}
