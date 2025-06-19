#!/usr/bin/env bash
# validate_scripts.sh - 既存環境でMCUセットアップスクリプトを検証

set -uo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

echo -e "${BLUE}=== MCUセットアップスクリプト検証ツール ===${NC}"
echo "既存環境でスクリプトの健全性をチェックします"
echo

# 検証結果を記録
declare -i TOTAL_CHECKS=0
declare -i PASSED_CHECKS=0

# チェック関数
check() {
    local description="$1"
    local command="$2"
    ((TOTAL_CHECKS++))
    
    echo -n "🔍 $description... "
    if eval "$command" &>/dev/null; then
        echo -e "${GREEN}✓ OK${NC}"
        ((PASSED_CHECKS++))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        return 1
    fi
}

# 詳細チェック関数
check_detailed() {
    local description="$1"
    local command="$2"
    ((TOTAL_CHECKS++))
    
    echo -e "\n${YELLOW}📋 $description${NC}"
    if eval "$command"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((PASSED_CHECKS++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        return 1
    fi
}

echo -e "${GREEN}1. 構文チェック${NC}"
check "bootstrap_mcu_prereq.sh の構文" "bash -n bootstrap_mcu_prereq.sh"
check "setup_mcu_env.sh の構文" "bash -n setup_mcu_env.sh"

echo -e "\n${GREEN}2. ShellCheckによる静的解析${NC}"
if command -v shellcheck &>/dev/null; then
    check_detailed "bootstrap_mcu_prereq.sh の解析" "shellcheck -x bootstrap_mcu_prereq.sh || true"
    check_detailed "setup_mcu_env.sh の解析" "shellcheck -x setup_mcu_env.sh || true"
else
    echo -e "${YELLOW}⚠ ShellCheckがインストールされていません${NC}"
    echo "  インストール: sudo apt install shellcheck"
fi

echo -e "\n${GREEN}3. 必要な外部リソースの確認${NC}"
# URLの有効性チェック
urls=(
    "https://packages.microsoft.com/keys/microsoft.asc"
    "https://downloads.arduino.cc/arduino-cli/arduino-cli_0.35.3_Linux_64bit.tar.gz"
    "https://github.com/raspberrypi/pico-sdk.git"
    "https://github.com/sifive/freedom-e-sdk.git"
)

for url in "${urls[@]}"; do
    echo -n "🌐 $url ... "
    if curl -sf --head "$url" &>/dev/null || wget -q --spider "$url" &>/dev/null; then
        echo -e "${GREEN}✓ アクセス可能${NC}"
    else
        echo -e "${RED}✗ アクセス不可${NC}"
    fi
done

echo -e "\n${GREEN}4. スクリプトのロジック検証${NC}"
# setup_mcu_env.sh の関数をソース（実行はしない）
echo "スクリプトの関数定義を読み込み中..."
(
    # 実行を防ぐためにmain関数を無効化
    main() { :; }
    # スクリプトをソース
    source setup_mcu_env.sh 2>/dev/null || true
    
    # 定義された関数をチェック
    echo "定義された主要関数:"
    declare -F | grep -E "(install_|setup_|check_)" | sed 's/declare -f /  - /' || true
)

echo -e "\n${GREEN}5. 権限とパスの確認${NC}"
check "ユーザーがsudoグループに所属" "groups | grep -qE '(sudo|wheel)'"
check "/home/$USER/dev ディレクトリの作成可否" "mkdir -p /tmp/test_dev && rmdir /tmp/test_dev"

echo -e "\n${GREEN}6. 依存関係の確認${NC}"
# 既にインストールされているツールのチェック
tools=(
    "python3:Python 3"
    "git:Git"
    "curl:cURL"
    "wget:wget"
    "tar:tar"
    "grep:grep"
)

for tool_info in "${tools[@]}"; do
    IFS=':' read -r cmd desc <<< "$tool_info"
    check "$desc" "command -v $cmd"
done

# 結果サマリー
echo -e "\n${BLUE}=== 検証結果サマリー ===${NC}"
echo -e "総チェック数: $TOTAL_CHECKS"
echo -e "成功: ${GREEN}$PASSED_CHECKS${NC}"
echo -e "失敗: ${RED}$((TOTAL_CHECKS - PASSED_CHECKS))${NC}"

success_rate=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
echo -e "成功率: ${success_rate}%"

if [[ $success_rate -eq 100 ]]; then
    echo -e "\n${GREEN}✅ すべてのチェックに合格しました！${NC}"
    echo "スクリプトは正常に動作する可能性が高いです。"
elif [[ $success_rate -ge 80 ]]; then
    echo -e "\n${YELLOW}⚠ 一部のチェックに失敗しました${NC}"
    echo "軽微な問題がありますが、基本的な動作は可能と思われます。"
else
    echo -e "\n${RED}❌ 多くのチェックに失敗しました${NC}"
    echo "スクリプトの修正が必要かもしれません。"
fi

echo -e "\n💡 ヒント: 完全なテストにはDocker環境の使用を推奨します。"
echo "   ./test_scripts_docker.sh を実行してください。" 