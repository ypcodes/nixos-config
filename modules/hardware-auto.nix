{ config, lib, pkgs, ... }:

let
  # 硬件检测函数
  detectHardware = pkgs.writeShellScriptBin "detect-hardware" ''
    #!/bin/bash
    
    # 检测CPU厂商
    CPU_VENDOR=$(lscpu | grep "Vendor ID" | awk '{print $3}')
    echo "CPU_VENDOR=$CPU_VENDOR"
    
    # 检测显卡
    if lspci | grep -i "intel" | grep -i "vga\|display" > /dev/null; then
      echo "GPU_VENDOR=intel"
    elif lspci | grep -i "nvidia" | grep -i "vga\|display" > /dev/null; then
      echo "GPU_VENDOR=nvidia"
    elif lspci | grep -i "amd" | grep -i "vga\|display" > /dev/null; then
      echo "GPU_VENDOR=amd"
    else
      echo "GPU_VENDOR=generic"
    fi
    
    # 检测是否为虚拟机
    if dmidecode -s system-manufacturer | grep -i "vmware\|virtualbox\|qemu\|kvm" > /dev/null; then
      echo "IS_VM=true"
    else
      echo "IS_VM=false"
    fi
  '';
in

{
  environment.systemPackages = [ detectHardware ];
  
  # 根据硬件自动配置
  boot.kernelModules = lib.optionals (builtins.readFile "/proc/cpuinfo" | lib.strings.hasInfix "GenuineIntel") [ "kvm-intel" ]
    ++ lib.optionals (builtins.readFile "/proc/cpuinfo" | lib.strings.hasInfix "AuthenticAMD") [ "kvm-amd" ];
  
  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
    
    # CPU微码更新
    cpu.intel.updateMicrocode = lib.mkDefault (builtins.readFile "/proc/cpuinfo" | lib.strings.hasInfix "GenuineIntel");
    cpu.amd.updateMicrocode = lib.mkDefault (builtins.readFile "/proc/cpuinfo" | lib.strings.hasInfix "AuthenticAMD");
    
    # OpenGL配置
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };
  
  # 显卡驱动配置
  services.xserver.videoDrivers = lib.optionals (builtins.readFile "/proc/version" | lib.strings.hasInfix "nvidia") [ "nvidia" ];
  
  # 环境变量
  environment.variables = {
    MESA_GL_VERSION_OVERRIDE = "4.5";
    MESA_GLSL_VERSION_OVERRIDE = "450";
  };
}
