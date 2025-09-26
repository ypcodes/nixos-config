#!/bin/bash

# NixOS 自动化安装脚本
# 使用方法: 从 NixOS Live CD 启动后运行此脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否在 NixOS Live 环境中
check_environment() {
    log_info "检查运行环境..."
    
    if ! command -v nixos-install &> /dev/null; then
        log_error "未检测到 NixOS 安装环境，请从 NixOS Live CD 启动"
        exit 1
    fi
    
    if [ "$EUID" -ne 0 ]; then
        log_error "请以 root 权限运行此脚本"
        exit 1
    fi
    
    log_success "环境检查通过"
}

# 硬件检测函数
detect_hardware() {
    log_info "开始硬件检测..."
    
    # 检测CPU厂商
    CPU_VENDOR=$(lscpu | grep "Vendor ID" | awk '{print $3}')
    log_info "CPU厂商: $CPU_VENDOR"
    
    # 检测显卡
    GPU_VENDOR=""
    if lspci | grep -i "intel" | grep -i "vga\|display" > /dev/null; then
        GPU_VENDOR="intel"
    elif lspci | grep -i "nvidia" | grep -i "vga\|display" > /dev/null; then
        GPU_VENDOR="nvidia"
    elif lspci | grep -i "amd" | grep -i "vga\|display" > /dev/null; then
        GPU_VENDOR="amd"
    else
        GPU_VENDOR="generic"
    fi
    log_info "显卡厂商: $GPU_VENDOR"
    
    # 检测是否为虚拟机
    IS_VM=false
    if dmidecode -s system-manufacturer | grep -i "vmware\|virtualbox\|qemu\|kvm" > /dev/null; then
        IS_VM=true
        log_info "检测到虚拟机环境"
    fi
    
    # 检测存储设备
    log_info "存储设备信息:"
    lsblk -f
    
    log_success "硬件检测完成"
}

# 磁盘分区函数
partition_disk() {
    log_info "开始磁盘分区..."
    
    # 显示可用磁盘
    log_info "可用磁盘:"
    lsblk
    
    # 获取目标磁盘
    read -p "请输入目标磁盘设备 (如 /dev/sda): " TARGET_DISK
    
    if [ ! -b "$TARGET_DISK" ]; then
        log_error "磁盘设备 $TARGET_DISK 不存在"
        exit 1
    fi
    
    log_warning "警告: 这将完全擦除磁盘 $TARGET_DISK 上的所有数据!"
    read -p "确认继续? (yes/no): " CONFIRM
    
    if [ "$CONFIRM" != "yes" ]; then
        log_info "操作已取消"
        exit 0
    fi
    
    # 创建分区表
    parted "$TARGET_DISK" --script mklabel gpt
    
    # 创建EFI分区 (512MB)
    parted "$TARGET_DISK" --script mkpart ESP fat32 1MiB 513MiB
    parted "$TARGET_DISK" --script set 1 esp on
    
    # 创建根分区 (剩余空间)
    parted "$TARGET_DISK" --script mkpart primary ext4 513MiB 100%
    
    # 格式化分区
    mkfs.fat -F 32 -n boot "${TARGET_DISK}1"
    mkfs.ext4 -L nixos "${TARGET_DISK}2"
    
    # 挂载分区
    mount /dev/disk/by-label/nixos /mnt
    mkdir -p /mnt/boot
    mount /dev/disk/by-label/boot /mnt/boot
    
    log_success "磁盘分区完成"
}

