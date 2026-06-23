# 架構師每日情報 2026-06-22

## 本日重點發現

1. **Loop Engineering 取代 Prompt Engineering** — Jonas Steinberger 與 Addy Osmani 在 2026 年 6 月提出「Loop Engineering」概念，核心論點：AI 工程的最小單位已從「回應」轉變為「軌跡」(trajectory)。重點在於設計反饋迴圈，讓模型自己偵測錯誤、執行測試並修正，而非要求模型一次做對。

2. **Oak — 專為 Agent 設計的版本控制系統** — Git 替代品，支援虛擬掛載 (virtual mounts)，讓 Agent 不需下載完整 repo 就能工作。已在內部完全取代 Git 數月。

3. **Context Engineering vs Prompt Engineering** — Anthropic 2025 年 9 月的文章指出：隨著 Agent 任務時間軸拉長，工程重點從「寫 prompt」轉移到「管理上下文狀態」——包含工具、MCP、歷史訊息等如何封裝進 token window。

4. **Context Rot 問題** — LLMs 隨 context length 增加而出現「注意力衰減」，所有模型都有這個特性。Context 是有限資源，必須精心策展 (curated)。

5. **Agent 框架陷阱** — Anthropic 建議：從 LLM API 直接實作，勝過引入多層抽象的框架（如 LangChain、Rivet）。複雜度該用時才加，不要預先套用。

---

## 詳細內容

### 1. Loop Engineering：從 Prompt 到 Trajectory

**來源**: [Prompt Engineering Institute - Chapter 1](https://www.promptengineering.org/)

**摘要**:
- 2020-2023: 單次 Prompt（單一指令）
- 2024: Chaining（鏈式組合）
- 2025 初: Vibe Coding（Karpathy 提出的「跟著感覺走」開發方式）
- 2026 中: Loop Engineering（閉環迭代）

核心 AI Loop 架構：
```
Intent/Goal → Planner → Action/Tool Use → Observation/Feedback 
    ↓                                      ↑
{Success?} ──No──→ Self-Correction Loop ←─Error
    Yes
    ↓
Final Output
```

**對 OpenClaw 的啟示**: 我們的 heartbeat/taskflow 系統正是 Loop Engineering 的實作。Steinberger 與 Osmani 的論點印證了我們的方向是正確的。

---

### 2. Oak — Agent 專用版本控制

**來源**: [oak.space](https://oak.space/oak/oak) (HN: 34 points, 2h ago)

**摘要**:
- 問題：傳統 Git 對 Agent 不友善，完整 clone 佔空間與時間
- 解法：Virtual mounts，Agent 無需完整副本即可操作
- 支援多 task 並行處理
- 已有 310+ merged PRs，已在 production 完全取代 Git
- AGENTS.md 已被更新為包含隔離 worker 規則與 finish checklist

**對 OpenClaw 的啟示**: 我們的 workspace 架構可以考慮 Oak-style 的 virtual mount 機制，減少 Agent 的磁碟 I/O。

---

### 3. Anthropic: Building Effective Agents

**來源**: [Anthropic Engineering Blog](https://www.anthropic.com/engineering/building-effective-agents)

**摘要**:
- **Workflow vs Agent 區分**:
  - Workflows：預定義程式路徑的組合
  - Agents：LLM 動態主導流程與工具使用
- **何時用 Agent**: 當需要靈活性與模型驅動決策時
- **何時不用**: 簡單 LLM call + retrieval + in-context examples 就夠了
- **框架建議**: 先從 API 直接實作，少用 LangChain 等過度抽象的框架

**對 OpenClaw 的啟示**: 我們的 skill 系統是 Workflow 模式 + Agent 模式混合。這個分類很清晰。

---

### 4. Anthropic: Effective Context Engineering

**來源**: [Anthropic Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)

**摘要**:
- Context Engineering 是 Prompt Engineering 的自然演化
- 核心挑戰：**Context Rot** — token 數量增加時模型準確度下降
- 所有 Transformer 架構都有這個問題（每個 token attend 所有其他 token）
- 解法：策展 (curation) vs 堆積 (accumulation)
- Context 是有限資源，有邊際效益遞減

**對 OpenClaw 的啟示**: 
- 我們的 `tool-output-discipline` skill 正是為了解決這個問題
- 每次 tool call 輸出後應該要摘要而非保留完整原始輸出

---

### 5. Model Context Protocol (MCP)

**來源**: [GitHub MCP Specification](https://github.com/modelcontextprotocol/modelcontextprotocol)

**摘要**:
- MCP 讓 Agent 能標準化地存取外部工具與資料
- 定義在 TypeScript (schema.ts)，同時有 JSON Schema 版本
- 由 David Soria Parra 與 Justin Spahr-Summers 建立
- 文件：modelcontextprotocol.io

**對 OpenClaw 的啟示**: OpenClaw 的 skill 系統與 MCP 在精神上相似（標準化工具存取），可以研究 MCP 作為可能的整合方向。

---

## 額外觀察：HN 趨勢

本日 Hacker News 值得關注的相關項目：
- **"Prompt Injection as Role Confusion"** (43 points) — 安全相關，對 agent 架構有影響
- **"The text in Claude Code's Extended Thinking output is not authentic"** (196 points) — Claude Code 的思考鏈輸出不真實，引發對 agent 可解釋性的討論
- **"Codex logging bug may write TBs to local SSDs"** (354 points) — Agent 系統的資源管理問題

---

## 執行狀態

- **任務完成時間**: 2026-06-22 18:03 UTC
- **主要資訊來源**: Prompt Engineering Institute, Anthropic Engineering Blog, Hacker News, oak.space, GitHub MCP
- **報告儲存位置**: 
  - Primary: `~/workspace-rowlet/architecture-daily-report.md`
  - Wiki sync: `wiki/sources/architecture-daily-2026-06-22.md`
