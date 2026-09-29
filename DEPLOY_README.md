# 个人作品集部署工具

一键生成 GitHub Pages 个人作品集永久链接。

## 快速开始

### 1. 下载脚本

```bash
# 从 GitHub 下载
git clone https://github.com/deep-act/portfolio.git
cd portfolio

# 或者直接下载脚本
curl -O https://raw.githubusercontent.com/deep-act/portfolio/master/portfolio-deploy.sh
chmod +x portfolio-deploy.sh
```

### 2. 运行部署

```bash
./portfolio-deploy.sh
```

脚本会引导你完成：
- GitHub 认证（CLI 登录 或 Token）
- 创建仓库
- 启用 GitHub Pages
- 生成永久链接

### 3. 以后更新内容

```bash
# 修改你的 HTML 文件后
./update.sh "更新了个人介绍"

# 或者不带参数
./update.sh
```

## 前置要求

- **Git** — [下载安装](https://git-scm.com/)
- **GitHub 账号** — [注册](https://github.com/signup)
- **GitHub CLI（可选）** — [下载安装](https://cli.github.com/)

## 认证方式

### 方式 A：GitHub CLI（推荐）

```bash
# 安装 gh
brew install gh        # macOS
sudo apt install gh    # Ubuntu/Debian

# 登录
gh auth login
```

### 方式 B：Personal Access Token

1. 打开 https://github.com/settings/tokens/new
2. Note 填任意名称
3. 勾选 `repo` 和 `workflow`
4. 生成并复制 Token

## 原理

```
你的 HTML 文件
    ↓ git push
GitHub 仓库
    ↓ GitHub Actions
GitHub Pages 托管
    ↓
永久链接 https://用户名.github.io/仓库名/
```

## 常见问题

**Q: 链接什么时候生效？**
A: 推送后 1-2 分钟自动部署。

**Q: 可以自定义域名吗？**
A: 可以，在仓库 Settings → Pages 中添加自定义域名。

**Q: Token 过期了怎么办？**
A: 重新生成 Token，运行 `./portfolio-deploy.sh` 重新配置。

**Q: 如何删除仓库？**
A: GitHub 仓库页面 → Settings → 最下方 Delete this repository。

## 许可证

MIT
