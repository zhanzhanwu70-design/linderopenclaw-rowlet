# 每日 Agent × 軟體開發情報 — 2026-10-19

> Rowlet 每日研究｜範圍：近 7–14 天
> 主要來源：Anthropic / OpenAI / Microsoft / Google 工程部落格、GitHub Trending、MCP 規範更新、Agent Skills 社群
> 本機 llm-wiki：`graphify query` 本次執行失敗（`npx graphify` 無法解析執行檔；可能 CLI 介面變更或需重新安裝），先以 web search 為主來源，下一輪再修。

---

## 今日 5 個重點

**1. MCP 2026-07-28 大改版正式落地，無狀態化與 deterministic tool ordering**
- 發生什麼：Model Context Protocol 在 7/28 由 David Soria Parra（Anthropic）推動最大幅度修訂，廢除 session handshake、改為 stateless 核心；同時要求 server 回傳 tool 列表時採 deterministic order 提升 prompt cache 命中率。
- 為什麼重要：MCP 已是 Claude / ChatGPT / Gemini / Copilot / Cursor 共通的 tool 層，這次改版把「快取效率」與「跨進程可重現性」放進 spec 等級，意味著 agent harness 的成本/延遲優化從「model 與 prompt」延伸到「protocol shape」。
- 來源：<https://en.wikipedia.org/wiki/Model_Context_Protocol>、<https://www.descope.com/learn/post/mcp>、<https://theairankings.com/guides/what-is-mcp/>

**2. Agent Skills 從 Anthropic 標準擴張為跨廠商可移植的檔案格式**
- 發生什麼：Anthropic 2025/10 發布、12 月開放的 Agent Skills 格式（markdown + YAML frontmatter）已被 DeepSeek Harness、Pi、vercel-labs/skills（34K stars）等 75+ 代理吃下；GitHub Trending 10 月再出現 obra/superpowers（300K stars，編碼方法論 TDD/YAGNI/DRY）與 affaan-m/ECC（280K stars，instincts + memory）。
- 為什麼重要：skills 正在變成「跨 agent 的可移植知識」，跟 MCP 解耦 tool 層是同一波趨勢。對 Linder/Rowlet：skill 投資是一次寫作、多 agent 通吃。
- 來源：<https://github.com/ai-boost/awesome-harness-engineering>、<https://valuestreamai.com/blog/harness-engineering-ai-agents-2026>、<https://www.coddykit.com/pages/blog-detail?id=5129985>

**3. Claude Code 2.1.291 / 2.1.296 + Sonnet 5 價格凍漲**
- 發生什麼：Claude Code 2.1.291（10/6）修掉 chat 訊息消失、permission prompt 被忽略等 critical bug；2.1.296 推出 workflow-level model pin，可把 pipeline 中所有 subagent 綁定到同一個模型。Sonnet 5 原訂 9/1 漲到 $3/$15 取消，維持 $2/$10。
- 為什麼重要：Anthropic 把「subagent 用同模型 / 不同模型」的策略權交給 workflow 作者，這對多 agent 編排（成本 vs 品質 trade-off）是很實用的控制點。Sonnet 5 凍漲對長時間 agent 跑 long-horizon 任務直接降低成本。
- 來源：<https://www.havoptic.com/tools/claude-code>、<https://platform.claude.com/docs/en/release-notes/overview>、<https://tech-insider.org/codex-cli-0-162-vs-claude-code-2-1-296-2026/>

**4. Vals AI 10/6 榜單：mini-SWE-agent harness 標準化，Opus 5.5 第一**
- 發生什麼：Vals AI 用同一個 harness（mini-SWE-agent）橫評所有模型，10/6 榜單：Claude Opus 5.5 65.15% > Sonnet 5.5 64.14% > GPT-6 Astra 59.60%。Anthropic 2026 Agentic Coding Trends Report 也指出 harness 設定本身可以 ±5 個百分點。
- 為什麼重要：「harness engineering」正式成為 first-class 學問；評測結果要綁定 harness 才有意義。這也呼應 ai-boost/awesome-harness-engineering 的崛起。
- 來源：<https://www.morphllm.com/best-ai-coding-agents-2026>、<https://github.com/ai-boost/awesome-harness-engineering>

