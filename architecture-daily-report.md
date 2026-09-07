# 每日 Agent × 軟體開發情報 — 2026-09-07

> Cron job: `每日 Agent × 軟體開發潮流研究`（08:00 Asia/Taipei）
> 今天查過的本地圖譜：`llm-wiki/graphify-out`，查詢句：AI agent architecture / agent skills / multi-agent workflow / software architecture / software development trends / coding agents 2026（budget 1000）。命中節點多集中於 community 1（AI / Code 與 Agent）與 community 24（Karpathy LLM Wiki Ecosystem）；既有主題「agent skills、harness engineering、multi-agent orchestration、memory/context architecture、OpenClaw、coding agent workflow、TDD/diagnosis/prototype」皆已建立連結，本次外部新資料將補強「Anthropic Skills API equivalent in OpenClaw」與「MCP Server Card」兩條主線。

---

## 今日 5 個重點

### 1. DeepSeek Harness v0.1 — 「Everything is a plugin」的開源 agent runtime
- **發生什麼**：DeepSeek 在 **2026-08-13** 把 `deepseek-ai/deepseek-harness`（MIT）以 developer preview 對外釋出。設計哲學是「agent = model + harness」，因此 model、tools、sessions、loop、sandbox、persistence、web UI **全部都是可替換 plugin**（代號 Cordis）。Flowtivity 稱上線兩天就 95k stars，Moclaw 的同期截圖顯示 62.7k stars，差異反映 PR/話題熱度。
- **為什麼重要**：第一次由模型供應商公開展示「harness 與模型解耦」的開源實作。這把「哪一家 agent runtime 比較好」的問題，從模型綁定拉回到**外層編排層** — 是 LangGraph / Microsoft Agent Framework 之後，harness 競爭再升級的訊號。
- **可信來源/URL**：
  - https://deepseek.com/harness/en/
  - https://github.com/deepseek-ai/deepseek-harness
  - https://flowtivity.ai/blog/deepseek-harness-open-source-agent-explained/
  - https://medium.com/@adnanmasood/deepseek-harness-and-the-rise-of-the-composable-agent-runtime-7ac7ae836380

### 2. Anthropic Skills API + Files API — skills 變成一等公民
- **發生什麼**：Anthropic 把 Skills API 與 Files API 推上線 — skill 是一個「資料夾」（instructions + scripts + templates），Claude **只在任務需要時才載入**，執行在內建 code execution sandbox，使用者不必自架 server。Skill 可版本化、可掛在任何 request 上。
- **為什麼重要**：把 skill 從 prompt hack 升級成平台支援的 runtime 概念。意味著：skills 已成為 agent platform 的可分發單位（不是「暖啟動提示詞」），所有做 agent framework 的人都必須思考 skill lifecycle。
- **可信來源/URL**：
  - https://releasebot.io/updates/anthropic/claude
  - https://code.claude.com/docs/en/sub-agents（sub-agent memory 欄位即同一系列觀念）
  - https://github.com/Picrew/awesome-agent-harness（彙整上述兩種定義）

### 3. Claude Code v2.1.261 + Codex CLI — sub-agent、thread memory、跨工具 import
- **發生什麼**：
  - Claude Code 在 **v2.1.198 預設把 sub-agent 跑在背景**、允許巢狀到 depth 3、預設同時跑 20 個（v2.1.2 起）。每個 sub-agent 有持久 **memory 目錄**，跨 session 保留 codebase patterns / 偵錯 insight / 架構決策。9 月最近的修補主要在「resume sub-agent 沒通知 main agent」、「`.mcp.json` 是 FIFO 時 `claude mcp add/remove` 會掛」。
  - Codex CLI 9 月：新增「分頁 thread history + 有效率 resume + 搜尋 + persisted names + sub-agent support + memories」；`/import` 擴充成能從 Cursor / Claude Code 把 settings、MCP servers、plugins **匯入**；cloud task 拒絕非信任 backend URL（拿掉 redirect）。Plugin recommendations 在 startup 預載，減少第一輪的延遲。
