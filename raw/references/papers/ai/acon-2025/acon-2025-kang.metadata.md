# ACON — Kang et al. 2025 (ICML 2026)

## Metadata

- **Title**: ACON: Optimizing Context Compression for Long-horizon LLM Agents
- **Authors**: Minki Kang, Wei-Ning Chen, Dongge Han, Huseyin A. Inan, Lukas Wutschitz, Yanzhi Chen, Robert Sim, Saravan Rajmohan
  - KAIST + Microsoft + University of Cambridge
  - First author: intern at Microsoft
- **Published**: October 2025 (v1) → revised June 2026 (v3)
- **Venue**: ICML 2026 (PMLR 306)
- **arXiv**: [2510.00615v3](https://arxiv.org/abs/2510.00615)
- **PDF**: `raw/references/papers/ai/acon-2025/acon-2025-kang.pdf`
- **Code**: <https://github.com/microsoft/acon>

## TL;DR

ACON is a **model-agnostic, prompt-space optimizer** for the compressor inside a long-horizon LLM agent.
Instead of RL-finetuning the agent model to compress its own context (impossible for proprietary LLMs), ACON
refines the **natural-language compression guideline** via contrastive failure feedback from paired
(successful / failed) trajectories, then **distills the optimized compressor into a small LM**.

**Numbers (gpt-4.1 agent + gpt-4.1 compressor)**:
- AppWorld: −25 % peak tokens, +30 % acc (small model), preserves upper-bound accuracy
- OfficeBench: ~30 % peak-token reduction, accuracy ≥ 74 %
- 8-objective QA: −54.5 % peak tokens, −61.5 % dependency, EM/F1 beats no-compression baseline
- Distilled compressor retains ≥ 95 % of teacher accuracy
- Small distilled agents (Qwen3-14B) gain +32.4 % on AppWorld, +45.6 % on 8-objective QA

## Problem framing

Long-horizon LLM agents accumulate observation + action + observation + ... histories. Two bottlenecks:

1. **Memory**: KV-cache cost grows with context length.
2. **Distraction**: long contexts dilute relevant signals, hurting decision quality.

Existing compression families are insufficient:
- Document-/RAG-centric (LLMLingua, RECOMP, …) → assume single-step reasoning
- Dialogue summarization (MemoryBank, …) → focuses on coherence, not state tracking
- Heuristic agent compression (FIFO, retrieval, …) → brittle, narrowly specialized
- RL-based joint training (ReSum, …) → entangles compression with the agent LM, requires weight access

ACON's claim: a **universal, model-agnostic** compressor that works for **both history and observation** and
stays useful for proprietary API models.

## Method (3.1–3.4)

### Formulation

POMDP ⟨S, A, O, T, R⟩, agent LLM M(·; θ, P_agent) fixed. Two compression modes:

```
h'_t  = f_hist(h_t;  φ, P_hist)        if |h_t|  > T_hist      else h_t
o'_t  = f_obs (o_t, h_{t-1}; φ, P_obs) if |o_t|  > T_obs       else o_t
```

Optimization objective:

```
max_ψ  E[R(s_T(ψ))] − λ · E[C(H'(ψ))]      ψ ≜ (φ, P)
```

Hard to optimize directly because: no gold compression supervision, sparse reward, discrete cost, RL variance.

### 3.3 Compression Guideline Optimization (textual gradient)

ACON does **not** fine-tune the compressor's weights. Instead it refines the **prompt P**:

1. Run agent with and without compression on `D_train`.
2. Build `D_cont` = tasks where uncompressed run **succeeds** but compressed run **fails**.
3. For each `(H, H')` pair, ask an **optimizer LLM** (o3) for natural-language feedback:
   - "Lost variable/state", "Incorrect summary", "Missing facts", ...
4. Aggregate feedbacks → new guideline P^(1) (`UT` step = utility maximization).
5. Generate `K` candidate prompts, pick best on `D_cont`.
6. **Optional `CO` step** (compression maximization): condition only on successful compressed trajectories,
   ask LLM which info was actually used → shorter-but-sufficient guideline P^(2).

Two variants: **ACON_UT** (reward-optimal) and **ACON_UTCO** (also trims tokens).

### 3.4 Distillation

Teacher `(φ_T, P*)` generates `(x, y) = (h_t, h'_t)` or `((h_{t-1}, o_t), o'_t)` pairs on tasks where
teacher-compressed run succeeds. Student (Qwen3-14B / 8B, Phi-4 via LoRA) trained with cross-entropy
(Kim & Rush sequence-level distillation):

```
min_{φ_S} E_(x,y) ~ D_train^+ [ -Σ_n log f(y_n | x, y_<n ; φ_S, P*) ]
```

After distillation, the small LM replaces the teacher for compression at inference — the expensive agent
LM is reserved for decisions.

## Experiments (4)

- **Benchmarks**: AppWorld (168 tasks, 9 apps, ~100 users, ≥ 10 steps), OfficeBench (Word/Excel/Email),
  8-objective QA (search tool + consolidated answer).
- **Baselines**: No-Compression, FIFO, Retrieval (embedding top-k), LLMLingua, Prompting (naive general instruction).
- **Metrics**: Accuracy (goal completion), Steps, Peak Tokens, Dependency (cumulative attention on prior tokens).
- **Agent backbone**: ReAct (Yao 2023). Two compressor variants (UT, UTCO) and history/observation compression ablated.

### Headline results (AppWorld, gpt-4.1)

| Method | Acc ↑ | Peak (×10³) ↓ |
|---|---|---|
| No compression | 56.0 | 9.93 |
| LLMLingua (history) | 39.3 | 7.50 |
| Naive Prompting | 43.5 | 6.93 |
| **ACON_UT** | 51.2 | 7.17 |
| **ACON_UTCO** | **56.5** | 7.33 |

Key takeaways:
- ACON_UTCO matches the no-compression upper bound while cutting peak tokens.
- LLMLingua **degrades** medium/hard tasks severely (−30+ acc). Heuristic extractive compression is
  unsafe for state-tracking.
- For **observation** compression ACON dominates too (53.6 vs 42.3 for Prompting).

### OfficeBench / 8-objective QA

- ACON cuts peak tokens by ~30 % (OfficeBench) and 54.5 % (8-QA).
- On 8-QA EM/F1 actually **exceeds** the no-compression baseline — compression as **filtering**, not just shrinking.

### Distillation (Figure 4)

- Qwen3-14B / 8B / Phi-4 retain **> 95 %** of gpt-4.1 teacher accuracy.
- gpt-4.1-mini **without** distillation is already competitive → with a good guideline, the compressor
  model size is largely fungible.

### Distilled agent (small LM agents, Figure 5)

| Agent | Benchmark | No comp | ACON | Δ |
|---|---|---|---|---|
| Qwen3-14B | AppWorld | 25.6 | 33.9 | **+32.4 %** |
| Qwen3-14B | 8-QA EM | 0.158 | 0.230 | **+45.6 %** |

Smaller agents benefit **more** from compression because they're more distracted by long context.
This is the **equalizer finding**: compression narrows the gap to large agents.

### Threshold ablation (Figure 6)

Moderate thresholds (T_hist=4096, T_obs=1024) win. Too small → too many compression calls, accuracy loss.
Too large → little saving.

### Prompt optimizer ablation (Table 3)

- o3 + contrastive feedback is best (51.2 acc)
- gpt-4.1 optimizer drops 3.6 acc — still better than naive Prompting
- Optimization cost: < $2 per benchmark

### Practical efficiency (Table 4)

| Method | API cost / task | Latency / task |
|---|---|---|
| No Compression | $0.331 | 73.24 s |
| ACON (history) | $0.285 | 87.68 s |
| ACON (observation) | $0.272 | 101.92 s |

ACON **saves tokens, adds latency**. Compressor call is the new bottleneck — distillation is mandatory
for production, not optional.

## Why it matters for me / for the workspace

1. **Failure-driven textual gradient is a general primitive.** ACON's recipe (contrastive success/failure
   pairs → natural-language feedback → prompt refinement) doesn't need gradient access to the agent or
   compressor. It works for **any** API-only LLM. Drop-in for production agent stacks.
