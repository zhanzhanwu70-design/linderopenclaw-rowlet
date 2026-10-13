---
title: "What to Keep, What to Forget: A Rate–Distortion View of Memory Compaction in LLMs and Agents"
arxiv_id: "2607.08032"
authors: "Ashwin Gerard Colaco, Nada Lahjouji (UC Irvine)"
submitted: "2026-07-09"
type: survey-paper
category: agent-context-processing
related: "[[memgpt-2024-packer]] [[amem-xu-2025]] [[acon-2025-kang]] [[compactionrl-2026-li]] [[contextweaver-wu-2026]] [[agentic-context-mgmt-dadhich-2026]]"
---

# Rate–Distortion View of Memory Compaction (Colaco & Lahjouji, 2026)

## One-sentence thesis

Memory compaction in LLMs and agents — KV eviction, prompt compression, bounded recurrent state, agent long-term memory — is **one rate–distortion problem** wearing four disguises, governed by a single lower bound on error.

## The formalism (Section 2)

Every compaction method is a pair `(C_θ, U)`:
- `C_θ : H → Z` shrinks history `H` into compact representation `Z` with `rate(Z) ≤ B`
- `U` consumes `Z` (almost always by continuing model compute) to produce `Ŷ`
- Quality = expected loss `E[ℓ(U(C_θ(H), Q), Y)]` ← **distortion D(θ)**

```math
min_θ E[ℓ(U(C_θ(H), Q), Y)]    s.t.   rate(Z) ≤ B        (Eq. 1)
```

**The lower bound (Eq. 2)** — holds at every layer, no architecture-specific escape:

```math
P_e ≥ (H(Y|Q) - B - 1) / log|Y|    whenever    B < I*(Q)
```

where `I*(Q) = I(Y; H | Q)` is the task-conditioned information content.

**Three consequences**:
1. Below the task's information requirement, every layer must err at a rate set by the same expression.
2. Compression ratio at fixed quality is `∝ 1/I*(Q)` — exact-recall tasks compress poorly, gist tasks compress well.
3. A **query-agnostic** operator pays a quantifiable penalty of `H(Q)` bits per query — the precise price of not knowing the query.

## Three first-class properties (the paper's analytical core)

| Property | Symbol | What it asks | Reversible example | Irreversible example |
|---|---|---|---|---|
| **Reversibility** | P-rev | Can dropped content be re-derived? | archival paging, retrieval-backed | eviction, summarization |
| **Query-conditioning** | P-q | Does C see the query (or its distribution)? | LongLLMLingua, Quest | offline gisting, attention-score evictors |
| **Fidelity profile** | P-fid | Lossless / near-lossless / uniformly lossy / multi-fidelity tier? | (P-fid) Compressive Transformer dual tier | flat summary buffer |

## Four falsifiable predictions (tested in Section 14)

1. **KV**: For attention-score eviction, needle recall collapses once per-token budget falls below the needle's share of attention mass. Collapse point tracks entropy of the answer's location (worse in mid-context).
2. **Prompt**: Query-aware compression shifts the accuracy-vs-ratio curve right by exactly `H(Q)`.
3. **Architectural**: A state of `s` bits cannot answer a query requiring more than `s` bits → SSM/linear-attention models have a hard accuracy cliff on multi-key recall; attention degrades gracefully.
4. **Agent**: Under **repeated irreversible summarization**, end-task error grows **super-linearly** in the number of compaction events; a reversible, retrieval-backed memory stays flat.

## Seven-axis taxonomy (Section 3)

A method is a point in the product of:
1. **Granularity** of compressed unit (bit → token → span → semantic item → inter-agent message)
2. **Lifecycle stage** (pretraining → prefill → decode → serving → within-task → between-task)
3. **Lossiness / fidelity** (lossless → near-lossless → uniformly lossy → multi-fidelity)
4. **Query/task adaptivity** (query-agnostic → query-conditioned → task-aware via learned policy)
5. **Learnability** (training-free heuristic → post-training adapter → trained-from-scratch → RL-learned → LLM-as-controller)
6. **Mechanism** (evict / select / merge / quantize / factorize / summarize / encode-to-latent / recurrent write-forget / structure / internalize)
7. **Storage substrate** (on-GPU KV / host-SSD / parameters / external vector store / knowledge graph)

Decisive axes: **granularity, lifecycle, adaptivity** — the three that predict failure mode.

## Four memory tiers — one hierarchy (Section 10)

| Tier | Substrate | Timescale | Reversible? | Representative methods |
|---|---|---|---|---|
| **KV cache** | on-GPU keys/values | microseconds | mostly no (evict) or yes (retrieve) | H2O, Quest, KIVI, Palu |
| **Working context** | in-window tokens | milliseconds–seconds | partly | MemGPT, ACON, MEM1, ReSum |
| **Long-term store** | semantic items, external | hours–days | partial | Mem0, A-MEM, RAPTOR, Zep |
| **Serving runtime** | GPU ↔ DRAM ↔ SSD ↔ remote | across requests | yes (prefix) | PagedAttention, RadixAttention, CacheGen, Mooncake |

All four answer Eq. 1. A mechanism refined at one tier is a candidate design for another.

## Five compaction-aware design principles

