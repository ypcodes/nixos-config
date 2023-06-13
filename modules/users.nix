{ config, lib, pkgs, ... }:

{
    users.users.peng = {
    isNormalUser = true;
    description = "peng";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "docker" "video" ];
    home = "/home/peng";
  };

  environment.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };

  systemd.user.services.kanshi = {
    description = "kanshi daemon";
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${pkgs.kanshi}/bin/kanshi -c kanshi_config_file'';
    };
  };
}
