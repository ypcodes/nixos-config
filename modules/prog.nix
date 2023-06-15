{ config, lib, pkgs, ... }:

{
    home-manager.users.peng = { pkgs, ... }: {
    /* The home.stateVersion option does not have a default and must be set */
    # home.stateVersion = "18.09";
    home.stateVersion = "23.05";
    /* Here goes the rest of your home-manager config, e.g. home.packages = [ pkgs.foo ]; */
    nixpkgs.config.allowUnfree = true;
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

  #virtualisation = {
  #  waydroid.enable = true;
  #  lxd.enable = true;
  #};

  services.emacs = {
      enable = true;
      defaultEditor = true;
  };
}
