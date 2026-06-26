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
| テンプレートリポジトリ | `myorg/automation-template` |
| 新しいリポジトリ名 | `yamada-sales-automation` |
| オーナー | `myorg` |
| 業務ユーザーのGitHubユーザー名 | `yamada-taro` |
| 業務ユーザーの表示名 | `山田 太郎` |
| アドバイザーの名前・連絡先 | `鈴木（suzuki@example.com）` |
| PAT（push用） | `ghp_xxxxxxxxxxxx`（事前に発行しておく） |

スクリプトが自動で行うこと：
- テンプレートから private リポジトリを作成
- `README_for_business_user.md` を `README.md` にリネーム（GitHub で表示される）
- テンプレート不要ファイル（旧 `README.md`、`CHANGELOG.md`、`scripts/`）を削除
- `README.md` に担当者名を記入
- コミット・プッシュ
- 業務ユーザーをコラボレーターとして招待

### PAT の発行方法

GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)

- **Scopes**: `repo` のみ
- **Expiration**: プロジェクト期間に合わせて設定（90日〜1年推奨）

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

## 業務ユーザーが行う初回セットアップ（参考）

業務ユーザーは受け取った内容をもとに以下を行います：

1. Claude Cowork を開く（フォルダ選択不要）
2. 「セットアップをお願いします」と話しかける
3. Claude が URL とアクセスキーを聞いてくるので入力する
4. Claude が自動でクローン＆認証設定を実行し、フォルダパスを伝えてくれる
5. Cowork のフォルダ選択で Claude が指定したフォルダを開いたら完了

以降は業務ユーザーが Cowork だけで作業します。アドバイザーは GitHub で進捗を確認できます。

---

## PAT の期限切れ時

業務ユーザーから「共有できなくなった」と連絡が来た場合：

1. 新しい PAT を発行
2. 業務ユーザーに送る
3. 業務ユーザーは Cowork で「アクセスキーを更新したいです」と伝える
4. Claude が `git remote set-url` を実行して更新完了
