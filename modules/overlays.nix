{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
     waybar = super.waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      });
    })
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
      # sha256 = lib.fakeSha256;
      sha256 = "0lv0k1f6rrlym43l6bz14dcc3sz3pmxmklc82qkw98wrrb4vz4lv";
    }))
  ];

}