- **為什麼重要**：兩個工具都把 **sub-agent 的持久記憶** 當核心功能（不是實驗），並把「從別家搬設定」當 v1 feature。鎖定效應正在消失。
- **可信來源/URL**：
  - https://releasebot.io/updates/anthropic/claude-code
  - https://www.havoptic.com/tools/claude-code
  - https://releasebot.io/updates/openai/codex
  - https://www.gradually.ai/en/changelogs/codex-cli/

### 4. Harness engineering 是 2026 真主旋律 — benchmarks 可被 harness 拉 ±5 pp
- **發生什麼**：
  - Google Cloud 部落格（Shir Meir Lador）：「How you engineer your harness」是 coding agent 周邊最重要的趨勢，因為「AI-generated code 怎麼在不想每行都看的前提下驗證」是當前最大問題。
  - Anthropic《2026 Agentic Coding Trends Report》：harness 設定本身就足以讓 benchmark 浮動 **5+ 百分點**。
  - OpenAI 2026-08-19〈Codex as a platform: build on the open agent harness〉明指「Codex 裡最值得複用的不是 chat 介面，是底層 agent harness」。
  - Garry Tan 2026-08-25：systems of record 必須把自己升級成 AI harness，否則會被 agent 取代 — 確定性 SQL/API/ACL 留下，產品必須搭完整 workflow。
- **為什麼重要**：把「寫好 prompt」這件事重新定義為「設計好圍繞模型的整層 runtime」。OpenClaw / skill_workshop 本來就在做這件事，現在有公開認可的命名與量化的 ROI。
- **可信來源/URL**：
  - https://medium.com/google-cloud/what-is-harness-engineering-and-why-should-i-care-43f6a0367772
  - https://kenhuangus.substack.com/p/from-software-engineering-to-harness
  - https://www.explainx.ai/blog/what-is-agent-harness-complete-guide-2026
  - https://github.com/ai-boost/awesome-harness-engineering

### 5. MCP 2026 roadmap：Server Card（`.well-known`） + 已開始正式 deprecate
- **發生什麼**：MCP 官方 roadmap 揭露：(a) **Server Card Working Group** 為 MCP server 訂 `.well-known` metadata，未連線就能被發現與推理；(b) 採用 Contributor Ladder；(c) Working Group 自管 SEP；(d) **2026-07-28 完成首批規格 deprecation** — 這是首次跑完整 feature lifecycle。安全面向另有新攻擊面：Grok 「加密式 indirect prompt injection」（AES payload 繞過純文字 guardrail）與 CISA 揭露的 AI-assisted Siemens S7 PLC OT 攻擊。
- **為什麼重要**：Server Card 直接影響 OpenClaw 未來如果要發 MCP server，必須具備可被外部 agent 在 zero-connect 時讀懂的 metadata — 這應該列為 MCP server 上線的驗收項目。
- **可信來源/URL**：
  - https://blog.modelcontextprotocol.io/posts/mcp-roadmap/
  - https://modelcontextprotocol.io/docs/2026-07-28/getting-started/intro
  - https://www.explainx.ai/blog/mcp-security-guide-2026

---

## 對 OpenClaw / Linder 的啟發

