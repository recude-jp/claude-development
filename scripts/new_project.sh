#!/bin/bash
# =============================================================================
# new_project.sh
# テンプレートから新規プロジェクトリポジトリを作成するセットアップスクリプト
# 実行場所: システムアドバイザーのPC
# 前提: gh コマンド (GitHub CLI) がインストール済みでログイン済みであること
# =============================================================================

set -e

# --- カラー出力 ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${BLUE}=== 業務自動化サポート：新規プロジェクトセットアップ ===${NC}"
echo ""

# --- 入力収集 ---
read -p "テンプレートリポジトリ (例: myorg/automation-template) : " TEMPLATE_REPO
read -p "新しいリポジトリ名 (例: yamada-sales-automation)       : " NEW_REPO_NAME
read -p "オーナー (GitHubユーザー名 or Organization)            : " OWNER
read -p "業務ユーザーの名前                                      : " BUSINESS_USER_NAME
read -p "システムアドバイザーの名前・連絡先                      : " ADVISOR_INFO
read -p "クローン先のディレクトリ (デフォルト: ./)              : " CLONE_DIR
CLONE_DIR=${CLONE_DIR:-.}

NEW_REPO_FULL="$OWNER/$NEW_REPO_NAME"
CLONE_URL="https://github.com/$NEW_REPO_FULL.git"
PROJECT_DIR="$CLONE_DIR/$NEW_REPO_NAME"

echo ""
echo -e "${YELLOW}以下の内容でセットアップを開始します:${NC}"
echo "  リポジトリ  : https://github.com/$NEW_REPO_FULL (private)"
echo "  業務ユーザー: $BUSINESS_USER_NAME"
echo "  アドバイザー: $ADVISOR_INFO"
echo "  クローン先  : $PROJECT_DIR"
echo ""
read -p "よろしいですか？ [y/N]: " CONFIRM
[[ "$CONFIRM" =~ ^[Yy]$ ]] || { echo "中断しました。"; exit 1; }

# --- リポジトリ作成 ---
echo ""
echo -e "${BLUE}▶ テンプレートから新規リポジトリを作成中...${NC}"
gh repo create "$NEW_REPO_FULL" --template "$TEMPLATE_REPO" --private

# GitHub 側の処理が完了するまで少し待つ
sleep 3

# --- クローン ---
echo -e "${BLUE}▶ クローン中...${NC}"
git clone "$CLONE_URL" "$PROJECT_DIR"
cd "$PROJECT_DIR"

# --- テンプレート不要ファイルを削除 ---
echo -e "${BLUE}▶ テンプレート不要ファイルを削除中...${NC}"
git rm README.md CHANGELOG.md
git rm -r scripts/

# --- README_for_business_user.md にプロジェクト情報を記入 ---
echo -e "${BLUE}▶ README_for_business_user.md を更新中...${NC}"
sed -i "" \
  "s/<!-- BUSINESS_USER_NAME -->/$BUSINESS_USER_NAME/g; \
   s/<!-- ADVISOR_INFO -->/$ADVISOR_INFO/g" \
  README_for_business_user.md

# --- コミット・プッシュ ---
echo -e "${BLUE}▶ コミット・プッシュ中...${NC}"
git add -A
git commit -m "docs: プロジェクト初期設定（テンプレート不要ファイル削除）"
git push origin main

# --- 完了・次のステップ案内 ---
echo ""
echo -e "${GREEN}✅ リポジトリの準備完了！${NC}"
echo "   https://github.com/$NEW_REPO_FULL"
echo ""
echo -e "${YELLOW}=== 次のステップ：業務ユーザーのPCで setup_user_pc.sh を実行してください ===${NC}"
echo ""
echo "  以下の情報が必要です："
echo "  ・リポジトリURL : $CLONE_URL"
echo "  ・GitHub PAT    : GitHub → Settings → Developer settings → Personal access tokens"
echo "                    （repo スコープのみ、有効期限はプロジェクト期間に合わせて設定）"
echo ""
echo "  業務ユーザーのPCで:"
echo "    bash setup_user_pc.sh $CLONE_URL"
echo ""
