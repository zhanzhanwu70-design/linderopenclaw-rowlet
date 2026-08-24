#!/bin/bash
# Wiki Search Script
# 用法：./search.sh <關鍵字>

SEARCH_DIR="/home/amr/.openclaw/workspace-rowlet/ai-agent-wiki/wiki"

if [ -z "$1" ]; then
    echo "用法：$0 <關鍵字>"
    exit 1
fi

echo "=== Wiki 搜尋結果 ==="
echo "關鍵字：$1"
echo ""

# 基本 grep 搜尋
echo "--- Markdown 內容中 ---"
grep -rn -i "$1" "$SEARCH_DIR"/*.md --exclude="index.md" --exclude="log.md" | head -20

echo ""
echo "--- 標題中 ---"
grep -l "# $1" "$SEARCH_DIR"/*.md 2>/dev/null || echo "無直接標題 match"

echo ""
echo "--- Tag 中 ---"
grep -l "tags:.*$1" "$SEARCH_DIR"/*.md 2>/dev/null || echo "無 tag match"

echo ""
echo "使用 qmd 可獲得更精確的向量搜尋結果"
