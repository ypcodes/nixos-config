# GitHub连接配置指南

本配置已经为您的NixOS系统设置了完整的GitHub连接支持。

## 已完成的配置

### 1. Git配置
- ✅ 启用了Git
- ✅ 配置了用户名和邮箱（需要您手动修改）
- ✅ 设置了GitHub特定的URL重写规则
- ✅ 配置了凭据存储
- ✅ 添加了有用的Git别名

### 2. SSH配置
- ✅ 配置了SSH客户端
- ✅ 设置了GitHub SSH连接规则
- ✅ 支持SSH over HTTPS（端口443）

### 3. 工具安装
- ✅ GitHub CLI (`gh`)
- ✅ Git LFS (`git-lfs`)
- ✅ Hub工具 (`hub`)

## 使用步骤

### 1. 更新Git配置
编辑 `modules/home-manager.nix` 文件，修改以下行：
```nix
userName = "your-github-username"; # 改为您的GitHub用户名
userEmail = "your-email@example.com"; # 改为您的GitHub邮箱
```

### 2. 重新构建系统
```bash
sudo nixos-rebuild switch
```

### 3. 设置SSH密钥
运行设置脚本：
```bash
# Linux/WSL
./scripts/setup-github.sh

# Windows PowerShell
.\scripts\setup-github.ps1
```

### 4. 添加SSH公钥到GitHub
1. 复制脚本输出的公钥内容
2. 访问 https://github.com/settings/keys
3. 点击 "New SSH key"
4. 粘贴公钥并保存

### 5. 测试连接
```bash
ssh -T git@github.com
```

### 6. 使用GitHub CLI登录
```bash
gh auth login
```

## 常用命令

### Git命令
```bash
# 克隆仓库
git clone git@github.com:username/repo.git

# 设置远程仓库
git remote add origin git@github.com:username/repo.git

# 推送代码
git push -u origin main
```

### GitHub CLI命令
```bash
# 登录
gh auth login

# 克隆仓库
gh repo clone username/repo

# 创建仓库
gh repo create my-new-repo

# 查看仓库信息
gh repo view username/repo
```

## 故障排除

### SSH连接问题
如果SSH连接失败，可以尝试：
1. 检查SSH密钥是否正确添加到GitHub
2. 使用SSH over HTTPS：
   ```bash
   git clone git@github-https:username/repo.git
   ```

### 代理设置
如果您在中国大陆，可能需要配置代理：
```bash
# 设置Git代理
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy https://127.0.0.1:7890

# 设置SSH代理（在~/.ssh/config中添加）
Host github.com
    ProxyCommand connect -H 127.0.0.1:7890 %h %p
```

## 注意事项

1. 请确保您的GitHub用户名和邮箱配置正确
2. SSH密钥生成后请妥善保管私钥
3. 如果使用代理，请根据实际情况调整代理设置
4. 建议定期更新SSH密钥以确保安全性
