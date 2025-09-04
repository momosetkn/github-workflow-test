# GitHub Actions Paths Filter Sample

このサンプルは `dorny/paths-filter` アクションを使用して、変更されたファイルに基づいて条件付きでジョブを実行する方法を示しています。

## 構成

### ディレクトリ構造
```
src/
├── backend/
│   └── app.py          # バックエンドサンプルファイル
└── frontend/
    ├── index.html      # フロントエンドサンプルファイル
    └── app.js          # JavaScript ファイル
```

### ワークフロー
`.github/workflows/paths-filter-sample.yml` には以下のジョブが含まれています：

1. **changes**: ファイルの変更を検出し、バックエンドまたはフロントエンドに変更があったかを判定
2. **deploy-backend**: `src/backend/**` に変更があった場合のみ実行
3. **deploy-frontend**: `src/frontend/**` に変更があった場合のみ実行

## 使用方法

### テスト方法

1. **バックエンドの変更をテスト**:
   ```bash
   # バックエンドファイルを変更
   echo "# Updated backend" >> src/backend/app.py
   git add src/backend/app.py
   git commit -m "Update backend"
   git push
   ```

2. **フロントエンドの変更をテスト**:
   ```bash
   # フロントエンドファイルを変更  
   echo "<!-- Updated frontend -->" >> src/frontend/index.html
   git add src/frontend/index.html
   git commit -m "Update frontend"
   git push
   ```

3. **両方の変更をテスト**:
   ```bash
   # 両方のディレクトリを変更
   echo "print('Updated')" >> src/backend/app.py
   echo "console.log('Updated');" >> src/frontend/app.js
   git add src/backend/ src/frontend/
   git commit -m "Update both backend and frontend"
   git push
   ```

## 期待される動作

- `src/backend/**` のみ変更: `deploy-backend` ジョブのみ実行
- `src/frontend/**` のみ変更: `deploy-frontend` ジョブのみ実行  
- 両方のディレクトリを変更: 両方のデプロイジョブが実行
- どちらも変更なし: デプロイジョブは実行されない

## カスタマイズ

フィルターパターンを変更して、他のディレクトリや拡張子に対応できます：

```yaml
filters: |
  docs:
    - 'docs/**'
    - '*.md'
  tests:
    - 'tests/**'
    - '**/*test.py'
```