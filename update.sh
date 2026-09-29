#!/bin/bash
# 作品集一键更新脚本
# 用法: ./update.sh "更新说明"

cd /ya/Code/tanghan/portfolio

# 如果有参数，用参数作为提交信息；否则用默认信息
MSG="${1:-更新作品集内容}"

echo "📝 提交更改: $MSG"
git add -A
git commit -m "$MSG"

echo "🚀 推送到 GitHub..."
git push origin master

echo "✅ 完成！GitHub Actions 会自动部署"
echo " 访问链接: https://deep-act.github.io/portfolio/"
echo "⏳ 通常 1-2 分钟内生效"
