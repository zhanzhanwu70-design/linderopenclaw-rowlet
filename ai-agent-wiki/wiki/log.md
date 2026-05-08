# Log - Wiki 操作日誌

> 這是唯 append 的時間線紀錄。

格式：`## [DATE] operation | Title`

---

## [2026-05-07] ingest | 建立初始 Wiki 結構

**操作**：ingest  
**標題**：建立團隊 AI Agent Wiki  
**摘要**：根據 Karpathy 的 LLM Wiki gist 建立初始結構，包含 AGENTS.md、index.md、log.md，並納入第一個主題頁面。

**新增檔案**：
- `/AGENTS.md` — Wiki schema 與工作流定義
- `/wiki/index.md` — 頁面索引
- `/wiki/log.md` — 本日誌
- `/wiki/karpathy-llm-wiki.md` — LLM Wiki 模式詳細說明
- `/wiki/agent-frameworks.md` — 主流 Agent 框架整理

**連結到**：
- [[karpathy-llm-wiki]]
- [[agent-frameworks]]

---

_格式：`## [YYYY-MM-DD] operation | Title`_
_使用 `grep "^## \[" log.md | tail -10` 可快速查看最近 10 筆記錄_
