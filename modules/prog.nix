{ config, lib, pkgs, ... }:

{
  programs.zsh.enable = true;
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Docker配置
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  #virtualisation = {
  #  waydroid.enable = true;
  #  lxd.enable = true;
  #};

  services.emacs = {
      enable = true;
      defaultEditor = true;
  };
}
