# MCU開発環境セットアップツール

[![MCU Setup Scripts Test](https://github.com/yonabeyona/mcu-dev-tools-clean/actions/workflows/test-mcu-setup.yml/badge.svg)](https://github.com/yonabeyona/mcu-dev-tools-clean/actions/workflows/test-mcu-setup.yml)
[![Comprehensive MCU Setup Test](https://github.com/yonabeyona/mcu-dev-tools-clean/actions/workflows/test-comprehensive.yml/badge.svg)](https://github.com/yonabeyona/mcu-dev-tools-clean/actions/workflows/test-comprehensive.yml)

Ubuntu 24.04 LTS向けのマイクロコントローラー（MCU）開発環境を自動構築するためのツールセットです。複数のMCUプラットフォームに対応した包括的な開発環境を一括でセットアップできます。

## 対応マイクロコントローラー

- **RP2040** (Raspberry Pi Pico)
- **AVR** (Arduino系)
- **STM32F103**
- **GD32VF103**
- **HiFive1 RevB** (RISC-V)
- **CH32V003** (32bit RISC-V)
- **Luckfox Pico Max M**
- **Z80 AKI-80ファミリー**

## 特徴

✅ **ワンクリックセットアップ**: 複雑な環境構築を自動化  
✅ **マルチプラットフォーム対応**: 8種類のMCUファミリーをサポート  
✅ **完全なツールチェーン**: コンパイラからデバッガまで一括インストール  
✅ **高信頼性**: 複数のインストール方法によるフォールバック機能  
✅ **IDE統合**: Visual Studio Code + 拡張機能  
✅ **udevルール自動設定**: USBデバイス認識の自動化  
✅ **詳細なログ記録**: インストール過程の完全な追跡  

## ファイル構成

```
.
├── bootstrap_mcu_prereq.sh  # 前提条件インストールスクリプト
├── setup_mcu_env.sh        # メイン環境セットアップスクリプト（強化版）
├── README.md               # このファイル
├── tests/                  # CI/CDテストスクリプト
│   ├── test_scripts_docker.sh  # Dockerコンテナテスト
│   ├── validate_scripts.sh     # スクリプト検証ツール
│   ├── test_dry_run.sh        # ドライランテスト
│   ├── ci_setup_helper.sh     # CI/CDセットアップヘルパー
│   └── README.md              # テストツールの説明
├── troubleshoot/          # トラブルシューティング用ツール
│   ├── mcu_env_diagnostic.sh  # 環境診断ツール
│   ├── installation_*.log     # インストールログ（自動生成）
│   └── README.md             # トラブルシューティングガイド
└── .github/
    └── workflows/         # GitHub Actionsワークフロー
        ├── test-mcu-setup.yml      # 基本テスト
        └── test-comprehensive.yml  # 包括的テスト
```

## インストール手順

### 1. 前提条件のインストール

```bash
chmod +x bootstrap_mcu_prereq.sh
./bootstrap_mcu_prereq.sh
```

### 2. メイン環境のセットアップ

```bash
chmod +x setup_mcu_env.sh
./setup_mcu_env.sh
```

### 3. 設定の適用

```bash
# グループとPATH変更を適用するため再ログインまたは再起動
sudo reboot
# または
source ~/.bashrc
```

## setup_mcu_env.sh の強化機能

このスクリプトは100%のインストール成功率を目指して設計されています：

### 多重インストール方法
各コンポーネントに対して複数のインストール方法を提供：
- パッケージマネージャー（APT、Snap）
- 公式バイナリダウンロード
- ソースからのビルド
- 代替配布チャンネル

### 自動リトライ機能
- ネットワークエラー時の自動再試行（最大3回）
- タイムアウト設定とインテリジェントな待機

### 詳細な進行状況表示
- カラー出力による視覚的なフィードバック
- パーセンテージ表示
- コンポーネント別の成功/失敗状況
- 最終的な成功率レポート

### ログ記録
- タイムスタンプ付きの詳細ログ
- `troubleshoot/installation_*.log`に自動保存
- エラー追跡とデバッグ情報

## インストール内容

### 開発ツール
- **IDE**: Visual Studio Code
- **ビルドシステム**: CMake, Arduino-CLI, PlatformIO Core
- **バージョン管理**: Git

### コンパイラ・ツールチェーン
- **ARM**: gcc-arm-none-eabi
- **RISC-V (64bit)**: gcc-riscv64-unknown-elf
- **RISC-V (32bit)**: xPack riscv-none-elf-gcc（CH32V用）
- **Z80**: z88dk, sjasmplus
- **AVR**: SDCC (Small Device C Compiler)
- **Rust**: rustc, cargo

### デバッグ・プログラミングツール
- **デバッガ**: OpenOCD, gdb-multiarch
- **プログラマ**: ST-Link tools, dfu-util
- **シリアル通信**: minicom

### SDK・ライブラリ
自動的に `~/dev` ディレクトリにクローンされます：
- **Pico SDK** (RP2040用)
- **Freedom E SDK** (SiFive HiFive1用)

### システム設定
- **ユーザーグループ**: `dialout`, `plugdev` への追加
- **udevルール**: 各種MCU用USBデバイスの自動認識
- **環境変数**: `PICO_SDK_PATH` の自動設定

## 使用方法

### RP2040 (Raspberry Pi Pico)
```bash
cd ~/dev/pico-sdk/examples/hello_world
mkdir build && cd build
cmake ..
make
```

### Arduino (AVR)
```bash
arduino-cli board list
arduino-cli compile --fqbn arduino:avr:uno your_sketch.ino
```

### STM32F103
```bash
# OpenOCDとST-Linkを使用
openocd -f interface/stlink.cfg -f target/stm32f1x.cfg
```

### PlatformIO
```bash
pio project init --board pico
pio run
pio run --target upload
```

## トラブルシューティング

### 診断ツール
環境のインストール状況を確認するための診断ツールを提供しています：
```bash
cd troubleshoot
./mcu_env_diagnostic.sh
```

インストール実行時のログは`troubleshoot/installation_*.log`に保存されます。

### 権限エラー
```bash
# ユーザーが適切なグループに追加されているか確認
groups $USER
# dialout, plugdev が含まれているはずです
```

### USBデバイスが認識されない
```bash
# udevルールの再読み込み
sudo udevadm control --reload-rules
sudo udevadm trigger
```

### PlatformIOインストール失敗
```bash
# 手動でPlatformIO Coreを再インストール
curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py | python3
```

### パスが通らない
```bash
# .bashrcの再読み込み
source ~/.bashrc
```

### インストールログの確認
```bash
# 最新のログファイルを表示
ls -t troubleshoot/installation_*.log | head -1 | xargs cat

# エラーのみ抽出
grep -E "(ERROR|FAIL)" troubleshoot/installation_*.log
```

## 環境診断

インストール後、環境が正しく設定されているか確認：

```bash
# 診断ツールを実行
./troubleshoot/mcu_env_diagnostic.sh
```

診断ツールは以下をチェックします：
- 基本ツール（gcc, make, cmake等）
- MCU開発ツール（各種コンパイラ、デバッガ）
- 開発環境（VSCode, Arduino CLI, PlatformIO）
- ユーザー権限とグループ設定

## 対応OS

- **Ubuntu 24.04 LTS** (メインサポート)
- 他のDebian系ディストリビューションでも動作する可能性があります

## 必要なディスク容量

- 約2-3GB（SDK、ツールチェーン、IDEを含む）

## ライセンス

このセットアップツール自体にライセンス制限はありませんが、インストールされる各種ツールやSDKは、それぞれのライセンスに従います。

## 貢献

バグ報告や機能追加のリクエストは、Issuesまでお願いします。

## 更新履歴

- **v2.0**: 強化版リリース - 100%インストール成功率を目指す改良版
  - 多重インストール方法の実装
  - 自動リトライ機能の追加
  - 診断ツールの統合
  - ログ記録機能の強化
- **v1.0**: 初期リリース - 8種類のMCUプラットフォーム対応

---

🎯 **Quick Start**: `./bootstrap_mcu_prereq.sh` → `./setup_mcu_env.sh` → 再起動  
🚀 **Happy Coding!** 