{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
     waybar = super.waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      });
    })
  # inputs.nur.overlay
  # inputs.nixos-cn.overlay
  ];
}
