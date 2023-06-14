{ config, lib, pkgs, ... }:

{
    home-manager.users.peng = { pkgs, ... }: {
    /* The home.stateVersion option does not have a default and must be set */
    # home.stateVersion = "18.09";
    home.stateVersion = "23.05";
    /* Here goes the rest of your home-manager config, e.g. home.packages = [ pkgs.foo ]; */
    nixpkgs.config.allowUnfree = true;

    home.packages = with pkgs; [
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
      bear
      libqalculate
      shellcheck
      qt6.qtwayland
      libsForQt5.qt5.qtwayland
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
      emacs-gtk
      networkmanagerapplet
      neovim
      ];
  programs.zsh = {
    shellAliases = {
      update = "sudo nixos-rebuild switch";
    };
    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; } # Simple plugin installation
        # { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; } # Installations with additional options. For the list of options, please refer to Zplug README.
      ];
    };
    # autosuggestions.enable = true;
  };
  services.emacs = {
      enable = true;
      defaultEditor = true;
  };
  };

  programs.zsh.enable = true;
  programs.zsh.shellInit = ''
# bindkey "''${key[Up]}" up-line-or-search"
  '';
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
