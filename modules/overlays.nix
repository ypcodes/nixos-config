{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      waybar = super.waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      });
    })
    (import (builtins.fetchTarball {
      url =
        "https://ghproxy.com/github.com/nix-community/emacs-overlay/archive/master.tar.gz";
      # sha256 = lib.fakeSha256;
      # sha256 = "1k04sc2h41zx7cp56mxq1g7lzz4nlnwax5z666nqbx7c84gxlm89";
    }))
    (import (builtins.fetchTarball {
      url =
        "https://ghproxy.com/github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz";
    }))
  ];

}
