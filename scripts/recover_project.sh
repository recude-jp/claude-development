#!/bin/bash
# =============================================================================
# recover_project.sh
# リポジトリ作成済みの状態からクローン以降をやり直すリカバリスクリプト
# 使いどころ: new_project.sh でリポジトリ作成には成功したが、
#             PAT 入力・クローン・初期コミットに失敗したとき
# 実行場所: システムアドバイザーのPC
# =============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${BLUE}=== 業務自動化サポート：リカバリセットアップ ===${NC}"
echo -e "${YELLOW}リポジトリ作成済みの状態からクローン以降をやり直します${NC}"
echo ""

# --- デフォルト値の解決 ---
_DEFAULT_OWNER=${OWNER:-$(gh api user --jq '.login' 2>/dev/null || echo "")}
_DEFAULT_CLONE_DIR=${CLONE_DIR:-$HOME/Documents/Claude/Projects}

# --- 入力収集 ---
read -p "オーナー (GitHubユーザー名 or Organization) [${_DEFAULT_OWNER}] : " OWNER
OWNER=${OWNER:-$_DEFAULT_OWNER}
read -p "リポジトリ名 (例: yamada-sales-automation)                     : " NEW_REPO_NAME
read -p "業務ユーザーの名前                                              : " BIZ_USER_NAME
read -p "システムアドバイザーの名前・連絡先 (例: 鈴木 suzuki@example.com) : " ADVISOR_INFO
read -p "クローン先ディレクトリ [${_DEFAULT_CLONE_DIR}]                  : " INPUT_CLONE_DIR
CLONE_DIR=${INPUT_CLONE_DIR:-$_DEFAULT_CLONE_DIR}

NEW_REPO_FULL="$OWNER/$NEW_REPO_NAME"
PROJECT_DIR="$CLONE_DIR/$NEW_REPO_NAME"

# --- リポジトリの存在確認 ---
echo ""
echo -e "${BLUE}▶ リポジトリの存在を確認中...${NC}"
if ! gh repo view "$NEW_REPO_FULL" > /dev/null 2>&1; then
  echo -e "${RED}❌ リポジトリ $NEW_REPO_FULL が見つかりません。${NC}"
  echo "   new_project.sh からやり直してください。"
  exit 1
fi
echo -e "${GREEN}   ✓ $NEW_REPO_FULL を確認しました${NC}"

# --- クローン先の確認 ---
if [[ -d "$PROJECT_DIR" ]]; then
  echo ""
  echo -e "${YELLOW}⚠️  $PROJECT_DIR はすでに存在します。${NC}"
  read -p "   削除して再クローンしますか？ [y/N]: " RM_OK
  if [[ "$RM_OK" =~ ^[Yy]$ ]]; then
    rm -rf "$PROJECT_DIR"
    echo "   削除しました。"
  else
    echo "中断しました。"
    exit 1
  fi
fi

# --- PAT 入力 ---
echo ""
echo -e "${YELLOW}Fine-grained PAT を貼り付けてください${NC}"
echo "  （発行済みの場合はそのまま使えます。GitHub から再表示はできないため、"
echo "   紛失した場合は新しいトークンを発行してください）"
echo ""

GITHUB_USER=$(gh api user --jq .login)

while true; do
  read -s -p "トークンを貼り付けてください: " PAT
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

# --- 接続確認 ---
echo ""
echo -e "${BLUE}▶ トークンの接続確認中...${NC}"
echo "   GitHub ユーザー : $GITHUB_USER"
echo "   リポジトリ      : $NEW_REPO_FULL"
echo ""
GIT_LS_OUTPUT=$(git ls-remote "https://$GITHUB_USER:$PAT@github.com/$NEW_REPO_FULL.git" 2>&1)
GIT_LS_STATUS=$?
if [[ $GIT_LS_STATUS -ne 0 ]]; then
  echo -e "${RED}❌ 接続できませんでした。エラー内容:${NC}"
  echo "$GIT_LS_OUTPUT"
  echo ""
  echo "よくある原因:"
  echo "  - トークンのスコープが不足している（Contents: Read and Write が必要）"
  echo "  - リポジトリ名またはオーナーが間違っている"
  echo "  - トークンが対象リポジトリに紐付けられていない"
  exit 1
fi
echo -e "${GREEN}   ✓ 接続成功${NC}"

# --- クローン ---
echo -e "${BLUE}▶ クローン中...${NC}"
mkdir -p "$CLONE_DIR"
git clone "https://$GITHUB_USER:$PAT@github.com/$NEW_REPO_FULL.git" "$PROJECT_DIR"
cd "$PROJECT_DIR"

# --- ファイル整理済みか確認 ---
if [[ -f "README_for_business_user.md" ]]; then
  echo -e "${BLUE}▶ ファイルを整理中...${NC}"
  git rm README.md CHANGELOG.md
  git rm -r scripts/
  git mv README_for_business_user.md README.md

  echo -e "${BLUE}▶ README を更新中...${NC}"
  sed -i "" \
    "s/<!-- PROJECT_NAME -->/$NEW_REPO_NAME/g; \
     s/<!-- BUSINESS_USER_NAME -->/$BIZ_USER_NAME/g; \
     s/<!-- ADVISOR_INFO -->/$ADVISOR_INFO/g" \
    README.md

  echo -e "${BLUE}▶ コミット・プッシュ中...${NC}"
  git add -A
  git commit -m "docs: プロジェクト初期設定"
  git push origin main
else
  echo -e "${YELLOW}   ファイル整理は完了済みです。スキップします。${NC}"
fi

# --- 完了 ---
echo ""
echo -e "${GREEN}✅ リカバリ完了！${NC}"
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
