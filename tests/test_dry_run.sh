#!/usr/bin/env bash
# test_dry_run.sh - MCUセットアップスクリプトのドライランテスト

set -euo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

echo -e "${BLUE}=== MCUセットアップスクリプト ドライランテスト ===${NC}"
echo "実際のインストールは行わず、実行される内容を確認します"
echo

# Function to simulate command execution
dry_run() {
    echo -e "${YELLOW}[DRY-RUN]${NC} $*"
}

# Test bootstrap_mcu_prereq.sh
echo -e "\n${GREEN}📋 bootstrap_mcu_prereq.sh の動作確認${NC}"
echo "以下のコマンドが実行されます："
dry_run "sudo apt update"
dry_run "sudo apt install -y sudo ca-certificates lsb-release software-properties-common wget curl gnupg git tar grep coreutils snapd python3 python3-pip"

# Test setup_mcu_env.sh main components
echo -e "\n${GREEN}📋 setup_mcu_env.sh の主要コンポーネント${NC}"

echo -e "\n1. システムパッケージ更新:"
dry_run "sudo apt update"
dry_run "sudo apt -y upgrade"

echo -e "\n2. コアパッケージインストール:"
dry_run "sudo apt install -y build-essential git cmake python3 python3-pip libusb-1.0-0-dev libudev-dev clang gcc-arm-none-eabi gdb-multiarch gcc-riscv64-unknown-elf openocd stlink-tools rustc cargo gnupg dfu-util minicom sdcc curl wget"

echo -e "\n3. VS Code インストール:"
dry_run "wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o microsoft.gpg"
dry_run "sudo install -Dm644 microsoft.gpg /usr/share/keyrings/microsoft.gpg"
dry_run "sudo apt update && sudo apt install -y code"

echo -e "\n4. Arduino CLI インストール:"
dry_run "wget https://downloads.arduino.cc/arduino-cli/arduino-cli_0.35.3_Linux_64bit.tar.gz"
dry_run "sudo tar -xzf arduino-cli.tar.gz -C /usr/local/bin arduino-cli"

echo -e "\n5. PlatformIO インストール:"
dry_run "python3 -m pip install --user platformio"

echo -e "\n6. SDK セットアップ:"
dry_run "mkdir -p $HOME/dev"
dry_run "git clone --recursive https://github.com/raspberrypi/pico-sdk.git"
dry_run "git clone --recursive https://github.com/sifive/freedom-e-sdk.git"

echo -e "\n7. 権限設定:"
dry_run "sudo usermod -aG dialout,plugdev $USER"
dry_run "sudo tee /etc/udev/rules.d/99-mcu-enhanced.rules"
dry_run "sudo udevadm control --reload-rules"
dry_run "sudo udevadm trigger"

# Check current environment
echo -e "\n${GREEN}📊 現在の環境状態チェック${NC}"
echo -e "既にインストール済みのコンポーネント:"

# Check installed components
components=(
    "gcc:GCC"
    "git:Git"
    "cmake:CMake"
    "python3:Python3"
    "arm-none-eabi-gcc:ARM GCC"
    "openocd:OpenOCD"
    "arduino-cli:Arduino CLI"
    "pio:PlatformIO"
    "code:VS Code"
)

for comp in "${components[@]}"; do
    IFS=':' read -r cmd name <<< "$comp"
    if command -v "$cmd" &>/dev/null; then
        version=$($cmd --version 2>/dev/null | head -n1 || echo "installed")
        echo -e "  ✅ $name: $version"
    else
        echo -e "  ❌ $name: 未インストール"
    fi
done

echo -e "\n${BLUE}ドライランテスト完了！${NC}"
echo "実際にインストールを実行する場合は、各スクリプトを直接実行してください。" 