{ config, pkgs, lib, ... }:
let
  # 配置GTK
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme 'Dracula'
    '';
  };

  # 模块路径
  modulesPath = ./modules;

  # 导入模块
  hardware = import "${modulesPath}/hardware.nix";
  hardware-auto = import "${modulesPath}/hardware-auto.nix";
  packages = import "${modulesPath}/packages.nix";
  boot = import "${modulesPath}/boot.nix";
  vim = import "${modulesPath}/vim.nix";
  overlays = import "${modulesPath}/overlays.nix";
  users = import "${modulesPath}/users.nix";
  font = import "${modulesPath}/font.nix";
  lang = import "${modulesPath}/lang.nix";
  desktop = import "${modulesPath}/desktop.nix";
  prog = import "${modulesPath}/prog.nix";
  network = import "${modulesPath}/network.nix";
  home-manager = import "${modulesPath}/home-manager.nix";
  security = import "${modulesPath}/security.nix";
  performance = import "${modulesPath}/performance.nix";
  nixvim = import (builtins.fetchGit {
    url = "https://gh-proxy.com/github.com/pta2002/nixvim";
    ref = "main";
  });
in {
  imports = [
    <home-manager/nixos>
    <musnix>
    hardware-auto
    boot
    overlays
    packages
    users
    lang
    font
    network
    desktop
    prog
    vim
    home-manager
    security
    performance
  ];

  # Bootloader.
  # 设置时区。
  time.timeZone = "Asia/Shanghai";

  # 启用CUPS打印文档。
  services.printing.enable = true;
  nix.settings.trusted-users = [ "root" "peng" ];

  system.stateVersion = "23.05"; # 请阅读注释！
}
