# CI/CDテストスクリプト

このディレクトリには、MCU開発環境セットアップスクリプトのテストと検証を行うためのツールが含まれています。

## ファイル一覧

### 🐳 test_scripts_docker.sh
Dockerコンテナ内でクリーンな環境でのテストを実行します。
```bash
./tests/test_scripts_docker.sh
```

### 🔍 validate_scripts.sh
既存の環境でスクリプトの健全性をチェックします。
- 構文チェック
- 外部リソースの可用性確認
- 関数定義の検証
```bash
./tests/validate_scripts.sh
```

### 🧪 test_dry_run.sh
実際のインストールを行わずに、実行される内容を確認します。
```bash
./tests/test_dry_run.sh
```

### 🛠️ ci_setup_helper.sh
GitHub CI/CDのセットアップを支援します。
- Gitリポジトリの状態確認
- READMEのバッジURL更新
- セットアップ手順の表示
```bash
./tests/ci_setup_helper.sh
```

### 📝 test_scripts_vm.md
仮想マシンでのテスト手順のドキュメント

## GitHub Actionsからの利用

これらのスクリプトは主にGitHub Actionsワークフローから自動的に実行されます：
- `.github/workflows/test-comprehensive.yml`
- `.github/workflows/test-mcu-setup.yml`

## ローカルでのテスト実行

プッシュ前にローカルでテストを実行することを推奨します：

```bash
# 検証スクリプトを実行
./tests/validate_scripts.sh

# ドライランテスト
./tests/test_dry_run.sh

# Dockerテスト（Dockerが必要）
./tests/test_scripts_docker.sh
```

## テストの追加

新しいテストスクリプトを追加する場合：
1. このディレクトリに配置
2. 実行権限を付与（`chmod +x`）
3. GitHub Actionsワークフローに追加
4. このREADMEを更新 