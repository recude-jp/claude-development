# システムアドバイザー向け：プロジェクト開始手順

スクリプト1本を実行するだけで、業務ユーザーへの引き渡しまで完了します。
**業務ユーザーのPCへのアクセスは不要です。**

---

## 前提条件（アドバイザーのPCに必要）

- **GitHub CLI (`gh`)** がインストール済みでログイン済みであること
  ```bash
  gh auth status
  ```
- 業務ユーザーが **GitHub アカウントを持っていること**
  （無料アカウントで可。まだの場合は https://github.com/signup で作成してもらう）

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

業務ユーザーは受け取ったリポジトリURLを開き、README.md の手順に沿って進めます：

1. GitHub Desktop をインストールしてサインイン
2. リポジトリをクローン
3. Claude Cowork でフォルダを開く
4. 「セットアップをお願いします」と話しかける → アクセスキーを入力
5. 「設定が完了しました」と表示されたら完了

以降は業務ユーザーが Cowork だけで作業します。アドバイザーは GitHub で進捗を確認できます。

---

## PAT の期限切れ時

業務ユーザーから「共有できなくなった」と連絡が来た場合：

1. 新しい PAT を発行
2. 業務ユーザーに送る
3. 業務ユーザーは Cowork で「アクセスキーを更新したいです」と伝える
4. Claude が `git remote set-url` を実行して更新完了
