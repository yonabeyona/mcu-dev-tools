#!/usr/bin/env bash
# troubleshoot_ci.sh - CI/CDトラブルシューティングガイド

set -euo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

echo -e "${BLUE}=== CI/CDトラブルシューティング ===${NC}"
echo

# 1. ローカルでの構文チェック
echo -e "${GREEN}1. ローカル構文チェック${NC}"
echo "Bashスクリプトの構文をチェック中..."

error_count=0
for script in *.sh tests/*.sh; do
    if [[ -f "$script" ]]; then
        if bash -n "$script" 2>/dev/null; then
            echo -e "  ✅ $script - OK"
        else
            echo -e "  ${RED}❌ $script - 構文エラー${NC}"
            bash -n "$script" 2>&1 | sed 's/^/    /'
            ((error_count++))
        fi
    fi
done

if [[ $error_count -eq 0 ]]; then
    echo -e "${GREEN}✓ すべてのスクリプトの構文は正常です${NC}"
else
    echo -e "${RED}✗ $error_count 個のスクリプトに構文エラーがあります${NC}"
fi

# 2. 必要なファイルの存在確認
echo -e "\n${GREEN}2. 必要なファイルの確認${NC}"
required_files=(
    "bootstrap_mcu_prereq.sh"
    "setup_mcu_env.sh"
    ".github/workflows/test-mcu-setup.yml"
    ".github/workflows/test-comprehensive.yml"
)

missing_count=0
for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo -e "  ✅ $file - 存在"
    else
        echo -e "  ${RED}❌ $file - 見つかりません${NC}"
        ((missing_count++))
    fi
done

if [[ $missing_count -eq 0 ]]; then
    echo -e "${GREEN}✓ すべての必要なファイルが存在します${NC}"
else
    echo -e "${RED}✗ $missing_count 個のファイルが見つかりません${NC}"
fi

# 3. 実行権限の確認
echo -e "\n${GREEN}3. 実行権限の確認${NC}"
scripts_without_exec=()
for script in *.sh tests/*.sh; do
    if [[ -f "$script" ]] && [[ ! -x "$script" ]]; then
        scripts_without_exec+=("$script")
    fi
done

if [[ ${#scripts_without_exec[@]} -eq 0 ]]; then
    echo -e "${GREEN}✓ すべてのスクリプトに実行権限があります${NC}"
else
    echo -e "${RED}✗ 以下のスクリプトに実行権限がありません:${NC}"
    for script in "${scripts_without_exec[@]}"; do
        echo -e "  ${YELLOW}$script${NC}"
    done
    echo -e "\n修正方法:"
    echo -e "  ${BLUE}chmod +x ${scripts_without_exec[*]}${NC}"
fi

# 4. よくあるCI/CDエラーと対処法
echo -e "\n${GREEN}4. よくあるCI/CDエラーと対処法${NC}"
cat << EOF

${YELLOW}エラー: Workflow not found${NC}
原因: ワークフローファイルのパスまたは名前が間違っている
対処: .github/workflows/ ディレクトリ内にYAMLファイルがあることを確認

${YELLOW}エラー: Permission denied${NC}
原因: スクリプトに実行権限がない
対処: chmod +x でスクリプトに実行権限を付与してコミット

${YELLOW}エラー: Command not found${NC}
原因: GitHub Actionsランナーに必要なコマンドがインストールされていない
対処: apt install などで必要なパッケージをインストール

${YELLOW}エラー: Syntax error${NC}
原因: Bashスクリプトまたはワークフローの構文エラー
対処: ローカルで構文チェックを実行して修正

${YELLOW}エラー: File not found${NC}
原因: スクリプトが参照しているファイルが存在しない
対処: パスを確認し、必要なファイルをコミット
EOF

# 5. 推奨される次のステップ
echo -e "\n${GREEN}5. 推奨される次のステップ${NC}"
echo "1. 上記で見つかった問題を修正"
echo "2. 変更をコミットしてプッシュ:"
echo "   git add ."
echo "   git commit -m 'Fix CI/CD issues'"
echo "   git push"
echo "3. GitHub Actionsで再実行を確認:"
echo "   https://github.com/yonabeyona/mcu-dev-tools/actions"
echo
echo -e "${BLUE}ヒント: ローカルでテストを実行してCI/CDエラーを事前に発見:${NC}"
echo "  ./tests/validate_scripts.sh"
echo "  ./tests/test_dry_run.sh" 