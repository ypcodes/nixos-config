{ config, lib, pkgs, ... }:

{
  networking.hostName = "nixos"; # 定义主机名。
  # networking.wireless.enable = true;  # 启用无线支持。

  # 配置网络代理（如果需要）。
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # 启用网络管理器。
  networking.networkmanager.enable = true;

  # 启用OpenSSH守护进程。
  # services.openssh.enable = true;

  # 在防火墙中打开端口。
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # 或者完全禁用防火墙。
  # networking.firewall.enable = false;
}
