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

# --- デフォルト値の解決 ---
# gh CLI からログインユーザー名を取得してオーナーのデフォルトに使用
_DEFAULT_OWNER=${OWNER:-$(gh api user --jq '.login' 2>/dev/null || echo "")}
# クローン先は環境変数 CLONE_DIR → ~/Documents/Claude/Projects の順で解決
_DEFAULT_CLONE_DIR=${CLONE_DIR:-$HOME/Documents/Claude/Projects}

# --- 入力収集 ---
read -p "テンプレートリポジトリ [recude-jp/claude-development]  : " TEMPLATE_REPO
TEMPLATE_REPO=${TEMPLATE_REPO:-recude-jp/claude-development}
read -p "新しいリポジトリ名 (例: yamada-sales-automation)       : " NEW_REPO_NAME
read -p "オーナー (GitHubユーザー名 or Organization) [${_DEFAULT_OWNER}] : " OWNER
OWNER=${OWNER:-$_DEFAULT_OWNER}
read -p "業務ユーザーの名前                                      : " BIZ_USER_NAME
read -p "システムアドバイザーの名前・連絡先 (例: 鈴木 suzuki@example.com) : " ADVISOR_INFO
read -p "クローン先ディレクトリ [${_DEFAULT_CLONE_DIR}]         : " INPUT_CLONE_DIR
CLONE_DIR=${INPUT_CLONE_DIR:-$_DEFAULT_CLONE_DIR}

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

# 現在ログインしているGitHubユーザー名を取得
GITHUB_USER=$(gh api user --jq .login)

# --- リポジトリ作成 ---
echo ""
echo -e "${BLUE}▶ テンプレートから新規リポジトリを作成中...${NC}"
gh repo create "$NEW_REPO_FULL" --template "$TEMPLATE_REPO" --private
sleep 3

# --- PAT 発行を促してから入力 ---
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Fine-grained PAT を発行してください（このリポジトリ専用）${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  ブラウザで以下を開いてください:"
echo "  https://github.com/settings/personal-access-tokens/new"
echo ""
echo "  設定内容:"
echo "  ・Token name    : $NEW_REPO_NAME-cowork"
echo "  ・Expiration    : No expiration（このリポジトリ専用のため期限不要）"
echo "  ・Repository access: Only select repositories → $NEW_REPO_FULL"
echo "  ・Permissions   : Contents = Read and Write"
echo "                    Metadata = Read-only（自動付与）"
echo ""
echo "  ※ アクセスできるのは $NEW_REPO_FULL だけです（他のリポジトリには影響しません）"
echo ""
while true; do
  read -s -p "発行したトークンを貼り付けてください: " PAT
  echo ""
  if [[ -z "$PAT" ]]; then
    echo "  ⚠️  入力が空です。もう一度貼り付けてください。"
    continue
  fi
  PAT_LEN=${#PAT}
  PAT_PREVIEW="${PAT:0:8}...${PAT: -4}"
  echo "  → ${PAT_LEN}文字を受け取りました: ${PAT_PREVIEW}"
  read -p "  正しいですか？ [Y/n]: " PAT_OK
  [[ "$PAT_OK" =~ ^[Nn]$ ]] && { echo "  もう一度貼り付けてください。"; continue; }
  break
done

# --- クローン ---
echo ""
echo -e "${BLUE}▶ クローン中...${NC}"
git clone "https://$GITHUB_USER:$PAT@github.com/$NEW_REPO_FULL.git" "$PROJECT_DIR"
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
echo -e "${YELLOW}業務ユーザー（$BIZ_USER_NAME）にそのまま送ってください：${NC}"
echo ""
echo "----ここからコピー----"
echo ""
echo "【手順】"
echo "① Claude Cowork を開く"
echo "② 左メニューの「プロジェクト」を選び、右上の「新規プロジェクト」を押す"
echo "③ ダイアログに以下を入力して「作成」を押す："
echo "   ・名前: 自由につけてOKです。わかりやすくやる気が湧いてくる名前を！"
echo "          （例: $NEW_REPO_NAME）"
echo "   ・手順: 空白のままでOK"
echo "   ・プロジェクトの場所: 以下のパスを入力してください"
echo "     $CLONE_DIR/$NEW_REPO_NAME"
echo "④ プロジェクトを開いて、下の「---」内のメッセージをチャットに貼り付けて送信する"
echo "   ※ プロジェクトを作成しただけでは何も起きません。必ずチャットに送ってください。"
echo ""
echo "--- チャットに貼り付けるメッセージ ---"
echo "GitHubリポジトリのセットアップをお願いします。"
echo "以下のコマンドを順番に実行してください："
echo ""
echo "cd \$(pwd)/mnt/$NEW_REPO_NAME"
echo "git init"
echo "git remote add origin https://$GITHUB_USER:$PAT@github.com/$NEW_REPO_FULL.git"
echo "git pull origin main"
echo ""
echo "完了したら \$(pwd)/mnt/$NEW_REPO_NAME/CLAUDE.md を読み込み、"
echo "その指示に従って作業を進めてください。"
echo "---"
echo ""
echo "----ここまで----"
echo ""
echo "  ※ アクセスキーが含まれます。メールや安全なチャットで送ってください。"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