- **P1. Never discard irreversibly what you cannot re-derive cheaply.** Reversible operator weakly dominates irreversible at equal budget; difference shows only on queries whose evidence was dropped. (H2O, fixed-schedule summarization violate.)
- **P2. Condition on the query distribution, not just the current query.** Bound charges `H(Q)` to query-agnostic operators. Trainable sparse attention (NSA) and query-aware compression (LongLLMLingua) pay less of this.
- **P3. Separate a cheap reversible episodic tier from a lossy semantic tier, with explicit promotion/demotion.** Multi-fidelity dominates single lossy tier. (MIRIX typed modules, Compressive Transformer dual tier.)
- **P4. Make compaction asynchronous and learnable, not a blocking heuristic.** RL-learned policies (Context-Folding, MemAct) and sleep-time consolidation move the decision off the critical path.
- **P5. Budget by marginal task-utility, not uniform ratio.** Bound is governed by `I*(Q)`, which spreads unevenly across heads/layers/items. PyramidKV/Ada-KV respect this; fixed ratio ignores it.

## Reference experiment results (Section 14)

**Experiment 1 (KV frontier, Qwen2.5-1.5B, 1395 generations)**: Six methods (SnapKV, StreamingLLM, TOVA, Knorm, ExpectedAttn, random) on one **bytes-per-token-of-history (BPT)** axis. All collapse below ~25% budget — the Fano floor of Eq. 2.

**Experiment 2 (repeated compaction)**: 12 key-value facts spread across chunks; agent compacts at varying frequency. **Irreversible (summarize)**: recall 0.33–0.56, drops with compaction frequency. **Reversible (retrieve)**: holds at ~0.95 regardless of frequency. **Single-turn needle test cannot tell them apart** — the divergence only appears in the agentic regime.

## Importance heuristics as distortion surrogates

Field's apparently unrelated scoring signals are all estimators of one quantity `D(θ)`:
- **Accumulated attention mass** (H2O, SnapKV) — biased toward early + high-frequency tokens
- **Token self-information / perplexity** (LLMLingua) — corpus-prior, query-agnostic
- **Mutual information** (QUITO-X) — closest to direct IB objective
- **Output-error bound** (Ada-KV) — ties surrogate to theory
- **LLM-judged salience** (Mem0, reflection) — expensive but query-aware

Naming them as estimators of one quantity is what makes them comparable and transferable across layers.

## Attention sinks (Section 12 detail)

Softmax forces large attention mass onto first few tokens ("sinks"), enabling StreamingLLM's `attention-sink + sliding window` for millions of tokens. **Ran-Milo et al.**: for a natural family of trigger-conditional tasks, any softmax model that solves them must develop a sink, whatever its training. Evicting sinks = violating budget feasibility, not lossy compression.

## Open problems (Section 15, prioritized)

1. Query-conditioned, reversible, multi-fidelity compaction at every layer
2. **Information-loss attribution + calibrated compaction confidence** — emit "compaction confidence" tied to residual `I*(Q)`, so a method can defer/fetch/escalate fidelity
3. **Composition map** for stacking operators (quant × low-rank × evict × KV × prompt × agent) — operator algebra, which pairs are synergistic/redundant/destructive
4. **Predictive compression scaling law** — closed-form `I*(Q)` as function of model size, context length, head/layer structure, task type
5. Episodic-to-semantic consolidation bridge + stop rule (Ada-KV-style output-error bound for agent summarization)
6. Cheap, asynchronous, RL-stable agent self-curation
7. Multimodal × multi-agent shared-memory compaction (cross-modal vs inter-message redundancy under per-agent query distributions)
8. Adaptivity with guarantees — content+query-adaptive allocation with distortion bound, not empirical sweep
9. **Safety, auditability, rollback** of evolving memory — AgentPoison, MINJA as adversarial form of self-reinforcing error

## Why this paper matters for Rowlet

This is the **first survey that provides a single optimization objective with a provable bound** for memory compaction across the full stack. Prior surveys (Memory in the Age of AI Agents; KV Cache Management; Prompt Compression; Memory for Autonomous Agents) cover subsets of the four layers descriptively; this one:

- Reaches the serving stack and quantization/low-rank mathematics alongside agent memory
- Transfers concrete mechanisms between layers (MemoryBank Ebbinghaus curve → KV prior; Quest no-evict → agent design; Ada-KV output-error bound → summarization stop rule)
- Proposes a **benchmark (COMPACT-Bench) and reference experiment** that holds one budget axis across all four layers AND measures repeated compaction — the regime agents actually live in

The four falsifiable predictions are testable on Rowlet's own three-layer memory. The P1/P3/P4 design principles translate directly to the heartbeats + MEMORY.md compaction loop.

## Key references for follow-up reading

- Haris & Onak (Θ(nd) space lower bound for exact attention)
- Wen et al. (fixed-state RNN provably weaker at in-context retrieval)
- Nichani et al. (parametric memory capacity scales linearly in params)
- Ran-Milo et al. (sinks are necessary, not just empirical)
- QUITO-X (Wang et al. — IB objective for context compression)
- NoLiMa (literal-match NIAH inflates quality)
- AgentPoison / MINJA (memory poisoning)
