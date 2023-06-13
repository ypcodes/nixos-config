{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    shellInit = ''
    '';
  };

  services.emacs = {
      enable = true;
      defaultEditor = true;
  };
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

}
