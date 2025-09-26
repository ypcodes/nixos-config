{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # ============================================================================
  # BOOT CONFIGURATION
  # ============================================================================
  
  boot = {
    # Kernel modules for hardware support
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "sdhci_pci"
      "rtsx_usb_sdmmc"
    ];
    
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    
    # Performance kernel parameters
    kernelParams = [
      # Performance optimizations
      "mitigations=off"  # Disable CPU mitigations for better performance
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
    initrd.compress = "xz";
  };

  # ============================================================================
  # FILESYSTEM CONFIGURATION
  # ============================================================================
  
  fileSystems = {
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
    
    "/boot" = {
      device = "/dev/disk/by-uuid/AD79-FB13";
      fsType = "vfat";
      options = [
        "defaults"
        "noatime"
        "nodiratime"
      ];
    };
    
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
    size = 8 * 1024;  # 8GB swap
    priority = 1;
  }];

  # ============================================================================
  # HARDWARE CONFIGURATION
  # ============================================================================
  
  hardware = {
    # Enable all firmware
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
    
    # CPU microcode updates
    cpu.intel.updateMicrocode = true;
    
    # Graphics and OpenGL
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    
    # Bluetooth (disabled by default)
    bluetooth = {
      enable = false;
      powerOnBoot = false;
    };
    
    # Sound configuration (PipeWire instead of PulseAudio)
    pulseaudio.enable = false;
    
    # USB devices
    usb.enable = true;
    
    # Sensor monitoring
    sensors.enable = true;
  };

  # ============================================================================
  # POWER MANAGEMENT
  # ============================================================================
  
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";  # Balanced performance/power
    powertop.enable = true;
  };

  # ============================================================================
  # NETWORKING
  # ============================================================================
  
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # ============================================================================
  # SERVICES
  # ============================================================================
  
  services = {
    # Hardware monitoring
    thermald.enable = true;  # Thermal daemon for Intel CPUs
    lm_sensors.enable = true;
    
    # TRIM service for SSDs
    fstrim = {
      enable = true;
      interval = "weekly";
    };
    
    # TLP for power management (disabled for desktop)
    tlp = {
      enable = false;  # Enable if you have a laptop
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      };
    };
    
    # Automatic CPU frequency management (disabled by default)
    auto-cpufreq = {
      enable = false;
      settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };
    };
    
    # Hardware-specific logging
    journald.extraConfig = ''
      Storage=persistent
      SystemMaxUse=100M
      RuntimeMaxUse=50M
      MaxRetentionSec=1week
    '';
    
    # UDEV rules for hardware
    udev = {
      enable = true;
      extraRules = ''
        # USB device rules
        SUBSYSTEM=="usb", ATTR{idVendor}=="*", ATTR{idProduct}=="*", MODE="0666"
        
        # Audio device rules
        SUBSYSTEM=="sound", KERNEL=="card*", ATTR{id}=="*", MODE="0666"
        
        # Storage device rules
        SUBSYSTEM=="block", KERNEL=="sd*", ATTR{removable}=="1", MODE="0666"
        
        # Network device rules
        SUBSYSTEM=="net", KERNEL=="*", MODE="0666"
      '';
    };
  };

  # ============================================================================
  # SYSTEMD SERVICES
  # ============================================================================
  
  systemd = {
    # Optimize systemd for hardware
    extraConfig = ''
      DefaultTimeoutStartSec=10s
      DefaultTimeoutStopSec=10s
    '';
    
    services = {
      # Hardware monitoring service
      hardware-monitor = {
        description = "Hardware monitoring service";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash -c 'echo \"Hardware monitoring started at $(date)\" >> /var/log/hardware-monitor.log'";
          RemainAfterExit = true;
        };
        wantedBy = [ "multi-user.target" ];
      };
    };
    
    timers = {
      # Weekly hardware health check
      hardware-health-check = {
        description = "Weekly hardware health check";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
        };
      };
    };
  };

  # ============================================================================
  # ENVIRONMENT VARIABLES
  # ============================================================================
  
  environment = {
    # Hardware acceleration variables
    variables = {
      # GPU acceleration
      LIBVA_DRIVER_NAME = "i965";
      VDPAU_DRIVER = "va_gl";
      
      # Hardware acceleration
      MESA_GL_VERSION_OVERRIDE = "4.5";
      MESA_GLSL_VERSION_OVERRIDE = "450";
      
      # Performance optimizations
      MALLOC_ARENA_MAX = "2";
      MALLOC_MMAP_THRESHOLD_ = "131072";
      MALLOC_TRIM_THRESHOLD_ = "131072";
      MALLOC_TOP_PAD_ = "131072";
      MALLOC_MMAP_MAX_ = "65536";
    };
    
    # Hardware monitoring and management packages
    systemPackages = with pkgs; [
      # Hardware monitoring tools
      htop
      iotop
      nvme-cli
      smartmontools
      lshw
      pciutils
      usbutils
      
      # Performance monitoring
      perf-tools
      sysstat
      dstat
      
      # Hardware information
      inxi
      neofetch
      hwinfo
      
      # Power management
      powertop
      cpupower
    ];
  };
}
