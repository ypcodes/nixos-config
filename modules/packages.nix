{ config, lib, pkgs, ... }:

{
  nixpkgs.config = {
      allowUnfree = true;
      packageOverrides = pkgs: with pkgs; {
          nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
              inherit pkgs;
          };
          systemPackages = with pkgs; [
              nixUnstable
          ];
      };
  };

  # nix.settings.substituters = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
  nix.settings.substituters = [
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://nixos-cn.cachix.org"
    "https://nix-community.cachix.org" ];
  nix.settings.trusted-public-keys = [ "nixos-cn.cachix.org-1:L0jEaL6w7kwQOPlLoCR3ADx+E3Q8SEFEcB9Jaibl0Xg=" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     wget
     gnumake
     gcc
     clang
     coreutils
     cmake
     neovim
     git
     clang-tools
     bear
     gdb
     zsh
     # home-manager
     glib
     emacs-gtk
 ];
  users.users.peng.packages = with pkgs; [
      firefox-wayland
      wpsoffice
      # xcape xorg.xmodmap xorg.xwininfo xclip xdotool
      wmctrl
      xdg-utils
      dracula-theme
      wayland wdisplays mako gnome3.adwaita-icon-theme
      wl-clipboard
      ctags
      rustc cargo go nodejs
      sqlite ripgrep fd exa languagetool
      zstd
      libqalculate
      shellcheck
      (python311.withPackages(ps: with ps; [
        editorconfig
        jupyter
        pandas
        requests
        pyqt6 sip qtpy qt6.qtwebengine epc lxml pyqt6-webengine # for eaf
        qrcode # eaf-file-browser
        pysocks # eaf-browser
        pymupdf # eaf-pdf-viewer
        pypinyin # eaf-file-manager
        psutil # eaf-system-monitor
        retry # eaf-markdown-previewer
        markdown
      ]))
      texlive.combined.scheme-full
      pandoc
      librsvg
      qq
      kitty
      wofi
      waybar
      clash
      ranger
      aspell
      glslang
      nixfmt
      scrot
      pavucontrol
    ];
}