**5. Microsoft Agent Framework 1.0 GA + AutoGen 仍 ship，但定位為繼承者**
- 發生什麼：MAF 4/2 GA（Semantic Kernel + AutoGen 合併），AutoGen 仍 1.45.0 釋出但 README 直接指向 MAF。同時 Google ADK 2026 擴大整合 Hugging Face / GitHub / Daytona / Notion；DeepSeek Harness 開源加入 skills 支援。
- 為什麼重要：「AI 進入 Microservices 時代」這篇 Innover 文章的論點開始有實證：企業不再買單體 agent，而是要 orchestration layer 調度 agents / APIs / data / 既有平台。對 OpenClaw 的 multi-agent specialist 架構是同方向紅利。
- 來源：<https://www.shakudo.io/blog/top-9-ai-agent-frameworks>、<https://www.developersdigest.tech/blog/microsoft-agent-framework-whats-new-2026>、<https://www.innoverdigital.com/enterprise-application-modernization-2027-should-cios-build-buy-augment-or-replace/>

---

## 對 OpenClaw / Linder 的啟發

1. **Skill 格式與 MCP server 解耦，雙軌投資**。OpenClaw 的 skill 已是 markdown + YAML frontmatter 結構，建議再加一條驗證：「此 skill 是否能脫離 OpenClaw 跑在 Claude Code / Codex / DeepSeek Harness？」若可，代表格式符合開放標準、可被社群複用，順勢往 llm-wiki 推廣。
2. **Harness engineering 是下一塊拼圖**。MCP stateless + deterministic tool ordering 提示：當前 cron 派的 `mcp-allowlist` 與「tool 結果快取」可以再進化一階（按 deterministic order 序列化、減少 prompt cache miss）。建議下個 sprint 評估是否在 gateway 層加 `tool-call-trace + replay` 機制。
3. **觀察多 agent orchestration 的「microservices 化」**。MAF / LangGraph / CrewAI / Mastra / Strands 都把 durable execution 與 zero-trust federation 當預設；OpenClaw 的 specialist agent + TaskFlow + flock locking 結構已是同方向，下一步可比對 ruvnet/ruflo 的 zero-trust federation 模式，看是否要強化跨 agent 信任鏈。

---

## 值得追蹤的 repo / paper / article

- `vercel-labs/skills`（34K stars，universal agent skills CLI）— <https://github.com/vercel-labs/skills>
- `obra/superpowers`（300K stars，agentic SDLC 方法論）— <https://github.com/obra/superpowers>
- `ai-boost/awesome-harness-engineering`（canonical list）— <https://github.com/ai-boost/awesome-harness-engineering>
- `ruvnet/ruflo`（75K stars，multi-agent swarm + zero-trust federation）— <https://github.com/ruvnet/ruflo>
- `affaan-m/ECC`（280K stars，harness instincts + memory）— <https://github.com/affaan-m/everything-claude-code>
- Wikipedia: Model Context Protocol（記錄 2026-07-28 改版）— <https://en.wikipedia.org/wiki/Model_Context_Protocol>
- Vals AI mini-SWE-agent leaderboard — <https://www.morphllm.com/best-ai-coding-agents-2026>
- Anthropic 2026 Agentic Coding Trends Report — 在 ai-boost/awesome-harness-engineering README 引用

---

## 下一步建議

1. **把今天 5 個重點 ingest 進 llm-wiki**：`/home/amr/llm-wiki/raw/2026-10-19-agent-trends/` 收 raw snapshot，再產 `wiki/concepts/2026-10-19-agent-trends.md`，並用 `graphify link` 連到既有 `agent-skills.md` / `mcp.md` / `harness-engineering.md`（若 wiki 已存在）。
2. **修好 `npx graphify` 執行檔問題**：下輪先 `which graphify` / `ls ~/.openclaw/bin/` 與 `npm ls -g graphify` 確認 CLI 來源，否則每日 wiki-first 步驟會持續失敗。
3. **排一輪小實驗**：用 `vercel-labs/skills` 跑一支 Rowlet skill（例如 `rowlet-self-reproduction`）確認可移植性，回報給 Linder。
