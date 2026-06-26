# システムアドバイザー向け：プロジェクト開始手順

業務ユーザーが **Claude Cowork だけで** 作業できる環境を整えるのがアドバイザーの役割です。
以下の2つのスクリプトを順に実行すれば、業務ユーザーへの引き渡しまで完了します。

> **業務ユーザーはターミナルもGitHubも触りません。**
> セットアップが済んだら Cowork を開いて話しかけるだけです。

---

## 前提条件（アドバイザーのPCに必要）

- **GitHub CLI (`gh`)** がインストール済みでログイン済みであること
  ```bash
  gh auth status  # ログイン確認
  ```

---

## Step 1：新規リポジトリ作成（アドバイザーのPCで実行）

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
| アドバイザーの名前・連絡先 | `鈴木（suzuki@example.com）` |
| クローン先ディレクトリ | Enter でデフォルト（./） |

スクリプトが自動で行うこと：
- テンプレートから private リポジトリを作成
- クローン・不要ファイル削除（`README.md`、`CHANGELOG.md`、`scripts/`）
- `README_for_business_user.md` に担当者名を記入
- コミット・プッシュ

---

## Step 2：業務ユーザーPCのセットアップ（**業務ユーザーのPCで**アドバイザーが実行）

業務ユーザーのPCに移動またはリモート接続し、アドバイザーが以下を実行します。
**業務ユーザー自身が操作する必要はありません。**

```bash
bash setup_user_pc.sh https://github.com/<オーナー>/<リポジトリ名>.git
```

> Step 1 完了時に正確なコマンドが画面に表示されます。

スクリプトが自動で行うこと：
- リポジトリをクローン
- GitHub PAT（要事前発行）を使った HTTPS 認証を設定
- 接続確認（push テスト）

完了後、クローン先のフォルダパスが表示されます。
このパスを業務ユーザーに伝えてください。

### PAT の発行（Step 2 実行前に済ませる）

GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)

- **Scopes**: `repo` のみ
- **Expiration**: プロジェクト期間に合わせて設定（90日〜1年推奨）

> 業務ユーザーは GitHub アカウントを持つ必要はありません。
> PAT はアドバイザーの GitHub アカウントで発行します。

---

## Step 3：業務ユーザーへの引き渡し

以下を伝えるだけで完了です：

```
「Claude Cowork を開いて、このフォルダを選択してください」
  → <Step 2 完了時に表示されたフォルダパス>

「あとは「業務を自動化したいです」と話しかけるだけです」
```

---

## PAT の期限切れ時

業務ユーザーから「共有できなくなった」と連絡が来た場合、
新しい PAT を発行してアドバイザーが業務ユーザーのPCで以下を実行します：

```bash
cd <リポジトリフォルダ>
git remote set-url origin https://<GitHubユーザー名>:<新PAT>@github.com/<オーナー>/<リポジトリ名>.git
```

---

## スクリプトの詳細

- `scripts/new_project.sh` — リポジトリ作成・初期化（アドバイザーのPCで実行）
- `scripts/setup_user_pc.sh` — 業務ユーザーPC認証設定（業務ユーザーのPCでアドバイザーが実行）
