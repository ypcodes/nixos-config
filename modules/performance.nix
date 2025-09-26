{ config, lib, pkgs, ... }:

{
  # Nix garbage collection and optimization
  nix = {
    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    
    # Optimize store
    settings = {
      # Enable auto-optimise-store
      auto-optimise-store = true;
      
      # Use more cores for building
      max-jobs = "auto";
      
      # Use more cores for evaluation
      eval-cache = true;
      
      # Keep more generations
      keep-derivations = true;
      keep-outputs = true;
    };
  };

  # Systemd optimizations
  systemd = {
    # Reduce systemd overhead
    extraConfig = ''
      DefaultTimeoutStartSec=10s
      DefaultTimeoutStopSec=10s
    '';
  };

  # Boot optimizations
  boot = {
    # Faster boot
    kernelParams = [
      "quiet"
      "loglevel=3"
      "systemd.show_status=0"
    ];
    
    # Use systemd-boot with faster timeout
    loader.timeout = 2;
  };

  # Memory management
  boot.kernel.sysctl = {
    # Optimize memory usage
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_ratio" = 15;
    "vm.dirty_background_ratio" = 5;
    
    # Network optimizations
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.ipv4.tcp_rmem" = "4096 87380 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
  };

  # Power management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };

  # Services optimization
  services = {
    # Optimize journald
    journald = {
      extraConfig = ''
        SystemMaxUse=100M
        RuntimeMaxUse=50M
        MaxRetentionSec=1week
      '';
    };
    
    # Optimize logrotate
    logrotate = {
      enable = true;
      settings = {
        "/var/log/*.log" = {
          daily = true;
          rotate = 7;
          compress = true;
          delaycompress = true;
          missingok = true;
          notifempty = true;
        };
      };
    };
  };
}
