---
arxiv_id: 2502.12110
title: "A-MEM: Agentic Memory for LLM Agents"
authors: [Wujiang Xu, Zujie Liang, Kai Mei, Hang Gao, Juntao Tan, Yongfeng Zhang]
venue: NeurIPS 2025
submitted: 2025-02-17
revised: 2025-10-08 (v11)
url: https://arxiv.org/abs/2502.12110
pdf: file://../../raw/references/papers/ai/2502.12110-amem-agentic-memory.pdf
tags:
  - agentic memory
  - long-term memory
  - Zettelkasten
  - memory evolution
  - link generation
  - retrieval-augmented
ingested: 2026-09-23
topic: Long-term Memory for Agents
related:
  - "[[memgpt-packer-2024]]"
  - "[[memory-r2-yan-2026]]"
  - "[[trajwiki-sun-2026]]"
  - "[[ace-liao-2026]]"
  - "[[acon-2025-kang]]"
---

# A-MEM: Agentic Memory for LLM Agents (Xu et al., 2025)

## TL;DR
Proposes an **agentic memory system** for LLM agents that dynamically organizes memories as interconnected knowledge networks inspired by the **Zettelkasten method**. Every new memory automatically triggers **(1) note construction with LLM-generated semantic attributes**, **(2) link generation** to similar existing memories, and **(3) memory evolution** — rewriting *historical* memory's context/keywords/tags as new information arrives. No predefined memory operations required.

## Problem
Existing memory systems (MemGPT, MemoryBank, ReadAgent, Mem0) require:
- **Predefined storage structures** set by developers
- **Fixed operational workflows** for write/read timing
- **Static schemas** (graph DBs) that can't adapt to new patterns

This rigidity limits generalizability and prevents "innovative connections or new organizational patterns as knowledge evolves" — when an agent learns a novel solution, current systems can only categorize it within a preset framework.

## Method (4 stages)

### 1. Note Construction
Each memory `m_i = {c_i, t_i, K_i, G_i, X_i, e_i, L_i}` where:
- `c_i`: original interaction content
- `t_i`: timestamp
- **`K_i`**: LLM-generated keywords
- **`G_i`**: LLM-generated tags
- **`X_i`**: LLM-generated contextual description
- `e_i`: dense embedding (all-MiniLM-L6-v2 over concatenation)
- `L_i`: linked memory set

**Key idea**: LLM enriches the note with semantic components rather than relying on raw input. This produces multi-faceted representations capturing different aspects.

### 2. Link Generation (LG)
- Embedding-based top-k retrieval → candidate neighbors `M_near`
- LLM analyzes `{m_n, M_near, P_s2}` → decides which links to establish
- Result: flexible Zettelkasten-style network, memories can belong to multiple "boxes"

### 3. Memory Evolution (ME)
- For each neighbor `m_j ∈ M_near`: re-run LLM with `{m_n, M_near \ m_j, m_j, P_s3}`
- Update **context/keywords/tags of existing historical memory**
- Mimics human learning: network "deepens its understanding over time"

This is unusual — most systems are append-only. A-MEM re-writes history.

### 4. Relative Memory Retrieval
- Cosine similarity over embeddings → top-k
- Linked memories in same "box" auto-included (graph traversal)

## Experimental Highlights

### Datasets
- **LoCoMo**: 9K-token dialogues, 35 sessions avg, 7,512 QA pairs (multi-hop, temporal, open-domain, single-hop, adversarial)
- **DialSim**: Friends / Big Bang / Office dialogues, 350K tokens, 1K questions/session

### Baselines
LoCoMo (LangChain-style), ReadAgent, MemoryBank, MemGPT

### Results — LoCoMo + GPT-4o-mini (F1)
- Multi-Hop: LoCoMo 25.02 / MemGPT 26.65 / **A-MEM 27.02**
- Temporal: LoCoMo 18.41 / MemGPT 25.52 / **A-MEM 45.85** (≈2× MemGPT)
- Open Domain: LoCoMo 12.04 / MemGPT 9.15 / **A-MEM 12.14**
- Single-Hop: LoCoMo 40.36 / MemGPT 41.04 / **A-MEM 44.65**
- Adversarial: LoCoMo 69.23 / MemGPT 43.29 / A-MEM 50.03 (LLM pre-trained knowledge helps raw baseline here)

**A-MEM wins 4/5 categories on GPT-4o-mini, 5/5 on smaller local models** (Qwen2.5, Llama 3.2).

