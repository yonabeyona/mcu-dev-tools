#!/usr/bin/env bash
# bootstrap_mcu_prereq.sh  --  prerequisite installer for MCU dev env
set -euo pipefail
log() { echo -e "\033[1;35m[BOOT]\033[0m $*"; }
export DEBIAN_FRONTEND=noninteractive

# CI環境の検出
if [[ -n "${CI:-}" ]] || [[ -n "${GITHUB_ACTIONS:-}" ]]; then
    log "CI環境を検出しました"
fi

log "Updating APT index"
if ! sudo apt-get update -qq 2>&1; then
    log "APT updateで警告がありましたが、続行します"
fi

log "Installing prerequisite commands"
# パッケージを個別にインストール（エラーハンドリング付き）
PACKAGES=(
    "ca-certificates"
    "lsb-release"
    "software-properties-common"
    "wget"
    "curl"
    "gnupg"
    "git"
    "tar"
    "grep"
    "coreutils"
    "python3"
    "python3-pip"
)

# snapdはCI環境では不要
if [[ -z "${CI:-}" ]] && [[ -z "${GITHUB_ACTIONS:-}" ]]; then
    PACKAGES+=("snapd")
fi

for pkg in "${PACKAGES[@]}"; do
    if ! dpkg -l "$pkg" &>/dev/null; then
        log "Installing $pkg..."
        sudo apt-get install -y --no-install-recommends "$pkg" || log "Warning: Failed to install $pkg"
    else
        log "$pkg is already installed"
    fi
done

log "Prerequisite installation finished 🎉"
log "➡  続いて setup_mcu_env.sh を実行してください"
