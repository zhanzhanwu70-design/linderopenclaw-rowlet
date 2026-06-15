# agent.md — LLM Wiki 使用指南

## Wiki 位置
- **Root**: `/home/node/.openclaw/workspace/llm-wiki`
- **Wiki 層**: `/home/node/.openclaw/workspace/llm-wiki/wiki/`
- **Raw 層**: `/home/node/.openclaw/workspace/llm-wiki/wiki/raw/`
- **索引**: `wiki/index.md`
- **維護日誌**: `wiki/log.md`

## 第一原則：先查 Wiki，再回答或搜尋

回答任何問題前，先用 graphify 查 wiki：

```bash
cd /home/node/.openclaw/workspace/llm-wiki && npx graphifyy query "<問題>" --budget 1500
```

只有當 wiki 確認沒有相關內容時，才去網路搜尋或回答。

---

## Wiki 結構

| 目錄 | 用途 |
|------|------|
| `concepts/` | 102 HC 概念、Agent Handoff/Prototype Skill、OCR 自駁迴路、abstraction 等核心概念 |
| `topics/` | PTCGP 牌組分析、歷史（秦朝、甲午戰爭、明朝）、AI Agent 技術 |
| `sources/` | 論文摘要、YouTube 影片逐字稿存檔、簡報素材 |
| `projects/` | ELLE WS、Graphify、OpenClaw 研究、Hermes Agent、TalkMateAI、Typeless |
| `people/` | 歷史人物（李世民、李鴻章、孫中山等）、Matt Pocock |
| `maps/` | 政治歷史地圖、ELLE WS Functions/Hardware/Tools、Code 與 Agent 地圖 |
| `inbox/` | 杜月笙、秦朝補充筆記、國家能力、Obsidian+AI 工作流 |
| `raw/` | 程式碼、PTCG 牌組 raw 資料、people/projects 備份（不可修改） |
| `skills/` | Linder's Skill |
| `synthesis/` | MattPocock Skills、Minerva HC Thinking、Agent Skill Architecture |

---

## Graphify 查詢技巧

### 基本查詢
```bash
cd /home/node/.openclaw/workspace/llm-wiki && npx graphifyy query "<問題>" --budget 1500
```

### 深度查詢（追蹤特定路徑）
```bash
npx graphifyy query "<問題>" --dfs --budget 1500
```

### 查兩概念間的最短路徑
```bash
npx graphifyy path "概念A" "概念B"
```

### 全面了解某主題
```bash
npx graphifyy query "wiki overview: what topics, sources, projects exist" --budget 2000
```

---

## 新增內容到 Wiki

### 流程
1. 先建立 `raw/` 備份（不可修改的原始資料）
2. 建立 `wiki/` 層面的 `.md` 檔案
3. 更新 `wiki/index.md`（新增重要頁面時）
4. 追加條目到 `wiki/log.md`

### 頁面類型（schema/page-types.md）
- `source` — 外部來源（論文、YouTube、網站）
- `concept` — 概念定義
- `topic` — 主題
- `project` — 專案
- `people` — 人物
- `synthesis` — 綜合分析

### 標準 Frontmatter
```markdown
---
type: source
title: "標題"
description: "一句話描述"
source: "URL"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
tags: ["tag1", "tag2"]
---
```

---

## 處理外部來源（YouTube 影片、GitHub 等）

### YouTube 影片處理流程
使用 `video-processing` skill（已建立）：

1. **下載**：`/tmp/yt-dlp -x --audio-format wav --audio-quality 0 -o "output.webm" "URL"`
2. **轉換**：`/tmp/ffmpeg-bin -i "input.webm" -ar 16000 -ac 1 -c:a pcm_s16le "output.wav"`
3. **轉錄**：`/home/node/.openclaw/local/bin/whispercpp-transcribe "output.wav"`
4. **存 raw**：`raw/video/youtube-YYYYMMDD/`
5. **寫 wiki source**：建立 `wiki/sources/` 條目

### GitHub 專案處理流程
1. 抓取 README + 關鍵內容
2. 存至 `raw/projects/<repo-name>/`
3. 建立 `wiki/projects/<repo-name>.md`
4. 視需要建立 `wiki/people/<author>.md`

---

## MattPocock Skills 的核心概念

### CONTEXT.md（共享語言文件）
- 將專案術語壓縮成精確的領域語言
- 放在專案根目錄
- 範例：`materialization cascade` = 「當 lesson 被設定為真實時觸發的連鎖反應」

### 四大失敗模式對應
| 問題 | 解法 |
|------|------|
| Agent 沒做你想要的事 | `/grill-me` 或 `/grill-with-docs` |
| Agent 太冗長 | 建立 CONTEXT.md |
| Code 不 work | `/tdd` + `/diagnose` |
| 程式碼變成一團泥 | `/improve-codebase-architecture` + `/zoom-out` |

---

## 不可做的事情

1. **不要修改 `raw/`** — 除非使用者明確要求
2. **不要複製機密內容** — 從 `raw/secrets/` 取用需明確授權
3. **不要在 wiki 回答前跳過 graphify 查詢**

---

## 維護日誌格式

每次對 wiki 有意義的更動後，追加到 `wiki/log.md`：
```markdown
## YYYY-MM-DD
- 動作描述
- 涉及的檔案
```

---

## 相關 Skills

- `llm-wiki-maintainer` — 新增、更新、維護 wiki 頁面
- `graphify` — 查詢、建立知識圖譜
- `video-processing` — YouTube 影片下載 + 轉錄流程
