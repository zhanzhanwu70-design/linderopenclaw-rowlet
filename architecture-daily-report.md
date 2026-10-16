# 每日 Agent × 軟體開發情報 — 2026-10-16

> 產出：Rowlet（木木鴞）· cron 自動研究  
> 範圍：2026-10-09 ~ 2026-10-16（含 7-14 天回顧）  
> 環境：Asia/Taipei

## 今日 5 個重點

1. **Anthropic 正式推出「Skills」+ 社群推出 Open Skills CLI 跨 70+ agent**  
   發生什麼：Anthropic 在 2026 年 10 月正式把 Skills 升級為一等公民（repeatable workflows），同時間 Google 的 Addy Osmani 開源 `agent-skills`，其 CLI 一次指令可安裝到 Claude Code、Cursor、Codex、Copilot、Cline 等 70+ agent。  
   為什麼重要：技能（skill）正在變成跨 provider 的可移植單位，比 prompt 更接近「一等公民」。對 OpenClaw 的 skill_workshop 工作流是直接驗證——市場已採納。  
   來源：<https://github.com/addyosmani/agent-skills>、<https://support.claude.com/en/articles/12138966-release-notes>、<https://github.com/bradAGI/awesome-cli-coding-agents>

2. **DeepSeek Harness 突破 ~248K stars，LangChain 重新定位為「agent engineering platform」**  
   發生什麼：依 dreaming.press 2026-10 統計，DeepSeek Harness 8/13 開源後 star 數已超越 LangChain（~148K）。LangChain 自我敘事從「framework」轉向「agent engineering platform」。Databricks 與 parallel.ai 都在十月正式撰文定義「harness engineering」。  
   為什麼重要：「模型重要，harness 才是可靠度」的命題在 2026 進入主流共識。harness 包含 tool / memory / context / guardrail 的整合層——正是 OpenClaw 在做的事。  
   來源：<https://dreaming.press/posts/ai-agent-frameworks-whats-changed-fall-2026.html>、<https://www.databricks.com/blog/ai-harness>、<https://parallel.ai/articles/what-is-an-agent-harness>、<https://github.com/ai-boost/awesome-harness-engineering>

3. **SWE-bench Pro 戰況：Claude Mythos Preview 77.8% 拉開差距**  
   發生什麼：依 codersera 2026-05 數據，Claude Mythos Preview 77.8% > Opus 4.7 64.3% > Qwen 3.7 Max 60.6% > GPT-5.4 xHigh 59.1% > GPT-5.3-Codex 56.8%。九月各家仍維持 ~$20/mo 訂閱入口。  
   為什麼重要：差距開始由「模型本體」與「scaffold 設計」共同決定；同模型換 scaffold 結果差很多。OpenClaw 內部 Codex / Claude 路徑選擇可依此基準決策。  
   來源：<https://codersera.com/blog/ai-coding-agents-complete-guide-2026/>、<https://www.developersdigest.tech/blog/ai-coding-tools-pricing-2026>

4. **MCP 2026-07-28 spec + A2A 變 stateless 為最大改版**  
   發生什麼：MCP 在 7/28 推出 2025-11-25 之後最大改版，address 過去「MCP 是不是要死」的焦慮：context bloat 改 reference-based results + streaming；auth 走 SSO cross-app。A2A 同時改成 stateless。Google ADK 2026 也擴大 Hugging Face/GitHub/Daytona/Notion 整合。  
   為什麼重要：protocol 正在主導 vendor 行為，框架競爭退到 protocol 之後。OpenClaw gateway 適合考慮 native MCP server（agent skills 已是 de facto 標準）。  
   來源：<https://modelcontextprotocol.io/docs/2026-07-28/getting-started/intro>、<https://getknit.dev/blog/the-future-of-mcp-roadmap-enhancements-and-whats-next/>、<https://medium.com/@bitcot.insider/what-is-mcp-model-context-protocol-how-it-works-what-it-costs-and-where-it-breaks-88d473ae4ea7>

5. **產業重組：SpaceX $60B all-stock 收購 Cursor（6/16 宣布、8/14 完成）**  
   發生什麼：Cursor CLI 現在與 xAI / Grok 同屬 SpaceX。Anthropic 同時限制 Claude 訂閱只能登入自家 app，迫使 OpenCode 移除 Claude Pro/Max 登入。Claude Code 跑 Opus 5.5（Fable 5.1 在上層），Codex 跑 GPT-6.1 Sol（9/29 出貨）。  
   為什麼重要：model + agent IDE 整合進入新一波重組；訂閱/登入鎖定正在分化生態。對 Linder 的意義：multi-vendor routing（OpenClaw gateway 抽象）比單押一家更安全。  
   來源：<https://pinggy.io/blog/top_cli_based_ai_coding_agents/>、<https://www.coddykit.com/pages/blog-detail?id=5129981&slug=the-state-of-ai-agents-mid-october-2026-what-30-days-of-github-trending-reveals->

## 對 OpenClaw / Linder 的啟發

1. **Skill 標準化對齊**：OpenClaw 既有 `skill_workshop` 與 `rowlet-self-reproduction` 已走在對的路上。下一步把 `agent-skills` 標準（SKILL.md frontmatter + 跨 agent CLI）作為內部 convention 引用，產生跨 CLI agent 的可移植技能。  
2. **Repo memory convention**：2026 已收斂到 `AGENTS.md` / `CLAUDE.md` / `GEMINI.md` 三件套。OpenClaw 的 `workspace-rowlet/AGENTS.md` 已是同類產物；可考慮在 skill_workshop 增一個「agent 啟動時讀取 AGENTS.md」的標準段。  
3. **MCP/A2A gateway 機會**：MCP 2026-07-28 + A2A stateless 是市場主導的 protocol。OpenClaw 適合在 gateway 層加入 native MCP server，把現有 `secrets`、`sessions`、`taskflow`、`automations` 都暴露為 MCP resource——讓其他 agent 可直接整合。

## 值得追蹤的 repo / paper / article

- <https://github.com/ai-boost/awesome-harness-engineering> — harness engineering 完整分類
- <https://github.com/addyosmani/agent-skills> — open skills CLI 70+ agents
- <https://github.com/bradAGI/awesome-cli-coding-agents> — CLI coding agent 與 harness 編目
- <https://dreaming.press/posts/ai-agent-frameworks-whats-changed-fall-2026.html> — 十月 agent framework 變化總覽
- <https://superset.sh/compare/best-ai-coding-agents-2026> — coding agent 2026 對照
- <https://modelcontextprotocol.io/docs/2026-07-28/getting-started/intro> — MCP 2026-07-28 spec
- <https://github.com/EvoMap/awesome-agent-evolution> — agent evolution / memory architecture
- <https://niteagent.com/blog/> — repo memory file（CLAUDE.md/AGENTS.md/GEMINI.md）收斂觀察

## 下一步建議

1. **Ingest 到 llm-wiki**：把上面三篇結構性文章（Dreaming.press 十月 framework、Superset 2026、MCP 2026-07-28 spec）下載 raw snapshot 到 `/home/amr/llm-wiki/raw/`，寫 `wiki/sources/`，並 `npx graphifyy link` 接到既有 `AI Agent 簡報` / `Code 與 Agent 地圖`。  
2. **產出新 skill**：寫一個 `cross-agent-skills-mirror` skill（暫名），把 SKILL.md 標準化並驗證跨 Claude Code / Codex / OpenCode / Cursor 的可移植性。  
3. **實驗**：安排 A2A stateless + MCP 2026-07-28 reference-based 結果的最小 PoC，評估 OpenClaw gateway 暴露為 MCP server 的可行性。
