---
title: "Less Context, Better Agents: Efficient Context Engineering for Long-Horizon Tool-Using LLM Agents"
category: source
type: research-paper
tags: [context-engineering, context-pruning, conversation-summarization, tool-use, mcp, enterprise-agent, recency-policy, stale-state-errors, d365, cost-efficiency]
domain: code-agent
created: 2026-09-20
modified: 2026-09-20
related_wikis: [code-agent]
---

# Source: Less Context, Better Agents (Lodha et al., 2026)

## 基本資訊

| 欄位 | 內容 |
|------|------|
| **論文** | Less Context, Better Agents: Efficient Context Engineering for Long-Horizon Tool-Using LLM Agents |
| **作者** | Abhilasha Lodha, Mahsa Pahlavikhah Varnosfaderani, Abir Chakraborty, Abhinav Mithal |
| **單位** | Microsoft (Dynamics 365 Finance & Operations team) |
| **發表** | arXiv:2606.10209v1, 2026-06-08 |
| **領域** | cs.AI / cs.SE — Tool-use agents / Context engineering |
| **長度** | 17 pages, 3 figures, 8 tables |
| **URL** | https://arxiv.org/abs/2606.10209 |
| **PDF** | raw/references/papers/ai/2606.10209-less-context-better-agents.pdf |
| **Metadata** | raw/references/papers/ai/2606.10209-less-context-better-agents.md |

---

## 核心論點

### 問題背景

企業 LLM agent 在長流程 workflow（如 ERP expense itemization）會遭遇：
- **Verbose MCP tool responses** — D365 F&O 單個 tool response 500–3,000 tokens，包含 form state snapshot、metadata、navigation breadcrumbs
- **Cumulative context overflow** — 15–30 tool calls 後累計 50,000–150,000+ tokens
- **Stale-state errors** — 舊 tool response 描述已被 supersede 的 form state，agent 拿來做當前決策 → 錯誤 field assignment / 錯誤 navigation
- **Context rot** — production agent 普遍 failure mode，有效 recall 在 hard limit 之前就退化

### 解法（Algorithm 1）

**Semantic-level recency policy**，操作單位是**整個 tool call/response pair**（不是 token）：
- N = 保留最近幾對 tool call/response（本研究 N=5）
- W = summary window（本研究 W=3）
- Evict 超過 N 的最舊 pair（保留整對，不拆）
- 對被 evict 的最近 W 個 pair 跑**單次 LLM summarization**，產生「form opened / control interacted / button clicked / data entered」形式的 progress report
- 插入到最早 evicted position
- **Cost: 每次 eviction event 恰好多一個 LLM call**

與 [[memgpt-packer-2024]] 的分層 paging 對比：本論文是 **lightweight single-session policy**，不需 external store / retriever，純 inference-time。

與 [[scroll-programmatic-context-mgmt]] 對比：Scroll 是 **lossless**（event log 完整保留 + 程式化 query），本論文是 **lossy bounded**（eviction 不可恢復，但 summary 保留 task-level awareness）。

與 [[compactionrl-2026-li]] 對比：本論文是 **fixed-recency + single-pass summary**，CompactionRL 是 **learned compaction via PPO**。本論文本身就是 CompactionRL/ACON 應該 benchmark 的 baseline。

---

## 實驗結果（50-task hotel expense benchmark, 5 runs avg）

| Config | Comp. Item. | %Amt Item. | Total Tok | Time (hrs) |
|--------|-------------|------------|-----------|------------|
| C1 no user model | 8.0% | 58.89% | 532.6K | 3.08 |
| C2 full context (baseline) | 71.0% | 92.03% | 1,481.0K | 14.56 |
| C3 last 5 tool calls | 79.0% | 96.92% | 535.3K | 5.39 |
| **C4 last 5 + summary** | **91.6%** | **99.64%** | 553.4K | 5.79 |

**兩個關鍵洞見**：
1. **Pruning 提升 performance 的同時省 64% tokens** — 直覺違反：少 context 比多 context 表現更好
2. **Summary 在 C3 基礎上 +12.6 pp 只多 3.4% tokens** — summary 的邊際效益巨大

Statistical strength：Wilson 95% CI for C4 [87.5, 94.4] vs C3 [73.5, 83.6] **cleanly separated**，pooled 250 task-runs 的強證據。

---

## Failure Mode 機制（直接證明 stale-state hypothesis）

| Failure mode | C2 | C3 | C4 |
|---|---|---|---|
| Stale-state reference | 34 | 6 | 4 |
| Premature termination | 9 | 18 | 3 |
| **Total non-completions** | **73** | **53** | **21** |

**C2 → C3**：stale-state error 從 34 → 6，pruning 切斷了舊 form state 對當前決策的污染。
**C3 → C4**：premature termination 從 18 → 3，summary 重新注入 task-level progress awareness。
**總失敗數 71% 下降** (73→21)。

Residual 失敗模式（wrong subcategory / dup-skip / nav error / residual mismatch）大致 policy-invariant，反映 model-level reasoning 與 23-entry subcategory catalog 的 label ambiguity —— context engineering **不直接 target** 這些，但開出 8.4% tail 改進空間。

