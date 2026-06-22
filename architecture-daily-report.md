# 架構師每日情報 2026-06-21

## 本日重點發現

1. **DeerFlow 2.0 — ByteDance SuperAgent Harness 重寫版**  
   開源 long-horizon SuperAgent framework，支援 sub-agents、memory、skills、sandboxes、message gateway。2.0 從零重寫，無 v1 共同代碼。 trending GitHub repo。

2. **LedgerAgent — Tool-Calling Agent 的狀態管理新範式**  
   提出將 task state 從 prompt 中分離出來，維護獨立的 ledger，並在執行 policy-violating tool call 前做狀態依賴檢查。適用於客服領域。arXiv:2606.20529

3. **MAMO — 多目標約束優化的多智能體 RL 系統（AAMAS 2026）**  
   將 reward weight 選擇本身建模為學習問題，任務執行與目標設計解耦。適用於動態環境的 cost-minimization 問題。arXiv:2606.20236

4. **"Scaling the Harness" 論文 — Agentic AI 的系統瓶頸轉移**  
   指出 Agentic AI 的下一個瓶頸是 system scaling 而非 model scaling，呼籲將 foundation model 周圍的執行層當作第一公民來設計。arXiv announced May 2026

5. **OpenMontage — 500+ Agent Skills 的開放視訊製作系統**  
   開放源代理視訊製作系統，12 pipelines、52 tools、500+ agent skills，將 AI coding assistant 擴展為完整影片工作室。GitHub trending，今日 993 stars。

---

## 詳細內容

### 1. DeerFlow 2.0（ByteDance）
- **Repo**: `github.com/bytedance/deer-flow`
- **官網**: deerflow.tech
- **架構特色**:
  - Sub-agents  orchestration
  - Long-term memory system
  - Sandbox isolation
  - Extensible skills system
  - Message gateway for IM channels integration
  - LangSmith / Langfuse tracing
  - MCP server support
- **推薦模型**: Doubao-Seed-2.0-Code, DeepSeek v3.2, Kimi 2.5
- **定位**: 從 Deep Research 框架進化為 SuperAgent harness，處理從幾分鐘到幾小時的長週期任務

---

### 2. LedgerAgent — Structured State for Policy-Adherent Tool-Calling
- **Paper**: [arXiv:2606.20529](https://arxiv.org/abs/2606.20529) | ICML 2026
- **問題**: Standard agent 將 task state 埋在 prompt 中，導致：
  - 事實正確但決策基於 stale/missing/incorrect 資訊
  - 語法有效但違反 policy 的 tool call
- **解法**: 
  - 獨立維護 `Ledger`（observed task states）
  - Ledger render 入 prompt 供 LLM 參考
  - Policy-constraint checking before environment-changing calls
- **實驗**: 4 個客服 domain，mixed panel of open/closed-weight models，pass@k 和 multi-trial consistency 均有提升
- **啟發**: OpenClaw 的 tool execution 可參考此模式，在執行前做 state-dependent policy check

---

### 3. MAMO — Multi-Agent Multi-Objective Optimization
- **Paper**: [arXiv:2606.20236](https://arxiv.org/abs/2606.20236) | OptLearnMAS @ AAMAS 2026
- **問題**: RL 解決 constrained optimization 時，Lagrangian weight 需要手動選擇，在非平穩環境中難以平衡 primary objective vs constraint violation
- **解法**: 
  - Decouple 任務執行與目標設計
  - 將 reward weight 選擇本身建模為學習問題
  - Multi-agent RL 架構
- **應用場景**: Computing/networking 系統的 cost-minimization under performance constraints

---

### 4. Scaling the Harness in Agentic AI
- **Status**: Announced arXiv, submitted May 2026
- **核心論點**: Agentic AI 的下一個瓶頸是 **system scaling** 而非 model scaling
- **呼籲**: 將 foundation model 周圍的執行層（harness）當作第一公民來設計
- **關鍵面向**: Auditable、Persistent、Modular、Verifiable architectures
- **與 OpenClaw 相關性**: 直接支持 OpenClaw 作為 harness 系統的定位

---

### 5. OpenMontage — Agentic Video Production System
- **Repo**: `calesthio/OpenMontage`
- **規糢**: 12 pipelines、52 tools、500+ agent skills
- **願景**: 將 AI coding assistant（Claude, Cursor 等）變成完整視訊製作工作室
- **今日**: 993 stars on GitHub trending

---

## arXiv 近期相關新論文（6月）

| ID | Title | Domain |
|----|-------|--------|
| [2606.20544](https://arxiv.org/abs/2606.20544) | Toward Calibrated MoE Under Distribution Shift | Calibration / MoE |
| [2606.20529](https://arxiv.org/abs/2606.20529) | LedgerAgent: Structured State for Tool-Calling Agents | Agent State Mgmt |
| [2606.20438](https://arxiv.org/abs/2606.20438) | Interpretable Sperm Morphology via Attention-Guided DL | Medical AI |
| [2606.20381](https://arxiv.org/abs/2606.20381) | UFP4 Recipe for LLM FP4 Pretraining | LLM Training |
| [2606.20274](https://arxiv.org/abs/2606.20274) | Lagrange: Open-Vocabulary Sparse Driving Framework | Autonomous Driving |
| [2606.20236](https://arxiv.org/abs/2606.20236) | MAMO: Multi-Agent Multi-Objective Constrained Optimization | Multi-Agent RL |
| — | VideoWeaver: Evaluating Skills for Agentic Video Generation | Agent Skills |
| — | Declarative Skills for AI Agents in Knowledge-Grounded Tool-Use | Skill Declarations |
| — | Harnessing AtomisticSkills for Agentic Research | Skill Architecture |

---

## 執行狀態

- **任務完成時間**: 2026-06-21 18:10 UTC
- **資訊來源**: arXiv cs.AI (220 entries), GitHub Trending, graphify wiki query, web_fetch
- **報告產出**: `architecture-daily-report.md`
- **Wiki 同步**: sources 同步至 `wiki/sources/architecture-daily-2026-06-21.md`

---

*🌿🦉 Rowlet — 架構師情報員*