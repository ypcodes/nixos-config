#!/bin/bash

# GitHub连接设置脚本
# 此脚本将帮助您配置与GitHub的连接

set -e

echo "🚀 GitHub连接设置脚本"
echo "========================"

# 检查是否已存在SSH密钥
if [ -f ~/.ssh/id_ed25519 ]; then
    echo "✅ 发现现有的SSH密钥: ~/.ssh/id_ed25519"
    echo "公钥内容:"
    cat ~/.ssh/id_ed25519.pub
    echo ""
    echo "如果这是您想要使用的密钥，请复制上面的公钥内容到GitHub账户设置中。"
    echo "如果这不是您想要的密钥，请删除现有密钥后重新运行此脚本。"
    exit 0
fi

# 生成新的SSH密钥
echo "🔑 生成新的SSH密钥..."
echo "请输入您的GitHub邮箱地址:"
read -r email

if [ -z "$email" ]; then
    echo "❌ 邮箱地址不能为空"
    exit 1
fi

# 生成SSH密钥
ssh-keygen -t ed25519 -C "$email" -f ~/.ssh/id_ed25519 -N ""

echo "✅ SSH密钥生成成功！"
echo ""

# 启动ssh-agent并添加密钥
echo "🔐 配置SSH代理..."
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

echo "✅ SSH代理配置完成！"
echo ""

# 显示公钥
echo "📋 您的公钥内容:"
echo "=================="
cat ~/.ssh/id_ed25519.pub
echo "=================="
echo ""

# 提供GitHub设置指导
echo "📝 接下来的步骤:"
echo "1. 复制上面的公钥内容"
echo "2. 访问 https://github.com/settings/keys"
echo "3. 点击 'New SSH key'"
echo "4. 粘贴公钥内容并保存"
echo ""

# 测试连接
echo "🧪 测试GitHub连接..."
echo "请确保您已经将公钥添加到GitHub账户中，然后按任意键继续..."
read -r

ssh -T git@github.com || true

echo ""
echo "🎉 GitHub连接设置完成！"
echo ""
echo "💡 有用的命令:"
echo "  - gh auth login    # 使用GitHub CLI登录"
echo "  - gh repo clone <repo>  # 克隆仓库"
echo "  - git clone git@github.com:username/repo.git  # 使用SSH克隆"
echo ""