---

## Generalization

### Cross-category（5 expense types → 3 結構不同的類別）

| Category | n | C2→C4 lift | Token cut | Time cut |
|---|---|---|---|---|
| Hotel | 50 | +20.6 pp | -62% | -60% |
| Travel | 30 | +19.0 pp | -62% | -60% |
| Meals & Gifts | 32 | +20.5 pp | -61% | -57% |

**Lift 在所有 category 都接近 +20 pp**，token/time cut 都 60% 左右。Policy 不限於 multi-night hotel itemization，可推廣到 broader enterprise workflow。

### Cross-model（Claude Sonnet 4.5）

- **GPT-5 C1 只有 8.0%** — 在 non-interactive harness 會 stall
- **Sonnet 4.5 C1 已達 88.0%** — 不 stall
- 證明 C1→C2 大跳躍是 **model-specific stalling**，**不是 context engineering 的價值**
- C3→C4 ordering 仍然 hold：92.0% → 94.5%（+5.6% wall-clock premium）

---

## 對 Rowlet / OpenClaw 的啟發

1. **Context policy 應該是 first-class runtime config**，不是 prompt engineering afterthought。對 OpenClaw 的 agent runtime 來說，`KeepLastN=5 + SummaryWindow=3` 是 production-ready 起點。

2. **Failures 是「可以被機制化診斷」的**：本論文證明可以從 tool-call log + read-back discrepancy 推出 stale-state reference / premature termination 等 distinct 模式。這直接對位 [[agentic-context-mgmt-dadhich-2026]] 的 lifecycle view（validated compaction 需要 fidelity check 機制）以及 [[sirin-belikova-2026]] 的 faithfulness check。

3. **Pruning 對 C2 full-context 的反向直覺結果直接挑戰「context 越多越好」的產業敘事**。對位 [[lost-in-the-middle-2023-liu]] 的 U-shaped curve：本論文是 stale STATE 導致（不是 mid-prompt position），但都指向「少而精 > 多而雜」。

4. **Single-pass LLM summarization 是 surprising strong baseline**。CompactionRL（RL 學 compression policy）、ACON（learned compressor）、TRACE（boundary-local verifier）都應該把「fixed-recency + single-pass summary」作為 head-to-head baseline，不只是 [[memgpt-packer-2024]] 的 external store baseline。

5. **OpenClaw runtime cost 估算**：本論文 50-task benchmark 跑 5.79 小時，agent runtime 占絕大部分。如果 OpenClaw cron 觸發的 long-horizon task 累積 context 沒做 eviction，每月 token spend 會線性爆炸。`KeepLastN + SummaryWindow` 應該是 default。

---

## 與現有 source 的關係

| 論文 | 關係 |
|------|------|
| [[lost-in-the-middle-2023-liu]] | 同樣證明「context 越長 ≠ 越好」，但機制不同：lost-in-middle 是 mid-prompt position 偏誤，本論文是 stale form state 污染 |
| [[memgpt-packer-2024]] | MemGPT 主張 external memory tier + paging；本論文主張 **single-session 內 lightweight recency + summary 已經足夠**，不需要外部 store |
| [[scroll-programmatic-context-mgmt]] | Scroll 是 lossless（event log 完整 + 程式化 query）；本論文是 lossy bounded（eviction 不可逆但 summary 保留 awareness） |
| [[compactionrl-2026-li]] | CompactionRL 用 PPO 學 summarization policy；本論文是 **固定 recency + 單次 LLM summary**，應作為 CompactionRL 的 baseline |
| [[acon-2025-kang]] | ACON 用 textual gradient 在 natural language space 學 compressor guideline；本論文的 fixed-recency + summary 是 ACON 應 benchmark 的 simpler alternative |
| [[trace-2608.06503-min-2026]] | TRACE 用 boundary-local verifier 評估 compression quality；本論文的 C4 可視為 fixed heuristic，TRACE 是 dynamic verifier |
| [[hmem-llm-agents-sun-2025]] | H-MEM 用四層 hierarchical index + positional routing；本論文是更簡單的 flat recency + linear summary |
| [[agentic-context-mgmt-dadhich-2026]] | Dadhich 提出 context management 是 lifecycle 不是 store；本論文的 Algorithm 1 是 Scoping + Compacting 兩個 primitive 的具體實作 |

---

## 適合的 OpenClaw 實驗

- **預設 agent runtime config**：在 session bootstrap 時設 `KeepLastN=5, SummaryWindow=3`，對 OpenClaw 的 cron-driven agent 是 zero-cost win
- **Audit dashboard**：基於本論文六種 failure mode 的分類法，為 OpenClaw agent 加 read-back verifier（tool-call log + saved state diff）
- **Head-to-head benchmark**：拿 OpenClaw 的 heartbeat compaction 跟本論文的 C4 policy 比較 — 預設 OpenClaw 應該打不過，因為我們沒有 model-level summary，只做 crude truncation
- **跨模型驗證**：本論文證明 GPT-5 vs Sonnet 4.5 的 C1 stall 差異巨大，OpenClaw 的 agent 也應該做 cross-model sanity check，不要 overfit 某一個 LLM 的行為
