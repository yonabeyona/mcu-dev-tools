#!/usr/bin/env bash
# mcu_env_diagnostic.sh  
# MCU開発環境の診断・確認ツール
# インストール状況の確認、問題の特定、修復方法の提案

set -euo pipefail

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# ログ機能
log() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }
header() { echo -e "${PURPLE}[SECTION]${NC} $*"; }

# 診断結果の追跡
declare -A DIAGNOSTIC_RESULTS
TOTAL_CHECKS=0
PASSED_CHECKS=0

record_check() {
    local component="$1"
    local status="$2"
    local details="$3"
    
    DIAGNOSTIC_RESULTS["$component"]="$status:$details"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [[ "$status" == "PASS" ]]; then
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        success "$component: $details"
    elif [[ "$status" == "WARN" ]]; then
        warn "$component: $details"
    else
        error "$component: $details"
    fi
}

# システム情報の収集
collect_system_info() {
    header "=== システム情報 ==="
    
    log "OS情報:"
    if command -v lsb_release &>/dev/null; then
        lsb_release -a 2>/dev/null | grep -E "(Description|Release)"
    else
        cat /etc/os-release | grep -E "(PRETTY_NAME|VERSION)"
    fi
    
    log "カーネル: $(uname -r)"
    log "アーキテクチャ: $(uname -m)"
    log "ユーザー: $USER"
    log "グループ: $(groups)"
    
    echo ""
}

# 基本ツールの確認
check_basic_tools() {
    header "=== 基本ツールの確認 ==="
    
    local basic_tools=(
        "gcc:GNU Compiler Collection"
        "g++:GNU C++ Compiler"
        "make:Build automation tool"
        "cmake:Cross-platform build system"
        "git:Version control system"
        "python3:Python interpreter"
        "pip3:Python package installer"
    )
    
    for tool_info in "${basic_tools[@]}"; do
        IFS=':' read -r tool desc <<< "$tool_info"
        if command -v "$tool" &>/dev/null; then
            local version=$(${tool} --version 2>/dev/null | head -n1 || echo "不明")
            record_check "$tool" "PASS" "$desc - インストール済み"
        else
            record_check "$tool" "FAIL" "$desc が見つかりません"
        fi
    done
    
    echo ""
}

# マイコン関連ツールの確認
check_mcu_tools() {
    header "=== マイコン開発ツールの確認 ==="
    
    local mcu_tools=(
        "arm-none-eabi-gcc:ARM Cortex-M toolchain"
        "gdb-multiarch:Multi-architecture debugger"
        "openocd:On-Chip Debugger"
        "st-info:ST-Link utilities"
        "dfu-util:Device Firmware Upgrade utilities"
        "minicom:Serial communication"
        "sdcc:Small Device C Compiler"
    )
    
    for tool_info in "${mcu_tools[@]}"; do
        IFS=':' read -r tool desc <<< "$tool_info"
        if command -v "$tool" &>/dev/null; then
            record_check "$tool" "PASS" "$desc - インストール済み"
        else
            record_check "$tool" "FAIL" "$desc が見つかりません"
        fi
    done
    
    echo ""
}

# RISC-V関連ツールの確認
check_riscv_tools() {
    header "=== RISC-V開発ツールの確認 ==="
    
    local riscv_variants=(
        "gcc-riscv64-unknown-elf"
        "riscv64-unknown-elf-gcc"
        "riscv-none-elf-gcc"
        "riscv32-unknown-elf-gcc"
    )
    
    local found_riscv=false
    for variant in "${riscv_variants[@]}"; do
        if command -v "$variant" &>/dev/null; then
            record_check "riscv-toolchain" "PASS" "RISC-V toolchain found: $variant"
            found_riscv=true
            break
        fi
    done
    
    if [[ "$found_riscv" == false ]]; then
        record_check "riscv-toolchain" "FAIL" "RISC-V toolchain が見つかりません"
    fi
    
    echo ""
}

# Z80開発ツールの確認
check_z80_tools() {
    header "=== Z80開発ツールの確認 ==="
    
    # z88dk確認
    if command -v zcc &>/dev/null; then
        record_check "z88dk" "PASS" "Z80 Development Kit - インストール済み"
    elif command -v z88dk.zcc &>/dev/null; then
        record_check "z88dk" "PASS" "Z80 Development Kit (snap) - インストール済み"
    else
        record_check "z88dk" "FAIL" "z88dk (Z80 Development Kit) が見つかりません"
    fi
    
    # sjasmplus確認
    if command -v sjasmplus &>/dev/null; then
        record_check "sjasmplus" "PASS" "Z80 assembler - インストール済み"
    else
        record_check "sjasmplus" "FAIL" "sjasmplus (Z80 assembler) が見つかりません"
    fi
    
    echo ""
}

