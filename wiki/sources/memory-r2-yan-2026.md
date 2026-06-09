---
title: "Memory-R2: Fair Credit Assignment for Long-Horizon Memory-Augmented LLM Agents"
category: source
type: research-paper
tags: [memory-augmented-llm, credit-assignment, reinforcement-learning, multi-session, long-horizon-agents, grpo, memory-operations]
domain: code-agent
created: 2026-06-08
modified: 2026-06-08
related wikis: [agent-frameworks]
---

# Source: Memory-R2 (Yan et al., 2026)

## 基本資訊

| 欄位 | 內容 |
|------|------|
| **論文** | Memory-R2: Fair Credit Assignment for Long-Horizon Memory-Augmented LLM Agents |
| **作者** | Sikuan Yan, Ahmed Bahloul, Ercong Nie, Susanna Schwarzmann, Riccardo Trivisonno, Volker Tresp, Yunpu Ma (LMU Munich / Siemens) |
| **發表** | May 2026 (arXiv:2605.21768) |
| **領域** | cs.LG / cs.MA — Long-term Memory for Agents / Reinforcement Learning |
| **URL** | https://arxiv.org/abs/2605.21768 |
| **PDF** | raw/references/papers/ai/memory-r2-2026-yan.pdf |
| **Metadata** | raw/references/papers/ai/memory-r2-2026-yan.md |

---

## 核心論點

### 問題背景
Memory-augmented LLM agents 在多 session 環境中，memory 操作（寫入、更新、刪除）會讓不同 rollouts 之間的 memory state 產生分歧。這使得 trajectory-level 獎勵信號對 memory 操作本身變得不公平、嘈雜、有偏。

### 核心問題：GRPO 的 fair comparison 假設被破壞
Group-relative methods（如 GRPO）假設所有 rollouts 來自同一個 effective environment。但當不同 rollouts 寫入不同 memory 後，它們不再共享同一個 intermediate memory state，導致 trajectory-level rewards 無法公平地用於 credit assignment。

### 解決方案：Memory-R2 Framework

**1. LoGo-GRPO（Local + Global GRPO）**
- **Global objective**：保留端到端學習，利用 long-horizon trajectory-level rewards
- **Local rerollouts**：在同一個 intermediate memory state 上比較不同的 memory-operation outcomes，產生更公平的 group comparison，提供更精確的 supervision 給 memory construction

**2. Shared-parameter Co-learning Design**
- Fact extractor + Memory manager 都從同一個 LLM backbone 實例化，透過 role-specific prompts
- 兩者共享參數，jointly optimize memory formation 和 memory evolution

**3. Progressive Curriculum**
- 訓練 horizon 從 8 → 16 → 32 sessions 逐步增加
- 穩定 multi-step RL over long memory horizons

---

## 和現有 Code-Agent Wiki 的關聯

### 和 [[agent-frameworks]] 的關聯
- Memory-R2 解決的是 **多 session RL 訓練中 memory 信用分配**的問題
- 屬於 Agent 四大工程支柱中的「提示詞工程」+「工作流管理」交界
- 對比 MemGPT/MemoryBank 等只做 inference-time memory management，Memory-R2 專注 training-time 的 credit assignment

### 和 [[harness-engineering]] 的關聯
- Memory-R2 的 rerollout 機制 = harness 的監控元件（compare 同一 state 不同 action 的 outcomes）
- Progressive curriculum = curriculum learning 在 RL 中的應用

### 和 [[karpathy-llm-wiki]] 的關聯
- 屬於 LLM Wiki Pattern 的「記憶與檢索」分支
- Memory-R2 = 一種 agent 長期記憶 training 的具體實作方式

---

## 討論問題（值得團隊討論）

1. **實用性評估**：LoGo-GRPO 的 local rerollouts 需要多次 rollout，計算開銷是否值得？在 production 環境中如何取捨？
2. **與現有方案的取捨**：MemGPT、MemoryBank 等 inference-time memory system 和 Memory-R2 的 training-time credit assignment 是否可以結合？
3. **Progressive curriculum 的泛化性**：從 8→16→32 sessions 的 curriculum 是否適用於其他 agent tasks（如 code generation、robotics）？
4. **對 OpenClaw 的啟發**：Rowlet 目前如何管理長對話歷史？Memory-R2 的信用分配概念可以如何應用於多 session 的工具使用？
5. **Shared-parameter co-learning**：Fact extractor 和 Memory manager 共享參數的設計是否會造成 capacity conflict？如何在實作中平衡？

---

## 備註

- PDF 已存：raw/references/papers/ai/memory-r2-2026-yan.pdf
- Metadata 已存：raw/references/papers/ai/memory-r2-2026-yan.md
- 原始 HTML：arXiv HTML 版本（arXiv:2605.21768）