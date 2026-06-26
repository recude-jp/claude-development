#!/bin/bash
# =============================================================================
# setup_user_pc.sh
# 業務ユーザーのPCにリポジトリをクローンし、GitHub認証を設定するスクリプト
# 実行場所: 業務ユーザーのPC（システムアドバイザーが代わりに操作してもOK）
# 引数: リポジトリのHTTPS URL（例: https://github.com/myorg/yamada-automation.git）
# =============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${BLUE}=== 業務ユーザーPC セットアップ ===${NC}"
echo ""

# --- 引数チェック ---
if [ -z "$1" ]; then
  read -p "リポジトリURL (例: https://github.com/myorg/repo.git): " REPO_URL
else
  REPO_URL="$1"
fi

# URL からリポジトリ名とオーナーを抽出
REPO_NAME=$(basename "$REPO_URL" .git)
REPO_OWNER=$(echo "$REPO_URL" | sed 's|https://github.com/||' | cut -d'/' -f1)

read -p "クローン先のディレクトリ (デフォルト: ~/) : " CLONE_DIR
CLONE_DIR=${CLONE_DIR:-~/}
PROJECT_DIR="$CLONE_DIR/$REPO_NAME"

echo ""
echo -e "${YELLOW}GitHub Personal Access Token (PAT) を入力してください${NC}"
echo "  発行方法: GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)"
echo "  スコープ: repo のみ"
echo ""
read -s -p "PAT (入力は非表示): " PAT
echo ""

if [ -z "$PAT" ]; then
  echo -e "${RED}エラー: PAT が入力されていません。${NC}"
  exit 1
fi

# GitHub ユーザー名を gh コマンドから取得（または手動入力）
if command -v gh &>/dev/null && gh auth status &>/dev/null 2>&1; then
  GITHUB_USER=$(gh api user --jq .login 2>/dev/null || echo "")
fi
if [ -z "$GITHUB_USER" ]; then
  read -p "GitHub ユーザー名 (PAT を発行したアカウント): " GITHUB_USER
fi

AUTHED_URL="https://$GITHUB_USER:$PAT@github.com/$REPO_OWNER/$REPO_NAME.git"

echo ""
echo -e "${BLUE}▶ リポジトリをクローン中...${NC}"
git clone "$REPO_URL" "$PROJECT_DIR"
cd "$PROJECT_DIR"

echo -e "${BLUE}▶ GitHub認証を設定中...${NC}"
git remote set-url origin "$AUTHED_URL"

echo -e "${BLUE}▶ 接続確認中...${NC}"
git push origin main --dry-run 2>&1 | grep -q "Everything up-to-date\|Would push" || git ls-remote origin HEAD > /dev/null

echo ""
echo -e "${GREEN}✅ セットアップ完了！${NC}"
echo ""
echo "  クローン先: $PROJECT_DIR"
echo ""
echo -e "${YELLOW}=== 業務ユーザーへの案内 ===${NC}"
echo ""
echo "  1. Claude Cowork アプリを開く"
echo "  2. 以下のフォルダを選択する:"
echo "     $PROJECT_DIR"
echo "  3. 「業務を自動化したいです」と話しかけるだけでOKです"
echo ""
