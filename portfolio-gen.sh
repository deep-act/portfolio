#!/bin/bash
# ============================================================
#  个人作品集生成器 v1.0
#  用法：保存为 portfolio-gen.sh，在本地电脑运行
#  功能：一键生成个人作品集 + GitHub Pages 永久链接
# ============================================================

set -e

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ============================================================
#  生成默认作品集 HTML
# ============================================================
generate_portfolio_html() {
    cat > index.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>个人作品集</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    font-family: -apple-system, BlinkMacSystemFont, "SF Pro SC", "PingFang SC", sans-serif;
    background: #f5f5f7; color: #1d1d1f;
    -webkit-font-smoothing: antialiased;
  }
  .lnav {
    position: fixed; top: 0; left: 0; right: 0; z-index: 100;
    height: 48px; background: rgba(255,255,255,.82);
    -webkit-backdrop-filter: saturate(180%) blur(20px);
    backdrop-filter: saturate(180%) blur(20px);
    border-bottom: 1px solid rgba(0,0,0,.08);
    display: flex; align-items: center; justify-content: space-between;
    padding: 0 6%; font-size: 13px;
  }
  .lnav .logo { font-weight: 600; font-size: 14px; }
  .hero {
    background: #f5f5f7; padding: 100px 6% 80px;
  }
  .hero-inner { max-width: 1000px; margin: 0 auto; }
  .hero-inner .eyebrow {
    font-size: 12px; letter-spacing: .14em; color: #86868b;
    text-transform: uppercase; margin-bottom: 12px; text-align: center;
  }
  .hero-inner h2 {
    font-size: clamp(28px, 4vw, 44px); font-weight: 700;
    letter-spacing: -.01em; line-height: 1.12; margin-bottom: 20px; text-align: center;
  }
  .hero-intro-card {
    position: relative; border-radius: 24px; overflow: visible;
    min-height: 320px; display: flex; align-items: flex-end;
    border: 1px solid #d2d2d7;
    max-width: 1000px; width: 100%; margin: 40px auto 0;
    background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
  }
  .hero-intro-content {
    position: relative; z-index: 1; width: 100%; padding: 48px 40px;
  }
  .hero-intro-content h3 {
    font-size: 32px; font-weight: 700; margin-bottom: 16px; color: #f5f5f7;
  }
  .hero-intro-content p {
    font-size: 17px; color: rgba(255,255,255,0.85); line-height: 1.7; max-width: 700px;
  }
  .profile-photo-wrapper {
    position: absolute; top: -60px; left: 40px; z-index: 10;
  }
  .profile-photo {
    width: 140px; height: 140px; border-radius: 50%;
    object-fit: cover; border: 4px solid #fff;
    box-shadow: 0 8px 32px rgba(0,0,0,0.15); display: block;
    background: #ddd;
  }
  .about-highlights {
    display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px;
    max-width: 1000px; margin: 40px auto 0;
  }
  .highlight-card {
    background: #fff; border: 1px solid #d2d2d7; border-radius: 20px;
    padding: 32px; position: relative; overflow: hidden;
    transition: transform 0.3s, box-shadow 0.3s;
  }
  .highlight-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 12px 40px rgba(0,0,0,0.08);
  }
  .highlight-number {
    position: absolute; top: 16px; right: 24px;
    font-size: 64px; font-weight: 700; color: #f0f0f5; line-height: 1;
  }
  .highlight-icon { font-size: 32px; margin-bottom: 16px; }
  .highlight-card h4 {
    font-size: 18px; font-weight: 600; margin-bottom: 12px; color: #1d1d1f;
  }
  .highlight-card p {
    font-size: 15px; color: #6e6e73; line-height: 1.6;
  }
  .skills-label {
    font-size: 13px; color: #86868b; margin: 32px auto 16px;
    max-width: 1000px; text-align: center;
  }
  .skills-grid {
    display: flex; flex-wrap: wrap; gap: 12px;
    max-width: 1000px; margin: 0 auto; justify-content: center;
    padding: 0 6% 80px;
  }
  .skill-tag {
    background: #fff; border: 1px solid #d2d2d7; border-radius: 980px;
    padding: 10px 20px; font-size: 14px; color: #1d1d1f;
    transition: background 0.2s;
  }
  .skill-tag:hover { background: #f0f0f5; }
  @media (max-width: 768px) {
    .about-highlights { grid-template-columns: 1fr; }
    .profile-photo { width: 110px; height: 110px; }
    .profile-photo-wrapper { top: -45px; left: 24px; }
  }
</style>
</head>
<body>

<nav class="lnav">
  <span class="logo">PORTFOLIO</span>
</nav>

<section class="hero">
  <div class="hero-inner">
    <p class="eyebrow">About Me</p>
    <h2>用技术解决真实问题。</h2>

    <div class="hero-intro-card">
      <div class="profile-photo-wrapper">
        <div class="profile-photo"></div>
      </div>
      <div class="hero-intro-content">
        <h3>关于我</h3>
        <p>在此填写你的个人介绍。描述你的背景、技能和职业目标。</p>
      </div>
    </div>

    <div class="about-highlights">
      <div class="highlight-card">
        <div class="highlight-icon"></div>
        <div class="highlight-number">01</div>
        <h4>工作经验</h4>
        <p>描述你的工作经历和核心能力。</p>
      </div>
      <div class="highlight-card">
        <div class="highlight-icon"></div>
        <div class="highlight-number">02</div>
        <h4>教育背景</h4>
        <p>描述你的学历和研究方向。</p>
      </div>
      <div class="highlight-card">
        <div class="highlight-icon">🏆</div>
        <div class="highlight-number">03</div>
        <h4>成果展示</h4>
        <p>描述你的项目成果和学术发表。</p>
      </div>
    </div>

    <p class="skills-label">技术方向：</p>
    <div class="skills-grid">
      <span class="skill-tag">技能 1</span>
      <span class="skill-tag">技能 2</span>
      <span class="skill-tag">技能 3</span>
      <span class="skill-tag">技能 4</span>
      <span class="skill-tag">技能 5</span>
    </div>
  </div>
</section>

</body>
</html>
HTMLEOF
    success "默认作品集 HTML 已生成"
}

