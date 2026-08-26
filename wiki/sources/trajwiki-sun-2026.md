# TrajWiki: Source-Grounded Memory Trajectories for Long-Horizon Dialogue Agents

## Metadata

| Field | Value |
|-------|-------|
| **arXiv ID** | 2608.00967v1 |
| **Title** | TrajWiki: Source-Grounded Memory Trajectories for Long-Horizon Dialogue Agents |
| **Authors** | Jingyu Sun, Yuyang Xue, Mingyang Li, Zhengtao Yao, Jiachen Li, Yang Cui, Wenhao Cai, Haozhe Liu, Fangying Wang, Magdalene Katharina Montgomery, Syed Murtuza Baker, Hongpeng Zhou |
| **Affiliations** | U Manchester (lead) · U Melbourne · U Edinburgh · USC · UT Austin |
| **Corresponding** | Hongpeng Zhou (Manchester) |
| **Submitted** | 2 Aug 2026 |
| **Subjects** | cs.AI |
| **URL** | https://arxiv.org/abs/2608.00967 |
| **PDF** | raw/references/papers/ai/2608-trajwiki/2608.00967.pdf |
| **Benchmarks** | LoCoMo (long-conversation memory), MedMT-Bench (LCMU / RCI / IC) |
| **Backbones** | GPT-4o-mini (closed), Qwen3-8B / Qwen3-32B (open) |
| **Date deep-read** | 2026-08-26 |

## Abstract 摘要

Long-horizon dialogue 受限於有限 context window + 缺乏 **traceable, updatable, diagnostically transparent** 的外部記憶。現有 memory-augmented agent 多以 isolated records / overwritable states 儲存，難以保留：資訊從哪來、如何演化、何時衝突、何時過時。

**TrajWiki** 提出 trajectory-based memory framework：
1. 把每段記憶視為一條 **source-grounded evolution trajectory**（不是 static entry）。
2. 由 **immutable episodic snapshots** + **claim-level operations**（ADD / REVISE / DEPRECATE）維護。
3. 引入 **Memory Wiki** 作為 persistent 中間層，incremental compile dialogue history 成 structured / interlinked wiki pages（entity / event / quantity / topic / conflict）。
4. Query 時走 hierarchical routing：wiki pages → linked trajectories → snapshots → source messages。

在 LoCoMo + MedMT 上 beat Full Context / Naive RAG / LangMem / A-MEM / Mem0。

## Core Contributions

### 1. Provenance-Aware Memory Trajectory Model

```text
D = {m_1, ..., m_N}, m_i = (x_i, u_i, τ_i, ρ_i)
            ↓
Σ = episodic snapshots (immutable)
            ↓
T_j = (σ_{j,1}, σ_{j,2}, ..., σ_{j,n_j})   # append-only trajectory
            ↓
C_{j,t} = Apply(C_{j,t-1}, O_{j,t}),   O ∈ {ADD, REVISE, DEPRECATE}
```

**核心概念**：
- **Snapshot 永遠 immutable**：修訂或廢棄的 claim 不刪除，永遠 link 回原 snapshot + source message。
- **Compatibility function g(σ, T⋆)** 決定 append 到既有 trajectory 還是 initialize new；考慮 entity continuity / facet overlap / lexical evidence / temporal compatibility / semantic drift。
- 這是 **git-like memory**：把 git 的 commit / diff / blame 模型搬進對話記憶。

### 2. Memory Wiki 中間層

```text
p = (η, y, h, L_p),  L_p ⊆ T
η ∈ {index, entity, topic, inventory}

W = Compile(T; C_active, C_hist, A)
```

四種 page type：
| Type | 職責 |
|------|------|
| **index** | Global directory — 所有 page 的入口 |
| **entity** | Recurring entities（人、地點、組織、物件） |
| **topic** | Events / thematic clusters |
| **inventory** | List-like / countable facts（食譜、活動、待辦） |

**關鍵設計**：wiki **不取代 source evidence**，只 organize 累積記憶；所有 page 都保留 trajectory link。

### 3. Hierarchical Retrieval + Evidence-Grounded Generation

```text
Query q
  ↓
P_q = Topt {S_p(q, p) : p ∈ W}      ← routing 到相關 wiki pages
  ↓
C_q = ∪_{p ∈ P_q} L_p                ← candidate trajectories
  ↓
R_q = Top_k {b(q,T) + α·Δcov(T) − λ·red(T) : T ∈ C_q}
  ↓
E_q = {(T, σ, c, ρ, τ) : T ∈ R_q, σ ∈ T, c ∈ C_T}
  ↓
z_q = Synth_θ(q, E_q),  a_q = Answer(z_q)
refs(a_q) ⊆ refs(E_q)                ← source-support constraint
```

**Retrieval objective 同時優化三件事**：
- `b(q, T)`：relevance baseline
- `Δcov(T)`：complementary entities / events / facets / counts（鼓勵多 trajectory 互補）
- `red(T)`：redundancy penalty（避免重複 evidence）

