# AI Agent Wiki

團隊的 AI Agent 核心知識庫，基於 [Karpathy LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) 模式建立。

---

## 快速開始

### 讓 LLM 幫你工作

1. 把這個目錄路徑告訴你的 LLM Agent
2. LLM 會讀取 `AGENTS.md` 了解結構
3. 開始 Ingest / Query / Lint 工作流

### 手動搜尋

```bash
./scripts/search.sh <關鍵字>
```

---

## 目錄結構

```
ai-agent-wiki/
├── AGENTS.md              ← 主要 schema
├── README.md              ← 本檔案
├── raw/                   ← 原始來源（不可修改）
├── wiki/                  ← LLM 生成的 wiki
│   ├── index.md          ← 頁面總索引
│   ├── log.md            ← 操作日誌
│   ├── CLAUDE.md         ← LLM 進入時的指示
│   ├── karpathy-llm-wiki.md
│   ├── agent-frameworks.md
│   ├── harness-engineering.md
│   ├── vibe-coding.md
│   └── raw-sources-list.md
└── scripts/
    └── search.sh
```

---

## Wiki 內容

| 頁面 | 描述 |
|------|------|
| [[karpathy-llm-wiki]] | LLM Wiki 核心概念 |
| [[agent-frameworks]] | 主流 Agent 框架總整理 |
| [[harness-engineering]] | Agent 的四大工程支柱 |
| [[vibe-coding]] | AI 輔助開發新方式 |
| [[raw-sources-list]] | 所有原始來源連結 |

---

## 工作流程

### Ingest（新來源）
把新來源告訴 LLM，它會：
- 閱讀並摘要
- 更新相關頁面
- 維護 index 與 log

### Query（查問題）
直接問任何問題，LLM 會：
- 先查 index
- 讀取相關頁面
- 合成答案並引用

### Lint（健康檢查）
定期請 LLM 檢查：
- 矛盾、過時、孤兒頁
- 缺少的連結

---

## 維護原則

1. **Raw sources 不可修改**
2. **矛盾時標記，不刪除**
3. **有價值的問答應存回 wiki**
4. **信任 LLM 的維護能力**

---

_Last updated: 2026-05-07_
