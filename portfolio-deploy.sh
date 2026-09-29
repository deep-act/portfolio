#!/bin/bash
# ============================================================
#  个人作品集一键部署工具
#  功能：创建 GitHub 仓库 + 开启 Pages + 一键更新
#  适用：任何人生成自己的作品集永久链接
# ============================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ============================================================
#  第一步：检查环境
# ============================================================
check_env() {
    info "检查环境..."
    
    # 检查 git
    if ! command -v git &> /dev/null; then
        error "未安装 git，请先安装: https://git-scm.com/"
    fi
    success "git 已安装"
    
    # 检查 gh (GitHub CLI)
    if ! command -v gh &> /dev/null; then
        warn "未安装 GitHub CLI (gh)"
        info "请手动安装: https://cli.github.com/"
        info "或者使用 Token 方式（见下方说明）"
        USE_GH=false
    else
        USE_GH=true
        success "GitHub CLI 已安装"
    fi
}

# ============================================================
#  第二步：GitHub 认证
# ============================================================
setup_auth() {
    echo ""
    info "=== GitHub 认证 ==="
    echo ""
    echo "请选择认证方式："
    echo "  1) 使用 GitHub CLI 浏览器登录（推荐）"
    echo "  2) 使用 Personal Access Token"
    echo ""
    read -p "请选择 [1/2]: " auth_choice
    
    case $auth_choice in
        1)
            if [ "$USE_GH" = true ]; then
                info "正在打开浏览器进行 GitHub 登录..."
                gh auth login --web --scopes repo,workflow
                success "GitHub 登录成功"
            else
                error "请先安装 GitHub CLI: https://cli.github.com/"
            fi
            ;;
        2)
            echo ""
            info "请提供你的 Personal Access Token"
            echo "获取方式："
            echo "  1. 打开 https://github.com/settings/tokens/new"
            echo "  2. Note 填任意名称（如 portfolio）"
            echo "  3. 勾选 repo 和 workflow 权限"
            echo "  4. 点击 Generate token"
            echo "  5. 复制生成的 token（以 ghp_ 开头）"
            echo ""
            read -p "请粘贴 Token: " GITHUB_TOKEN
            
            if [ -z "$GITHUB_TOKEN" ]; then
                error "Token 不能为空"
            fi
            
            # 配置 git 凭证
            read -p "你的 GitHub 用户名: " GITHUB_USER
            echo "https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com" > ~/.git-credentials
            chmod 600 ~/.git-credentials
            git config --global credential.helper store
            
            success "Token 已配置"
            ;;
        *)
            error "无效选择"
            ;;
    esac
}

# ============================================================
#  第三步：创建/配置仓库
# ============================================================
setup_repo() {
    echo ""
    info "=== 仓库配置 ==="
    echo ""
    
    # 获取用户名
    if [ "$USE_GH" = true ]; then
        GITHUB_USER=$(gh api user --jq '.login' 2>/dev/null)
    else
        read -p "GitHub 用户名: " GITHUB_USER
    fi
    
    if [ -z "$GITHUB_USER" ]; then
        error "无法获取 GitHub 用户名"
    fi
    
    success "GitHub 用户: $GITHUB_USER"
    
    # 仓库名称
    read -p "仓库名称 [portfolio]: " REPO_NAME
    REPO_NAME=${REPO_NAME:-portfolio}
    
    # 检查仓库是否存在
    if [ "$USE_GH" = true ]; then
        if gh repo view "$GITHUB_USER/$REPO_NAME" &>/dev/null; then
            warn "仓库 $GITHUB_USER/$REPO_NAME 已存在"
            read -p "是否使用现有仓库？[Y/n]: " use_existing
            use_existing=${use_existing:-Y}
            if [[ ! "$use_existing" =~ ^[Yy] ]]; then
                read -p "请输入新的仓库名称: " REPO_NAME
            fi
        fi
    fi
    
    REPO_FULL="$GITHUB_USER/$REPO_NAME"
    info "目标仓库: $REPO_FULL"
}

# ============================================================
#  第四步：初始化 Git 仓库
# ============================================================
init_git() {
    echo ""
    info "=== 初始化 Git 仓库 ==="
    echo ""
    
    # 检查是否已在 git 仓库中
    if [ ! -d ".git" ]; then
        git init
        git branch -M master
        success "Git 仓库已初始化"
    else
        success "已在 Git 仓库中"
    fi
    
    # 配置用户信息（如果未配置）
    if [ -z "$(git config user.name)" ]; then
        git config user.name "$GITHUB_USER"
    fi
    if [ -z "$(git config user.email)" ]; then
        read -p "Git 邮箱: " GIT_EMAIL
        git config user.email "$GIT_EMAIL"
    fi
}