# ============================================================
#  生成 GitHub Actions 部署配置
# ============================================================
generate_workflow() {
    mkdir -p .github/workflows
    cat > .github/workflows/deploy.yml << 'YMLEOF'
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
YMLEOF
    success "GitHub Actions 部署配置已生成"
}

# ============================================================
#  生成更新脚本
# ============================================================
generate_update_script() {
    cat > update.sh << 'SHEOF'
#!/bin/bash
# 作品集一键更新脚本
cd "$(dirname "$0")"
MSG="${1:-更新作品集内容}"
echo "📝 提交更改: $MSG"
git add -A
git commit -m "$MSG"
echo "🚀 推送到 GitHub..."
git push origin master
echo "✅ 完成！访问: https://$(git remote get-url origin | sed 's|.*github.com[:/]||;s|\.git.*||').github.io/$(git remote get-url origin | sed 's|.*github.com[:/]||;s|\.git.*||;s|/.*||')/"
echo "⏳ 通常 1-2 分钟内生效"
SHEOF
    chmod +x update.sh
    success "更新脚本已生成"
}

# ============================================================
#  主流程
# ============================================================
main() {
    echo ""
    echo "=============================================="
    echo "  个人作品集生成器 v1.0"
    echo "=============================================="
    echo ""

    # 检查 git
    if ! command -v git &> /dev/null; then
        error "未安装 git，请先安装: https://git-scm.com/"
    fi
    success "git 已安装"

    # 选择模式
    echo "请选择模式："
    echo "  1) 生成作品集文件（本地预览）"
    echo "  2) 生成并部署到 GitHub Pages（需要 GitHub 账号）"
    echo ""
    read -p "请选择 [1/2]: " mode

    case $mode in
        1)
            info "生成作品集文件..."
            generate_portfolio_html
            echo ""
            success "作品集已生成！"
            echo "  文件: $(pwd)/index.html"
            echo "  用浏览器打开即可查看"
            echo ""
            info "以后要部署到 GitHub，运行:"
            echo "  ./portfolio-gen.sh  然后选择 2"
            ;;
        2)
            # 检查 gh
            USE_GH=false
            if command -v gh &> /dev/null; then
                USE_GH=true
            fi

            # 认证
            echo ""
            info "=== GitHub 认证 ==="
            echo ""
            echo "  1) GitHub CLI 浏览器登录（推荐）"
            echo "  2) Personal Access Token"
            echo ""
            read -p "请选择 [1/2]: " auth_choice

            GITHUB_TOKEN=""
            GITHUB_USER=""

            case $auth_choice in
                1)
                    if [ "$USE_GH" = true ]; then
                        gh auth login --web --scopes repo,workflow
                        GITHUB_USER=$(gh api user --jq '.login')
                    else
                        error "请先安装 GitHub CLI: https://cli.github.com/"
                    fi
                    ;;
                2)
                    echo ""
                    echo "  获取 Token："
                    echo "  1. 打开 https://github.com/settings/tokens/new"
                    echo "  2. Note 填任意名称"
                    echo "  3. 勾选 repo 和 workflow"
                    echo "  4. 生成并复制 Token"
                    echo ""
                    read -p "粘贴 Token: " GITHUB_TOKEN
                    read -p "GitHub 用户名: " GITHUB_USER

                    echo "https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com" > ~/.git-credentials
                    chmod 600 ~/.git-credentials
                    git config --global credential.helper store
                    ;;
                *)
                    error "无效选择"
                    ;;
            esac

            # 仓库名
            echo ""
            read -p "仓库名称 [portfolio]: " REPO_NAME
            REPO_NAME=${REPO_NAME:-portfolio}

            if [ -z "$GITHUB_USER" ] && [ "$USE_GH" = true ]; then
                GITHUB_USER=$(gh api user --jq '.login')
            fi

            REPO_FULL="$GITHUB_USER/$REPO_NAME"

            # 生成文件
            echo ""
            info "生成作品集文件..."
            generate_portfolio_html
            generate_workflow
            generate_update_script

            # Git 初始化
            echo ""
            info "初始化 Git 仓库..."
            if [ ! -d ".git" ]; then
                git init
                git branch -M master
            fi
            git config user.name "${GITHUB_USER:-portfolio}"
            git config user.email "${GITHUB_USER:-portfolio}@users.noreply.github.com"

            git add -A
            git commit -m "Initial portfolio"

            # 创建仓库并推送
            echo ""
            info "创建 GitHub 仓库并推送..."
            if [ "$USE_GH" = true ]; then
                gh repo create "$REPO_FULL" --public --source=. --remote=origin --push 2>/dev/null || {
                    git remote set-url origin "https://github.com/$REPO_FULL.git"
                    git push -u origin master
                }
            else
                curl -s -X POST \
                    -H "Authorization: token $GITHUB_TOKEN" \
                    -H "Accept: application/vnd.github.v3+json" \
                    https://api.github.com/user/repos \
                    -d "{\"name\":\"$REPO_NAME\",\"auto_init\":false,\"private\":false}"
                git remote add origin "https://github.com/$REPO_FULL.git" 2>/dev/null || true
                git remote set-url origin "https://github.com/$REPO_FULL.git"
                git push -u origin master
            fi

            # 启用 Pages
            echo ""
            info "启用 GitHub Pages..."
            if [ "$USE_GH" = true ]; then
                gh api repos/$REPO_FULL/pages \
                    -f build_type=workflow \
                    -f source/branch=master \
                    -f source/path=/ 2>/dev/null || true
            else
                curl -s -X POST \
                    -H "Authorization: token $GITHUB_TOKEN" \
                    https://api.github.com/repos/$REPO_FULL/pages \
                    -d '{"build_type":"workflow","source":{"branch":"master","path":"/"}}'
            fi

            # 推送工作流
            git add .github/workflows/deploy.yml update.sh 2>/dev/null
            git commit -m "Add deploy workflow and update script" 2>/dev/null
            git push origin master 2>/dev/null

            # 结果
            echo ""
            echo "=============================================="
            success "🎉 部署完成！"
            echo "=============================================="
            echo ""
            echo "  你的作品集链接:"
            echo "  ${GREEN}https://$GITHUB_USER.github.io/$REPO_NAME/${NC}"
            echo ""
            echo "  以后更新内容:"
            echo "  ${YELLOW}./update.sh \"更新说明\"${NC}"
            echo ""
            echo "=============================================="
            ;;
        *)
            error "无效选择"
            ;;
    esac
}

main "$@"
