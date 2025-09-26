# GitHub连接设置脚本 (Windows PowerShell版本)
# 此脚本将帮助您配置与GitHub的连接

Write-Host "🚀 GitHub连接设置脚本" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green

# 检查是否已存在SSH密钥
$sshKeyPath = "$env:USERPROFILE\.ssh\id_ed25519"
if (Test-Path $sshKeyPath) {
    Write-Host "✅ 发现现有的SSH密钥: $sshKeyPath" -ForegroundColor Yellow
    Write-Host "公钥内容:" -ForegroundColor Cyan
    Get-Content "$sshKeyPath.pub"
    Write-Host ""
    Write-Host "如果这是您想要使用的密钥，请复制上面的公钥内容到GitHub账户设置中。" -ForegroundColor Yellow
    Write-Host "如果这不是您想要的密钥，请删除现有密钥后重新运行此脚本。" -ForegroundColor Yellow
    exit 0
}

# 生成新的SSH密钥
Write-Host "🔑 生成新的SSH密钥..." -ForegroundColor Blue
$email = Read-Host "请输入您的GitHub邮箱地址"

if ([string]::IsNullOrEmpty($email)) {
    Write-Host "❌ 邮箱地址不能为空" -ForegroundColor Red
    exit 1
}

# 确保.ssh目录存在
$sshDir = "$env:USERPROFILE\.ssh"
if (!(Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir -Force
}

# 生成SSH密钥
Write-Host "正在生成SSH密钥..." -ForegroundColor Blue
ssh-keygen -t ed25519 -C $email -f $sshKeyPath -N '""'

Write-Host "✅ SSH密钥生成成功！" -ForegroundColor Green
Write-Host ""

# 启动ssh-agent并添加密钥
Write-Host "🔐 配置SSH代理..." -ForegroundColor Blue
Start-Service ssh-agent
ssh-add $sshKeyPath

Write-Host "✅ SSH代理配置完成！" -ForegroundColor Green
Write-Host ""

# 显示公钥
Write-Host "📋 您的公钥内容:" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan
Get-Content "$sshKeyPath.pub"
Write-Host "==================" -ForegroundColor Cyan
Write-Host ""

# 提供GitHub设置指导
Write-Host "📝 接下来的步骤:" -ForegroundColor Yellow
Write-Host "1. 复制上面的公钥内容" -ForegroundColor White
Write-Host "2. 访问 https://github.com/settings/keys" -ForegroundColor White
Write-Host "3. 点击 'New SSH key'" -ForegroundColor White
Write-Host "4. 粘贴公钥内容并保存" -ForegroundColor White
Write-Host ""

# 测试连接
Write-Host "🧪 测试GitHub连接..." -ForegroundColor Blue
Write-Host "请确保您已经将公钥添加到GitHub账户中，然后按任意键继续..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

ssh -T git@github.com

Write-Host ""
Write-Host "🎉 GitHub连接设置完成！" -ForegroundColor Green
Write-Host ""
Write-Host "💡 有用的命令:" -ForegroundColor Cyan
Write-Host "  - gh auth login    # 使用GitHub CLI登录" -ForegroundColor White
Write-Host "  - gh repo clone <repo>  # 克隆仓库" -ForegroundColor White
Write-Host "  - git clone git@github.com:username/repo.git  # 使用SSH克隆" -ForegroundColor White
Write-Host ""
