{ config, lib, pkgs, ... }:

{
  # Hardware-specific optimizations
  hardware = {
    # Enable all firmware
    enableRedistributableFirmware = true;
    
    # CPU microcode updates
    cpu.intel.updateMicrocode = true;
    
    # Enable OpenGL
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    
    # Enable hardware acceleration
    enableAllFirmware = true;
    
    # Bluetooth (if you have it)
    bluetooth = {
      enable = false; # Enable if you have Bluetooth hardware
      powerOnBoot = false;
    };
    
    # Sound configuration
    pulseaudio = {
      enable = false; # Disabled in favor of PipeWire
    };
    
    # USB devices
    usb = {
      enable = true;
    };
    
    # Sensor monitoring
    sensors = {
      enable = true;
    };
  };

  # Enhanced power management
  powerManagement = {
    enable = true;
    # Use performance governor for better responsiveness
    cpuFreqGovernor = "ondemand";
    # Enable power management for PCI devices
    powertop.enable = true;
  };

  # Boot optimizations
  boot = {
    # Kernel parameters for better performance
    kernelParams = [
      # Performance
      "mitigations=off"  # Disable CPU mitigations for better performance (security trade-off)
      "preempt=full"     # Full preemption for better responsiveness
      "threadirqs"       # Threaded IRQs
      
      # Memory management
      "transparent_hugepage=always"
      "hugepagesz=1G"
      
      # I/O optimizations
      "elevator=deadline"
      "scsi_mod.use_blk_mq=1"
      
      # Network optimizations
      "net.core.busy_read=50"
      "net.core.busy_poll=50"
    ];
    
    # Initrd optimizations
    initrd = {
      # Compress initrd for faster boot
      compress = "xz";
      # Include additional modules
      kernelModules = [
        "vfio-pci"
        "vfio"
        "vfio_iommu_type1"
      ];
    };
    
    # Kernel modules
    kernelModules = [
      "kvm-intel"
      "vfio-pci"
      "vfio"
      "vfio_iommu_type1"
    ];
    
    # Extra module packages
    extraModulePackages = with pkgs; [
      # Add any additional kernel modules you need
    ];
  };

  # Enhanced filesystem configuration
  fileSystems = {
    # Root filesystem optimizations
    "/" = {
      device = "/dev/disk/by-uuid/04f1804e-fc47-4732-bd96-7e427420a9b7";
      fsType = "ext4";
      options = [
        "defaults"
        "noatime"        # Don't update access times
        "nodiratime"     # Don't update directory access times
        "discard"        # Enable TRIM for SSDs
        "barrier=1"      # Enable barriers for data integrity
      ];
    };
    
    # Boot partition
    "/boot" = {
      device = "/dev/disk/by-uuid/AD79-FB13";
      fsType = "vfat";
      options = [
        "defaults"
        "noatime"
        "nodiratime"
      ];
    };
    
    # Home partition optimizations
    "/home" = {
      device = "/dev/disk/by-uuid/495c2260-8d49-424f-91a6-0566ebcac6e7";
      fsType = "ext4";
      options = [
        "defaults"
        "noatime"
        "nodiratime"
        "discard"
        "barrier=1"
      ];
    };
  };

  # Optimized swap configuration
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 8 * 1024;  # Reduced from 16GB to 8GB (more reasonable)
    priority = 1;
  }];

  # Systemd optimizations for hardware
  systemd = {
    # Optimize systemd for hardware
    extraConfig = ''
      DefaultTimeoutStartSec=10s
      DefaultTimeoutStopSec=10s
    '';
  };

  # Services for hardware monitoring
  services = {
    # Hardware monitoring
    thermald.enable = true;  # Thermal daemon for Intel CPUs
    
    # TLP for power management (if you have a laptop)
    tlp = {
      enable = false;  # Enable if you have a laptop
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      };
    };
    
    # Hardware monitoring tools
    lm_sensors = {
      enable = true;
    };
    
    # Automatic hardware detection
    udev = {
      enable = true;
      extraRules = ''
        # USB device rules
        SUBSYSTEM=="usb", ATTR{idVendor}=="*", ATTR{idProduct}=="*", MODE="0666"
        
        # Audio device rules
        SUBSYSTEM=="sound", KERNEL=="card*", ATTR{id}=="*", MODE="0666"
      '';
    };
  };

  # Environment variables for hardware
  environment.variables = {
    # GPU acceleration
    LIBVA_DRIVER_NAME = "i965";
    VDPAU_DRIVER = "va_gl";
    
    # Hardware acceleration
    MESA_GL_VERSION_OVERRIDE = "4.5";
    MESA_GLSL_VERSION_OVERRIDE = "450";
  };
}
