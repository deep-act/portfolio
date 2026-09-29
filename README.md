# 个人作品集

基于 GitHub Pages 的个人作品集网站，支持一键部署和持续更新。

## 在线预览

**https://deep-act.github.io/portfolio/**

## 功能

- 个人介绍卡片（支持自定义背景图）
- 三大亮点展示
- 技术方向标签
- 项目作品展示
- 响应式设计，支持移动端

## 快速部署

```bash
# 克隆仓库
git clone https://github.com/deep-act/portfolio.git
cd portfolio

# 运行部署脚本
chmod +x portfolio-gen.sh
./portfolio-gen.sh
```

## 更新内容

```bash
# 修改 HTML 文件后
./update.sh "更新说明"
```

推送后 GitHub Actions 自动部署，1-2 分钟生效。

## 技术栈

- 纯 HTML/CSS/JavaScript
- GitHub Pages 托管
- GitHub Actions 自动部署

## 自定义

编辑 `index.html` 修改内容：
- 个人介绍文字
- 技术方向标签
- 项目卡片内容
- 背景图片

## 许可证

MIT
