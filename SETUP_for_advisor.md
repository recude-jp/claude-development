# システムアドバイザー向け：プロジェクト開始手順

スクリプト1本を実行するだけで、業務ユーザーへの引き渡しまで完了します。
**業務ユーザーのPCへのアクセスは不要です。**

---

## 前提条件

### アドバイザーのPCに必要なもの

- **GitHub CLI (`gh`)** がインストール済みでログイン済みであること
  ```bash
  gh auth status
  ```

### このテンプレートリポジトリ自体の設定（初回のみ）

このリポジトリが GitHub 上でテンプレートとして設定されていないと `new_project.sh` が失敗します。
一度だけ以下を実行してください：

```bash
gh api repos/recude-jp/claude-development -X PATCH -f is_template=true
```

または GitHub の画面で：**Settings → General → "Template repository" をチェック**

> **業務ユーザーは GitHub アカウント不要、GitHub Desktop 不要、ターミナル不要です。**
> 業務ユーザーの作業はすべて Claude Cowork の中だけで完結します。

---

## Step 1：新規リポジトリ作成

```bash
bash scripts/new_project.sh
```

対話形式で以下を入力します：

| 入力項目 | 例 |
|---|---|
| テンプレートリポジトリ | Enter でデフォルト（`recude-jp/claude-development`）|
| 新しいリポジトリ名 | `yamada-sales-automation` |
| オーナー | `myorg` |
| 業務ユーザーの名前 | `山田 太郎` |
| アドバイザーの名前・連絡先 | `鈴木（suzuki@example.com）` |

スクリプトが自動で行うこと：
- テンプレートから private リポジトリを作成
- PAT 発行の案内を表示（リポジトリ作成後に一時停止）
- PAT を入力するとクローン・ファイル整理・コミット・プッシュまで完了

### PAT の発行方法（スクリプト実行中に案内されます）

リポジトリ作成後にスクリプトが一時停止するので、以下の手順で発行してください：

GitHub → Settings → Developer settings → Personal access tokens → **Fine-grained tokens** → Generate new token

| 設定項目 | 値 |
|---|---|
| Token name | `<リポジトリ名>-cowork`（例: `yamada-sales-automation-cowork`）|
| Expiration | **No expiration** を推奨（理由は下記）|
| Repository access | **Only select repositories** → 作成したリポジトリのみ |
| Contents | **Read and Write** |
| Metadata | Read-only（自動付与）|

> **Fine-grained PAT はそのリポジトリ専用です。** アカウント上の他のリポジトリにはアクセスできません。
> No expiration を推奨する理由：アクセス範囲がこのリポジトリ1つに限定されているため漏洩時の影響が小さく、期限切れによる業務ユーザーの作業停止リスクを避けられます。プロジェクト終了時はリポジトリを削除すれば PAT は事実上無効になります。

---

## Step 2：業務ユーザーへの通知

スクリプト完了後に表示される内容をそのまま業務ユーザーに送ってください：

```
📎 リポジトリURL（README を確認してもらう）:
   https://github.com/<オーナー>/<リポジトリ名>

🔑 アクセスキー（初回セットアップで入力）:
   ghp_xxxxxxxxxxxx
```

> アクセスキー（PAT）はメールや安全なチャットで送ってください。

---

## ⚠️ 業務ユーザーがウイルス対策ソフトを使っている場合

Claude が作成する Markdown ファイル（要件定義書・設計書など）が、ウイルス対策ソフトの誤検知で削除されることがあります。**特に Norton は `MD:HttpRequest-inf [Susp]` として誤検知します。**

業務ユーザーに事前に伝えてください：

> `~/Documents/Claude/Projects/` フォルダをウイルス対策ソフトの除外リストに追加してください。
> Norton の場合: 設定 → ウイルス対策 → スキャンの除外 → フォルダを追加

---

## 業務ユーザーが行う初回セットアップ（参考）

業務ユーザーは受け取ったメッセージをもとに以下を行います：

1. Claude Cowork を開く（プロジェクト・フォルダ選択不要）
2. スクリプト完了時に表示された「---」内のメッセージをそのまま貼り付けて送信する
3. Claude が自動でクローン＆認証設定を実行し、プロジェクト作成の手順を案内してくれる
4. 「新規プロジェクトを開始」で Claude が指示した内容（名前・場所）を入力して「作成」を押す

以降は業務ユーザーが Cowork のプロジェクトを開くだけで作業できます。アドバイザーは GitHub で進捗を確認できます。

---

## セットアップが途中で失敗した場合

リポジトリ作成には成功したが PAT 入力・クローン・初期コミットに失敗した場合は、リカバリスクリプトを使ってください：

```bash
bash scripts/recover_project.sh
```

- リポジトリの再作成は行いません（作成済みのリポジトリをそのまま使います）
- PAT 入力後に文字数と先頭/末尾を表示して確認できます
- クローン前に接続確認を行い、失敗したらその場でエラーを表示します

---

## PAT を再発行したい場合

No expiration を推奨しているため通常は不要ですが、セキュリティ上の理由で無効化したい場合：

1. GitHub → Settings → Developer settings → Fine-grained tokens → 該当トークンを Revoke
2. 新しい PAT を発行して業務ユーザーに送る
3. 業務ユーザーは Cowork で「アクセスキーを更新したいです」と伝える
4. Claude が `git remote set-url` を実行して更新完了
