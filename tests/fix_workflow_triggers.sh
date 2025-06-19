#!/usr/bin/env bash
# fix_workflow_triggers.sh - ワークフローのトリガー条件を改善

echo "=== ワークフロートリガー改善提案 ==="
echo
echo "現在の問題:"
echo "- test-mcu-setup.yml は特定のファイルが変更された時のみ実行"
echo "- tests/ ディレクトリの変更では実行されない"
echo
echo "提案する修正:"
echo
echo "1. すべてのプッシュで実行（シンプル）:"
echo "   on:"
echo "     push:"
echo "       branches: [ master, main ]"
echo "     pull_request:"
echo "       branches: [ master, main ]"
echo "     workflow_dispatch:"
echo
echo "2. 関連ファイルをすべて含める（推奨）:"
echo "   on:"
echo "     push:"
echo "       paths:"
echo "         - 'bootstrap_mcu_prereq.sh'"
echo "         - 'setup_mcu_env.sh'"
echo "         - 'tests/**'"
echo "         - '.github/workflows/**'"
echo "     pull_request:"
echo "       paths:"
echo "         - 'bootstrap_mcu_prereq.sh'"
echo "         - 'setup_mcu_env.sh'"
echo "         - 'tests/**'"
echo "         - '.github/workflows/**'"
echo "     workflow_dispatch:"
echo
echo "どちらを選択しますか？" 