#!/usr/bin/env bash
# ci_setup_helper.sh - GitHub CI/CDセットアップヘルパー

set -euo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

echo -e "${BLUE}=== GitHub CI/CD セットアップヘルパー ===${NC}"
echo

# Function to get GitHub info
get_github_info() {
    local remote_url=$(git remote get-url origin 2>/dev/null || echo "")
    if [[ -n "$remote_url" ]]; then
        # Extract username and repo from URL
        if [[ "$remote_url" =~ github\.com[:/]([^/]+)/([^/.]+)(\.git)?$ ]]; then
            echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
        fi
    fi
}

# Check Git status
echo -e "${GREEN}1. Gitリポジトリ状態チェック${NC}"
if [[ -d .git ]]; then
    echo "✅ Gitリポジトリが初期化されています"
    
    # Get remote info
    if git remote get-url origin &>/dev/null; then
        echo "✅ リモートリポジトリが設定されています"
        echo "   URL: $(git remote get-url origin)"
        
        # Update README with actual repo info
        repo_info=$(get_github_info)
        if [[ -n "$repo_info" ]]; then
            echo -e "\n${YELLOW}READMEのバッジURLを更新します...${NC}"
            sed -i "s|YOUR_USERNAME/YOUR_REPO|$repo_info|g" README.md
            echo "✅ README.mdのバッジURLを更新しました: $repo_info"
        fi
    else
        echo "❌ リモートリポジトリが設定されていません"
        echo -e "${YELLOW}以下のコマンドでリモートリポジトリを追加してください:${NC}"
        echo "  git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git"
    fi
else
    echo "❌ Gitリポジトリが初期化されていません"
    echo -e "${YELLOW}以下のコマンドで初期化してください:${NC}"
    echo "  git init"
fi

# Check for uncommitted changes
echo -e "\n${GREEN}2. 未コミットの変更をチェック${NC}"
if git diff --quiet && git diff --staged --quiet; then
    echo "✅ すべての変更がコミットされています"
else
    echo "⚠️  未コミットの変更があります"
    echo -e "${YELLOW}変更をコミットしてください:${NC}"
    echo "  git add ."
    echo "  git commit -m 'Add CI/CD workflows and test scripts'"
fi

# Check GitHub Actions files
echo -e "\n${GREEN}3. GitHub Actionsワークフローファイル${NC}"
workflows=(
    ".github/workflows/test-mcu-setup.yml"
    ".github/workflows/test-comprehensive.yml"
)

for workflow in "${workflows[@]}"; do
    if [[ -f "$workflow" ]]; then
        echo "✅ $workflow が存在します"
    else
        echo "❌ $workflow が見つかりません"
    fi
done

# Instructions
echo -e "\n${BLUE}=== セットアップ手順 ===${NC}"
echo
echo "1️⃣  ${GREEN}GitHubでリポジトリを作成${NC}"
echo "   https://github.com/new でリポジトリを作成してください"
echo
echo "2️⃣  ${GREEN}ローカルリポジトリをGitHubに接続${NC}"
echo "   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git"
echo "   git branch -M main"
echo
echo "3️⃣  ${GREEN}すべてのファイルをコミット${NC}"
echo "   git add ."
echo "   git commit -m 'Initial commit with CI/CD setup'"
echo
echo "4️⃣  ${GREEN}GitHubにプッシュ${NC}"
echo "   git push -u origin main"
echo
echo "5️⃣  ${GREEN}GitHub Actionsの確認${NC}"
echo "   プッシュ後、GitHubリポジトリの'Actions'タブで実行状況を確認"
echo

# Optional: Create a quick commit script
echo -e "${YELLOW}💡 ヒント: 簡単にコミット&プッシュするスクリプトを作成しますか？ (y/n)${NC}"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    cat > quick_push.sh << 'EOF'
#!/usr/bin/env bash
# Quick commit and push script
set -euo pipefail

# Commit message from argument or default
MESSAGE="${1:-Update MCU setup scripts}"

echo "📝 Adding all changes..."
git add .

echo "📦 Committing with message: $MESSAGE"
git commit -m "$MESSAGE" || echo "No changes to commit"

echo "🚀 Pushing to GitHub..."
git push

echo "✅ Done! Check GitHub Actions for CI/CD results"
EOF
    chmod +x quick_push.sh
    echo "✅ quick_push.sh を作成しました"
    echo "   使い方: ./quick_push.sh \"コミットメッセージ\""
fi

echo -e "\n${GREEN}✨ セットアップヘルパー完了！${NC}" 