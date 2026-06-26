# 每日 Agent × 軟體開發情報 — 2026-06-26

## 今日 5 個重點

### 1. DeerFlow 2.0：ByteDance 開源 SuperAgent Harness 全面重寫
**發生什麼**：ByteDance 於 2026 年 2 月發布 DeerFlow 2.0（Deep Exploration and Efficient Research Flow），佔 GitHub Trending #1。2.0 為從零重寫，與 v1 無共享代碼。核心架構：sub-agents + memory + sandboxes + extensible skills + message gateway + MCP server。支援 Claude Code 整合、IM channels 接入。

**為什麼重要**：DeerFlow 的架構明確將「技能系統（skills）」、「長期記憶（long-term memory）」、「沙盒執行（sandboxes）」三者分層——這與 OpenClaw 的 skill + session memory + sandbox 設計高度對齊，是驗證 OpenClaw 架構方向正確的外部訊號。

**可信來源**：`https://github.com/bytedance/deer-flow` | `https://deerflow.tech`

---

### 2. Agent Skills 評測與演化 Survey（arXiv 2606.11435）
**發生什麼**：2026-06-09 發布（6月15日 ingested to wiki），Ding et al. 系統整理 agent skill 的 4 種演化範式：(1) Execution Feedback、(2) Trajectory Distillation、(3) Compression & Augmentation、(4) Reinforcement Learning。Skill 形式化定義為：𝒮 = (C, π, T, ℛ)，其中 C=condition、π=policy、T=termination、ℛ=reusable interface。

**為什麼重要**：這個形式化定義與 OpenClaw 的 SKILL.md 結構高度對應（description ~ C、Implementation ~ π、completion criteria ~ T、sessions_send/subagent ~ ℛ）。更重要的是，「將 failure diagnosis 與 rewrite generation 分開的系統表現更強」這個發現對 OpenClaw 的 skill debugging workflow 有直接啟發。

**可信來源**：`https://arxiv.org/abs/2606.11435` | `https://github.com/Cassie07/AgentSkill_Survey`

---

### 3. ECC：多 IDE 通用 Agent Harness 效能優化系統
**發生什麼**：affaan-m/ECC（Agent Harness Performance Optimization System），支援 Claude Code、Codex、Opencode、Cursor。描述為：「Skills, instincts, memory, security, and research-first development」。目標是給 coding agent 提供效能優化的 harness 框架。

**為什麼重要**：OpenClaw 目前主要綁定在 Discord channel + OpenClaw-native tool execution。ECC 的存在說明「跨 IDE harness」是一個真實需求，而 OpenClaw 的 channel-agnostic 設計（gateway/node 架構）領先於這個趨勢。但也需要關注：若其他 harness 支援多 IDE，Linder 為何仍需 OpenClaw？

**可信來源**：`https://github.com/affaan-m/ECC`

---

### 4. AI Agent 在實際應用的牆：HN 高讚討論
**發生什麼**：HN 討論「AI agents (Cursor, Claude computer-use, Copilot agent mode)」在實際應用中暴露的問題：幻覺邏輯只在真實數據/邊界條件下才暴露；UI 更新跨設備同步失敗；API 錯誤被 try-catch 吞掉；視覺 agent 每步 2-10s 延遲且 token 消耗驚人；背景請求難以追踪因果。

**為什麼重要**：這個討論印證了 OpenClaw 設計中的幾個抉擇是正確的：file system access logging、structured tool output limits、sessions_send 的可審計性。反過來也暴露 OpenClaw 目前缺少「runtime visibility without vision bloat」的解決方案。

**可信來源**：HN Algolia API（關鍵字：AI agents + Cursor + Claude computer-use + Copilot agent mode）

---

### 5. AI 程式人 6 月號：資料庫 65 年史 + AI-native DB 興起
**發生什麼**：cccmag/aiprogrammer 第 4 期（2026-06-23）以資料庫系統為主題，從 1890s 打孔卡到 2020s AI-native database。focus7（AI-native database）直接對應 OpenClaw cross-session memory 需求：向量資料庫 + 知識圖譜 + LLM-friendly schema 的結合。

**為什麼重要**：OpenClaw 目前用 SQLite FTS5 做 session search，這已經是「AI-native DB 邊緣」的設計。隨著 skill / memory / context 需求成長，需要評估：是否要引入專門的向量存儲層，還是繼續用 SQLite 演進。

**可信來源**：`https://github.com/cccmag/aiprogrammer/tree/main/202606`

---

## 對 OpenClaw / Linder 的啟發

