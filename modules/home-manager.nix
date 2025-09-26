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
      
      # SSH configuration
      programs.ssh = {
        enable = true;
        extraConfig = ''
          # GitHub SSH configuration
          Host github.com
            HostName github.com
            User git
            Port 22
            PreferredAuthentications publickey
            IdentityFile ~/.ssh/id_ed25519
            IdentitiesOnly yes
          
          # GitHub SSH over HTTPS (if port 22 is blocked)
          Host github-https
            HostName ssh.github.com
            User git
            Port 443
            PreferredAuthentications publickey
            IdentityFile ~/.ssh/id_ed25519
            IdentitiesOnly yes
        '';
      };
      
      # Git configuration
      programs.git = {
        enable = true;
        userName = "ypcodes"; # Change this to your GitHub username
        userEmail = "yepeng230@gmail.com"; # Change this to your actual GitHub email
        extraConfig = {
          init.defaultBranch = "main";
          pull.rebase = false;
          # GitHub specific settings
          url."https://github.com/".insteadOf = "git@github.com:";
          url."https://".insteadOf = "git://";
          # Credential helper
          credential.helper = "store";
          # Push settings
          push.default = "simple";
          push.autoSetupRemote = true;
          # Pull settings
          pull.ff = "only";
          # Merge settings
          merge.tool = "vimdiff";
          # Diff settings
          diff.tool = "vimdiff";
          # Color settings
          color.ui = true;
          color.branch = true;
          color.diff = true;
          color.status = true;
          # Alias settings
          alias.st = "status";
          alias.co = "checkout";
          alias.br = "branch";
          alias.ci = "commit";
          alias.unstage = "reset HEAD --";
          alias.last = "log -1 HEAD";
          alias.visual = "!gitk";
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
