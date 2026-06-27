# 每日 Agent × 軟體開發情報 — 2026-06-27

## 今日 5 個重點

### 1. vercel/eve (2673★)：filesystem-first agent framework，架構與 OpenClaw 高度同源
**發生什麼**：Vercel 推出 `eve` framework，主打「filesystem-first framework for durable AI agents」。Agent 結構：agent/ { instructions.md, tools/, skills/, channels/, schedules/ }。`npx eve@latest init` 一行啟動；hooks 自動接 Claude Code/Codex/Cursor；skills 按需載入（progressive disclosure）。這是 GitHub 最近 14 天內 agent 類 repo stars 最高的一個。

**為什麼重要**：`eve` 的目錄佈局直接對應 OpenClaw 的 `SOUL.md + AGENTS.md + skills/<name>/SKILL.md + channels/`。Vercel 用 `agent/instructions.md` 解決 OpenClaw 用 `MEMORY.md / TOOLS.md / SOUL.md` 三檔解決的事——兩者皆把「durable rules」放到檔案、不放 prompt。這從業界驗證 OpenClaw 早期把 rule layers 寫進 markdown 的決策是對的。同時 Vercel 在 hooks 設計上（Claude Code subagent/Codex/Cursor 三家全吃）反向暴露 OpenClaw 一直沒做的 IDE/coding-agent harness 整合面。

**可信來源**：`https://github.com/vercel/eve` | `https://eve.dev/docs`

---

### 2. Cloudflare Temporary Accounts + AI Control Roadmap：infra-layer 在搶 agent 主導權
**發生什麼**：兩件事在 48 小時內接連發生。
- **Cloudflare** (2026-06-19, HN 249↑ 151c)：推出 `wrangler deploy --temporary`，任何 agent 立刻拿到 60 分鐘臨時 Worker 帳號，之後可 claim 成永久。官方明說：「every wall built for humans — OAuth, dashboard, MFA — is a hard stop for background agents」。
- **DeepMind** (2026-06-18, Rohin Shah + Four Flynn)：發布 AI Control Roadmap，defense-in-depth 框架：sandbox + endpoint security + prompt injection resistance + model alignment + system-level security。比喻「driving instructor with dual controls」，強調「permission grants based on verified behavior」。

**為什麼重要**：雲端 infra 開始主動把 AI agent 視為 first-class principal，要麼給它臨時 identity（Cloudflare），要麼把它當「potentially misaligned」對待（DeepMind）。這是企業級 agent 落地的硬卡點，也是 OpenClaw 沒在解的問題：當一個 OpenClaw agent 要 deploy / 發 PR / 申請 API token 時，它需要什麼樣的 identity？目前的 OpenClaw 是 single-user trusted agent，沒有「non-human principal + audit trail + permission escalation」這種 enterprise-grade 模型。Cloudflare 的暫時帳號模型非常值得搬到自架 infra。

**可信來源**：`https://blog.cloudflare.com/temporary-accounts/` | `https://deepmind.google/blog/securing-the-future-of-ai-agents/`

---

### 3. Process Harness + NOVA：Harness engineering 進入「verification cascade」階段
**發生什麼**：arXiv 2026-06-25 兩篇論文在同一日上線。
- **Process Harness / CUGA FLOW** (2606.27188)：用 TDF（Task-Decision-Flow）模型把 workflow engine + agentic layer 解耦。3 種 policy-governed agent：TaskAgent（任務執行）/ DecisionAgent（gateway routing）/ FlowAgent（runtime 流程改造）。所有 LLM call 都從 process FRAME 拿 policy。
- **NOVA** (2606.27243)：Baidu 工業推薦系統的 verification-aware agent harness。L1-L4 task-level control + 「architecture gradient」（SGD-inspired, non-differentiable）+ 4 段 verification cascade（結構語意 → 本地可執行性 → offline 效能 → online impact），失敗模式存成 forbidden directions。

