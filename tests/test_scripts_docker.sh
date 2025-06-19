#!/usr/bin/env bash
# test_scripts_docker.sh - Docker環境でMCUセットアップスクリプトをテスト

set -euo pipefail

echo "🐳 Docker環境でのMCUセットアップスクリプトテスト"
echo "=================================================="

# Dockerイメージの選択
DOCKER_IMAGE="ubuntu:24.04"
CONTAINER_NAME="mcu-setup-test-$(date +%s)"

echo "📦 使用するDockerイメージ: $DOCKER_IMAGE"

# Dockerfileの作成
cat > Dockerfile.test <<'EOF'
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo

# テスト用の基本環境設定
RUN apt-get update && \
    apt-get install -y sudo && \
    useradd -m -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/testuser

# スクリプトをコピー
COPY bootstrap_mcu_prereq.sh /home/testuser/
COPY setup_mcu_env.sh /home/testuser/

# 所有権とパーミッションの設定
RUN chown testuser:testuser /home/testuser/*.sh && \
    chmod +x /home/testuser/*.sh

# テストユーザーに切り替え
USER testuser
WORKDIR /home/testuser

# エントリーポイント
CMD ["/bin/bash"]
EOF

echo "🔨 Dockerイメージをビルド中..."
docker build -t mcu-setup-test -f Dockerfile.test .

echo "🚀 コンテナを起動してテスト実行..."
docker run --rm -it --name "$CONTAINER_NAME" mcu-setup-test bash -c '
    echo "=== Phase 1: bootstrap_mcu_prereq.sh ==="
    ./bootstrap_mcu_prereq.sh
    
    echo -e "\n=== Phase 2: setup_mcu_env.sh ==="
    ./setup_mcu_env.sh
    
    echo -e "\n=== インストール確認 ==="
    echo "✓ GCC: $(gcc --version 2>/dev/null | head -n1 || echo "Not found")"
    echo "✓ Git: $(git --version 2>/dev/null || echo "Not found")"
    echo "✓ CMake: $(cmake --version 2>/dev/null | head -n1 || echo "Not found")"
    echo "✓ Python3: $(python3 --version 2>/dev/null || echo "Not found")"
    echo "✓ ARM GCC: $(arm-none-eabi-gcc --version 2>/dev/null | head -n1 || echo "Not found")"
'

# クリーンアップ
rm -f Dockerfile.test

echo "✅ テスト完了！" 