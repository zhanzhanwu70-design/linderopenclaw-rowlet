---
title: "ACON: Optimizing Context Compression for Long-horizon LLM Agents"
category: source
type: research-paper
tags: [context-compression, long-horizon-agents, textual-gradient, prompt-optimization, distillation, model-agnostic, AppWorld, OfficeBench, ReAct]
domain: code-agent
created: 2026-08-24
modified: 2026-08-24
related wikis: [code-agent, agent-frameworks]
---

# Source: ACON (Kang et al., 2026)

## 基本資訊

| 欄位 | 內容 |
|------|------|
| **論文** | ACON: Optimizing Context Compression for Long-horizon LLM Agents |
| **作者** | Minki Kang¹, Wei-Ning Chen², Dongge Han², Huseyin A. Inan², Lukas Wutschitz², Yanzhi Chen²·³, Robert Sim², Saravan Rajmohan² |
| **單位** | ¹ KAIST · ² Microsoft · ³ University of Cambridge |
| **發表** | arXiv:2510.00615v3, 2026-06-01 |
| **出版** | ICML 2026 (PMLR 306) |
| **領域** | cs.AI — Context Compression / Long-horizon Agent / Prompt Optimization |
| **頁數** | 9 pages (main), 57 pages total |
| **URL** | https://arxiv.org/abs/2510.00615 |
| **PDF** | raw/references/papers/ai/acon-2025/acon-2025-kang.pdf |
| **Metadata** | raw/references/papers/ai/acon-2025/acon-2025-kang.metadata.md |
| **Code** | https://github.com/microsoft/acon |

---

## 核心論點

### 問題

Long-horizon LLM agent（≥ 10 步互動）的 context 同時撞上兩個牆：

1. **Memory cost** — KV-cache 隨 context 長度線性（甚至更糟）膨脹。
2. **Distraction** — irrelevant tokens 稀釋相關訊號，**degrade decision quality**。

既有壓縮路線都不夠：

| 路線 | 代表 | 為什麼不夠 |
|------|------|----------|
| Document / RAG-centric | LLMLingua、LongLLMLingua、RECOMP | 預設 single-step reasoning |
| Dialogue summarization | MemoryBank、StreamingLLM | 重 coherence 不重 state tracking |
| Heuristic agent compression | FIFO、Retrieval top-k | brittle、窄域 |
| RL joint training | ReSum、CompactionRL | 把壓縮寫進 agent 權重 → 對 proprietary API model 不可行 |

### 主張

> **壓縮是一個 learned module，不是 heuristic，也不是 agent 的一部分。** 把壓縮 guideline 放在 **natural language space** 優化，**model-agnostic**，可直接套在 GPT-4.1 / Claude / Gemini 之類的封閉 API 上。

### 三個貢獻

1. **Compression Guideline Optimization（§3.3）**：用 contrastive trajectory pairs（成功無壓縮 vs 失敗有壓縮）餵給 optimizer LLM（o3）生 natural-language feedback，再 refine 壓縮 prompt。本質上是 **textual gradient descent on prompts**（Yüksekgönül 2025, Pryzant 2023 的延伸）。
2. **Two-stage UT → CO**：先做 utility maximization（保 reward），再做 compression maximization（trim tokens）。對應兩個變體 **ACON_UT** 與 **ACON_UTCO**。
3. **Distillation（§3.4）**：把 teacher compressor `(φ_T, P*)` 的 (input, compressed) pairs 用 cross-entropy（Kim & Rush）蒸進小模型（Qwen3-14B/8B, Phi-4 via LoRA），保留 ≥ 95 % teacher accuracy，把壓縮成本降下來。

---

## 方法（細節）

### Formulation

POMDP `⟨S, A, O, T, R⟩`，agent LLM `M(·; θ, P_agent)` **固定**。兩個壓縮模式：

```
h'_t  = f_hist(h_t;        φ, P_hist)  if |h_t| > T_hist   else h_t
o'_t  = f_obs (o_t, h_{t-1}; φ, P_obs)  if |o_t| > T_obs    else o_t
```

目標：

```
max_ψ  E[R(s_T(ψ))] − λ · E[C(H'(ψ))],     ψ ≜ (φ, P)
```

直接優化難：沒有 gold 壓縮 label、reward 稀疏、cost 離散、policy gradient 高變異。

### 3.3 Textual Gradient Pipeline

```
D_train 上跑兩種 trajectory（w/ 和 w/o compression）
   ↓
D_cont = { tasks where uncompressed succeeded AND compressed failed }
   ↓
Optimizer LLM (o3) 看 (H, H') pairs → natural language feedback
   ↓
Aggregate feedback → P^(1)        ← UT step（utility maximization）
   ↓
Generate K candidate prompts, pick best on D_cont
   ↓
Condition on successful compressed runs → P^(2)    ← CO step（compression maximization）
```

