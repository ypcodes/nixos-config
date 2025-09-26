# NixOS 硬件自动适配解决方案

## 概述

本解决方案提供了完整的 NixOS 硬件自动适配功能，支持在不同硬件配置的电脑和虚拟机之间无缝迁移。

## 文件结构

```
nixos-config/
├── modules/
│   ├── hardware-auto.nix          # 自动硬件检测模块
│   ├── hardware-detection.nix     # 硬件检测工具
│   └── hardware.nix               # 原始硬件配置
├── hardware-templates/
│   ├── intel-intel.nix            # Intel CPU + Intel 显卡
│   ├── intel-nvidia.nix           # Intel CPU + NVIDIA 显卡
│   ├── amd-amd.nix                # AMD CPU + AMD 显卡
│   └── vm-generic.nix             # 虚拟机通用配置
├── scripts/
│   ├── auto-install.sh            # 自动化安装脚本
│   └── quick-configure.sh         # 快速配置脚本
└── configuration.nix              # 主配置文件
```

## 使用方法

### 1. 从 NixOS Live CD 全新安装

```bash
# 1. 从 NixOS Live CD 启动
# 2. 下载配置
git clone https://github.com/your-username/nixos-config.git
cd nixos-config

# 3. 运行自动安装脚本
chmod +x scripts/auto-install.sh
sudo ./scripts/auto-install.sh
```

### 2. 在现有 NixOS 系统上快速配置

```bash
# 1. 克隆配置到本地
git clone https://github.com/your-username/nixos-config.git
cd nixos-config

# 2. 运行快速配置脚本
chmod +x scripts/quick-configure.sh
./scripts/quick-configure.sh
```

### 3. 手动配置

```bash
# 1. 检测硬件
detect-hardware

# 2. 生成硬件配置
generate-hardware-config

# 3. 构建和部署
nixos-rebuild switch --flake .#nixos
```

## 硬件支持

### 支持的硬件组合

| CPU | 显卡 | 配置模板 | 说明 |
|-----|------|----------|------|
| Intel | Intel 集成显卡 | intel-intel.nix | 最常见的笔记本配置 |
| Intel | NVIDIA 独立显卡 | intel-nvidia.nix | 游戏本和工作站 |
| AMD | AMD 显卡 | amd-amd.nix | AMD 平台配置 |
| 任意 | 任意 | vm-generic.nix | 虚拟机环境 |

### 自动检测功能

- **CPU 检测**: 自动识别 Intel/AMD CPU
- **显卡检测**: 自动识别 Intel/NVIDIA/AMD 显卡
- **虚拟机检测**: 自动识别 VMware/VirtualBox/QEMU
- **存储检测**: 自动检测磁盘和分区
- **网络检测**: 自动检测网络设备

## 配置说明

### 硬件自动检测模块 (hardware-auto.nix)

```nix
# 自动检测 CPU 类型并加载相应内核模块
boot.kernelModules = lib.optionals (builtins.readFile "/proc/cpuinfo" | lib.strings.hasInfix "GenuineIntel") [ "kvm-intel" ]
  ++ lib.optionals (builtins.readFile "/proc/cpuinfo" | lib.strings.hasInfix "AuthenticAMD") [ "kvm-amd" ];

# 自动启用 CPU 微码更新
hardware.cpu.intel.updateMicrocode = lib.mkDefault (builtins.readFile "/proc/cpuinfo" | lib.strings.hasInfix "GenuineIntel");
hardware.cpu.amd.updateMicrocode = lib.mkDefault (builtins.readFile "/proc/cpuinfo" | lib.strings.hasInfix "AuthenticAMD");
```

### 硬件模板

每个硬件模板都包含针对特定硬件组合的优化配置：

- **内核模块**: 根据 CPU 类型加载相应的虚拟化模块
- **显卡驱动**: 根据显卡类型配置相应的驱动
- **性能优化**: 针对不同硬件的性能调优
- **环境变量**: 设置硬件加速相关的环境变量

## 故障排除

### 常见问题

1. **硬件检测失败**
   ```bash
   # 手动运行检测
   detect-hardware
   ```

2. **配置构建失败**
   ```bash
   # 检查配置语法
   nix flake check
   
   # 查看详细错误
   nixos-rebuild build --flake .#nixos --show-trace
   ```

3. **显卡驱动问题**
   ```bash
   # 检查显卡信息
   lspci | grep -i vga
   
   # 检查驱动状态
   nvidia-smi  # NVIDIA
   intel_gpu_top  # Intel
   ```

### 调试模式

```bash
# 启用详细日志
nixos-rebuild switch --flake .#nixos --show-trace

# 检查系统日志
journalctl -u hardware-detection
```

## 高级用法

### 自定义硬件模板

1. 复制现有模板
2. 修改硬件特定配置
3. 更新检测逻辑

### 添加新硬件支持

1. 在 `hardware-detection.nix` 中添加检测逻辑
2. 创建对应的硬件模板
3. 更新自动选择逻辑

## 注意事项

1. **备份重要数据**: 安装前请备份重要数据
2. **网络连接**: 确保有稳定的网络连接以下载包
3. **硬件兼容性**: 某些特殊硬件可能需要额外配置
4. **虚拟机支持**: 虚拟机环境会自动使用通用配置

## 贡献

欢迎提交 Issue 和 Pull Request 来改进硬件支持！

## 许可证

MIT License
