#!/usr/bin/env bash
# bootstrap_mcu_prereq.sh  --  prerequisite installer for MCU dev env
set -euo pipefail
log() { echo -e "\033[1;35m[BOOT]\033[0m $*"; }
export DEBIAN_FRONTEND=noninteractive

log "Updating APT index"
sudo apt update

log "Installing prerequisite commands"
sudo apt install -y \
  sudo ca-certificates lsb-release software-properties-common \
  wget curl gnupg git tar grep coreutils snapd python3 python3-pip

log "Prerequisite installation finished 🎉"
log "➡  続いて setup_mcu_env.sh を実行してください"
