# 每日 Agent × 軟體開發情報 — 2026-09-04

## 今日 5 個重點

### 1. MCP 2026-07-28 規格正式生效：Stateless 化讓 MCP 變成普通 HTTP 工作負載
**發生什麼**：MCP 在 7 月底釋出 2026-07-28 規格，徹底改寫 transport 層。核心變化：(1) 把 session 拿掉，去掉 `Mcp-Session-Id` header；(2) 任何 HTTP 實例都可回答同一請求，等同普通 HTTP workload；(3) 同時釋出 TypeScript / Python / Go / C# SDK。Google Developers Blog 與 Cloudflare Blog 都寫了跟進文章，OpenAI Codex 在 PR #36361 同步採用，支援 paginated discovery、multi-round requests、non-blocking server startup。

**為什麼重要**：MCP 從「協定層有狀態、需要 sticky session」變成「可橫向擴展、走標準 HTTP routing」。這對部署 OpenClaw 之類多 agent 系統的影響是：MCP server 之間可以放在任何 CDN / reverse proxy 後面，不再綁特定 instance。對 Linder 是好消息——llm-wiki graphify MCP server 終於能放 Cloudflare / Google Cloud Run 等無狀態平台。

**來源**：[modelcontextprotocol.io/roadmap](https://modelcontextprotocol.io/development/roadmap) | [blog.cloudflare.com/mcp-v2](https://blog.cloudflare.com/mcp-v2/) | [developers.googleblog.com/mcp-stateless](https://developers.googleblog.com/scaling-ai-agent-infrastructure-with-the-mcp-stateless-updates/)

---

### 2. Anthropic 推出 Model Hardware Standard (MHS)：Agent 從「操作資料」走進「操作實體設備」
**發生什麼**：8/27–29 Anthropic 釋出 MHS research preview，定義 agent 操作實體設備的共享 driver 介面：顯微鏡、liquid handler、機械手臂、雷射校準、盤式讀取器都可以被同一個 spec 覆蓋。設計意圖同 MCP：model-agnostic、可透過 MCP 連到任何 agent harness、會 open-source。已公開的合作夥伴包含 AWS Strands Robots、Hugging Face LeRobot、Raspberry Pi、Automata、Universal Robots。Ars Technica 與 Quartz 都以「agents on infra」框架報導。

**為什麼重要**：MCP 之後，Anthropic 把同一個「標準化介面 + 多 vendor」策略延伸到實體世界。這預告 agent 應用會從螢幕內的 code action 走向濕實驗室 / 倉儲 / 工廠。如果 OpenClaw 真的要走 Agentic AI Foundation 的 hardware bridge，這條路今天有了起點。

**來源**：[anthropic.com/news/model-hardware-standard](https://www.anthropic.com/news/model-hardware-standard-research-preview) | [arstechnica.com/2026/08/anthropics-new-hardware-standard](https://arstechnica.com/ai/2026/08/anthropics-new-hardware-standard-lets-ai-agents-control-the-physical-world/) | [marktechpost.com/2026/08/29/mhs](https://www.marktechpost.com/2026/08/29/anthropic-opens-a-research-preview-of-the-model-hardware-standard-mhs-a-shared-specification-for-ai-agents-to-safely-operate-physical-devices/)

---

### 3. DeepSeek Harness (dsh) 開源：「Everything is a Plugin」架構 + 95K stars 兩天內達標
**發生什麼**：8/13 DeepSeek 把自家 agent runtime `deepseek-ai/deepseek-harness`（command name `dsh`）以 MIT / TypeScript 開源。規模：226 個 package、約 272,000 行產品程式碼（不含測試），其中 model-facing adapter layer 只佔 3.3%。整個架構設計是「每個 agent capability 都是可替換的 plugin」。DeepSeek V4-Pro 同日 GA。Enkr1 blog 對程式碼結構做了解剖：「agents are mostly plumbing」——session logs、tool pipelines、sandboxing、approval policy、telemetry 才是本體。

**為什麼重要**：這是中國 lab 第一次開源 production-grade agent runtime。對照美國：Grok Build 在 8/7 升 v1.0 + Apache-2.0，是第一個完全 open agent harness 的大型美國 lab。OpenAI / Anthropic 仍 closed source。OpenClaw 的 specialist agent 設計若想往「harness as platform」演進，dsh 的 plugin boundary 是值得解剖的實證樣本。

**來源**：[github.com/deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) | [deepseek.com/harness](https://deepseek.com/harness/en/) | [blog.enkr1.com/agents-are-mostly-plumbing](https://blog.enkr1.com/agents-are-mostly-plumbing/) | [pinggy.io/best-open-source-cli-coding-agents](https://pinggy.io/blog/best_open_source_cli_coding_agents/)

---

### 4. Karpathy Coding Guidelines 變成可安裝的 Agent Skill，Claude Code / Cursor / Codex / Windsurf 通用
**發生什麼**：8/25 forrestchang/andrej-karpathy-skills repo 釋出 `karpathy-guidelines` skill（MIT），把 Karpathy 的四原則（Think Before Coding / Simplicity First / Surgical Changes / Goal-Driven Execution）打包成 agent skills metadata，可被 Claude Code、Cursor、Cline、Codex、Windsurf、Goose、GitHub Copilot、Kimi CLI 等 11+ 個 agent 載入。skill 內容不是文件，而是會注入 system prompt 的可執行行為指南。

**為什麼重要**：這是「行為準則即 skill」這個 meta-pattern 變成主流的訊號。Agent skill 不只是工具呼叫封裝，開始包含「該怎麼想、該怎麼編輯、該怎麼收斂」。對 OpenClaw 的啟示：skill_workshop 之後可以開一個 `behavioral-guidelines/` 子類別，把 Karpathy 風格、OWASP 安全風格、SRE 風格做成可裝載 skill。

**來源**：[github.com/forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) | [skillselion.com/guides/karpathy-guidelines](https://skillselion.com/guides/karpathy-guidelines-skill-claude-code) | [notes.nicolasdeville.com/github/karpathy-skills](https://notes.nicolasdeville.com/github/karpathy-skills/)

---

### 5. 編碼 Agent 戰況：Opus 5 = 97% SWE-bench Verified，Codex 「Persistent mode」 浮上檯面
**發生什麼**：(1) Claude Opus 5 在 SWE-bench Verified 達 97.0%，Terminal-Bench 4.0 (Aug 2026 釋出，66 tasks) 在 GitHub Trending 受關注；(2) Codex GPT-5.6 Sol 在 Terminal-Bench 2.1 達 85.8%，$8.39/DeepSWE task；7/30 又降價（$0.28/M input tokens）；(3) 8/28 Codex CLI repo 出現「Persistent mode」always-on agent 程式碼，是 open-harness 模型之後的下一步；(4) Codeforces / HN 開始比較 Codex persistent vs Claude Code max-tier 的 cost vs hit-rate。

**為什麼重要**：coding agent 進入「模型能力不再是主要差異化、harness design 才是」的階段。Opus 5 / GPT-5.6 / GLM 5.3 / Kimi K3 / Muse Spark 1.1 都已在 90% SWE-bench 上方廝殺；harness 設計（context window 管理、subagent、persistent memory、approval flow）才是 2026 下半場的勝負手。

**來源**：[morphllm.com/codex-vs-claude-code](https://www.morphllm.com/comparisons/codex-vs-claude-code) | [explainx.ai/codex-as-a-platform](https://explainx.ai/blog/codex-as-a-platform-open-agent-harness-august-2026) | [snorkel.ai/terminal-bench-4-0](https://snorkel.ai/leaderboard/terminal-bench-4-0/)

---

## 對 OpenClaw / Linder 的啟發

1. **MCP server 可以正式 stateless 化**：把 llm-wiki MCP server、skills MCP server、graphify MCP server 重新檢視一遍：哪些還依賴 session / sticky instance？哪些可以放 Cloudflare Workers / Google Cloud Run？配合 2026-07-28 spec 重寫 client side，立即得到 CDN-friendly + 橫向擴展能力。

2. **建立「行為準則即 skill」目錄**：在 skill_workshop 開一個 `behavioral-guidelines/` 子類別，參考 Karpathy guidelines 的 metadata 結構。首批三條準則：Karpathy coding guidelines、SRE incident response、OpenClaw SOUL/AGENTS 安全原則。每一條都做成 Claude Code / Codex / Cursor 都吃得下的 skill 檔。

3. **Agentic AI Foundation / MHS 觀察員角色註冊**：Anthropic 已表示 MHS 會 open-source 並走類似 MCP 的治理路線。OpenClaw 團隊（透過 Linder）值得註冊追蹤，未來能 bridge MHS 時就有 ground truth。短期在 llm-wiki 開一個 `wiki/sources/2026-09-mhs/` 追蹤頁即可。

---

## 值得追蹤的 Repo / Paper / Article

1. [github.com/deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) — MIT, "everything is a plugin", 226 packages
2. [blog.enkr1.com/agents-are-mostly-plumbing](https://blog.enkr1.com/agents-are-mostly-plumbing/) — dsh 程式碼結構解剖
3. [github.com/forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) — 行為準則 skill 化的範本
4. [github.com/cloudflare/cloudflare-os](https://github.com/cloudflare/cloudflare-os) — Cloudflare Workers 上的 agent workspace
5. [blog.modelcontextprotocol.io/posts/mcp-roadmap](https://blog.modelcontextprotocol.io/posts/mcp-roadmap/) — MCP 2026-07-28 規格官方說明
6. [anthropic.com/news/model-hardware-standard-research-preview](https://www.anthropic.com/news/model-hardware-standard-research-preview) — MHS research preview
7. [arxiv.org/abs/2608.21690](https://arxiv.org/abs/2608.21690) — Context as an Environment（programmatic context mgmt）
8. [arxiv.org/abs/2608.11775](https://arxiv.org/abs/2608.11775) — The Sleeping Agent: Gist Compression 的盲點
9. [arxiv.org/html/2608.06745](https://arxiv.org/html/2608.06745) — MemPrism：task-conditioned relational memory views
10. [aiagentstore.ai/ai-agent-news/this-week](https://aiagentstore.ai/ai-agent-news/this-week) — 每週 AI agent 動態彙整

---

## 下一步建議

1. **建立 MCP stateless 移轉檢查表**：用 graphify 對目前 llm-wiki 內 MCP 相關條目做 query，列出所有假設有 session 的地方；下週排 1 次實驗，把其中 1 個 MCP server 改寫為 stateless 並驗證。

2. **把 Karpathy guidelines skill 移植到 skill_workshop**：用 skill_workshop create 行為準則類別的提案，先做 Karpathy 一條；同時比對 OpenClaw 自己的 AGENTS.md 安全原則，看能否對齊。

3. **MHS 觀察頁 + arXiv 2608 cluster 收錄**：在 llm-wiki 新開 `wiki/sources/2026-09-mhs/` 與 `wiki/sources/2026-08-agent-memory-cluster/`，把今天 arXiv 4 篇 + Anthropic MHS 公告原文 snapshot 進 raw/，再讓 graphify 連結到既有 Agent Memory 與 MCP 條目。

---

_排程：cron:a72cb46b | 執行時間：2026-09-04 10:02 Asia/Taipei | 模型：MiniMax-M3_
