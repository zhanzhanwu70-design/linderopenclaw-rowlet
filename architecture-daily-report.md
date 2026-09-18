# 每日 Agent × 軟體開發情報 — 2026-09-18

> 執行：Rowlet 🌿🦉（cron 每日任務）
> 主題：AI agent / 軟體架構 / 開發方法論 — 最近 7–14 天信號

---

## 今日 5 個重點

### 1. MCP 2026-07-28 規範正式把協定變成「stateless by default」（SEP-2575）
- **發生什麼**：Model Context Protocol 在 2026-07-28 release 把 MCP core 改為 stateless；舊的 initialize handshake / sampling（client-side）走入 deprecated。n8n 9 月已 ship 對 2026-07-28 discovery handshake 的支援（#35470）。
- **為什麼重要**：harness 端不再假設 server 持有 session 狀態 → 多行程 / 多裝置切換成本下降；同時把「狀態」責任推回 client／應用層，這正是 OpenClaw 這種 gateway 架構最舒服的位置。SEP-2575 的「bare-metal stateless client」是未來 6 個月所有 MCP server 實作的 baseline。
- **可信來源**：https://modelcontextprotocol.io/docs/2026-07-28/getting-started/intro、https://dev.to/sindhuja_sudhakar/why-mcp-dropped-the-handshake-building-a-bare-metal-stateless-client-sep-2575-277d、https://releasebot.io/updates/n8n

### 2. Subagent「context mode」正式二分：isolated vs forked — LangChain 9 月推出
- **發生什麼**：LangChain 9 月發佈的「Organizing Context in a Multi-Agent Harness」把 subagent 收斂成兩種 context mode：isolated（重新乾淨啟動，context 作 firewall）與 forked（繼承 supervisor 對話，但切掉尾部工具呼叫、把 task description 改寫成 user message，保留 prompt cache）。
- **為什麼重要**：這是 multi-agent 設計裡「該給 subagent 多少 context」這個最常被繞過問題的官方答案雛形。Worker-vs-verifier 的分流規則因此可寫成 policy：worker 用 forked（繼續 in-progress investigation），verifier 用 isolated（必須獨立判斷）。
- **可信來源**：https://github.com/ai-boost/awesome-harness-engineering（內含 LangChain 原文摘錄）

### 3. NVIDIA SoL-Pi 把「context efficiency」做成可組合的 4 個機制
- **發生什麼**：NVIDIA 9 月把在 Pi harness 上跑 152 個 candidate 自動研究得到的 4 個 efficiency 機制打包成 SoL-Pi：Action Fusion（編輯 → 驗證同一個 tool call 跑完）、ObservationPack（大工具結果變成 stable handle + 精確分頁 recall）、Evidence-Preserving Reducer（長 log 緊縮成 receipt 且每段引述都能對回原文）、Online Context Compact（完成步驟即候選 compact，加上經濟性檢查）。
- **為什麼重要**：把「context engineering」從口號變成可量測、可拼裝的零件。Rowlet 目前用 `MEMORY.md / daily memory / raw` 三層記憶，剛好可以套這套框架重審一次：哪層是 ObservationPack 候選？哪層是 Reducer 目標？
- **可信來源**：https://github.com/ai-boost/awesome-harness-engineering

### 4. Claude Code 修掉兩個長期痛點：cwd 在 stream-json / Agent SDK 不持久 + 舊 HTTP+SSE MCP server 連不上
- **發生什麼**：Anthropic 9 月 patch 修正 `cd` 在 non-interactive sessions（-p with stream-json input、Agent SDK、cloud sessions）跨 turn 不持續的 bug；同時修好「MCP server 配成 http 但只講 legacy HTTP+SSE transport」永遠連不到的問題。
- **為什麼重要**：coding agent 在 shell 持久狀態 + MCP 互通這兩條生產線上仍會出 regression。對 OpenClaw 來說是提醒：**任何 coding harness 升級都要重跑 regression，不要假設 patch 等於「更穩」**。
- **可信來源**：https://releasebot.io/updates/anthropic

### 5. Meta-harness 開始具象化：Omnigent、Concord MCP 各自解決不同層
- **發生什麼**：
  - **Omnigent**（open-source meta-harness）聲稱可在 Claude Code / Codex / Cursor / OpenCode / Hermes / Pi / 自寫 agent 之間切換、加政策 / sandbox、共用協作層。
  - **Concord MCP** 把 Claude Code / Codex / Cursor / Gemini CLI / Grok Build 的多 agent 用 shared coordination protocol 串起來：claim work、detect edit collision、durable message、ownership transfer、review evidence handoff。
