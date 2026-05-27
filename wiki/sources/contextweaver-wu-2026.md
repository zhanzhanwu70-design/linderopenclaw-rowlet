---
title: "ContextWeaver: Selective and Dependency-Structured Memory Construction for LLM Agents"
category: source
type: research-paper
tags: [context-window, long-term-memory, llm-agents, dependency-graph, context-compression, retrieval-augmented]
domain: code-agent
created: 2026-05-26
modified: 2026-05-26
related wikis: [agent-frameworks]
---

# Source: ContextWeaver (Wu et al., 2026)

## 基本資訊

| 欄位 | 內容 |
|------|------|
| **論文** | ContextWeaver: Selective and Dependency-Structured Memory Construction for LLM Agents |
| **作者** | Yating Wu (UT Austin), Yuhao Zhang, Sayan Ghosh, Sourya Basu, Anoop Deoras, Jun Huan, Gaurav Gupta (AWS AI Labs) |
| **發表** | April 2026 (arXiv:2604.23069) |
| **領域** | cs.CL — Context Window Management / Long-term Memory for Agents |
| **URL** | https://arxiv.org/abs/2604.23069 |
| **PDF** | raw/references/papers/ai/contextweaver-2026-wu.pdf |
| **Metadata** | raw/references/papers/ai/contextweaver-2026-wu.md |

---

## 核心論點

### 問題背景
LLM Agent 在多步 Tool-use 任務中，互動歷史快速膨脹，常用管理方法：
- **Sliding window** — 只看最近 turns，刪掉早期但關鍵的資訊
- **Prompt compression** — 基於語意相似度選內容，可能誤刪依賴資訊
- **Retrieval-based memory** — 以語意相似度取材，忽略因果/邏輯依賴結構

### 核心貢獻：ContextWeaver Framework
提出三元件協作：
1. **Dependency-Aware Construction** — 將每個推理步驟建成 graph node，node 包含 `summary`、`dependency_summary`、`parents`、`validation`
2. **Dependency Summarizer** — 將 root-to-step 路徑压缩成可重複使用的單元
3. **Lightweight Validation Layer** — 記錄每次工具執行的 outcome（pass/fail/unknown），過濾不可靠的 nodes

### 創新點：Dependency Graph 而非線性序列
- 舊方法 treat history 為 sequence，按 recency/salience/semantic 刪除
- ContextWeaver 將 agent interaction trace 建為 **DAG**，保留資訊流結構
- Parent selection 用 LLM 作邏輯依賴分析（"是否有因果/邏輯依賴"），不只是相似度計算
- Ancestry BFS traverse 收集 current step 的所有上游依賴

### 實驗結果
- **SWE-Bench Verified + Lite**：pass@1 上優於 sliding-window baseline
- 減少 reasoning steps 和 token usage
- 可解釋性更高（graph structure 提供推理軌跡可追蹤）

---

## 和現有 AI / Code-Agent Wiki 的關聯

### 和 [[agent-frameworks]] 的關聯
- ContextWeaver 解決的是 **Tool-use LLM Agent 的長 context 管理問題**
- 屬於 Agent 四大工程支柱中的「提示詞工程」+「工作流管理」交界
- 對比 Memorial/MemGPT 等分層 memory 系統，ContextWeaver 更強調**邏輯依賴結構**

### 和 [[harness-engineering]] 的關聯
- Harness Engineering 四大支柱：提示詞工程、工作流管理、監控、自動修復
- ContextWeaver 的 Validation Layer = harness 的監控元件（catch 工具執行 failure）
- 其 Dependency Graph = 工作流管理的結構化呈現

### 和 [[karpathy-llm-wiki]] 的關聯
- 屬於 LLM Wiki Pattern 的「記憶與檢索」分支
- ContextWeaver = 一種 agent 持久 memory 的具體實作方式

---

## 討論問題（值得團隊討論）

1. **實用性評估**：ContextWeaver 的 parent selection 每次都要呼叫 LLM（計算開銷），在實際 production 使用時，效益是否大於額外开销？
2. **與現有方案的取捨**：SWE-Agent、OpenHands 已有各自的 compression 機制，ContextWeaver 是否更好？還是互補？
3. **Validation Layer 的泛化性**：在非 software engineering（e.g., 機器人控制、資料分析）的 agent task，validation 如何實作？
4. **對 OpenClaw 的啟發**：Rowlet 目前如何管理長對話歷史？可以把 ContextWeaver 的 dependency graph concept 納入嗎？
5. **Dependency vs. Semantic**：如果一個 later step 依賴 earlier step，但兩者內容完全不相似，語意檢索會失敗；dependency graph 能捕捉這點。這對我們的 workflow有何影響？

---

## 備註

- PDF 已存：raw/references/papers/ai/contextweaver-2026-wu.pdf
- Metadata 已存：raw/references/papers/ai/contextweaver-2026-wu.md
- 原始 HTML：arXiv HTML 版本（arXiv:2604.23069）
