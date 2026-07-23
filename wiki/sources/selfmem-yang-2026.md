---
title: "SelfMem: Self-Optimizing Memory for AI Agents"
category: source
type: research-paper
tags: [agent-memory, self-optimizing, context-management, long-horizon-agents, memory-framework, self-improving-ai, BEAM]
domain: code-agent
created: 2026-07-22
modified: 2026-07-22
arXiv: "2607.03726"
authors: ["Shu Yang", "Junchao Wu", "Derek F. Wong", "Di Wang"]
affiliations: ["PRADA Lab, KAUST", "NLP2CT Lab, University of Macau"]
submitted: "2026-07-04"
---

# Metadata

| 欄位 | 內容 |
|------|------|
| **論文** | SelfMem: Self-Optimizing Memory for AI Agents |
| **作者** | Shu Yang (KAUST), Junchao Wu (UM), Derek F. Wong (UM), Di Wang (KAUST) |
| **發表** | July 2026 (arXiv:2607.03726, cs.CL) |
| **領域** | cs.CL — Agent Memory / Self-improving AI |
| **URL** | https://arxiv.org/abs/2607.03726 |
| **PDF** | raw/references/papers/ai/selfmem-2026-yang.pdf |
| **Benchmark** | BEAM (long conversation QA) |

# 核心問題

現有 agent memory 框架（LoCoMo、RAG、MemGPT、MemoryBank）都依賴**固定預設的記憶策略**：
- 固定的儲存格式（summary schema, profile）
- 固定檢索規則（retrieval pipeline）
- 固定更新操作（summarize-then-store）

這些框架在面對不同任務時**不夠彈性**，且需要手動調整。

核心問題：**不同任務、不同對話歷史，需要不同的記憶行為，但現有方法無法讓 agent 自適應調整記憶策略。**

# SelfMem 核心設計：「教 agent 釣魚，而非給魚」

SelfMem 將記憶管理從「框架預定義」轉變為「agent 自己控制的優化過程」。

## 三大原則

1. **Raw transcript 保持為不可變的 source of truth**（SQLite 記錄）
2. **Agent 獲得 memory workspace + 工具，讓 agent 自己決定記憶策略**
3. **Feedback 是可觀察信號（非 gold answer）**

## 架構：4 類記憶工具

```
A = A_read ∪ A_write ∪ A_review ∪ A_probe
```

- **Transcript-read tools**：檢視原始對話歷史（manifest, SQL query, entity search）
- **Memory-read tools**：檢視當前 workspace（避免重複寫入、檢測過時資訊）
- **Memory-write tools**：修改 workspace（ADD / REPLACE / MERGE / ARCHIVE / TIMELINE 等操作）
- **Memory-review tools**：診斷現有記憶（source support、stale facts、contradictions、retrievability risk）

## Feedback 訊號（不給 gold answer）

```
F_i = { o_i^H (transcript read), o_i^M (memory read), 
        d_i^write (write diagnostics), d_i^review (review feedback), 
        u_i (operational: token usage, latency, cache reuse, cost) }
```

這組 feedback 的關鍵：**不 collapse 成單一 scalar reward**，讓 agent 能夠在 language 層面reason about trade-offs（多放資訊→更好的回憶但更高的成本；壓縮→延遲降低但精確度降低）。

## Memory Construction Loop

```
M_0 = ∅
At step i:
  a_i = Select_LLM(P_mem, I, M_{i-1}, o_{<i}, d_{<i})
  If a_i ∈ A_write:
    M_i = Apply(M_{i-1}, ΔM_i)
  Else:
    M_i = M_{i-1}
```

Agent 執行「inspect → write → review → revise」的循環，而非一次性的 summarization。

# 實驗結果

| Scale | Official Score Δ | Pass@0.5 Δ |
|-------|-----------------|------------|
| 100K tokens | +0.165 (+48.7%) | +17.0 pp |
| 500K tokens | +0.141 (+40.8%) | +14.9 pp |
| 1M tokens | +0.134 (+41.9%) | +14.3 pp |

Question-type robustness：9/10 問題類型最佳（100K）、8/10（500K）、7/10（1M）。

# 與現有工作的關係

- **承接** [[sources/memgpt-towards-llms-as-operating-systems|MemGPT]] 的分層記憶方向，但 SelfMem 讓 agent 自己學會什麼時候 paging
- **對比** [[sources/a-mem-agentic-memory|A-Mem]] 的 Zettelkasten 風格組織，SelfMem 不預設組織結構，讓 agent 自己發現
- **對比** [[sources/lost-in-the-middle|Lost in the Middle]]：不是讓模型「忽略中間」，而是讓 agent 主動選擇要保留什麼
- **類比** [[sources/onepred-chen-2026|OnePred]] 的 bounded memory，但 SelfMem 是 RL-free 的 framework，靠 feedback signals 引导

# 值得討論的點

1. **SelfMem 的 feedback signals vs. RL reward**：論文刻意避免 gold answer / scalar reward，而是用可觀察的 tool feedback + operational signals。這與 Memory-R2 用 LoGo-GRPO 做 credit assignment 的方向有何取捨？
2. **Agent 自己發現的 memory strategy 是否真的泛化？** 論文的 optimization study 顯示 model-guided refinement 能改善記憶行為，但這些策略在新任務上是否仍然有效？
3. **SQLite transcript store 的實用性**：將完整對話歷史存成 SQLite 並用 SQL query 讀取，在實際應用（而非 BEAM benchmark）中是否現實？與向量檢索相比的取捨？
4. **與 MemGPT 的 paging 對比**：MemGPT 需要明確的 function calls 來做 memory transfer，SelfMem 的 approach 是否更簡單或更有效？
5. **對 Rowlet 的啟發**：Rowlet 目前用固定的三層記憶系統（SOUL + daily + long-term MEMORY），SelfMem 的 feedback-driven self-optimization 概念是否可以借鑒？
