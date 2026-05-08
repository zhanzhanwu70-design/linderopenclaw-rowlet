---
title: "Karpathy LLM Wiki Pattern"
category: pattern
tags: [knowledge-base, wiki, llm, karpathy, pattern]
created: 2026-05-07
modified: 2026-05-07
sources: ["https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f"]
---

# Karpathy LLM Wiki Pattern

## 一句話定義

**用 LLM 持續維護的結構化 wiki，取代傳統 RAG 的每次重新撈取。**

---

## 核心問題

### 傳統 RAG 的缺陷

```
你問問題
  → 從原始文件隨機撈片段
  → 每次都重新拼湊
  → 知識無法累積
  → 問細節就散掉
```

### LLM Wiki 的優點

```
新來源進來
  → LLM 讀取、理解、摘要
  → 寫入現有 wiki 結構
  → 更新相關頁面
  → 知識持續複利
```

---

## 三層架構

```
┌─────────────────────────────────┐
│       Raw Sources（原始資料）     │  不可修改，來源事實
├─────────────────────────────────┤
│          Wiki（維琪百科）          │  LLM 生成的結構化知識
│   主題頁 / 實體頁 / 比較頁        │
├─────────────────────────────────┤
│     Schema（規範 / AGENTS.md）    │  定義結構與工作流
└─────────────────────────────────┘
```

### Raw Sources
- 文章、論文、影片字幕、PDF
- **嚴格不可修改**
- 視為 source of truth

### Wiki
- 由 LLM 完全維護
- 摘要、實體頁、概念頁、比較頁
- 持續更新與 cross-reference

### Schema / AGENTS.md
- 定義 wiki 結構
- 定義工作流（Ingest / Query / Lint）
- 定義命名規範與格式
- 定義輸出格式（Markdown / Marp / Dataview）

---

## 三個核心 Workflow

### 1. Ingest（新來源入庫）

```
1. 把新來源放進 /raw/
2. 告訴 LLM：「請處理這個來源」
3. LLM 自動：
   ├─ 讀取來源
   ├─ 寫摘要到 wiki
   ├─ 更新 index.md
   ├─ 更新相關頁面（可能觸及 10-15 個）
   └─ 在 log.md 追加紀錄
```

### 2. Query（查詢）

```
1. 你問問題
2. LLM 先查 index.md
3. 找到相關頁面
4. 閱讀後合成答案
5. 引用 wiki 頁面
6. 重要問答 → 存回 wiki（新頁面）
```

### 3. Lint（健康檢查）

LLM 定期檢查：
- [ ] 頁面間矛盾
- [ ] 新來源已取代的舊聲明
- [ ] 孤兒頁（無 inbound link）
- [ ] 重要概念缺乏獨立頁面
- [ ] 缺少的 cross-reference
- [ ] 可用網路填補的資料缺口

---

## 兩個導航關鍵檔案

### index.md
**面向內容**

- 所有頁面的目錄
- 每頁一行摘要 + link
- 按 category 分類
- 規模 ~100 sources / 數百頁時足夠

### log.md
**面向時間線**

- Append-only 操作日誌
- 格式：`## [DATE] operation | Title`
- 可用 unix 工具 parse：`grep "^## \[" log.md | tail -5`

---

## 與傳統 RAG 的關鍵差異

| 面向 | 傳統 RAG | LLM Wiki |
|------|-----------|----------|
| 知識累積 | 無，每次重新理解 | 有，持續整合 |
| Cross-reference | 無 | 有，LLM 主動維護 |
| 矛盾處理 | 忽略 | 標記並追蹤 |
| 維護成本 | 高，人會放棄 | 極低，LLM 處理 |
| 適用規模 | 小規模 | 大規模長期 |

---

## 推薦工具

| 工具 | 用途 |
|------|------|
| Obsidian | Wiki 瀏覽與編輯 IDE |
| qmd | 本地搜尋引擎（BM25 + vector + LLM rerank）|
| Obsidian Web Clipper | 快速把網頁存入 raw |
| Marp | 從 wiki 生成簡報 |
| Dataview | 用 YAML frontmatter 做動態查詢 |
| Git | 版本控制與協作 |

---

## 實際應用範例

### 個人使用
- 追蹤目標、健康、心理、改進
- filing journal entries、文章、podcast 筆記

### 研究
- 持續數週或數月深入一個主題
- 閱讀論文、文章、報告
- 逐步建立綜合維琪

### 閱讀書籍
- 每閱讀一章就 filing
- 建立角色、主題、情節線的頁面
- 最終得到一本豐富的伴讀維琪

### 團隊協作
- 內部維琪由 LLM 維護
- 餵入 Slack thread、會議記錄、專案文檔
- 人類抽查更新

---

## 與 Memex 的淵源

這個想法呼應了 **Vannevar Bush 的 Memex (1945)**：

> 「個人化、持續整理的知識庫，文件之間的連結跟內容同樣重要。」

Bush 當年的瓶頸：
- 連結難以維護
- **誰來做維護工作？**

LLM 解決了這個問題。

---

## 總結金句

> **人類的任務是策劃來源、引導分析、問好問題、思考意義。**
> **LLM 的任務是處理其他所有事情。**

---

## 原始來源

- [Karpathy LLM Wiki Gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)

---

_tags: [pattern, knowledge-base, wiki, llm, karpathy]_
