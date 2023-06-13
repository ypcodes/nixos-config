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
    "https://nixpkgs-wayland.cachix.org"
    "https://nix-community.cachix.org" 
    "https://colemickens.cachix.org"
    "https://unmatched.cachix.org"
];
  nix.settings.trusted-public-keys = [ 
    "nixos-cn.cachix.org-1:L0jEaL6w7kwQOPlLoCR3ADx+E3Q8SEFEcB9Jaibl0Xg=" 
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4="
    "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    "unmatched.cachix.org-1:F8TWIP/hA2808FDABsayBCFjrmrz296+5CQaysosTTc="
];
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
     #emacs-pgtk
     emacsNativeComp
    # ((emacsPackagesFor emacsPgtkNativeComp).emacsWithPackages)
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
        pyte playsound #eaf-pyqterminal
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