**重要 safety property**：`refs(a_q) ⊆ refs(E_q)` — 答案的所有引用都必須來自 retrieved evidence。證據不足時 abstain 或 controlled retry。

### 4. Diagnostic Visibility

不只追求 retrieval quality，還提供**可量化的 audit 指標**：
- **Gold Ref Coverage**：retrieval 中含 gold source reference 的比例
- **Unsupported Risk Proxy**：retrieved evidence 中沒有 source support 的比例
- **Trajectory Semantic Drift**：head-tail cosine similarity + adjacent-snapshot similarity（圖 5）
- **Snapshot Budget Coverage**：gold evidence 在 trajectory 中的 rank 分布（圖 4）

## Empirical Results

### LoCoMo (Table 1)

| Method | Backbone | Single-hop (F1) | Multi-hop (Acc) | Temporal (Acc) | Open (Acc) |
|--------|----------|----------------|-----------------|----------------|------------|
| Full Context | GPT-4o-mini | 32.98 | 30.22 | 35.42 | 43.77 |
| Mem0 | GPT-4o-mini | 40.07 | 30.56 | 25.02 | 37.19 |
| **TrajWiki** | **GPT-4o-mini** | **59.44** | **35.39** | **42.12** | **48.72** |
| Mem0 | Qwen3-32B | 45.74 | 31.49 | 42.70 | 42.58 |
| **TrajWiki** | **Qwen3-32B** | 50.33 | 37.33 | 39.68 | 41.88 |

**Multi-hop +19.5 Acc over strongest baseline (Mem0)** on GPT backbone — 是 source-grounded trajectory + wiki routing 的最大戰場。

### MedMT-Bench (Stress Test)

| Method | LCMU (Acc) | RCI (Acc) | IC (Acc) |
|--------|-----------|-----------|----------|
| Full Context | 71.72 | 27.12 | 7.47 |
| Mem0 | 44.48 | 17.11 | 12.17 |
| **TrajWiki (GPT)** | **78.56** | **29.33** | **17.68** |

**IC subset 17.68 vs 12.17** — Information Contradiction（偵測 historical fact 與 current user statement 衝突）正是 trajectory-level provenance 的目標場景。

### Counterfactual Ablation (Table 2, GPT-4o-mini, k=15, 32K ctx)

| Setting | Cand. Univ. | Gold Ref Cov | Unsup. Risk |
|---------|------------|--------------|-------------|
| **Full TrajWiki** | 55.6 | **0.610** | 0.645 |
| Direct Trajectory Retrieval（去掉 wiki routing） | 130.4 | 0.356 | 0.872 |
| Wiki Summaries Only（只取 wiki 不要 snapshot expansion） | — | **0.000** | **1.000** |
| Flat Raw-Memory Retrieval（全部扁平檢索） | — | 0.237 | 0.918 |
| Latest Snapshot Only（只看 trajectory 最新 snapshot） | — | 0.613 | 0.649 |

**最震撼的數字**：
- 沒有 wiki routing → candidate 從 55.6 暴增到 130.4，gold ref coverage 從 0.610 → 0.356。Wiki 不是 lossy filter，是 semantic organization。
- **Wiki Summaries Only → Gold Ref Cov = 0.000**：光靠 wiki 摘要拿不到 source reference，因為 wiki 是 abstraction、不是 raw evidence。**Wiki 必須和 snapshot expansion 一起**。

### Cost & Scalability

- 整體 LoCoMo run：43.28M deployment tokens
  - 23.71M memory construction（reusable）
  - 10.84M query-time retrieval
  - 6.92M answer generation
- **Memory Wiki 把 search space 從 130.4 → 55.6 trajectories（2.35× reduction）**
- Hyperparameter sweet spot：t=15 wiki pages, k=15 trajectories, m=15 snapshot budget

### Trajectory Semantic Drift (Figure 5)

- 大多 non-singleton trajectories 維持 moderate-to-high head-tail similarity
- 長 trajectory 自然有 broader semantic range，但 **adjacent-update similarity 仍穩定**
- 表示 TrajWiki 支持 gradual memory evolution，不是 arbitrary aggregation

## Limitations（論文自己承認的）

1. **Provenance-aware ≠ provenance-perfect**：依賴 structured LLM outputs，malformed output 觸發 fallback / repair paths（弱 instruction-tuned model 更明顯）。
2. **Repeated abstraction shift salience**：summarization 可能讓某些 facts 重要度被壓低，導致生成答案時依賴 compressed memory 而非最相關 raw evidence。
3. **Diagnostics 是 proxy**：unsupported-answer risk、invalid supporting references 是 proxy metrics，不是 human-verified audit accuracy。
4. **Cost trade-off**：43M token 是真的前置成本（雖然 reusable）。

## 與同類方法的關鍵差異