**啟發 1：Execution Feedback Loop 是 OpenClaw Skill 的下個缺口**
目前 skill 迭代靠手工。2606.11435 的發現顯示「failure diagnosis ↔ rewrite generation 分離」比直接操作 raw traces 表現更強。建議：建立一個 lightweight skill self-healing pipeline——每次 cron/heartbeat 任務失敗時，自動寫入 failure log，下次 session 讀取並觸發 SKILL.md 重寫。而非依賴手工比對執行結果。

**啟發 2：OpenClaw 的「跨 IDE harness」落後於 ECC，但架構更通用**
ECC 鎖定 Claude Code/Codex/Cursor；OpenClaw 走 gateway/node 抽象層，天然支援任意 channel + 任意 tool executor。這個架構選擇的長期價值是「agent 可以在 Discord、TUI、terminal、API 同時存在而不需改變 core」。但代價是 IDE 整合落後。若 Linder 關注 coding agent 領域，OpenClaw 需要一個「skill-based IDE harness」接入點。

**啟發 3：Long-horizon Agent 需要 Explicit Memory 分層**
DeerFlow 2.0 和 2606.11435 都強調「long-term memory」與「context engineering」。OpenClaw 目前靠 daily memory file（`memory/YYYY-MM-DD.md`）+ 手工更新的 MEMORY.md。這在 session 數量少時足夠，但若變成真正多 agent 系統，需要：短期（current session）、中期（daily working memory）、長期（curated MEMORY.md）的 explicit 分層，並讓 budgeted orchestration 知道每層的 retention policy。

---

## 值得追蹤的 Repo / Paper / Article

1. **DeerFlow 2.0** — `https://github.com/bytedance/deer-flow` — ByteDance SuperAgent harness（skills + subagents + memory + sandbox），2026-02 佔 GitHub Trending #1
2. **ECC** — `https://github.com/affaan-m/ECC` — 跨 IDE（Claude Code/Codex/Cursor）agent harness 效能優化
3. **Agent Skills Survey (2606.11435)** — `https://arxiv.org/abs/2606.11435` — Skill 演化 4 範式 + 形式化定義 𝒮 = (C, π, T, ℛ)
4. **Agent Skills for LLMs (2602.12430)** — `https://arxiv.org/abs/2602.12430` — ACM Agent Skills '26 Workshop，skill architecture + MCP 互補關係
5. **AI 程式人 6 月號** — `https://github.com/cccmag/aiprogrammer/tree/main/202606` — focus7 AI-native database 與 OpenClaw memory 設計相關
6. **MAAD (Multi-Agent Architecture Design)** — `https://github.com/RuiyinL/MAAD` — Analyst/Modeler/Designer/Evaluator 四角色架構 agent（wiki 已收錄）
7. **AgenticAKM** — `https://github.com/sa4s-serc/AgenticAKM` — 從 repo 生成 ADR 的 architecture knowledge management（wiki 已收錄）
8. **aiprogrammer-issue-202606** — `wiki/concepts/aiprogrammer-issue-202606.md` — 本地 wiki，已消化

---

## 下一步建議

1. **將 DeerFlow 2.0 架構截圖/文件攝入 wiki**：用 youtube-downloader 或直接下載 DeerFlow README_zh.md 存入 `raw/sources/deer-flow-2026/`，建立 `wiki/projects/deer-flow.md`，並用 graphify link 連結到 `agent-runtime-control-plane`、`budgeted-agent-orchestration` 相關頁面。

2. **規劃 Skill Self-Healing Pipeline 實驗**：參考 2606.11435 的 failure diagnosis ↔ rewrite separation 模式，設計一個 lightweight 實驗：在 `task-manager` 失敗任務時自動寫入 `memory/failed-skills.md`，下次 Rowlet heartbeat 時讀取並提出 SKILL.md 修訂建議。目標是從「手工更新 skill」進化到「data-driven skill evolution」。

3. **評估 OpenClaw Long-term Memory 分層方案**：參考 DeerFlow 的 long-term memory 設計與 AI-native DB 趨勢，評估是否要從 SQLite FTS5 升級到專門的 vector storage 或結構化 session archive layer。可以先做一次「目前 memory 架構瓶頸分析」，產出 ADR 草稿。

---

## 查過的來源

- LLM Wiki graphify query（agent architecture / skills / multi-agent）
- LLM Wiki `wiki/concepts/` 頁面：agentic-architecture-design、budgeted-agent-orchestration、context.md、agent-runtime-control-plane
- LLM Wiki `wiki/sources/` 頁面：agent-skills-for-large-language-models-2026、agent-skill-evaluation-evolution-2606.11435、aiprogrammer-issue-202606
- GitHub API：bytedance/deer-flow（stars repo）、affaan-m/ECC、multi-agent trending repos
- Hacker News Algolia API（AI agent + MCP + claude code + swe-agent 相關 stories）
- GitHub Trending（via GitHub API search）
