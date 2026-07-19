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

## 新增深度發現（2026-07-15 每日論文討論）

### Method 層面關鍵發現

1. **Chunk-wise Memory Construction（分塊建構）**
   - 每個 session 再切成 K 個 chunks，extractor + manager 在每個 chunk 上交替運行
   - 把 session 從單一 transition 變成多步決策過程，可隨更多 evidence 逐步 refine
   - 消融實驗：N=10（太多 chunks）反而下降，N=4（太少）不夠 refinement，最佳值在兩者之間

2. **Length-Normalized Step-level RL（步驟級別長度正規化）**
   - 問題：extractor 和 manager 生成長度不同，直接 token-level RL 會讓輸出長的 role 收到更多 loss terms
   - 解法：每個 extractor/manager call 視為一個 step aggregation，統一 weight
   - 消融：無此正規化 F1 從 49.67 降到 43.53

3. **Memory Penalty（壓縮懲罰）**
   - Token-level F1 reward 之外，加上內存膨脹懲罰：記憶 tokens 超過 session tokens 的 α fraction 就開始扣分
   - λcomp 控制懲罰強度，實驗找到最佳值 0.3

4. **LoGo-GRPO 的 Global vs. Local Branch 混合機制**
   - Global branch：全部 n 個 rollouts 正常比較，保留端到端學習
   - Local branch：每個 session 以 plocal 概率被選中，從 anchor rollout 的 memory state 重新 rollout m 次
   - Local rerollouts 因為共享起點，comparisons 更乾淨

5. **M-Fail：記憶覆蓋率診斷指標**
   - Required evidence location IDs 中有多少比例完全沒出現在 memory bank
   - 完整 LoGo-GRPO + curriculum 可把 M-Fail 壓到 6.72%，無 curriculum 直接 32-session 訓練 M-Fail 爆炸到 72.1%

### 實驗結果亮點

- **Memory-R2 (7B) vs Memory-R1**：F1 43.14→50.60，B1 36.44→44.01
- **泛化性超強**：只在 LoCoMo 2 個對話上訓練，zero-shot 到 LongMemEval F1 從 27.88→50.60
- **小模型受益最大**：Qwen2.5-3B F1 從 10.3→46.8（+36.5），遠超大模型的相對增益
- **延遲降低**：訓練後的 policy 生成更簡潔的 memory 操作，3B 和 7B 的 per-conversation 延遲都下降
- **Training-free 最佳 baseline（MemoryOS）只有 34.64 F1**，比 Memory-R2 差 15+ F1 points

### 為何這篇值得讀（行動呼籲）

| 維度 | Memory-R2 解決了什麼 |
|------|------|
| **問題新穎度** | 第一篇明確指出「memory 使環境 non-stationary」導致 GRPO credit assignment 失效 |
| **實用性** | 只需要 2 個訓練對話就能泛化，data-efficient |
| **系統性** | 同時優化 formation + evolution，不是只做 retrieval |
| **可操作性** | Chunk + curriculum + step-norm 三件套明確，其他 memory agent 可直接採用 |

---

## 討論問題（值得團隊討論）

1. **Local rerollout 的計算代價**：每個 session 都要多跑 m 次 rerollouts，這個 overhead 在 production 是否值得？
2. **對 OpenClaw Rowlet 的啟發**：我們目前的三層記憶（SOUL + daily + MEMORY.md）是否可以套用 LoGo-GRPO 的 local rerollout 概念來評估哪些記憶決策真正帶來好結果？
3. **M-Fail 指標**：可用來診斷 Rowlet 的 heartbeat 是否真的把關鍵資訊寫入記憶，還是只是在 context 裡飄著沒落地。
4. **Progressive curriculum 的遷移**：OpenClaw 的新 agent onboarding（從簡單到複雜的 task）是否就是隱式的 curriculum？
5. **Shared-parameter co-learning**：兩個 role 用同一 backbone + different prompts — 這不就是 tool-use agent 的 tool selection + response generation 嗎？有什麼陷阱？

---

## 備註

- PDF 已存：raw/references/papers/ai/memory-r2-2026-yan.pdf
- Metadata 已存：raw/references/papers/ai/memory-r2-2026-yan.md
- 原始 HTML：arXiv HTML 版本（arXiv:2605.21768）
- 代碼：https://github.com/ahmedehabb/Memory-R2