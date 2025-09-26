{ config, lib, pkgs, ... }:

let
  # 硬件检测脚本
  detect-hardware = pkgs.writeShellScriptBin "detect-hardware" ''
    #!/bin/bash
    
    echo "=== 硬件检测开始 ==="
    
    # 检测CPU厂商
    CPU_VENDOR=$(lscpu | grep "Vendor ID" | awk '{print $3}')
    echo "CPU厂商: $CPU_VENDOR"
    
    # 检测显卡
    GPU_INFO=$(lspci | grep -i vga || lspci | grep -i display)
    echo "显卡信息: $GPU_INFO"
    
    # 检测存储设备
    echo "=== 存储设备检测 ==="
    lsblk -f
    
    # 检测网络设备
    echo "=== 网络设备检测 ==="
    ip link show
    
    # 检测音频设备
    echo "=== 音频设备检测 ==="
    lspci | grep -i audio
    
    # 检测USB设备
    echo "=== USB设备检测 ==="
    lsusb
    
    echo "=== 硬件检测完成 ==="
  '';
  
  # 生成硬件配置脚本
  generate-hardware-config = pkgs.writeShellScriptBin "generate-hardware-config" ''
    #!/bin/bash
    
    CONFIG_DIR="/etc/nixos/modules"
    TEMPLATE_DIR="/etc/nixos/hardware-templates"
    
    echo "生成硬件配置..."
    
    # 检测CPU类型
    CPU_VENDOR=$(lscpu | grep "Vendor ID" | awk '{print $3}')
    
    # 检测显卡类型
    GPU_VENDOR=""
    if lspci | grep -i "intel" | grep -i "vga\|display" > /dev/null; then
      GPU_VENDOR="intel"
    elif lspci | grep -i "nvidia" | grep -i "vga\|display" > /dev/null; then
      GPU_VENDOR="nvidia"
    elif lspci | grep -i "amd" | grep -i "vga\|display" > /dev/null; then
      GPU_VENDOR="amd"
    fi
    
    # 检测存储设备
    ROOT_DEVICE=$(findmnt -n -o SOURCE / 2>/dev/null || echo "unknown")
    BOOT_DEVICE=$(findmnt -n -o SOURCE /boot 2>/dev/null || echo "unknown")
    
    echo "CPU厂商: $CPU_VENDOR"
    echo "显卡厂商: $GPU_VENDOR"
    echo "根分区: $ROOT_DEVICE"
    echo "启动分区: $BOOT_DEVICE"
    
    # 根据检测结果生成配置
    case $CPU_VENDOR in
      "GenuineIntel")
        CPU_CONFIG="intel"
        ;;
      "AuthenticAMD")
        CPU_CONFIG="amd"
        ;;
      *)
        CPU_CONFIG="generic"
        ;;
    esac
    
    case $GPU_VENDOR in
      "intel")
        GPU_CONFIG="intel"
        ;;
      "nvidia")
        GPU_CONFIG="nvidia"
        ;;
      "amd")
        GPU_CONFIG="amd"
        ;;
      *)
        GPU_CONFIG="generic"
        ;;
    esac
    
    echo "使用CPU配置: $CPU_CONFIG"
    echo "使用显卡配置: $GPU_CONFIG"
    
    # 生成硬件配置文件
    cat > "$CONFIG_DIR/hardware-detected.nix" << EOF
    { config, lib, pkgs, ... }:
    
    {
      # 自动检测的硬件配置
      hardware = {
        # CPU配置
        cpu = {
          vendor = "$CPU_VENDOR";
          config = "$CPU_CONFIG";
        };
        
        # 显卡配置
        gpu = {
          vendor = "$GPU_VENDOR";
          config = "$GPU_CONFIG";
        };
        
        # 存储配置
        storage = {
          rootDevice = "$ROOT_DEVICE";
          bootDevice = "$BOOT_DEVICE";
        };
      };
      
      # 根据检测结果启用相应的内核模块
      boot.kernelModules = lib.optionals (config.hardware.cpu.config == "intel") [ "kvm-intel" ]
        ++ lib.optionals (config.hardware.cpu.config == "amd") [ "kvm-amd" ];
      
      # CPU微码更新
      hardware.cpu.intel.updateMicrocode = lib.mkDefault (config.hardware.cpu.config == "intel");
      hardware.cpu.amd.updateMicrocode = lib.mkDefault (config.hardware.cpu.config == "amd");
      
      # 显卡驱动配置
      hardware.opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
        extraPackages = lib.optionals (config.hardware.gpu.config == "intel") [ pkgs.mesa.drivers ]
          ++ lib.optionals (config.hardware.gpu.config == "nvidia") [ pkgs.linuxPackages.nvidia_x11 ];
      };
      
      # 环境变量
      environment.variables = lib.mkMerge [
        (lib.optionalAttrs (config.hardware.gpu.config == "intel") {
          LIBVA_DRIVER_NAME = "i965";
          VDPAU_DRIVER = "va_gl";
        })
        (lib.optionalAttrs (config.hardware.gpu.config == "nvidia") {
          LIBVA_DRIVER_NAME = "nvidia";
          VDPAU_DRIVER = "nvidia";
        })
      ];
    }
    EOF
    
    echo "硬件配置已生成: $CONFIG_DIR/hardware-detected.nix"
  '';
in

{
  environment.systemPackages = [ detect-hardware generate-hardware-config ];
  
  # 在系统启动时自动检测硬件
  systemd.services.hardware-detection = {
    description = "Hardware Detection Service";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${detect-hardware}/bin/detect-hardware";
      RemainAfterExit = true;
    };
    wantedBy = [ "multi-user.target" ];
  };
}