# 生成硬件配置
generate_hardware_config() {
    log_info "生成硬件配置..."
    
    # 根据硬件检测结果选择配置模板
    HARDWARE_PROFILE=""
    
    if [ "$IS_VM" = true ]; then
        HARDWARE_PROFILE="vm-generic"
    elif [ "$CPU_VENDOR" = "GenuineIntel" ] && [ "$GPU_VENDOR" = "intel" ]; then
        HARDWARE_PROFILE="intel-intel"
    elif [ "$CPU_VENDOR" = "GenuineIntel" ] && [ "$GPU_VENDOR" = "nvidia" ]; then
        HARDWARE_PROFILE="intel-nvidia"
    elif [ "$CPU_VENDOR" = "AuthenticAMD" ] && [ "$GPU_VENDOR" = "amd" ]; then
        HARDWARE_PROFILE="amd-amd"
    else
        HARDWARE_PROFILE="vm-generic"
    fi
    
    log_info "使用硬件配置模板: $HARDWARE_PROFILE"
    
    # 创建配置目录
    mkdir -p /mnt/etc/nixos/modules
    mkdir -p /mnt/etc/nixos/hardware-templates
    
    # 复制硬件模板
    cp "/etc/nixos/hardware-templates/$HARDWARE_PROFILE.nix" "/mnt/etc/nixos/modules/hardware-profile.nix"
    
    # 生成文件系统配置
    ROOT_UUID=$(blkid -s UUID -o value /dev/disk/by-label/nixos)
    BOOT_UUID=$(blkid -s UUID -o value /dev/disk/by-label/boot)
    
    cat > "/mnt/etc/nixos/modules/filesystem.nix" << EOF
{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/$ROOT_UUID";
      fsType = "ext4";
      options = [
        "defaults"
        "noatime"
        "nodiratime"
        "discard"
        "barrier=1"
      ];
    };
    
    "/boot" = {
      device = "/dev/disk/by-uuid/$BOOT_UUID";
      fsType = "vfat";
      options = [
        "defaults"
        "noatime"
        "nodiratime"
      ];
    };
  };
  
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 8 * 1024;  # 8GB swap
    priority = 1;
  }];
}
EOF
    
    log_success "硬件配置生成完成"
}

# 下载并配置 NixOS 配置
setup_nixos_config() {
    log_info "设置 NixOS 配置..."
    
    # 配置仓库地址
    CONFIG_REPO="https://github.com/your-username/nixos-config.git"
    read -p "请输入你的 NixOS 配置仓库地址 (或按回车使用默认): " USER_REPO
    
    if [ -n "$USER_REPO" ]; then
        CONFIG_REPO="$USER_REPO"
    fi
    
    # 克隆配置
    cd /mnt/etc/nixos
    git clone "$CONFIG_REPO" temp-config
    
    # 复制配置文件
    cp temp-config/configuration.nix ./
    cp temp-config/flake.nix ./
    cp -r temp-config/modules ./
    
    # 清理临时文件
    rm -rf temp-config
    
    # 修改主配置文件以包含硬件配置
    cat >> configuration.nix << EOF

  # 硬件特定配置
  imports = [
    ./modules/hardware-profile.nix
    ./modules/filesystem.nix
  ];
EOF
    
    log_success "NixOS 配置设置完成"
}

# 安装 NixOS
install_nixos() {
    log_info "开始安装 NixOS..."
    
    # 生成配置
    nixos-generate-config --root /mnt
    
    # 安装系统
    nixos-install --root /mnt
    
    log_success "NixOS 安装完成!"
}

# 设置用户
setup_user() {
    log_info "设置用户账户..."
    
    read -p "请输入用户名: " USERNAME
    read -s -p "请输入密码: " PASSWORD
    echo
    
    # 创建用户
    useradd -m -s /bin/bash "$USERNAME"
    echo "$USERNAME:$PASSWORD" | chpasswd
    
    # 添加到 sudo 组
    usermod -aG wheel "$USERNAME"
    
    log_success "用户设置完成"
}

# 主函数
main() {
    log_info "NixOS 自动化安装脚本启动"
    log_info "=================================="
    
    check_environment
    detect_hardware
    partition_disk
    generate_hardware_config
    setup_nixos_config
    setup_user
    install_nixos
    
    log_success "=================================="
    log_success "安装完成! 请重启系统"
    log_info "重启命令: reboot"
}

# 运行主函数
main "$@"
