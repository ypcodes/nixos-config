{ config, lib, pkgs, ... }:

# 虚拟机通用配置模板
{
  boot = {
    kernelModules = [ ];
    kernelParams = [
      "console=ttyS0"
      "console=tty1"
      "nomodeset"
    ];
  };

  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
    
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };

  services = {
    lm_sensors.enable = false;
    thermald.enable = false;
  };

  # 虚拟机优化
  virtualisation = {
    vmware.guest.enable = true;
    virtualbox.guest.enable = true;
  };

  environment.variables = {
    MESA_GL_VERSION_OVERRIDE = "3.3";
    MESA_GLSL_VERSION_OVERRIDE = "330";
  };
}
