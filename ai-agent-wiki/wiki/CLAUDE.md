# CLAUDE.md - AI Agent Wiki

你正在進入團隊的 AI Agent Wiki 目錄。

## 這個 Wiki 的目標

- 成為團隊的 AI Agent 核心知識庫
- 收錄所有成員的研究筆記
- 建立內部技術文檔
- 追蹤專案進展與技術決策

## 結構

```
ai-agent-wiki/
├── AGENTS.md          # 主要 schema，定義工作流
├── raw/               # 原始來源（不可修改）
├── wiki/              # LLM 生成的結構化知識
│   ├── index.md       # 頁面總索引
│   ├── log.md         # 操作日誌
│   └── *.md           # 各主題頁面
└── scripts/           # 工具腳本
```

## 工作流程

### Ingest（新來源）
1. 將來源放入 `/raw/`
2. 告訴 LLM：「請 ingest [來源連結]」
3. LLM 會處理並更新 wiki

### Query（查詢）
1. 直接問問題
2. LLM 會先查 index.md，再搜相關頁面

### Lint（健康檢查）
定期請 LLM：
- 檢查矛盾
- 更新過時資訊
- 修補連結
- 找出孤兒頁

## 命名規範

- Wiki 頁面：kebab-case，如 `agent-frameworks.md`
- Category 前綴：topic-、entity-、ref-
- 每頁需要有 YAML frontmatter

## 重要約定

- Raw sources **不可修改**
- 矛盾時標記，不刪除
- 有價值的問答應存回 wiki
- 每次修改後更新 index.md

## 第一步

讀取 `../AGENTS.md` 了解完整 schema。