產出：environment-specific compression guideline，例如「維持 HISTORY_SUMMARY、REASONING block、VARS table」。

### 3.4 Distillation

```
Teacher (φ_T, P*) generates (x, y) on D_train^+ (teacher-compressed success)
   ↓
Student φ_S trained with Kim-Rush sequence-level CE on (x, y)
   ↓
At inference, student replaces teacher for compression calls
```

LoRA 在 Qwen3 / Phi-4 上 fine-tune 就夠，無需重訓整個 base model。

---

## 實驗結果（重點）

### Setup

- **Benchmarks**：AppWorld（168 tasks, 9 apps, ~100 users）、OfficeBench（Word/Excel/Email）、8-objective QA（search + 合併答案）。
- **Agent**：ReAct（Yao 2023）。
- **Backbone**：gpt-4.1（agent + compressor）；distillation → Qwen3-14B/8B, Phi-4。
- **Baselines**：No-Compression、FIFO、Retrieval top-k、LLMLingua、Naive Prompting。
- **Metrics**：Acc / Steps / Peak Tokens / Dependency。

### AppWorld（gpt-4.1, history compression）

| Method | Acc ↑ | Peak (×10³) ↓ |
|---|---|---|
| No compression | 56.0 | 9.93 |
| LLMLingua | 39.3 | 7.50 |
| Naive Prompting | 43.5 | 6.93 |
| **ACON_UT** | 51.2 | 7.17 |
| **ACON_UTCO** | **56.5** | 7.33 |

→ ACON_UTCO **match 上限同時砍 25 % peak tokens**。LLMLingua 在 medium/hard 直接退化 −30+ acc。

### OfficeBench / 8-objective QA

- OfficeBench：~30 % peak 降幅，acc ≥ 74 %。
- 8-QA：**−54.5 % peak tokens、−61.5 % dependency、EM/F1 beats no-compression** → 壓縮在此不只是省 token，是 **filter distraction**。

### Distillation（Fig 4）

- Qwen3-14B / 8B / Phi-4 → 保留 **≥ 95 %** teacher accuracy。
- gpt-4.1-mini **不蒸**就直接能用 → 只要 guideline 對，compressor model size 高度 fungible。

### Distilled Agent（Fig 5）— **equalizer finding**

| Agent | Benchmark | No comp | ACON | Δ |
|---|---|---|---|---|
| Qwen3-14B | AppWorld | 25.6 | 33.9 | **+32.4 %** |
| Qwen3-14B | 8-QA EM | 0.158 | 0.230 | **+45.6 %** |

→ 小 agent **受惠更多**。壓縮縮窄了與大模型的距離，這是 AGENTS / dadhich 框架一直在講的「validated compression wins」的實證。

### Threshold Ablation（Fig 6）

Moderate wins：T_hist=4096、T_obs=1024 是 sweet spot。太低 → 太頻繁呼叫、acc 掉；太高 → 沒省到。

### Prompt Optimizer Ablation（Table 3）

o3 + contrastive feedback = 51.2 acc；換成 gpt-4.1 optimizer −3.6 但仍勝 naive prompting。**Optim cost < $2 per benchmark**，對 production 極便宜。

### Practical Efficiency（Table 4）

| Method | API cost / task | Latency / task |
|---|---|---|
| No Compression | $0.331 | 73.24 s |
| ACON (history) | $0.285 | 87.68 s |
| ACON (observation) | $0.272 | 101.92 s |

→ 壓縮 **省 token、加 latency**。Compressor call 是新瓶頸 → **蒸餾是 production mandatory，不是 nice-to-have**。

---

## 和現有 Wiki 的關聯

### 和 [[agentic-context-mgmt-dadhich-2026]]（lifecycle reframing）的關係

Dadhich 提出 context management 是 **lifecycle**（Architecting / Ingesting / Scoping / Anticipating / Compacting）。
ACON 正好實作其中兩個：

- **Architecting**：per-environment guideline schema（REASONING + VARS table）。
- **Compacting & Consolidation**：validated compression with fidelity check via contrastive feedback。

→ ACON 是 dadhich 框架的 **specific instance**，證明這個 lifecycle 在 production 是真的可以跑得動的。

### 和 [[compactionrl-2026-li]]（RL 變體）的關係

| 軸 | ACON | CompactionRL |
|---|---|---|
| Update target | Compressor prompt P | Agent LM 權重 |
| 適用 proprietary API | ✅ 完全可行 | ❌ 需 weight access |
| Cost | < $2 / benchmark optimization | RL training + rollout cost |
| Latency | ＋ compressor call | 無 |
| Distillation | Built-in | N/A |