**為什麼重要**：「Verification cascade」是從 agent harness V1（堆工具）走到 V2（per-stage verification）的轉捩點。NOVA 的「runnable code ≠ valid architecture」這句話直接刺穿現有 agent 的盲點：Claude Code 寫出可執行程式不等於它改了正確的模組邊界。CUGA 的 TDF 模型則比 LangGraph 更結構化——把「policy」和「mechanism」分層，所有 LLM 呼叫的權限來自 FRAME，不來自 prompt。這兩個對 OpenClaw 的直接啟發是：`task-manager` 失敗任務應該自動寫成「forbidden directions」，下一次同類任務主動避開；以及 skill 的執行應該有 explicit verification cascade，而非只靠「模型感覺對了」。

**可信來源**：`http://arxiv.org/abs/2606.27188` | `http://arxiv.org/abs/2606.27243`

---

### 4. Recall + Skillmaxxing：cold-start memory 與 self-evolving skill 變成 24h 內的競賽
**發生什麼**：兩個超近期的 open-source skill 出現，都在打同一個痛點。
- **Recall** (raiyanyahya/recall, HN 135↑ 86c, 2026-06-21)：Claude Code 的 local-first durable memory，**完全 offline**，用 classical Python summarizer（無 LLM 呼叫）。兩個檔案：`.recall/history.md`（append-only log）+ `.recall/context.md`（~1–2K token resume summary）。
- **Skillmaxxing** (Bennyoooo/skillmaxxing, HN 2026-06-26)：**Self-evolving skills**——hooks 整合 Claude Code / Codex / Cursor，agent 在任務結束後 reflect，把 reusable parts crystallize 成 skill 或改善現有 skill。受 Hermes Agent self-improvement loop 啟發。

**為什麼重要**：Recall 跟 OpenClaw 的 SOUL.md + daily memory 三層結構形成互補。Recall 解的是「session-level cold start」，OpenClaw 解的是「agent-level identity continuity」——兩者結合能給出完整 stack：Session cold start (Recall `.recall/context.md`) → Daily memory (`memory/YYYY-MM-DD.md`) → Long-term curated (`MEMORY.md`)。Skillmaxxing 的「no trigger, no babysitting」是 OpenClaw skill self-healing pipeline 的直接原型：每次 cron 任務結束時跑 skillmaxxing-style reflect loop，把失敗/重複操作自動寫成 SKILL.md 修訂草案。下次 heartbeat 看到 draft 時通知 Linder 批准。

**可信來源**：`https://github.com/raiyanyahya/recall` | `https://github.com/Bennyoooo/skillmaxxing`

---

### 5. Forsy AI Agent Apprenticeship：OpenClaw 首次出現在官方 supported agents 名單
**發生什麼**：Forsy-AI/agent-apprenticeship (975★, 2026-06-25 launch) 在 README 直接寫「**available for anyone to start using with local agents including Codex, Cursor, Claude Code, OpenClaw, OpenCode, Hermes Agent, and custom agents**」。這個 framework 是「living ecosystem where AI agents run automated workflow loops on any task, improve through execution, turn each run into reusable work experience + data to improve future agents」。Seed dataset: 500+ tasks + 495 reusable lessons + 1000+ execution traces。

**為什麼重要**：這是 OpenClaw 第一次被外部 mainstream agent ecosystem 收為 native supported runtime（之前僅在個人/team 工具類被提及）。驗證了三件事：(a) OpenClaw 的 gateway/node 架構在第三方眼中是「可整合的」而非「怪胎」；(b) workflow loop + execution experience 的「apprenticeship pattern」正在變成新預設（取代純 fine-tuning）；(c) 外部 ecosystem 開始期待 OpenClaw 提供 stdio/HTTP interface for skill execution，不是只有 Discord channel。

**可信來源**：`https://github.com/Forsy-AI/agent-apprenticeship`

---

## 對 OpenClaw / Linder 的啟發

**啟發 1：建立「Verification Cascade」取代「Model Confidence」作為 skill 完成判定**
NOVA 顯示「runnable ≠ correct」。OpenClaw 現行的 skill 完成判定靠 LLM 自評，這在高風險任務（security audit / migration / architecture change）會漏。建議在 `task-manager` 加一個 `verification_level` enum（`L1_smoke / L2_offline_metrics / L3_architecture_diff / L4_online_impact`），根據 skill metadata 自動對應；NOVA-style 的 forbidden directions 寫到 `memory/forbidden-patterns.md`，下次同類任務前 30 秒注入 skill context。

