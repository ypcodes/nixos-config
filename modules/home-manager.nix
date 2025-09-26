{ config, lib, pkgs, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.peng = { pkgs, ... }: {
      home.stateVersion = "23.05";
      
      # Basic home configuration
      home.packages = with pkgs; [
        # Desktop applications
        firefox-wayland
        wmctrl
        xdg-utils
        dracula-theme
        wayland
        wdisplays
        mako
        gnome3.adwaita-icon-theme
        wl-clipboard
        ctags
        rustc
        cargo
        go
        nodejs
        sqlite
        languagetool
        zstd
        bear
        libqalculate
        shellcheck
        qt6.qtwayland
        libsForQt5.qt5.qtwayland
        texlive.combined.scheme-full
        pandoc
        librsvg
        qq
        kitty
        wofi
        rofi-wayland
        waybar
        clash
        ranger
        aspell
        glslang
        nixfmt
        scrot
        pavucontrol
        networkmanagerapplet
        xfce.thunar
        emacs-gtk
        clipman
        swww
        
        # Python packages
        (python311.withPackages (ps:
          with ps; [
            editorconfig
            jupyter
            pandas
            requests
            pyqt6
            sip
            qtpy
            qt6.qtwebengine
            epc
            lxml
            pyqt6-webengine # for eaf
            qrcode # eaf-file-browser
            pysocks # eaf-browser
            pymupdf # eaf-pdf-viewer
            pypinyin # eaf-file-manager
            psutil # eaf-system-monitor
            retry # eaf-markdown-previewer
            markdown
            pyte
            playsound # eaf-pyqterminal
          ]))
      ];
      
      # Shell configuration
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        history = {
          size = 10000;
          path = "${config.users.users.peng.home}/.zsh_history";
        };
        shellAliases = {
          ll = "ls -la";
          la = "ls -A";
          l = "ls -CF";
          ".." = "cd ..";
          "..." = "cd ../..";
        };
      };
      
      # Git configuration
      programs.git = {
        enable = true;
        userName = "peng";
        userEmail = "peng@example.com"; # Change this to your actual email
        extraConfig = {
          init.defaultBranch = "main";
          pull.rebase = false;
        };
      };
      
      # Editor configuration
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
      };
    };
  };
}
