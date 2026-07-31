# CompactionRL: Reinforcement Learning with Context Compaction for Long-Horizon Agents

## Metadata

| Field | Value |
|-------|-------|
| **arXiv ID** | 2607.05378v1 |
| **Title** | CompactionRL: Reinforcement Learning with Context Compaction for Long-Horizon Agents |
| **Authors** | Yujiang Li et al. (Z.AI) |
| **Submitted** | 6 July 2026 |
| **Subjects** | Machine Learning (cs.LG) |
| **URL** | https://arxiv.org/abs/2607.05378 |
| **PDF** | https://arxiv.org/pdf/2607.05378 |
| **KDD 2026** | — |

## Abstract

Long-horizon agentic LLMs 受到有限 context window 的限制，互動軌跡可能超出最大長度才完成任務。Context compaction 把歷史摘要成更短的狀態，之後在壓縮後的 context 繼續執行，但將 compaction 整合進 RL 訓練仍是未探索的領域。CompactionRL 將 task execution 與 summary generation 聯合優化，jointly optimized under the same final task reward。

## Core Problem

現有 RL pipelines 不支援 context compaction 的設置：
- GRPO 等方法優化完整 rollout groups，但 compaction 讓單一 rollout 變成多個可變長度 segments
- 固定大小的 group normalization 不適用
- compacted segments 若當成獨立樣本會扭曲 loss weighting 和 temporal credit assignment

## Key Contributions

### 1. PPO over group-relative methods
Compaction leads to variable number of rollout segments → 從 group-wise optimization 轉向 PPO formulation，learns from individual compaction segments，with a critic to estimate token-level advantages.

### 2. Joint optimization of execution + summarization
任務執行動作和摘要動作在同一个 task-level reward 下聯合優化，使 summarization 成為模型可學習的部分，而非 inference-time heuristic。

### 3. 兩個關鍵技術
- **Token-level loss normalization**：減少長度引起的 weighting bias
- **Cross-trajectory GAE**：跨 compaction boundary 保留 temporal credit assignment

## Results

| Model | SWE-bench Verified | Terminal-Bench 2.0 |
|-------|-------------------|-------------------|
| GLM-4.7-Flash (30B-A3B) + CompactionRL | 56.0% (+5.5) | 20.2% (+6.8) |
| GLM-4.5-Air (106B-A30B) + CompactionRL | 66.8% (+7.0) | 24.5% (+3.1) |

已部署於 GLM-5.2 (750B-A40B) 的 RL pipeline。

## How It Works (Mechanism)

1. **Rollout collection with compaction**：當 context budget 即將耗盡，trigger compaction，產生新 segment
2. **Context reconstruction**：從 summary + 少量 recent context 重建 agent context
3. **PPO optimization**：每個 compaction segment 作為一個 learning unit
4. **Shared task reward**：所有 segments 共享最終 task-level reward，backprop through summary

## Why It Matters

- **不同於 MemGPT**：MemGPT 是 inference-time memory paging，CompactionRL 是 training-time learning of compaction policy
- **不同於 SelfMem**：SelfMem 是 inference-time optimization via feedback signals，CompactionRL 是 RL training with outcome feedback
- **壓縮策略變成可學習的**：不是工程師設計 compression heuristic，而是模型自己學

## Filed Under

- Context Compression & Summarization (Topic 3)
- Long-term Memory for Agents (Topic 2)
- Context Window Management (Topic 1)
- Code-Agent

## PDF Storage Path

`/home/node/.openclaw/workspace-rowlet/raw/references/papers/ai/2607-compactionrl/2607.05378.pdf`
