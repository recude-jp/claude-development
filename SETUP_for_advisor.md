# システムアドバイザー向け：プロジェクト開始から業務ユーザー引き渡しまでの手順

このファイルは**システムアドバイザーだけが読む**セットアップガイドです。
業務ユーザーへの引き渡し前に、以下の手順をすべて完了してください。

---

## 全体の流れ

```
Step 1: GitHubでテンプレートから新規リポジトリを作成
  ↓
Step 2: ローカルにクローン
  ↓
Step 3: テンプレート不要ファイルを削除・整理
  ↓
Step 4: README_for_business_user.md にプロジェクト情報を記入
  ↓
Step 5: 整理した状態をコミット・プッシュ
  ↓
Step 6: 業務ユーザーのPCにクローン
  ↓
Step 7: 業務ユーザーのPCにGitHub認証（HTTPS+PAT）を設定
  ↓
Step 8: 動作確認して業務ユーザーに引き渡す
```

---

## Step 1：テンプレートから新規リポジトリを作成

1. GitHub でこのテンプレートリポジトリを開く
2. **Use this template** → **Create a new repository** をクリック
3. 設定内容：
   - **Repository name**: プロジェクト名（例: `yamada-sales-automation`）
   - **Owner**: 適切なオーナー（個人またはOrganization）
   - **Visibility**: `Private`（社内業務データを扱うため原則プライベート）
4. **Create repository** をクリック

---

## Step 2：ローカルにクローン（システムアドバイザーのPC）

```bash
git clone https://github.com/<オーナー>/<リポジトリ名>.git
cd <リポジトリ名>
```

---

## Step 3：テンプレート不要ファイルを削除・整理

以下のファイルはテンプレート管理用のため、**プロジェクトリポジトリからは削除**してください。

| ファイル | 理由 |
|---|---|
| `CHANGELOG.md` | テンプレート自体の改訂履歴。プロジェクトには不要 |

```bash
git rm CHANGELOG.md
```

以下のファイルは**そのまま残す**ものです：

| ファイル | 用途 |
|---|---|
| `CLAUDE.md` | Claude への操作指示。プロセス全体を通して必要 |
| `SETUP_for_advisor.md` | 本ファイル。引き渡し後は削除しても可 |
| `README_for_business_user.md` | 業務ユーザーが最初に読むガイド |
| `01_requirements_brainstorm.md` | ステップ①のテンプレート |
| `02_basic_design.md` | ステップ②のテンプレート |

> `03_design_review_checklist.md` と `04_coding_instruction.md` はプロセス中に作成するため、現時点では不要です。

---

## Step 4：README_for_business_user.md にプロジェクト情報を記入

ファイル冒頭のメタ情報を埋めてください：

```
担当: （業務ユーザーの名前）
システムアドバイザー: （あなたの名前・連絡先）
```

業務ユーザーが困ったときに誰に連絡するか明記しておくと安心です。

---

## Step 5：整理した状態をコミット・プッシュ

```bash
git add -A
git commit -m "docs: プロジェクト初期設定（テンプレート不要ファイル削除）"
git push origin main
```

---

## Step 6：業務ユーザーのPCにクローン

業務ユーザーのPCで以下を実行します（システムアドバイザーが代わりに操作してOK）。

```bash
git clone https://github.com/<オーナー>/<リポジトリ名>.git
cd <リポジトリ名>
```

クローン先のフォルダパスを業務ユーザーに伝えておいてください。
Claude Cowork でそのフォルダを開く必要があります。

---

## Step 7：業務ユーザーのPCにGitHub認証（HTTPS+PAT）を設定

### 7-1：PAT を発行する（システムアドバイザーのGitHubアカウントで実施）

1. GitHub → 右上アイコン → **Settings**
2. 左メニュー最下部 **Developer settings** → **Personal access tokens** → **Tokens (classic)**
3. **Generate new token (classic)** をクリック
4. 設定：
   - **Note**: `<業務ユーザー名>-cowork` など
   - **Expiration**: 90日〜1年（プロジェクト期間に合わせて設定）
   - **Scopes**: `repo` のみチェック
5. **Generate token** → 表示されたトークンをコピーして安全に保管

> 業務ユーザー自身は GitHub アカウントを持つ必要はありません。

### 7-2：業務ユーザーのPCでリモートURLを変更する

```bash
cd <リポジトリのフォルダパス>

git remote set-url origin https://<GitHubユーザー名>:<PAT>@github.com/<オーナー>/<リポジトリ名>.git
```

**例：**

```bash
git remote set-url origin https://advisor-account:ghp_xxxxxxxxxxxxxxxxxxxx@github.com/myorg/yamada-sales-automation.git
```

設定確認：

```bash
git remote -v
# → https://advisor-account:ghp_xxx...@github.com/myorg/yamada-sales-automation.git と表示されればOK
```

---

## Step 8：動作確認して業務ユーザーに引き渡す

```bash
# 業務ユーザーのPCで push が通るか確認
git push origin main
```

エラーなく完了したら準備完了です。
業務ユーザーに以下を伝えてください：

1. **Claude Cowork を開いて、クローンしたフォルダを選択する**
2. **「業務を自動化したいです」と話しかけるだけでOK**
3. **困ったことがあればすぐ連絡する**（遠慮不要、それがこのプロセスの正式な進め方）

---

## PAT の期限切れ・再設定が必要なとき

業務ユーザーから「push できなくなった」と連絡が来た場合：

1. GitHub で新しい PAT を発行（Step 7-1）
2. 業務ユーザーのPCで `git remote set-url` を再実行（Step 7-2）

---

## トラブルシューティング

| エラー | 対処 |
|---|---|
| `remote: Repository not found.` | リポジトリ名・オーナー名のスペルミスを確認 |
| `could not read Username` | URL に `ユーザー名:PAT@` が含まれているか確認 |
| `403 Forbidden` | PAT の `repo` スコープ確認、有効期限切れでないか確認 |
| `push` できない | `git remote -v` でURLを再確認し、PATを再発行して設定し直す |