# 開発環境の確認
check_development_environments() {
    header "=== 開発環境の確認 ==="
    
    # Visual Studio Code
    if command -v code &>/dev/null; then
        record_check "vscode" "PASS" "Visual Studio Code - インストール済み"
    else
        record_check "vscode" "FAIL" "Visual Studio Code が見つかりません"
    fi
    
    # Arduino CLI
    if command -v arduino-cli &>/dev/null; then
        record_check "arduino-cli" "PASS" "Arduino CLI - インストール済み"
    else
        record_check "arduino-cli" "FAIL" "Arduino CLI が見つかりません"
    fi
    
    # PlatformIO
    if command -v pio &>/dev/null; then
        record_check "platformio" "PASS" "PlatformIO - インストール済み"
    elif python3 -c "import platformio" 2>/dev/null; then
        record_check "platformio" "PASS" "PlatformIO (Python module)"
    else
        record_check "platformio" "FAIL" "PlatformIO が見つかりません"
    fi
    
    echo ""
}

# 問題の修復提案
suggest_fixes() {
    header "=== 修復提案 ==="
    
    local has_failures=false
    
    for component in "${!DIAGNOSTIC_RESULTS[@]}"; do
        IFS=':' read -r status details <<< "${DIAGNOSTIC_RESULTS[$component]}"
        
        if [[ "$status" == "FAIL" ]]; then
            has_failures=true
            
            case "$component" in
                "gcc"|"g++"|"make"|"cmake"|"git"|"python3"|"pip3")
                    log "修復: sudo apt install -y $component"
                    ;;
                "arm-none-eabi-gcc"|"gdb-multiarch"|"openocd"|"st-info"|"dfu-util"|"minicom"|"sdcc")
                    log "修復: sudo apt install -y gcc-arm-none-eabi stlink-tools"
                    ;;
                "riscv-toolchain")
                    log "修復: sudo apt install -y gcc-riscv64-unknown-elf"
                    ;;
                "z88dk")
                    log "修復: sudo snap install z88dk --edge (PATH設定要確認)"
                    ;;
                "sjasmplus")
                    log "修復: sudo apt install -y sjasmplus または源码编译"
                    ;;
                "vscode")
                    log "修復: sudo snap install --classic code"
                    ;;
                "arduino-cli")
                    log "修復: Arduino CLI 公式サイトからダウンロード"
                    ;;
                "platformio")
                    log "修復: python3 -m pip install --user platformio --break-system-packages"
                    ;;
            esac
        fi
    done
    
    if [[ "$has_failures" == false ]]; then
        success "修復が必要な項目はありません！"
    fi
    
    echo ""
}

# 診断結果のサマリー
show_summary() {
    header "=== 診断結果サマリー ==="
    
    local success_rate=0
    if [[ $TOTAL_CHECKS -gt 0 ]]; then
        success_rate=$(( PASSED_CHECKS * 100 / TOTAL_CHECKS ))
    fi
    
    echo "総合成功率: $success_rate% ($PASSED_CHECKS/$TOTAL_CHECKS)"
    echo ""
    
    if [[ $success_rate -eq 100 ]]; then
        success "🎉 完璧です！すべての項目が正常に動作しています。"
    elif [[ $success_rate -ge 80 ]]; then
        warn "⚠️  ほぼ良好ですが、いくつかの改善点があります。"
    elif [[ $success_rate -ge 60 ]]; then
        warn "⚠️  基本的な機能は動作しますが、追加インストールが推奨されます。"
    else
        error "❌ 多くの項目で問題があります。setup_mcu_env_enhanced.sh の実行を推奨します。"
    fi
    
    echo ""
    log "詳細な修復手順については、上記の修復提案を参照してください。"
}

# メイン実行
main() {
    log "MCU開発環境診断ツールを開始します..."
    echo ""
    
    collect_system_info
    check_basic_tools
    check_mcu_tools
    check_riscv_tools
    check_z80_tools
    check_development_environments
    suggest_fixes
    show_summary
}

# スクリプトが直接実行された場合のみmainを実行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