2. **Compression as a learned module, not a heuristic.** Validates the AGENTS.md direction:
   validated compression >> crude summarization (dadhich 2026 already framed this).
3. **Distilled compressor** is the production pattern. Don't run gpt-4.1 twice per step — distill
   the guideline into a 1B-class model and reserve the big model for decisions.
4. **Two-mode compression matters.** History compression + observation compression give different
   savings; benchmarks suggest combining both.
5. **UT vs UTCO trade-off rule.** Verbose/redundant env → UTCO; high-fidelity fact env → UT.
   This is a deployable heuristic, not just an experimental knob.

## Limitations / open questions

- Contrastive dataset `D_cont` requires **at least one successful uncompressed trajectory per task** —
  fails for tasks where uncompressed baseline can't solve the task at all.
- Single-step UT/CO iterations. Multi-step convergence (Appendix C) is mentioned but the paper defaults
  to one step. Risk of under-optimization.
- Compressor adds latency (Table 4) — only viable with distilled small model in production.
- Failure-mode granularity (Figure 3) is heuristic — "Lost variable/state / Incorrect summary / Missing facts"
  is hand-coded. Could itself be learned.

## Related work to read next

- **ReSum** (Wu et al. 2026) — RL-trained policy that better utilizes summarized contexts. Different
  trade-off (needs weight access).
- **LLMLingua-2 / LongLLMLingua** (Jiang 2024) — extractive compression baseline that ACON beats.
- **dadhich 2026** (already in our corpus) — lifecycle reframing of context management. ACON
  instantiates the **Architecting** + **Compacting** primitives explicitly.
- **CompactionRL** (Li 2026, already in our corpus) — RL variant for comparison.
- **StreamingLLM** (Xiao 2023) — KV-cache level complement; ACON is token-level, the two stack.

## BibTeX

```bibtex
@inproceedings{kang2026acon,
  title  = {ACON: Optimizing Context Compression for Long-horizon LLM Agents},
  author = {Kang, Minki and Chen, Wei-Ning and Han, Dongge and Inan, Huseyin A.
            and Wutschitz, Lukas and Chen, Yanzhi and Sim, Robert and Rajmohan, Saravan},
  booktitle = {Proceedings of the 43rd International Conference on Machine Learning},
  year   = {2026},
  url    = {https://arxiv.org/abs/2510.00615}
}
```