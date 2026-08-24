# TrajWiki: Source-Grounded Memory Trajectories for Long-Horizon Dialogue Agents

## Metadata

| Field | Value |
|-------|-------|
| **arXiv ID** | 2608.00967v1 |
| **Title** | TrajWiki: Source-Grounded Memory Trajectories for Long-Horizon Dialogue Agents |
| **Authors** | Jingyu Sun, Yuyang Xue, Mingyang Li, Zhengtao Yao, Jiachen Li, Yang Cui, Wenhao Cai, Haozhe Liu, Fangying Wang, Magdalene Katharina Montgomery, Syed Murtuza Baker, Hongpeng Zhou |
| **Submitted** | 1 August 2026 |
| **Subjects** | Computation and Language (cs.CL) |
| **URL** | https://arxiv.org/abs/2608.00967 |
| **PDF** | https://arxiv.org/pdf/2608.00967 |

## Abstract

現有 agent 的 memory system 把記憶存成 isolated records 或 overwritable states，難以追蹤資訊的來源、演變、衝突、過時與否。TrajWiki 提出以 **trajectory-based memory** 取代靜態記憶條目——每段記憶是一個 source-grounded evolution trajectory，透過不可變的 episodic snapshots + claim-level operations（ADD / REVISE / DEPRECATE）維護。並額外提出 **Memory Wiki** の中間層，持續把對話歷史編譯成結構化 wiki page。

## Core Problem

現有 memory-augmented agents 的三大痛點：
1. **Traceability** — 資訊從哪裡來、如何演化，無從得知
2. **Update transparency** — 記憶覆寫後沒有版本歷史
3. **Diagnostic opacity** — 檢索失敗或答案錯了，無法診斷哪個環節出問題

## Key Contributions

### 1. Memory Trajectory Model
每段記憶 = 一條 trajectory，包含：
- **Immutable episodic snapshots**：每個 snapshot 是時間戳記的對話狀態快照，不可變
- **Claim-level operations**：ADD（新增）、REVISE（修訂）、DEPRECATE（廢棄）
- 解決了 overwriting 導致的資訊丟失問題

### 2. Memory Wiki — Persistent Intermediate Layer
對話歷史 → 增量編譯成結構化 wiki pages，涵蓋：
- salient entities、events、quantities、topics、conflicts
- Wiki page 之間互相連結，形成知識圖譜
- 查詢時：wiki page → linked memory trajectories → snapshots → source messages（hierarchical routing）

### 3. Evidence-Grounded Answer Synthesis
答案生成時，明确引用 source messages，不只是靠內部參數知識。

## Results

| Dataset | Model | Improvement |
|---------|-------|-------------|
| LoCoMo | open-source + closed-source LLM backbones | ↑ long-horizon dialogue performance |
| MedMT | open-source + closed-source LLM backbones | ↑ long-horizon dialogue performance |

同時提供 greater **interpretability** 和 **diagnostic visibility**（可看見 memory evolution、retrieval failures）。

## Why It Matters

- **不同於 MemGPT**：MemGPT 是 paging-based memory（把不常用的 context 移到外部），TrajWiki 是結構化的 evolution trajectory，強調版本演化
- **不同於 SelfMem**：SelfMem 是 inference-time self-reflection，TrajWiki 是 persistent structured wiki + explicit operations
- **核心洞察**：記憶不是 static store，而是 evolving entity with provenance — 這個直覺很接近人類如何建立和更新知識

## Architecture Overview

```
Dialogue History
     ↓ (incremental compilation)
Memory Wiki (structured wiki pages: entities, events, conflicts)
     ↓ (hierarchical query routing)
Memory Trajectories (per-memory: snapshots + operations)
     ↓
Episodic Snapshots + Source Messages
     ↓ (evidence-grounded synthesis)
Answer
```

## Filed Under

- Long-term Memory for Agents (Topic 2)
- Context Window Management (Topic 1)
- Conversation History Handling (Topic 5)
- Memory Architecture for Agents

## PDF Storage Path

`/home/amr/.openclaw/workspace-rowlet/raw/references/papers/ai/2608-trajwiki/2608.00967.pdf`

## Related Papers

- [[memgpt-packer-2024|MemGPT]] — paging-based external memory
- [[selfmem-yang-2026|SelfMem]] — inference-time self-reflection for memory
- [[compactionrl-2026-li|CompactionRL]] — RL-trained context compaction
- [[contextweaver-wu-2026|ContextWeaver]] — context composition for agents