| 方法 | Memory model | Update semantics | Organization | Retrieval | Provenance |
|------|--------------|------------------|--------------|-----------|------------|
| **TrajWiki** | evolution trajectory | ADD/REVISE/DEPRECATE | wiki pages | hierarchical | claim-level |
| MemGPT | tier paging | FIFO eviction | main/recall/archival | function calls | weak |
| Mem0 | facts + reflections | extract/consolidate | extraction pipeline | flat | weak |
| A-MEM | Zettelkasten notes | dynamic linking | graph | associative | link-level |
| CompactionRL | compact segments | learned summary action | none | token-level | none |
| ACE | raw+abstract dual-layer | per-step type assignment | orchestrator | per-step | reversible |

## 對 OpenClaw / Rowlet 的直接啟發

1. **Memory revision 要變成 explicit operations**：目前 `MEMORY.md` / daily memory 的更新是 append + overwrite 混合，沒有區分「新增」、「修訂」、「廢棄」。可以借鑒 git-like ADD / REVISE / DEPRECATE：
   - 修訂時保留 predecessor + delta（不在 daily memory 刪原文，而是 mark as `revised_by: 2026-08-26 T12:00`）
   - 廢棄時 mark `deprecated_at` 但保留 snapshot（避免「歷史被無聲改寫」）
   - 這對 long-horizon task（例如 multi-session research project）特別有價值

2. **Memory Wiki 是 graphify 的精神同伴**：現有 graphify graph 偏向「靜態 entity-relation」，沒有 evolution trajectory 與 claim-level provenance。下一代可以考慮：
   - 為每個 node 加上 evolution history（每次 update 是一個 immutable snapshot）
   - 加入 conflict detection（IC subset 的 17.68% TrajWiki vs 12.17% Mem0 是直接證據：軌跡化比純 fact extraction 更能抓 contradiction）
   - query 時不只是 top-k similarity，而是 relevance + coverage + redundancy 三軸

3. **Hierarchical routing 可直接套到 graphify**：
   - 現有 `/graphify query` 是 flat top-k。
   - 借鑒 `P_q = Topt {S_p(q, p)}` 模式：先 route 到 wiki/community level（graphify 已經有 community detection），再展開到 source-level。

4. **Diagnostic visibility 應該進入 Rowlet 的 heartbeat**：TrajWiki 把 unsupported-answer risk 量化，是「不只追求性能，也追求可審計」的代表。Rowlet 的三層記憶寫入前可以加：
   - source link check（這段記憶有沒有 source message reference？）
   - trajectory coherence check（與同 trajectory 上一 snapshot 的 semantic drift 是否過大？）
   - conflict check（是否與現有 active claim 矛盾？）

5. **Trade-off 認知**：43M tokens 是 non-trivial 前置成本。對 Rowlet 來說，這個成本只有在「long-running agent with persistent memory」場景才划算 — 對每次 session 重新讀 SOUL.md 的 case 不需要。

## 最值得討論的 5 個重點

1. **Memory 應從 static entries 升級到 evolution trajectories** — git-like commit / diff / blame 模型對 long-horizon dialogue agent 是 auditability 必備，而非可選。

2. **Wiki + Snapshot 是必要組合，不能二選一** — Counterfactual 證明：Wiki alone = 0% gold ref coverage；Flat alone = high unsupported risk。Semantic organization 必須跟 raw evidence preservation 並存。

3. **Claim-level provenance > record-level provenance** — 大部分現有 system 只記「現在相信什麼」，TrajWiki 記「現在相信什麼 + 之前相信過什麼 + 何時改變 + 為什麼改變」。後者才能做 IC detection、temporal reasoning、retrieval failure diagnosis。

4. **Diagnostic visibility 應該是 first-class output，不是 afterthought** — 把 unsupported risk / trajectory drift / snapshot budget coverage 量化，是 production agent debug 的基礎設施。對應 [[sirin-belikova-2026]] 的 faithfulness check + [[agentic-context-mgmt-dadhich-2026]] 的 lifecycle view。

5. **Long-horizon memory 是 amortizable investment** — 43M token 前置成本看似高，但 reusable memory construction（23.71M / 43.28M = 55%）是 amortized 跨所有後續 query。在 long-running agent 場景下，unit cost 隨 query 數下降。

## Related Work 對位

- **MemoryBank** / **MemoryOS** → hierarchical storage
- **MemGPT** → paging-based runtime memory（vs TrajWiki 的 provenance-based）
- **A-MEM** → dynamically linked memory notes（link-level provenance，無 claim-level）
- **Mem0** → incremental extraction + consolidation（no edit semantics）
- **RAPTOR** / **GraphRAG** → tree/graph organization for external corpora（TrajWiki 目標是 internal dialogue memory）
- **HippoRAG** → neurobiologically inspired long-term memory
- **Zep** → temporal knowledge graph（vs TrajWiki 的 episodic trajectory）

## Status

- Deep-read: 2026-08-26
- Status: seed（待後續 graphify 整合 + heartbeat integration）
