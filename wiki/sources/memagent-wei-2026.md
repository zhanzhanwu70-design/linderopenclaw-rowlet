---
arxiv_id: 2609.32521
title: "MemAgent: Learning to Manage Heterogeneous Memory Providers for LLM Agents"
authors:
  - Yongxian Wei
  - Yilin Zhao
  - Runxi Cheng
  - Xinrui Chen
  - Chun Yuan
  - Yaoru Wang
  - Jiahong Yan
  - Dian Li
venue: arXiv preprint (cs.AI)
submitted: 2026-09-26
version: v1
subjects: cs.AI
url: https://arxiv.org/abs/2609.32521
pdf: https://arxiv.org/pdf/2609.32521
code_eval: not provided
tags:
  - agent memory
  - heterogeneous memory providers
  - memory routing
  - content-aware probing
  - short-term memory gating
  - multi-provider storage
  - long-horizon agents
  - training-data synthesis
related:
  - MemGPT (2310.08560)
  - A-MEM (2502.12110)
  - Memory-R2 (2607 LoGo-GRPO)
  - AgeMem (Yu et al., 2026)
  - MEM1 (Zhou et al., 2026)
  - MemoryOS (Kang et al., 2025)
  - ARC (Yao et al., 2026)
ingested: 2026-10-06
topic: Long-term Memory for Agents
---

# MemAgent: Learning to Manage Heterogeneous Memory Providers for LLM Agents

## TL;DR
Frames **agent memory as a routing problem**: instead of committing to one representation (trajectories / reflections / skills / structured KG), a memory agent decides **which provider to retrieve from**, **whether to inject short-term memory**, and **which providers should store** the resulting experience. Empirical survey shows **no single memory method generalizes across benchmarks** — so heterogeneous routing is the right level of abstraction.

## The empirical motivation (paper's strongest move)
Evaluated **13 memory methods** across benchmarks and found **no single one generalizes**. This is the negative result that justifies the architecture — it isn't a theoretical bet, it's a measured gap.

## Architecture: three orthogonal routing decisions

### 1. Content-aware probing (pre-retrieval)
- Inspect the incoming query/context **before** spending retrieval budget
- Decide which provider(s) are likely to help — *probe before you fetch*
- This is the **routing** half of "memory as routing"

### 2. Short-term memory gating (during execution)
- Decide **whether** to inject a short-term scratchpad for this step
- Some steps don't need scratch memory; injecting it adds noise and tokens
- Gating turns scratchpad from always-on infrastructure into a per-step action

### 3. Selective multi-provider storage (post-execution)
- After the step completes, **route the experience** to one or more providers
- A reflection goes to reflection store; a successful skill to skill library; a structured fact to KG
- The provider set is **content-aware** — what you store depends on what kind of experience it was

## Training the router
- Phase-specific supervision synthesized from rollouts — different supervision signal per phase (probing / gating / storage) rather than one end-to-end loss
- This is the same insight as [[memory-r2-yan-2026]] (chunk-wise construction, separate global/local branches) but applied to **routing actions** rather than memory read/write

## Results
- **+10% average accuracy** across GAIA, WebWalkerQA, xBench-DS
- **Beats every individual memory method** on all three benchmarks — the heterogeneous router dominates the best single-provider baseline
- **<0.3% routing overhead** — the meta-agent doesn't add measurable cost
- **12% reduction in average task steps** — better memory → fewer wasted actions

## Why it matters for Rowlet / OpenClaw
- Our current three-layer memory (SOUL.md / daily / MEMORY.md) is **single-representation** — daily files are essentially append-only markdown
- The routing framing matches `sirin-belikova-2026` (write-time fidelity check) and `agentic-context-mgmt-dadhich-2026` (lifecycle primitives)
- Specific design question: should heartbeat ingestion route different memory types to different layers? (e.g., user preferences → MEMORY.md; per-session observations → daily; tooling fixes → wiki/sources/)
- The "13 methods, no generalization" finding matches our direct experience — A-MEM worked for trajectory recall, LeanMem for compaction, Lost in the Middle for token placement, none of them the whole answer

## Open questions the paper raises
1. **How does the router scale beyond 13 providers?** If we add episodic / episodic-emotional / sparse-attention providers, does the routing accuracy hold?
2. **Phase-specific supervision** is a clever trick but requires rollout access; how do you get the same routing quality without a simulator?
3. **Storage routing** has no equivalent in single-LLM-agent systems — most don't have multiple stores to route into. This paper assumes a multi-store harness exists.

## Personal take
Most useful single paper for our work this month. It validates the design intuition behind `agentic-context-mgmt-dadhich-2026` (lifecycle not store) with a quantitative ablation, and gives a concrete 3-decision routing vocabulary we can reuse for heartbeat design. The "no method generalizes" finding is the citation we'll keep coming back to when someone proposes replacing MEMORY.md with a single structure.