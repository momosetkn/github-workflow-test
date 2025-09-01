#!/bin/bash

body="$1"
echo "Comment body: $body"
prompt="${body#*@claude}"

# 空文字ならデフォルト値を設定
if [ -z "$prompt" ]; then
  prompt="このプルリクエストをレビューしてください"
fi

# すべての過去コメントから Notion URL を抽出
# すべての過去コメントを取得
comments=$(curl -sSL -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "$ISSUE_COMMENTS_URL")

echo "$comments"
all_bodies=$(echo "$comments" | jq -r '.[]?.body? // empty')
notion_urls=$(echo "$all_bodies" | grep -o 'https://www.notion.so[^ )]*' | sort -u)

if [ -n "$notion_urls" ]; then
  notion_context="Related Notion pages:"
  while IFS= read -r url; do
notion_context="$notion_context
- $url"
  done <<< "$notion_urls"
  
prompt="[Use NotionMcp]
$notion_context

$prompt"
fi

echo "$prompt"

# 改行を変換
{
  echo 'prompt<<EOF'
  printf '%s\n' "$prompt" | tr -d '\r'
  echo 'EOF'
} >> $GITHUB_OUTPUT