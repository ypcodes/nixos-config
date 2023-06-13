{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
     waybar = super.waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      });
    })
    #(import (builtins.fetchTarball {
    #  url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
    #}))
  ];
}