1. **把 OpenClaw 的 skill 重新定位為「Skills API 等價層」**。Anthropic 把 skill 變成可版本化、可附掛、可在 sandbox 內執行的 runtime 單位；OpenClaw 已經有 `skill_workshop` 與 SKILL.md frontmatter，但缺一個**對外宣告**：每個 OpenClaw skill 可被打包成可移植資料夾、附 SKILL metadata、可在不同 session 載入。我們可以在不破壞現有 skill 的前提下，新增「skill pack」格式（`skill.json` + `SKILL.md` + scripts/ + references/），並寫一個 `skill-pack publish --to skills-hub-compatible`。
2. **把 MCP server 的 Server Card（`.well-known/mcp/server.json`）列為上線驗收項目**。OpenClaw 若發布任何 MCP server，補上 Server Card 是低成本的可發現性投資。順手把它寫成新的 skill：`mcp-server-card-bootstrap`（檢查、生成、校驗、列入 wiki）。
3. **把 Codex-style 跨工具 import 變成 OpenClaw 一等公民 feature**。Codex 已實作從 Cursor / Claude Code 把 settings + MCP servers + plugins 拉進來。我們可以用 `sessions_send` 反向做：寫一個 `interop-import` skill，能吃進 Codex / Claude Code 的設定檔，吐回 OpenClaw 的 `~/.openclaw/` 配置對應，並把任何 MCP server 自動在我們 sandbox 內驗證。

---

## 值得追蹤的 repo / paper / article

- **DeepSeek Harness** — `github.com/deepseek-ai/deepseek-harness` （MIT，2026-08-13）
- **Prime Agent: Self-Improving RLM Harness** — `github.com/PrimeIntellect-ai/prime-agent` （Karten et al., arXiv 2026）
- **awesome-harness-engineering** — `github.com/ai-boost/awesome-harness-engineering` （彙整 harness 工具與 pattern）
- **awesome-ai-agent-papers** — `github.com/VoltAgent/awesome-ai-agent-papers` （含 GRACE 神經符號安全架構、Hidden-in-Plain-Text RAG 注入 benchmark）
- **Codex CLI changelog（September 2026）** — `gradually.ai/en/changelogs/codex-cli/` + `releasebot.io/updates/openai/codex`
- **Claude Code v2.1.261** — `havoptic.com/tools/claude-code` + `releasebot.io/updates/anthropic/claude-code`
- **MCP 2026 roadmap** — `blog.modelcontextprotocol.io/posts/mcp-roadmap/`
- **TencentDB Agent Memory** — 跨 agent/framework 的團隊級 memory hub（Chat Memory / Skill / LLM-Wiki / Code-Graph 四件 reusable asset）
- **`awslabs/aidlc-workflows`** — AWS adaptive workflow steering rules（出現在 GitHub Trending 9 月榜）
- **`qufei1993/skills-hub`** — 跨桌面工具管理/同步 agent skills（呼應今天重點 #2）

---

## 下一步建議（最多 3 條）

1. **執行 ingests**：把 DeepSeek Harness 公告原文、MCP roadmap 部落格全文、Codex CLI 9 月 changelog、Claude Code v2.1.261 changelog **四份 raw snapshot** 存到 `/home/amr/llm-wiki/raw/2026-09-07-agent-trends/`，再寫 `wiki/sources/` 短摘要 + `wiki/concepts/harness-engineering.md` 把命名與 5pp benchmark 結論定錨，最後用 `graphify link` 接回 `wiki/maps/Code 與 Agent 地圖.md` 與 `wiki/maps/ai.md`。
2. **寫一個 spike skill**（用 `skill_workshop` proposal → apply 流程）：`mcp-server-card-bootstrap`，一次性檢查/生成/驗證我們內部 MCP server 的 `.well-known/mcp/server.json`，並在 llm-wiki 留下「通過/未通過」紀錄。
3. **安排一場小實驗**：用 30 分鐘，把一個 OpenClaw skill（例如 `rowlet-self-reproduction`）打包成 Anthropic Skills API 相容的資料夾結構，跑一次 `sessions_spawn` 載入驗證，順手補完 frontmatter 缺失欄位，結論回填到 MEMORY.md。

---

_快取備註：本次 4 次 web_search + 1 次 graphify query + 1 次 wiki scan；DeepSeek Harness 部分原始公告已記下 raw snapshot 路徑備存；報告完成時間 2026-09-07 10:02 Asia/Taipei。_
