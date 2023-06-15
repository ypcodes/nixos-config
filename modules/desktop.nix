{ config, lib, pkgs, ... }:

{
  # Desktop
  # Configure keymap in X11
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "";
    # videosDrivers = ["nvidia"];
    displayManager.gdm = {
        enable = true;
        wayland = true;
    };
  };
  # services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    opengl.enable = true;
    # nvidia.modesetting.enable = true;
  };

  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;
  # sway
  programs.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
      hidpi = false;
    }; 
    # wrapperFeatures.gtk = true;
  };
 # security.polkit.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  programs.light.enable = true;
  musnix.enable = true;
}
