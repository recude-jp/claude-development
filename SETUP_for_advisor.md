# システムアドバイザー向け：プロジェクト開始手順

セットアップはスクリプトで自動化されています。
`scripts/` フォルダの2本のスクリプトを順に実行するだけで完了します。

---

## 前提条件

- システムアドバイザーのPCに **GitHub CLI (`gh`)** がインストール済みでログイン済みであること
  ```bash
  gh auth status  # ログイン確認
  ```
- このテンプレートリポジトリへのアクセス権があること

---

## Step 1：新規リポジトリ作成（システムアドバイザーのPCで実行）

```bash
bash scripts/new_project.sh
```

対話形式で以下を入力します：

| 入力項目 | 例 |
|---|---|
| テンプレートリポジトリ | `myorg/automation-template` |
| 新しいリポジトリ名 | `yamada-sales-automation` |
| オーナー | `myorg` |
| 業務ユーザーの名前 | `山田 太郎` |
| システムアドバイザーの名前・連絡先 | `鈴木（suzuki@example.com）` |
| クローン先ディレクトリ | `./` (Enterでデフォルト) |

スクリプトが以下を自動で行います：
- テンプレートから private リポジトリを作成
- クローン
- テンプレート不要ファイル（`README.md`、`CHANGELOG.md`、`scripts/`）を削除
- `README_for_business_user.md` に担当者名を記入
- コミット・プッシュ

---

## Step 2：業務ユーザーPCのセットアップ（業務ユーザーのPCで実行）

業務ユーザーのPCに移動し、Step 1 完了時に表示されたリポジトリURLを使って実行します。

```bash
bash setup_user_pc.sh https://github.com/<オーナー>/<リポジトリ名>.git
```

> Step 1 のスクリプト完了時に正確なコマンドが表示されます。

スクリプトが以下を自動で行います：
- リポジトリをクローン
- GitHub PAT を使った HTTPS 認証を設定（PAT 入力を求められます）
- 接続確認
- 業務ユーザーへの案内メッセージを表示

> **PAT の発行**: Step 2 実行前に GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic) で `repo` スコープのトークンを発行してください。業務ユーザー自身は GitHub アカウント不要です。

---

## 完了後

業務ユーザーに以下だけ伝えてください：

1. **Claude Cowork を開いて、クローンされたフォルダを選択する**
2. **「業務を自動化したいです」と話しかけるだけでOK**

---

## PAT の期限切れ時

業務ユーザーから「共有できなくなった」と連絡が来た場合、
新しい PAT を発行して業務ユーザーのPCで以下を実行します：

```bash
cd <リポジトリフォルダ>
git remote set-url origin https://<GitHubユーザー名>:<新しいPAT>@github.com/<オーナー>/<リポジトリ名>.git
```

---

## スクリプトの詳細

詳細な処理内容は各スクリプトのコメントを参照してください：

- `scripts/new_project.sh` — リポジトリ作成・初期化
- `scripts/setup_user_pc.sh` — 業務ユーザーPC認証設定
