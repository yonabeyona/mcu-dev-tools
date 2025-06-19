#!/usr/bin/env bash
# check_ci_status.sh - GitHub Actions CI/CDステータス確認スクリプト

set -euo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

echo -e "${BLUE}=== GitHub Actions CI/CDステータス確認 ===${NC}"
echo

# GitHubリポジトリ情報を取得
get_repo_info() {
    if git remote get-url origin &>/dev/null; then
        local url=$(git remote get-url origin)
        # SSH URLの場合
        if [[ "$url" =~ git@github\.com:([^/]+)/([^.]+)(\.git)?$ ]]; then
            echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
        # HTTPS URLの場合
        elif [[ "$url" =~ https://github\.com/([^/]+)/([^/.]+)(\.git)?$ ]]; then
            echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
        fi
    fi
}

# GitHub CLIがインストールされているか確認
if ! command -v gh &>/dev/null; then
    echo -e "${YELLOW}⚠ GitHub CLI (gh) がインストールされていません${NC}"
    echo "インストール方法:"
    echo "  sudo apt install gh"
    echo "  または"
    echo "  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg"
    echo "  echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null"
    echo "  sudo apt update && sudo apt install gh"
    echo
    echo "代わりにWebブラウザでステータスを確認してください："
    
    repo_info=$(get_repo_info)
    if [[ -n "$repo_info" ]]; then
        echo -e "${BLUE}https://github.com/$repo_info/actions${NC}"
    fi
    exit 0
fi

# リポジトリ情報を取得
repo_info=$(get_repo_info)
if [[ -z "$repo_info" ]]; then
    echo -e "${RED}✗ Gitリポジトリ情報を取得できませんでした${NC}"
    exit 1
fi

echo -e "リポジトリ: ${GREEN}$repo_info${NC}"
echo

# GitHub CLIでログインしているか確認
if ! gh auth status &>/dev/null; then
    echo -e "${YELLOW}⚠ GitHub CLIでログインしていません${NC}"
    echo "以下のコマンドでログインしてください:"
    echo "  gh auth login"
    echo
    echo "代わりにWebブラウザでステータスを確認してください："
    echo -e "${BLUE}https://github.com/$repo_info/actions${NC}"
    exit 0
fi

# 最新のワークフロー実行を取得
echo -e "${GREEN}最新のワークフロー実行状態:${NC}"
echo

# ワークフロー一覧を取得
workflows=$(gh workflow list --repo "$repo_info" 2>/dev/null || echo "")

if [[ -z "$workflows" ]]; then
    echo -e "${YELLOW}ワークフローが見つかりませんでした${NC}"
    exit 0
fi

# 各ワークフローの最新実行を表示
while IFS=$'\t' read -r name state id; do
    echo -e "${BLUE}$name${NC}"
    
    # 最新の実行を取得
    latest_run=$(gh run list --workflow "$id" --repo "$repo_info" --limit 1 2>/dev/null || echo "")
    
    if [[ -n "$latest_run" ]]; then
        # 実行情報をパース
        status=$(echo "$latest_run" | awk '{print $1}')
        conclusion=$(echo "$latest_run" | awk '{print $2}')
        branch=$(echo "$latest_run" | awk '{print $(NF-2)}')
        run_id=$(echo "$latest_run" | awk '{print $NF}')
        
        # ステータスに応じた色付け
        case "$conclusion" in
            success)
                echo -e "  状態: ${GREEN}✓ 成功${NC}"
                ;;
            failure)
                echo -e "  状態: ${RED}✗ 失敗${NC}"
                ;;
            cancelled)
                echo -e "  状態: ${YELLOW}⚠ キャンセル${NC}"
                ;;
            *)
                echo -e "  状態: ${YELLOW}○ $status${NC}"
                ;;
        esac
        
        echo "  ブランチ: $branch"
        echo "  実行ID: $run_id"
        echo "  詳細: https://github.com/$repo_info/actions/runs/$run_id"
    else
        echo -e "  ${YELLOW}実行履歴がありません${NC}"
    fi
    echo
done <<< "$workflows"

# サマリー
echo -e "${BLUE}=== サマリー ===${NC}"
echo -e "すべてのワークフロー: ${BLUE}https://github.com/$repo_info/actions${NC}"

# 失敗したワークフローがある場合
failed_runs=$(gh run list --repo "$repo_info" --status failure --limit 5 2>/dev/null || echo "")
if [[ -n "$failed_runs" ]]; then
    echo
    echo -e "${RED}最近失敗したワークフロー:${NC}"
    echo "$failed_runs" | head -5
fi 