# ============================================================
#  第五步：创建 GitHub 仓库并推送
# ============================================================
create_and_push() {
    echo ""
    info "=== 创建 GitHub 仓库并推送 ==="
    echo ""
    
    if [ "$USE_GH" = true ]; then
        # 使用 gh 创建仓库
        if ! gh repo view "$REPO_FULL" &>/dev/null; then
            info "创建新仓库: $REPO_FULL"
            gh repo create "$REPO_FULL" --public --source=. --remote=origin --push
        else
            info "使用现有仓库"
            git remote set-url origin "https://github.com/$REPO_FULL.git"
            git push -u origin master
        fi
    else
        # 使用 Token 方式
        # 通过 API 创建仓库
        info "通过 API 创建仓库..."
        curl -s -X POST \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github.v3+json" \
            https://api.github.com/user/repos \
            -d "{\"name\":\"$REPO_NAME\",\"auto_init\":false,\"private\":false}"
        
        echo ""
        git remote add origin "https://github.com/$REPO_FULL.git" 2>/dev/null || true
        git remote set-url origin "https://github.com/$REPO_FULL.git"
        git push -u origin master
    fi
    
    success "代码已推送到 GitHub"
}

# ============================================================
#  第六步：启用 GitHub Pages
# ============================================================
enable_pages() {
    echo ""
    info "=== 启用 GitHub Pages ==="
    echo ""
    
    # 创建 GitHub Actions 工作流
    mkdir -p .github/workflows
    cat > .github/workflows/deploy.yml << 'EOF'
name: Deploy to GitHub Pages

on:
  push:
    branches: [master]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Setup Pages
        uses: actions/configure-pages@v4
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: '.'
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
EOF
    
    git add .github/workflows/deploy.yml
    git commit -m "Add GitHub Pages deploy workflow"
    git push origin master
    
    # 启用 Pages
    if [ "$USE_GH" = true ]; then
        gh api repos/$REPO_FULL/pages \
            -f build_type=workflow \
            -f source/branch=master \
            -f source/path=/ || true
    else
        curl -s -X POST \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github.v3+json" \
            https://api.github.com/repos/$REPO_FULL/pages \
            -d '{"build_type":"workflow","source":{"branch":"master","path":"/"}}'
    fi
    
    success "GitHub Pages 已启用"
}

# ============================================================
#  第七步：创建更新脚本
# ============================================================
create_update_script() {
    echo ""
    info "=== 创建更新脚本 ==="
    echo ""
    
    cat > update.sh << EOF
#!/bin/bash
# 作品集一键更新脚本
# 用法: ./update.sh "更新说明"

cd "\$(dirname "\$0")"

MSG="\${1:-更新作品集内容}"

echo "📝 提交更改: \$MSG"
git add -A
git commit -m "\$MSG"

echo "🚀 推送到 GitHub..."
git push origin master

echo "✅ 完成！GitHub Actions 会自动部署"
echo "  访问链接: https://$GITHUB_USER.github.io/$REPO_NAME/"
echo "⏳ 通常 1-2 分钟内生效"
EOF
    
    chmod +x update.sh
    git add update.sh
    git commit -m "Add update script"
    git push origin master
    
    success "更新脚本已创建"
}

# ============================================================
#  第八步：显示结果
# ============================================================
show_result() {
    echo ""
    echo "=============================================="
    success "🎉 部署完成！"
    echo "=============================================="
    echo ""
    echo "  你的作品集链接:"
    echo "  ${GREEN}https://$GITHUB_USER.github.io/$REPO_NAME/${NC}"
    echo ""
    echo "  以后更新内容，运行:"
    echo "  ${YELLOW}./update.sh \"更新说明\"${NC}"
    echo ""
    echo "  GitHub 仓库:"
    echo "  https://github.com/$REPO_FULL"
    echo ""
    echo "=============================================="
}

# ============================================================
#  主流程
# ============================================================
main() {
    echo ""
    echo "=============================================="
    echo "  个人作品集一键部署工具"
    echo "=============================================="
    echo ""
    
    check_env
    setup_auth
    setup_repo
    init_git
    create_and_push
    enable_pages
    create_update_script
    show_result
}

# 运行主流程
main "$@"
