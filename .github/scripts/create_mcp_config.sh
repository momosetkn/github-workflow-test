#!/bin/bash

NOTION_KEY="$1"

cat > /tmp/mcp-config.json << EOF
{
  "mcpServers": {
    "notionApi": {
      "command": "npx",
      "args": ["-y", "@notionhq/notion-mcp-server"],
      "env": {
        "OPENAPI_MCP_HEADERS": "{\"Authorization\": \"Bearer $NOTION_KEY\", \"Notion-Version\": \"2022-06-28\" }"
      }
    }
  }
}
EOF