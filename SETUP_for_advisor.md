# システムアドバイザー向け：業務ユーザーPCの初期セットアップ手順

業務ユーザーが Claude Cowork から GitHub へ push できるよう、
**最初の一回だけ**このセットアップを業務ユーザーのPCで行ってください。

---

## 前提

- 業務ユーザーのPCにはすでにリポジトリがクローンされている
- システムアドバイザーが GitHub の PAT（Personal Access Token）を発行する

---

## Step 1：GitHub で PAT を発行する（システムアドバイザーが実施）

1. GitHub にログインし、右上のアイコン → **Settings** を開く
2. 左メニュー最下部の **Developer settings** → **Personal access tokens** → **Tokens (classic)** を開く
3. **Generate new token (classic)** をクリック
4. 設定内容：
   - **Note**（名前）: `業務ユーザー名-cowork` など任意
   - **Expiration**: 必要な期間を設定（90日〜1年推奨）
   - **Scopes**: `repo` にチェック（これだけでOK）
5. **Generate token** をクリックし、表示されたトークン文字列をコピーして安全な場所に保管する
   （このページを閉じると二度と表示されません）

---

## Step 2：業務ユーザーのPCでリモートURLを設定する（システムアドバイザーが実施）

業務ユーザーのPCのターミナルで以下を実行します。

```bash
cd <リポジトリのフォルダパス>

# 現在のリモートURLを確認
git remote -v

# HTTPSにPATを埋め込んだURLに変更（以下の3箇所を置き換える）
git remote set-url origin https://<GitHubユーザー名>:<PAT>@github.com/<リポジトリのオーナー>/<リポジトリ名>.git
```

### 例

```bash
git remote set-url origin https://recude-jp:ghp_xxxxxxxxxxxxxxxxxxxx@github.com/recude-jp/claude-development.git
```

設定が正しいか確認：

```bash
git remote -v
# → https://recude-jp:ghp_xxx...@github.com/recude-jp/claude-development.git と表示されればOK
```

---

## Step 3：動作確認

```bash
git push origin main
```

エラーなく完了すれば設定完了です。
以後、業務ユーザーは Claude Cowork から「共有してください」と言うだけで push できます。

---

## 注意事項

- PAT は `.git/config` に保存されますが、このファイルは `.gitignore` 対象外であるため  
  **絶対に `git add .git/config` しないでください**（通常の `git add` では追跡されません）
- PAT の有効期限が切れた場合は、Step 1〜2 を再実施してください
- PAT を紛失・漏洩した場合は GitHub の設定画面から即座に無効化してください

---

## トラブルシューティング

| エラー | 対処 |
|---|---|
| `remote: Repository not found.` | リポジトリ名・オーナー名のスペルミスを確認 |
| `could not read Username` | URL に `ユーザー名:PAT@` が含まれているか確認 |
| `403 Forbidden` | PAT の `repo` スコープが有効か、有効期限切れでないか確認 |
| `push` が通らない | `git remote -v` でURLを再確認し、PATを再発行して設定し直す |
