#!/bin/bash

# NixOS 快速安装脚本
# 适用于从现有 NixOS 系统迁移到新硬件

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 检查环境
check_environment() {
    log_info "检查环境..."
    
    if ! command -v nix &> /dev/null; then
        log_error "未检测到 Nix，请先安装 Nix"
        exit 1
    fi
    
    if [ ! -f "flake.nix" ]; then
        log_error "未找到 flake.nix 文件，请在配置目录中运行此脚本"
        exit 1
    fi
    
    log_success "环境检查通过"
}

# 硬件检测和配置生成
detect_and_configure() {
    log_info "检测硬件并生成配置..."
    
    # 运行硬件检测
    if command -v detect-hardware &> /dev/null; then
        HARDWARE_INFO=$(detect-hardware)
        log_info "硬件信息: $HARDWARE_INFO"
    else
        log_warning "未找到硬件检测工具，使用默认配置"
    fi
    
    # 生成硬件配置
    log_info "生成硬件配置..."
    
    # 检测CPU类型
    CPU_VENDOR=$(lscpu | grep "Vendor ID" | awk '{print $3}')
    
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
    
    log_info "检测到 CPU: $CPU_VENDOR, GPU: $GPU_VENDOR"
    
    # 根据检测结果更新配置
    case $CPU_VENDOR in
        "GenuineIntel")
            case $GPU_VENDOR in
                "intel")
                    log_info "使用 Intel CPU + Intel 显卡配置"
                    ;;
                "nvidia")
                    log_info "使用 Intel CPU + NVIDIA 显卡配置"
                    ;;
                *)
                    log_info "使用 Intel CPU + 通用显卡配置"
                    ;;
            esac
            ;;
        "AuthenticAMD")
            case $GPU_VENDOR in
                "amd")
                    log_info "使用 AMD CPU + AMD 显卡配置"
                    ;;
                *)
                    log_info "使用 AMD CPU + 通用显卡配置"
                    ;;
            esac
            ;;
        *)
            log_info "使用通用硬件配置"
            ;;
    esac
    
    log_success "硬件配置完成"
}

# 构建和部署
build_and_deploy() {
    log_info "构建和部署配置..."
    
    # 检查配置语法
    log_info "检查配置语法..."
    nix flake check
    
    # 构建配置
    log_info "构建系统配置..."
    nixos-rebuild build --flake .#nixos
    
    # 询问是否应用配置
    read -p "是否应用配置? (y/n): " APPLY_CONFIG
    
    if [ "$APPLY_CONFIG" = "y" ] || [ "$APPLY_CONFIG" = "Y" ]; then
        log_info "应用配置..."
        nixos-rebuild switch --flake .#nixos
        
        log_success "配置应用成功!"
        log_info "建议重启系统以确保所有更改生效"
    else
        log_info "配置已构建但未应用"
    fi
}

# 主函数
main() {
    log_info "NixOS 快速配置脚本启动"
    log_info "=========================="
    
    check_environment
    detect_and_configure
    build_and_deploy
    
    log_success "=========================="
    log_success "配置完成!"
}

# 运行主函数
main "$@"
