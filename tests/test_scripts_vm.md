# 仮想マシンでのMCUセットアップスクリプトテスト手順

## 前提条件
- VirtualBox または VMware がインストール済み
- Ubuntu 24.04 LTS のISOイメージ

## 手順

### 1. 仮想マシンの作成
```
- メモリ: 4GB以上推奨
- ディスク: 20GB以上
- ネットワーク: NAT or ブリッジ接続
```

### 2. Ubuntu 24.04 LTSのインストール
- 最小インストールでOK
- ユーザー作成時にsudo権限を付与

### 3. スクリプトの転送
```bash
# ホストマシンから仮想マシンへファイル転送
scp bootstrap_mcu_prereq.sh setup_mcu_env.sh user@vm-ip:~/
```

### 4. テスト実行
```bash
# 仮想マシン内で実行
chmod +x *.sh
./bootstrap_mcu_prereq.sh
./setup_mcu_env.sh
```

### 5. スナップショットの活用
- インストール前の状態でスナップショットを取得
- エラーが発生した場合、スナップショットから復元して再テスト 