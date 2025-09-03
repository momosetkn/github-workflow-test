#!/bin/bash
set -e

# Read entire stdin safely
body="$(cat)"
echo "Comment body: $body"

# Extract content after @claude
prompt="${body#*@claude}"

# 空文字ならデフォルト値を設定
if [ -z "$prompt" ]; then
  prompt="このプルリクエストをレビューしてください"
fi

# 以下はそのまま
comments=$(curl -sSL -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "$ISSUE_COMMENTS_URL" || echo '[]')

if [[ "$comments" != '[]' ]]; then
  all_bodies=$(echo "$comments" | jq -r '.[]?.body? // empty')
  notion_urls=$(echo "$all_bodies" | grep -o 'https://www.notion.so[^ )]*' | sort -u || echo '')

  if [ -n "$notion_urls" ]; then
    notion_context="Related Notion pages:"
    while IFS= read -r url; do
      notion_context="${notion_context}
- ${url}"
    done <<< "$notion_urls"

    prompt="[Use NotionMcp]
${notion_context}

${prompt}"
  fi
fi

echo "Processed prompt: $(echo "$prompt" | tr '\n' ' ' | cut -c 1-100)..."

{
  echo 'prompt<<EOF'
  printf '%s\n' "$prompt" | tr -d '\r'
  echo 'EOF'
} >> "$GITHUB_OUTPUT"
