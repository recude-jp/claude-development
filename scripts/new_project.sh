#!/bin/bash
# =============================================================================
# new_project.sh
# テンプレートから新規プロジェクトリポジトリを作成するセットアップスクリプト
# 実行場所: システムアドバイザーのPC
# 前提: gh コマンド (GitHub CLI) がインストール済みでログイン済みであること
# =============================================================================

set -e

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
read -p "業務ユーザーの名前                                      : " BIZ_USER_NAME
read -p "システムアドバイザーの名前・連絡先                      : " ADVISOR_INFO
read -p "クローン先ディレクトリ (デフォルト: ./)               : " CLONE_DIR
CLONE_DIR=${CLONE_DIR:-.}

NEW_REPO_FULL="$OWNER/$NEW_REPO_NAME"
CLONE_URL="https://github.com/$NEW_REPO_FULL.git"
PROJECT_DIR="$CLONE_DIR/$NEW_REPO_NAME"

echo ""
echo -e "${YELLOW}以下の内容でセットアップを開始します:${NC}"
echo "  リポジトリ    : https://github.com/$NEW_REPO_FULL (private)"
echo "  業務ユーザー  : $BIZ_USER_NAME"
echo "  アドバイザー  : $ADVISOR_INFO"
echo ""
read -p "よろしいですか？ [y/N]: " CONFIRM
[[ "$CONFIRM" =~ ^[Yy]$ ]] || { echo "中断しました。"; exit 1; }

# --- PAT 入力（push 用） ---
echo ""
echo -e "${YELLOW}業務ユーザーが Cowork から push するための PAT を入力してください${NC}"
echo "  GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)"
echo "  スコープ: repo のみ / 有効期限: プロジェクト期間に合わせて設定"
echo ""
read -s -p "PAT: " PAT
echo ""
[[ -z "$PAT" ]] && { echo "PAT が未入力です。中断しました。"; exit 1; }

# 現在ログインしているGitHubユーザー名を取得
GITHUB_USER=$(gh api user --jq .login)

# --- リポジトリ作成 ---
echo ""
echo -e "${BLUE}▶ テンプレートから新規リポジトリを作成中...${NC}"
gh repo create "$NEW_REPO_FULL" --template "$TEMPLATE_REPO" --private
sleep 3

# --- クローン ---
echo -e "${BLUE}▶ クローン中...${NC}"
git clone "$CLONE_URL" "$PROJECT_DIR"
cd "$PROJECT_DIR"

# --- テンプレート不要ファイルを削除し、README をリネーム ---
echo -e "${BLUE}▶ ファイルを整理中...${NC}"
git rm README.md CHANGELOG.md
git rm -r scripts/
git mv README_for_business_user.md README.md

# --- README にプロジェクト情報を記入 ---
echo -e "${BLUE}▶ README を更新中...${NC}"
sed -i "" \
  "s/<!-- PROJECT_NAME -->/$NEW_REPO_NAME/g; \
   s/<!-- BUSINESS_USER_NAME -->/$BIZ_USER_NAME/g; \
   s/<!-- ADVISOR_INFO -->/$ADVISOR_INFO/g" \
  README.md

# --- コミット・プッシュ ---
echo -e "${BLUE}▶ コミット・プッシュ中...${NC}"
git add -A
git commit -m "docs: プロジェクト初期設定"
git push origin main

# --- 完了 ---
echo ""
echo -e "${GREEN}✅ セットアップ完了！${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${YELLOW}業務ユーザー（$BIZ_USER_NAME）に以下を伝えてください：${NC}"
echo ""
echo "  📎 リポジトリURL（README を確認してもらう）:"
echo "     https://github.com/$NEW_REPO_FULL"
echo ""
echo "  🔑 アクセスキー（初回セットアップで入力）:"
echo "     $PAT"
echo ""
echo "  ※ アクセスキーはメールや安全なチャットで送ってください。"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
