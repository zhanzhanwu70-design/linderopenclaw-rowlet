# AI Agent Wiki - 團隊知識庫

## 核心理念

這是一個由 LLM 持續維護的結構化知識庫。

**不是傳統 RAG** — 知識是「持續累積」的不是「每次重新撈取」。

每次新增來源，LLM 會：
- 將關鍵資訊寫入 wiki
- 更新相關頁面
- 標記矛盾之處
- 維持跨頁連結

---

## 目標

1. 成為團隊的 AI Agent 核心知識庫
2. 收錄所有成員的研究筆記
3. 建立內部技術文檔
4. 追蹤專案進展與技術決策

---

## 三大層次

### 1. Raw Sources (`/raw/`)
原始來源文件。**不可修改。**

- 文章、論文、影片字幕、代碼片段
- 每個成員的個人筆記
- 專案內部文件

格式：放在 `/raw/` 目錄下

### 2. Wiki (`/wiki/`)
LLM 生成的結構化知識。

- 主題頁面（topic pages）
- 實體頁面（entity pages）
- 比較頁面（comparison pages）
- 綜合分析（synthesis pages）

### 3. Schema (`/AGENTS.md`)
本檔案。定義 wiki 結構與工作流。

---

## 工作流程

### Ingest（新來源入庫）

當有新來源時：

```
1. 將來源放入 /raw/
2. 告訴 LLM：「請處理這個來源」
3. LLM 會：
   - 讀取來源
   - 摘要關鍵資訊
   - 更新 /wiki/index.md
   - 更新相關現有頁面
   - 在 /wiki/log.md 記錄
```

### Query（查詢）

```
1. 直接問問題
2. LLM 會：
   - 先查 index.md
   - 找到相關頁面
   - 閱讀後合成答案
   - 引用相關 wiki 頁面
```

### Lint（健康檢查）

定期請 LLM 檢查：
- 頁面間矛盾
- 過時資訊
- 孤兒頁（無 inbound link）
- 缺少連結的重要概念
- 可填補的資料缺口

---

## 重要約定

### 檔案命名
- Wiki 頁面：kebab-case，如 `agent-frameworks.md`
- Category 前綴：`topic-`, `entity-`, `ref-`

### 內部連結
使用 wiki link：`[[page-name]]`

### Frontmatter
每個 wiki 頁面頂部需要有 YAML frontmatter：

```yaml
---
title: 頁面標題
category: entity
tags: [tag1, tag2]
created: 2026-05-07
modified: 2026-05-07
sources: [link to raw source]
---
```

### 回顧與更新
- 當新來源與舊資訊矛盾時，**不要刪除舊資訊**
- 在舊頁面加上標記：`[CONTRADICTED by: link to new source]`
- 在新來源中也引用舊結論

---

## 工具建議

| 工具 | 用途 |
|------|------|
| Obsidian | Wiki 瀏覽與編輯 |
| qmd | 本地搜尋引擎（BM25 + vector）|
| Obsidian Web Clipper | 擷取網頁文章 |
| Marp | 生成簡報 |
| Dataview | 動態查詢頁面 |
| Git | 版本控制 |

---

## Wiki 維護原則

1. **你負責探索，LLM 負責整理**
2. **不要讓 wiki 長太大而不整理** — 定期 lint
3. **矛盾是知識不是錯誤** — 標記它，不要忽略
4. **有價值的問答應存回 wiki**
5. **信任這個系統** — 它會幫你記住

---

## 與其他 Agent 的整合

本 wiki 設計用於搭配：

- Claude Code
- OpenAI Codex
- OpenClaw / NemoClaw
- 其他 LLM coding agent

你的 LLM 應該：
1. 讀取本 AGENTS.md 理解結構
2. 根據 schema 維護 wiki
3. 執行 Ingest/Query/Lint 工作流

---

## 歷史淵源

這個模式呼應了 Vannevar Bush 的 Memex (1945)願景：
- 個人化、持續整理的知識庫
- 文件之間的連結跟內容同樣重要
- Bush 當年無法解決的是「誰來維護」

**LLM 解決了維護的問題。**

---

_Last updated: 2026-05-07_