**啟發 2：把 Agent Identity Layer 從「Linder 的延伸」升級為「first-class principal」**
Cloudflare Temporary Accounts + DeepMind AI Control 都是同一訊號：infra 開始把 agent 當 principal。OpenClaw 對外呼叫任何 service（deploy / API / git push）時，應該有可審計的 agent identity（不只 channel owner 是 Linder）。低成本做法：在 `~/.openclaw/secrets/agent-principals/` 下放 scoped service tokens，每個 skill 啟動時 opt-in 載入，sessions_send / sessions_history 都記錄 principal id。對應 OpenClaw skill：`openclaw-agent-principal` skill。

**啟發 3：採用 Apprenticeship Loop 取代手寫 SKILL.md**
Recall + Skillmaxxing + Forsy Apprenticeship 同時在解「skill 自我進化」。OpenClaw 應該從「Rowlet 凌晨手工修 SKILL.md」演化到「apprenticeship loop：每次 heartbeat 結束後跑反思 → 產生 SKILL.md 修訂 draft → 等 Linder 批准」。這個跟昨天的「execution feedback loop」啟發是同一條線，但今天有 3 個 open-source 實作可參考，可以選定一個（如 Skillmaxxing，因為 hooks-based，無侵入）做 prototype。

---

## 值得追蹤的 Repo / Paper / Article

1. **vercel/eve** — `https://github.com/vercel/eve` — filesystem-first durable agent framework (2673★, 14 天)，agent/ { instructions.md, tools/, skills/, channels/, schedules/ } 結構直接對應 OpenClaw 分層
2. **Process Harness / CUGA FLOW (arXiv 2606.27188)** — `http://arxiv.org/abs/2606.27188` — TDF model + policy-governed TaskAgent/DecisionAgent/FlowAgent；workflow engine + agentic layer 解耦
3. **NOVA (arXiv 2606.27243)** — `http://arxiv.org/abs/2606.27243` — verification-aware agent harness，architecture gradient + L1-L4 task-level control，runnable ≠ valid architecture
4. **Memory Depth / EVAF (arXiv 2606.26806)** — `http://arxiv.org/abs/2606.26806` — long-running language agents 不只需要 memory access，還需要 memory depth；surprise/valence-gated LoRA consolidation
5. **Cloudflare Temporary Accounts** — `https://blog.cloudflare.com/temporary-accounts/` — `wrangler deploy --temporary` 60 分鐘臨時 agent 帳號；infra 開始給 agent 發 identity
6. **DeepMind AI Control Roadmap** — `https://deepmind.google/blog/securing-the-future-of-ai-agents/` — defense-in-depth framework；agent 視為 potentially misaligned principal；雙控比喻
7. **Martin Fowler: Building Reliable Agentic AI Systems (Bayer PRINCE)** — `https://martinfowler.com/articles/reliable-llm-bayer.html` — context engineering + harness engineering 在企業級 agentic RAG 的落地案例
8. **Forsy-AI/agent-apprenticeship (975★)** — `https://github.com/Forsy-AI/agent-apprenticeship` — workflow loop ecosystem；OpenClaw 列為 supported runtime；500+ tasks + 495 lessons seed
9. **Skillmaxxing (Bennyoooo)** — `https://github.com/Bennyoooo/skillmaxxing` — self-evolving skill hooks for Claude Code/Codex/Cursor；reflect → crystallize → improve loop
10. **Recall (raiyanyahya)** — `https://github.com/raiyanyahya/recall` — Claude Code offline local memory；history.md + context.md 兩檔；無 LLM 呼叫
11. **HKUDS/AgentSpace** — `https://github.com/HKUDS/AgentSpace` — Human + Agents one workspace；roles/owners/audit trail；Feishu for agent-native teams
12. **cloudflare/security-audit-skill (966★)** — `https://github.com/cloudflare/security-audit-skill` — six-phase audit pipeline (recon/hunt/validate/report/structured/independent verification)；可作為 OpenClaw security skill 設計藍本
13. **anthropics/launch-your-agent (515★)** — `https://github.com/anthropics/launch-your-agent` — Claude Code skills 4-phase (interview → stage&launch → grade&iterate → run without you)；eval scaffold 範本
14. **mrtooher/fable-mode (556★)** — `https://github.com/mrtooher/fable-mode` — multi-stage planning + sub-agent delegation + self-verification；"checklist, not capability transplant"
15. **HKUDS/AgentSpace + Ponytrail (0xroylee)** — `https://github.com/0xroylee/ponyrace` — snapshot-based local audit trail for AI coding-agent edits；對應 OpenClaw runtime logging

