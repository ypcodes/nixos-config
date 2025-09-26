{ config, lib, pkgs, ... }:

{
  # Security hardening
  security = {
    # Enable auditd for security auditing
    auditd.enable = true;
    
    # Enable AppArmor for application sandboxing
    apparmor.enable = true;
    
    # Enable polkit for privilege escalation
    polkit.enable = true;
    
    # Enable sudo with proper configuration
    sudo.enable = true;
    sudo.wheelNeedsPassword = true;
    
    # Enable doas as alternative to sudo
    doas.enable = false; # Keep disabled if using sudo
    
    # Protect against kernel exploits
    protectKernelImage = true;
    
    # Lock kernel modules
    lockKernelModules = true;
  };

  # Firewall configuration
  networking.firewall = {
    enable = true;
    # Allow SSH (if enabled)
    allowedTCPPorts = [ 22 ];
    # Allow HTTP/HTTPS for web browsing
    allowedTCPPorts = [ 80 443 ];
    # Allow local network access
    allowedUDPPorts = [ 53 67 68 ]; # DNS, DHCP
    # Log denied packets
    logDenied = "all";
  };

  # SSH hardening (if SSH is enabled)
  services.openssh = {
    enable = false; # Enable only if needed
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      PubkeyAuthentication = true;
      X11Forwarding = false;
      AllowUsers = [ "peng" ];
    };
  };

  # Kernel security features
  boot.kernelParams = [
    "slab_nomerge"
    "slub_debug=FZP"
    "page_poison=1"
    "init_on_alloc=1"
    "init_on_free=1"
    "pti=on"
    "vsyscall=none"
    "debugfs=off"
    "oops=panic"
    "module.sig_enforce=1"
    "lockdown=confidentiality"
  ];

  # Disable unnecessary services for security
  services = {
    # Disable avahi if not needed
    avahi.enable = false;
    
    # Disable bluetooth if not needed
    blueman.enable = false;
    bluetooth.enable = false;
  };

  # Systemd security hardening
  systemd.services = {
    # Harden systemd services
    "systemd-logind".serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
