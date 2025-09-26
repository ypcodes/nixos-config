{ config, lib, pkgs, ... }:

{
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs:
      with pkgs; {
        nur = import (builtins.fetchTarball
          "https://github.com/nix-community/NUR/archive/master.tar.gz") {
            inherit pkgs;
          };
        systemPackages = with pkgs; [ nixUnstable ];
      };
  };

  # Binary cache configuration
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
  
  # Enable Flatpak
  services.flatpak.enable = true;
  
  # Enable experimental Nix features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # System packages (essential tools and development environment)
  environment.systemPackages = with pkgs; [
    # Core utilities
    wget
    gnumake
    gdb
    gcc
    clang
    coreutils
    cmake
    git
    clang-tools
    zsh
    glib
    home-manager
    neovim-nightly
    
    # System tools
    htop
    tree
    unzip
    zip
    curl
    jq
    bat
    eza
    fzf
    ripgrep
    fd
    zoxide
  ];

  # User-specific packages (moved to home-manager configuration)
  # These will be managed by home-manager for better isolation
}