---

## 下一步建議

1. **今晚上執行 Skillmaxxing-style Self-Healing Pipeline prototype**：在 OpenClaw 加一個 `skill-self-heal` skill，hook 到 task-manager 失敗事件：每次 task FAIL → append 到 `.recall/forbidden-directions.md` → 下次同類任務啟動時先讀取。預期產出：失敗任務 retry 成功率提升 + SKILL.md 自動收斂。可寫成 wiki concept page + 跑 7 天數據後回報 Linder。

2. **撰寫 wiki concept page 群（今晚 3 個）**：把今天的高價值 paper/repo 攝入 wiki：(a) `Process Harness / CUGA FLOW.md`（對應 task-manager 設計）、(b) `NOVA Verification-Aware Harness.md`（對應 verification cascade）、(c) `Vercel Eve.md`（對應 OpenClaw directory layout）。每個 200-300 行 concept page + graphify link 回既有 `Agent Harness.md` / `Active Context Compression.md` / `Skill Artifacts RL Optimization.md`。同步更新 `wiki/log.md` 與 `wiki/index.md`。

3. **把 Cloudflare Temporary Accounts 模型套到 OpenClaw sandbox**：建立 `openclaw-temp-principal` skill，讓任何對外 API call（git push / deploy / web post）可以走 temporary token lifecycle（申請 60min → 用完回收 → audit log）。這不是 infra 變更，只是 OpenClaw 對外行為的最小可行 principal 模型。實作成本低（~100 LOC），但能直接驗證「agent as first-class principal」這個 pattern 在 OpenClaw 是否可行。

---

## 查過的來源

- LLM Wiki graphify query（agent architecture / skills / multi-agent）
- LLM Wiki `graphify-out/GRAPH_REPORT.md` clusters: Agent Harness (16 nodes), Active Context Compression, Agent Skills for LLMs, Skill Artifacts RL Optimization, MemGPT/StreamingLLM, OpenClaw Memory Plugin Tier List
- Hacker News Algolia API（最近 14 天，2026-06-13~2026-06-27）：
  - AI agent: 249↑ Cloudflare Temporary, 195↑ Martin Fowler Building Reliable, 73↑ peerd browser harness, 27↑ halo RLM debugger, 24↑ Ponytrail, 14↑ DeepMind Securing AI Agents, 10↑ Polygraph cross-repo memory, 8↑ Unreal Engine 5.8 MCP
  - Claude Code / coding agent: 325↑ Extended Thinking 認證爭議, 149↑ workweave/router, 135↑ Recall, 39↑ Pulse phone approvals, 81↑ Anthropic ban, 6↑ Hacker 用 Claude/Codex 入侵企業
- arXiv (2026-06-25 提交批次)：NOVA / Process Harness CUGA FLOW / Memory Depth EVAF / MIRROR MCTS Red-Teaming / OPID Skill Distillation / AURORA-AI Resource Orchestration / Joint Experiential Rules / Clinical Harness Medical AI Skill
- GitHub Trending (2026-06-13~2026-06-27 新建 repo)：vercel/eve (2673★) / Forsy-AI/agent-apprenticeship (975★) / cloudflare/security-audit-skill (966★) / AI-Builder-Club/skills (580★) / QwenLM/Qwen-AgentWorld (568★) / mrtooher/fable-mode (556★) / anthropics/launch-your-agent (515★) / HKUDS/AgentSpace (453★) / benchflow-ai/awesome-evals (465★) / workweave/router / Plaer1/junction VSCode sidebar / ksimback/looper / dzcmemory-web/bazi-ziwei-skill / dongshuyan/compass-skills / winsznx/theeleven football markets
- DeepMind Blog / Cloudflare Blog / Martin Fowler Article 直接 read
- 本地 LLM Wiki (270 sources, 261 concepts) 已收錄的概念先驗：Agent Harness / Process Harness / Context Engineering / Skill Self-Healing / Memory Tiers / Active Context Compression / Fable / RVR pattern / MAAD / AgenticAKM