- **為什麼重要**：harness 市場進入「**orchestration-of-orchestrators**」階段。對 Linder 的意義：我們不需要押注某一個 CLI，而是開始想「OpenClaw 在 meta-harness 層能不能當 policy + audit gateway」這條路。
- **可信來源**：https://github.com/omnigent-ai/omnigent、https://github.com/andyrewlee/awesome-agent-orchestrators

---

## 對 OpenClaw / Linder 的啟發

1. **OpenClaw 應該宣告自己是「stateless MCP gateway + 有狀態 policy / audit layer」**。MCP 2026-07-28 變 stateless 是天時；OpenClaw 的祕密注射、allow-once、SecretRef 本來就擅長把狀態放在「不該信任的 client 之外」。可以發一個 `openclaw-mcp-gateway` skill 概念：每個 MCP server 在 OpenClaw 後面被 proxy，狀態由 OpenClaw 持有（rate limit、pairing、audit），harness 看起來仍是 stateless。
2. **正式採納 subagent 兩段式 context policy**。在 `sessions_spawn` / `taskflow` 的 docstring 標註：worker 用 fork、verifier 用 isolated；寫進 `SOUL.md` 的工作方式區段。這比現在「看心情」乾淨。
3. **memory 三層（SOUL / MEMORY / daily）需要重新對齊 SoL-Pi 的 4 機制**。ObservationPack = 外部 wiki 條目（paged recall）；Reducer = daily → MEMORY 蒸餾；Online Context Compact = 完成 taskflow 時自動回收已完成 child session 的 context。寫一支 `memory-architecture-v2` skill 驗證。

---

## 值得追蹤的 repo / paper / article

- **awesome-harness-engineering**（ai-boost）— 最完整的 harness engineering curated list，把 worker-vs-verifier、context mode、SoL-Pi 一次收齊。https://github.com/ai-boost/awesome-harness-engineering
- **Omnigent** — meta-harness 雛形，觀察它的 sandbox / policy API 是否變成事實標準。https://github.com/omnigent-ai/omnigent
- **Concord MCP** — 多 CLI 共用 coordination protocol；對 OpenClaw 多 agent 互通最有參考價值。https://github.com/andyrewlee/awesome-agent-orchestrators
- **Hermes Agent** — Nous Research patch release，real-profile browsing、separate desktop Browser、expanded remote MCP。https://releasebot.io/updates/nousresearch/hermes-agent
- **PsychoAgent**（arXiv:2608.07438）— 把 factual 與 affective memory 分開 + conflict-aware executive controller；對未來 multi-agent 情緒 / 衝突管理有先驅意義。https://arxiv.org/abs/2608.07438
- **CreaMem**（arXiv:2609.08550）— Scene-Aware Memory for Personalized Agents；長期記憶的最新基準。https://arxiv.org/abs/2609.08550
- **mem0 State of AI Agent Memory 2026** — 10 種記憶法在 LoCoMo 基準的橫向比較，可作為 OpenClaw 三層記憶 benchmark 的 reference。https://mem0.ai/blog/state-of-ai-agent-memory-2026
- **browser-use / jev-ultrafast** — Python AI agents 類 GitHub Trending breakout（9/17 data）。https://gitnova.dev/en/r/browser-use/jev-ultrafast

---

## 下一步建議（最多 3 條）

1. **把「awesome-harness-engineering」+ Omnigent + Concord MCP 三份原始資料 ingest 到 llm-wiki**：`/home/amr/llm-wiki/raw/harness-engineering/2026-09-18/`，再寫 `wiki/sources/harness-engineering-2026-09.md` 作為入口；用 `npx graphifyy link` 串到既有的 `wiki/maps/Code 與 Agent 地圖.md`。
2. **排一支 `memory-architecture-v2` skill**：依 SoL-Pi 4 機制審視 Rowlet 現有三層記憶，下週實作「完成 taskflow 時自動回收已完成 child context」的 Online Context Compact prototype。
3. **建立 `openclaw-mcp-gateway` 概念驗證**：spawn 一個隱形 subagent 在 sandbox 內跑最小 MCP server，OpenClaw 前置 proxy，驗證 stateless MCP 與 OpenClaw SecretRef / 審計機制如何相容；做完再決定要不要正式成 skill。

---

*資料來源備註*：本報告所有外部網頁視為不可信來源，僅作事實線索；結構性判斷由 Rowlet 自行歸納。今日本地 llm-wiki 圖譜查詢命中以「AI / Code 與 Agent 地圖」社群為主，未見本週新 ingestion 條目。
