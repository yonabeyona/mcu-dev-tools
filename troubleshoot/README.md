# トラブルシューティングツール

このディレクトリには、MCU開発環境のトラブルシューティングとメンテナンス用のツールが含まれています。

## mcu_env_diagnostic.sh

MCU開発環境の診断・確認ツールです。インストール状況の確認、問題の特定、修復方法の提案を行います。

### 使用方法

```bash
cd troubleshoot
chmod +x mcu_env_diagnostic.sh
./mcu_env_diagnostic.sh
```

### 機能

- システム情報の収集
- 基本ツールの確認（gcc, make, cmake等）
- MCU開発ツールの確認（ARM, RISC-V, Z80等）
- 開発環境の確認（VSCode, Arduino CLI, PlatformIO）
- 問題の修復提案
- インストール成功率の表示

### 実行例

```bash
$ ./mcu_env_diagnostic.sh
[INFO] MCU開発環境診断ツールを開始します...

[SECTION] === システム情報 ===
[INFO] OS情報:
Description:    Ubuntu 24.04 LTS
[INFO] カーネル: 6.11.0-26-generic
[INFO] アーキテクチャ: x86_64

[SECTION] === 基本ツールの確認 ===
[OK] gcc: GNU Compiler Collection - インストール済み
[OK] make: Build automation tool - インストール済み
...

総合成功率: 95% (19/20)
```

問題が発生した場合は、提案された修復コマンドを実行してください。

## インストールログ

`setup_mcu_env.sh`を実行すると、詳細なインストールログが`installation_YYYYMMDD_HHMMSS.log`という形式でこのディレクトリに保存されます。

### ログファイルの確認方法

```bash
# 最新のログファイルを表示
ls -t troubleshoot/installation_*.log | head -1 | xargs cat

# すべてのログファイルを一覧表示
ls -la troubleshoot/installation_*.log
```

ログファイルには以下の情報が記録されます：
- タイムスタンプ付きの詳細なインストール進行状況
- 成功/失敗したコンポーネント
- エラーメッセージと警告
- 使用されたインストール方法 