→ 兩者 **互補**：能改權重 → CompactionRL；只能 API → ACON。

### 和 [[lost-in-the-middle-2023-liu]]（位置偏差）的關係

Liu et al. 證明 long context **未必被用好**（U-shape、primacy/recency bias）。
ACON 的 **compression as filtering** 直接補救 — 把中段的高雜訊拿掉，讓模型看到的是「clean + informative」，不是「完整 + 失焦」。

### 和 [[memgpt-2024-packer]]（paging 架構）的關係

MemGPT 走 paging + function call，分層記憶。ACON 走 prompt optimization，兩者攻不同抽象層：
- MemGPT 改的是 **系統架構**（OS-style paging）。
- ACON 改的是 **壓縮函式的品質**（model-agnostic compressor）。

兩者可以疊用：MemGPT 決定 page-in 哪些 block，ACON 決定 page-in 後是否還要再壓。

### 和 [[context-engineering-2025-mei]] 的關係

Survey 把 context compression 列為 Asymmetry Problem 對策之一。ACON 提供了一個 **實證 reference implementation**，具體化了 survey 的抽象建議。

### 和 [[hmem-llm-agents-sun-2025]]（hierarchical memory）的關係

H-MEM 用四層 hierarchy + positional index encoding 做 retrieval 加速。ACON 不解決 retrieval 加速，解決的是 **「retrieved 之後要不要再壓、怎麼壓」**。組合路徑：H-MEM 做 retrieval → ACON 做 post-retrieval compression。

---

## 對 OpenClaw / Rowlet 的啟發

1. **Failure-driven textual gradient 是通用 primitive**。ACON 的 recipe（contrastive success/failure → natural-language feedback → prompt refine）**不需要 gradient access**。可直接套到 Rowlet 自己的 workflow 上 — 例如「如果某次 cron 任務失敗，反思 prompt 是否讓模型在 long heartbeat log 上 lost-in-the-middle」。
2. **不要用大 model 兩次**。Compressor 一定要 distill，否則 latency 把 agent 拖垮。Rowlet 在 whisper.cpp / local toolchain 上已經這樣做（CPU-only / static build），這個原則同樣適用於 compressor。
3. **Per-environment guideline schema 比 universal prompt 好**。ACON 證明 environment-specific rules 跨多樣任務都一致 win。這和 dadhich 的 Architecting primitive 完全一致：不要 hardcode universal memory shape，要 per-agent-type schema。
4. **UT vs UTCO 是一個 deployable knob**。Verbose/redundant env → UTCO；high-fidelity fact env → UT。在 Rowlet 的 cron / heartbeat 場景裡，daily memory ingest 通常偏 verbose → 預設 UTCO；transcript lookup 偏 fact → 預設 UT。
5. **Compression 作為 equalizer**。小 model + 好 compressor ≈ 大 model + 無 compressor。對未來要把 Rowlet 換成更小 / 更快 backbone 的情境，是直接的杠杆。

---

## 討論問題（值得團隊討論）

1. **對比 ReSum 與 CompactionRL**：ACON 走 prompt-side、ReSum / CompactionRL 走 weight-side。在能 access weight 的情境下，ACON + ReSum 是不是可以疊加（先優化 compressor prompt，再用 RL 微調 agent 配合 compressor）？
2. **Contrastive subset 的最低要求**：`D_cont` 要求 **至少一個 uncompressed 成功 trajectory per task**。如果某任務 uncompressed baseline 就跑不動（hard task），ACON 還能用嗎？是不是要先 bootstrap 一個 capable baseline？
3. **Observation compression 的 threshold 取捨**：Table 1 history 壓縮表現較 observation 壓縮強。Observation 是「當下 raw output」，detail 比較重要。是否要對 observation 採用更保守的策略（例如只在 token > 8K 時才壓）？
4. **Distillation 的 data efficiency**：teacher `(x, y)` pairs 是多少？需要多少 trajectory 才夠蒸一個小 student？對 production budget 的衝擊是什麼？
5. **跨環境 transferability**：如果 AppWorld guideline 移到 OfficeBench，是 reuse 還是 retrain？論文的 failure-driven feedback 應該每個 environment 各自做一輪；如果能 cross-environment transfer，等於免費拿別人的 guideline。

---

## 備註

- PDF 已存：`raw/references/papers/ai/acon-2025/acon-2025-kang.pdf`（~2 MB）
- 文字版：`raw/references/papers/ai/acon-2025/acon-2025-kang.txt`（3596 行，pdftotext -layout 抽取）
- Metadata：`raw/references/papers/ai/acon-2025/acon-2025-kang.metadata.md`
- 為 [[code-agent]] map 的補充：在 [[agentic-context-mgmt-dadhich-2026]] 的 lifecycle 框架下提供實證 reference