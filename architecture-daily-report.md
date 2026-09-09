# 每日 Agent × 軟體開發情報 — 2026-09-09

> Rowlet 每日研究報告 · 篩選原則：最近 7–14 天優先；事實／推論／個人判斷分開；不堆新聞標題，講結構性意義。
> 本日查過的來源：本地 LLM Wiki（graphify query）、arXiv、Hacker News、Releasebot（OpenClaw / Anthropic / Microsoft）、awesome-harness-engineering、Martin Fowler、mem0、StartupCorners GitHub Trending、tech-insider.org MCP 文章、volcengine/OpenViking、mattpocock/skills、lilianweng（Lilian Weng 轉述見 The AI News Report 9/2）。

---

## 今日 5 個重點

1. **MCP 2026-07-28 規格大改：stateful handshake 被拔掉**
   - 發生什麼：MCP steering group 7/28 發出 2026-07-28 spec，把 stateful handshake 拆掉、加入 stateless scaling、企業級授權、Python/TS/Go/C# SDK 進入 stable beta。OpenAI、Google DeepMind、Microsoft 都已採用。
   - 為什麼重要：MCP 從「連線協議」變成「企業級 infra」。我們 gateway-side MCP 整合若還在依賴 stateful session，要規劃 stateless 化。
   - 來源：tech-insider.org / hackernoon.com（MCP Explained）。

2. **Anthropic 把 Skills 變成 open standard；Claude Code 9 月加入 managed MCP + headless permissions + GitLab MR 識別 + JSON plugin validation**
   - 發生什麼：2025-12 Anthropic 開源 Skills 規格；9 月 Claude Code 新版內建 managed MCP servers、無人值守 headless 權限控制、JSON plugin schema 驗證、開機更快、workflow views、concurrency/resume/permissions/remote sessions 全面修穩。
   - 為什麼重要：「Agent Skills」正式成為跨廠商可移植的單位，這對 OpenClaw 自家 skill_workshop 是結構性利多——可以直接做 MCP Skills 互通層。
   - 來源：releasebot.io/updates/anthropic/claude-code、SiliconANGLE 12/18/2025 報導。

3. **Git-native agent memory 浮上檯面：OKF Agent Memory（9/5/2026）+ OpenViking（ByteDance）+ mem0 State of AI Agent Memory 2026**
   - 發生什麼：OKF 把 agent context 存成 git 版控的 Markdown + YAML frontmatter，零依賴 Go binary；OpenViking（VLDB 2026）把 memory / RAG / skills 統一成「context database」；mem0 報告主張「memory 在 2026 已成 first-class architectural component」。
   - 為什麼重要：HN 的高票評論點出「precision/recall 已解，真正沒解的是 maintenance / provenance / staleness」——30+ 年的 knowledgebase 痛點正在 agent memory 上重演。我們的 llm-wiki 三層架構正好踩到這個位置。
   - 來源：news.ycombinator.com/item?id=49581240、samcodeman.com、github.com/volcengine/OpenViking、mem0.ai/blog/state-of-ai-agent-memory-2026。

4. **Lilian Weng「harness engineering」成為新主流詞；awesome-harness-engineering 已收 200+ 工具／pattern**
   - 發生什麼：Lilian Weng 主張「model 周圍的 code 現在跟 model 一樣重要」，命名為 *harness engineering*。社群整理出 awesome-harness-engineering 清單（tools、patterns、evals、memory、MCP、permissions、observability、orchestration）。Matt Pocock 把「code-review」做成平行 sub-agent（Standards vs Spec 兩軸）。
   - 為什麼重要：把 agent 拆成「Model + Harness」的分工框架已成共識；對 OpenClaw 的意義是我們不該只想做更好的 LLM 介面，而要把 harness（skills、evals、memory、permissions、orchestration）模組化成可重複使用的零件。
   - 來源：github.com/ai-boost/awesome-harness-engineering、github.com/mattpocock/skills、theainewsreport.com（9/2 報導）。

5. **LangGraph 2.0 收編了「Router / Supervisor / Subagent」三個 agent primitive；arXiv 2609.03335（9/3）討論異質 GPU 上的 latency-aware 多 agent 編排**
   - 發生什麼：LangGraph 2.0 把過去三年生產編排 pattern 凝固成 type-safe streaming、Deploy CLI 託管、統一 agent primitives（Router / Supervisor / Subagent），省掉手刻 coordination。arXiv 9/3 出現 *Latency-Aware Orchestration for Multi-Agent LLM Workflows on Heterogeneous GPUs*（Jinghao Wang et al.）。
   - 為什麼重要：「Supervisor + Subagent」正式成為產業標準 pattern；OpenClaw 的 sessions_spawn（subagent）+ taskflow（coordinator）已經在結構上對齊這個抽象，可以做更明確的 primitive 文檔化。
   - 來源：github.com/ai-boost/awesome-harness-engineering、arxiv.org/abs/2609.03335。

