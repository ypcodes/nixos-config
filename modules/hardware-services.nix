{ config, lib, pkgs, ... }:

{
  # Hardware-specific services
  services = {
    # CPU frequency scaling
    cpupower-gui.enable = false;  # Enable if you want GUI for CPU scaling
    
    # Hardware monitoring
    prometheus = {
      enable = false;  # Enable if you want metrics collection
      exporters = {
        node = {
          enable = false;
          enabledCollectors = [ "cpu" "memory" "disk" "filesystem" ];
        };
      };
    };
    
    # Hardware-specific optimizations
    fstrim = {
      enable = true;  # Enable TRIM for SSDs
      interval = "weekly";
    };
    
    # Automatic hardware detection and configuration
    auto-cpufreq = {
      enable = false;  # Enable for automatic CPU frequency management
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
    journald = {
      extraConfig = ''
        # Hardware-specific logging
        Storage=persistent
        SystemMaxUse=100M
        RuntimeMaxUse=50M
        MaxRetentionSec=1week
      '';
    };
  };

  # Hardware-specific packages
  environment.systemPackages = with pkgs; [
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

  # Hardware-specific systemd services
  systemd.services = {
    # TRIM service for SSDs
    fstrim = {
      description = "Discard unused blocks on filesystems from /etc/fstab";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.util-linux}/bin/fstrim -av";
        PrivateDevices = false;
        PrivateNetwork = false;
        ProtectHome = false;
        ProtectSystem = false;
      };
    };
    
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

  # Hardware-specific timers
  systemd.timers = {
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

  # Hardware-specific udev rules
  services.udev.extraRules = ''
    # USB device rules
    SUBSYSTEM=="usb", ATTR{idVendor}=="*", ATTR{idProduct}=="*", MODE="0666"
    
    # Audio device rules
    SUBSYSTEM=="sound", KERNEL=="card*", ATTR{id}=="*", MODE="0666"
    
    # Storage device rules
    SUBSYSTEM=="block", KERNEL=="sd*", ATTR{removable}=="1", MODE="0666"
    
    # Network device rules
    SUBSYSTEM=="net", KERNEL=="*", MODE="0666"
  '';

  # Hardware-specific environment variables
  environment.variables = {
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
}