### DialSim F1
A-MEM 3.45 vs LoCoMo 2.55 vs MemGPT 1.18 (+35% / +192%).

### Cost / Efficiency
- **~1,200 tokens per operation** (vs 16,900 for LoCoMo/MemGPT) → **85–93% reduction**
- <$0.0003 per operation with GPT-4o-mini
- 5.4s/operation (GPT-4o-mini), 1.1s (Llama 3.2 1B local)

### Scaling (1M memories)
Retrieval time: 3.70 µs (A-MEM) vs 120,069 µs (ReadAgent) — **~32,000× faster at scale**. Linear space complexity O(N).

### Ablation (GPT-4o-mini, Multi-Hop F1)
- w/o LG & ME: 9.65
- w/o ME: 21.35
- Full A-MEM: 27.02

Both modules contribute; LG is the foundation, ME refines.

### Visualization
T-SNE shows A-MEM embeddings form **tighter, more clustered structures** vs dispersed baseline — empirical evidence for the evolution mechanism.

## Discussion — 3–5 Points Worth Talking About

1. **Agency at the memory layer, not just the retrieval layer.** Unlike agentic RAG (which only decides *when/what to retrieve* over a static KB), A-MEM lets the *memory itself* generate context, link itself, and evolve. This is a meaningful conceptual shift — storage and structure become first-class agent behaviors, not developer-engineered fixed operations.

2. **Zettelkasten as engineering primitive, not just a metaphor.** Atomic notes + flexible links + continuous recombination produces measurable improvements in **multi-hop** and **temporal** reasoning — exactly the categories where flat retrieval fails. Connects well to [[context-engineering-2025-mei]] taxonomy: this is a "memory system" implementation with explicit evolution semantics.

3. **Memory evolution = backwards writing. Risk underexamined.** Re-running the LLM to rewrite *historical* memory attributes when a *new* memory arrives is unusual — most systems are append-only. This both enables "learning over time" AND creates risk: hallucinated rewrites of past events. The paper does NOT address: (a) privacy/selective forgetting, (b) conflicting memory resolution, (c) drift from evolution, (d) cost of evolution loop in production. The wins are real but the failure modes are unexamined. **TrajWiki's claim-level provenance (ADD/REVISE/DEPRECATE) is a more rigorous response to the same instinct.**

4. **Token economics flip the script.** Cutting tokens from 16,900 → 1,200 (85–93%) while *improving* accuracy is the headline production story. Selective top-k + linked-box retrieval beats dumping the full context window. Direct empirical evidence against "more context = better" for multi-hop agents — aligns with [[lost-in-the-middle-2023-liu]]'s U-shaped curve. But: the dial still depends on **what k to pick** (paper sweeps 10–50, plateaus around 20–30).

5. **Scaling claim needs scrutiny.** Retrieval stays at ~3 µs even at 1M memories, but the paper doesn't separately cost the **evolution step** (a chain of LLM calls per *write*, not per read). Writes are amortized, but per-write LLM calls + linkage search can dominate in production at scale. A real-world 1M-evolving-memory deployment would behave very differently from the static benchmark shown.

## Connections to Existing Stack

- vs **MemGPT ([[memgpt-packer-2024]])**: paging tiers vs Zettelkasten knowledge network. MemGPT decides *when* to page; A-MEM decides *what* to write + how to update history.
- vs **Memory-R2 ([[memory-r2-yan-2026]])**: training-time credit assignment vs inference-time evolution. Memory-R2 needs RL; A-MEM is system-only.
- vs **TrajWiki ([[trajwiki-sun-2026]])**: link-level provenance vs claim-level provenance. A-MEM knows "which note is connected"; TrajWiki knows "which claim was revised."
- vs **ACE ([[ace-liao-2026]])**: A-MEM rewrites historical embeddings freely; ACE keeps raw+abstract lossless and reversible. ACE = safety-first, A-MEM = expressiveness-first.
- vs **ACON ([[acon-2025-kang]])**: A-MEM optimizes the memory layer; ACON optimizes the compression function around the memory. Both show "smaller representation can beat larger context."

## Files
- PDF: `raw/references/papers/ai/2502.12110-amem-agentic-memory.pdf`
- Metadata: `raw/references/papers/ai/2502.12110-amem-agentic-memory.md`
- Source entry: `wiki/sources/amem-xu-2025.md`
- Code (eval): https://github.com/WujiangXu/AgenticMemory
- Code (system): https://github.com/WujiangXu/A-mem-sys