---

## 對 OpenClaw / Linder 的啟發

1. **把「Memory as first-class」做成 OpenClaw 工作流預設**——參考 OKF Agent Memory 與 OpenViking，把 sessions_spawn / taskflow 的 child state 統一以 git 版控 Markdown 落到 `~/llm-wiki/memory/agents/`，讓每次 subagent 結束都留下可審計的 trail。實作上可在 rowlet-self-reproduction 技能上擴充「post-task memory commit」hook，並用 graphify 把新頁面 link 回相關 source/concept。

2. **把 skill_workshop 對齊 MCP Skills open standard 與 harness engineering**——Lilian Weng 的定義讓 skill 不再只是 prompt 模板，而是 procedures + evals + permissions 三件套。下一步：把現有 12+ 個 skills 重寫成 frontmatter 包含 *triggers / steps / pitfalls / evals* 的四段式，並產出一個 `skill_workshop/mcp-bridge` 範本，讓技能可以在 Claude Code / Codex / OpenClaw 之間移植。

3. **TDD in the agent loop 不只是「要測試」，而是「self-verification 契約」**——Martin Fowler 9 月新文章 *TDD inside the agent loop* 與 Johnson Lee 的 *Does an Agent Really Need TDD?* 都指向同一件事：TDD 在 agent 場景下是「self-verification loop」，不是給人類看的測試。建議在 `task-manager` 技能上加一條「TDD-first」selector：當任務型態是「寫新功能 / 修 bug」且有可跑 test runner 時，自動要求 red→green→refactor 三段並把測試當成交付契約。

---

## 值得追蹤的 repo / paper / article

- `github.com/ai-boost/awesome-harness-engineering` — 200+ harness 工程清單，pattern 索引
- `arxiv.org/abs/2609.03335` — Latency-Aware Multi-Agent Orchestration on Heterogeneous GPUs（9/3）
- `github.com/vercel-labs/agent-browser` — 為 AI agent 設計的瀏覽器 CLI（GitHub Trending 9/6）
- `github.com/mattpocock/skills` — 平行 sub-agent code-review（Standards × Spec）
- `github.com/volcengine/OpenViking` — 統一 memory / RAG / skills 的 context database
- `github.com/mksglu/context-mode` — tool output sandboxing（98% reduction）+ 17 平台 routing
- `martinfowler.com/articles/exploring-gen-ai/tdd-in-the-agent-loop.html` — TDD 在 agent loop 的實驗
- `news.ycombinator.com/item?id=49581240` — OKF Agent Memory 討論串（含 30+ 年 knowledgebase 痛點）
- `releasebot.io/updates/openclaw` — OpenClaw 9 月：GPT-5.6 Ultra / Opus 5 跨 runtime model setup
- `startupcorners.com/digest/devtools-digest-2026-09-06` — GitHub Trending 9/6 摘要

---

## 下一步建議（最多 3 條，可執行）

1. **把 OKF Agent Memory 與 OpenViking 兩個 repo 抓 raw snapshot 到 `~/llm-wiki/raw/2026-09-09/agent-memory/`**，並產出 `wiki/sources/OKF Agent Memory.md` 與 `wiki/concepts/Agent Memory First-Class Architecture.md`，最後跑 `npx graphifyy link` 接到 `wiki/maps/Code 與 Agent 地圖.md`。

2. **安排一個 30 分鐘實驗**：挑一個現有 skill（例如 `task-manager` 或 `ptcgp`），套 MCP 2026-07-28 的 stateless server 範式重寫一次，看能不能在同一個 skill 內同時被 Claude Code 與 OpenClaw 呼叫，驗證 skills 跨平台可移植性。

3. **把「TDD self-verification」做成 cron-friendly 的小型實驗腳本**：在 `~/workspace-rowlet/experiments/` 開一個 `agent-tdd-self-verify/`，拿 martinfowler 的題目重跑，比較 red-green-refactor vs 自由寫法 的 diff 與測試覆蓋率，結果丟回 `wiki/concepts/` 當 case study。
