---
title: "PAIR: Counterfactual-Adjusted Context Compression for Frozen Long-Horizon Agents"
category: source
type: research-paper
tags: [context-compression, long-horizon-agents, counterfactual, prompt-adaptation, frozen-agent, reliability, pass3, PAIR, AppWorld, OfficeBench, tau2-bench]
domain: code-agent
created: 2026-10-15
modified: 2026-10-15
related: [acon-2025-kang, memgpt-2024-packer, context-engineering-2025-mei, lost-in-the-middle-2023-liu]
---

# Source: PAIR (Min et al., 2026)

## 基本資訊

| 欄位 | 內容 |
|------|------|
| **論文** | Adapting Context Compression for Long-Horizon Agents with Counterfactual Continuations |
| **作者** | Guanghui Min¹, Liang Wu², Minjia Shi¹, Yinhan He¹, Mayank Darbari², Liangjie Hong², Chen Chen¹ |
| **單位** | ¹ University of Virginia · ² Nokia |
| **發表** | arXiv:2609.36526v1, 2026-09-29 |
| **頁數** | 41 (9 main figures / 9 tables) |
| **領域** | cs.LG / cs.AI / cs.CL — Counterfactual Prompt Adaptation |
| **URL** | https://arxiv.org/abs/2609.36526 |
| **PDF** | raw/references/papers/ai/pair-2026-min/pair-2026-min.pdf |
| **Code** | （arXiv 沒列，9 天前 v1 通常還沒公開 release）|

---

## 一句話總結

> **Trajectory-level 訊號不夠；要用 matched counterfactual continuations 在每個 compression boundary 上算 (pre, post) 的 Q-value 差，才能準確地改 compression prompt。**

實作上叫 **PAIR (Prompt Adaptation using Interventional Rollouts)**，在 Pass3 上系統性贏 ACON 2.1%–10.0%，accuracy 偶爾超過 no-compression baseline。

---

## 核心論點

### 1. 問題再定義

> 9 days after ACON, the field needs causal attribution at compression boundaries, not trajectory-level comparisons.

ACON 的弱點（pair 論文自己講）：
- A long trajectory 可能經歷 **好幾次** compression。
- Trajectory outcome（成功 / 失敗）**無法定位是哪一次** compression 害的。
- Agent stochasticity → 同一 context 兩次 rollout 可能差很多，**A/B comparison 噪音巨大**。
- 結果：修 prompt 的時候修錯地方、或者修了沒用的地方。

### 2. 關鍵發現

#### 2.1 Reliability degrades before solvability

把 90 個 AppWorld training tasks 用 GPT-5.6 Luna 和 MiniMax-M3 各跑 3 次：

| Window | Pass@3 (solvability) | Pass3 (reliability) |
|--------|---------------------|---------------------|
| ∞ (no comp) | ~85% | ~78% |
| 8K | 略降 | 顯著降 |
| 4K | 顯著降 | 暴降 |
| 2K | 還行 | 谷底 |

→ Pass3 永遠比 Pass@3 掉得快。**Compression 不只是把任務變難，是把任務變 flaky**。

#### 2.2 Severe degradation concentrated at isolated boundaries

對每個 boundary ξₜ = (hₜ₊₁, z̄ₜ₊₁)：
- **同樣的 environment state** 從 `z̄ₜ₊₁` (pre) 與 `cₜ₊₁` (post) 兩條 rollout。
- 兩條都**關掉後續 compression**，純粹量「這一次 compression 的因果效應」。
- 觀察結果：**大多數** boundary 影響 mild（多幾步），**少數** boundary 才是 catastrophic failure。

→ Compression 的 risk 是 **長尾分佈**。大部分 boundary 還行，害死 agent 的是那幾顆「壞 boundary」。**這是 causal attribution 必要性的統計根據**。

### 3. PAIR 方法

三步：

1. **Detect**：在 D_train 上跑 baseline compression rollout + counterfactual pre/post continuations。對每個 boundary 算 (ΔR, ΔL) = (R_post − R_pre, L_post − L_pre)，找出 **outlier bad boundaries**（ΔR 顯著負、ΔL 顯著正）。
2. **Diagnose**：把 bad boundary 的 (pre, post) context 餵給 LLM-as-judge，問「post 漏了什麼關鍵資訊？」
3. **Revise**：在 **固定的、deployment-compatible compression template** 上，**只改對應 section**（不是全改）。生成 K=5 candidate prompts，選在 D_train 上 Pass3 最高的那個。

**全程不改 agent / compressor model / tools / decoding**。這和 ACON 一樣是 model-agnostic，但 attribution 更精準。

### 4. 形式化亮點

PAIR 引進一個 **Performance-Difference Identity**：

```
E[R(τ | z_{t+1}=c)] - E[R(τ | z_{t+1}=z̄)]
   = E[ Q^R(z̄, c) - Q^R(z̄, z̄) ]     ←  boundary effect
   - λ · E[ cost(c) - cost(z̄) ]       ←  compression cost
```

→ 連接 **boundary-level Q-value** 和 **compressor policy objective**。這個 identity 讓「修哪段 prompt」有理論根據，不是 heuristic。

---

## 實驗結果

### Setup

- **Benchmarks**：AppWorld (90 train + 168 test)、OfficeBench (Word/Excel/Email)、τ²-Bench Retail。
- **Models**：GPT-5.6 Luna（agent + compressor），MiniMax-M3（cross-model transfer）。
- **Backbone contexts**：frozen (agent 權重不動)。
- **Baselines**：No Compression, FIFO, LLMLingua-2, Prompting, ACON-UT, ACON-UTCO。
- **Metrics**：Accuracy, Pass@3, **Pass3** (主要), Steps, Peak tokens。

### Headline result（節錄）

**OfficeBench (history-only)**：

| Method | Acc ↑ | Pass3 ↑ | Steps ↓ | Peak ↓ |
|---|---|---|---|---|
| No Compression | 82.1 | 75.8 | 11.2 | 7.02K |
| LLMLingua-2 | 76.1 | 68.4 | 14.4 | 4.14K |
| ACON-UTCO | 73.0 | 60.0 | 13.6 | 3.95K |
| **PAIR** | **81.1** | **70.5** | **11.9** | **3.89K** |

**AppWorld (history-only)**：
- PAIR 84.7% acc, 79.8% Pass3 → **超過 no-compression**（84.1 / 78.6）。
- Pass3 勝過 best ACON 2.1%–10.0%。
- 增益集中在 medium / hard tasks；easy task 已 saturation。

### Cross-model transfer (Fig 4)

GPT-5.6 Luna 訓練的 PAIR prompt，**零樣本 transfer 到 MiniMax-M3**：
- AppWorld prefix-conditioned：acc 79.6 → 84.1，Pass3 65.5 → 73.2。
- OfficeBench：acc 雙 scope 都升。

→ **PAIR 學到的是「什麼資訊該留」，不是「怎麼對某個模型說話」**。這是比 ACON 更強的 generalization claim。

### Efficiency (Fig 5)

- Pass3 全面提升 5.0%–11.3% 的同時，**6 個 benchmark×scope 組合中有 4 個 token 用量下降**。
- 例外：AppWorld prefix +3.7%, τ²-Bench prefix +8.5%（compressor overhead 蓋過 agent 端省下的）。
- 相對 no-compression：AppWorld token 持平，OfficeBench 少 15–19%，τ²-Bench 多 ~12%。

---

## 與 [[acon-2025-kang]] 的關鍵差異

| 軸 | ACON | PAIR |
|---|---|---|
| 訊號源 | Trajectory-level 對比 (whole run) | Boundary-level counterfactual (per compression) |
| Attribution | 整條 run 成功/失敗 | 單次 compression 的 Q-value 差 |
| Template 結構 | Free-form prompt optimization | **固定的 sectioned template**，只改相關段 |
| 主要 metric | Accuracy | **Pass3**（reliability） |
| Counterfactual | ❌ | ✅ 核心 |
| Cross-model transfer | 未深入測試 | ✅ Zero-shot transfer 驗證 |
| 編輯粒度 | 整段 prompt 重生 | Section-level surgical edit |
| 主要贏點 | AppWorld acc | **Pass3 + 跨模型 generalization** |

→ ACON 和 PAIR **不是競爭關係，是同路線的兩代**。PAIR 解決了 ACON 的 attribution 問題，ACON 的 textual-gradient recipe 仍可作為 PAIR 內部 prompt candidate generator。

---

## 對 OpenClaw / Rowlet 的啟發

1. **Causal attribution 是通用 recipe**。PAIR 證明「**counterfactual 評估 + 局部 prompt 編輯**」對 frozen agent 普遍有效。Rowlet 的 cron jobs 大多是 frozen workflow → 同一個 recipe 可以套到「哪一步 prompt 讓 task 失敗」的診斷上。
2. **長尾邊界 = 高 ROI 修補點**。PAIR 證明 catastrophic degradation 集中在少數 boundary。Rowlet 的記憶系統若有 boundary 概念（daily memory → MEMORY.md 抽樣），可以優先 audit 那些「失敗率異常高」的 boundary。
3. **Pass3 > Pass@3 才是 production metric**。ACON 看 accuracy，PAIR 看 reliability（Pass3 = 3 次都過的比率）。Rowlet 的 cron 任務應該 track 「連續 3 次都成功才計 success」 — 這比單次成功率更能反映 deployment 真實可靠性。
4. **Sectioned template 優於 free-form prompt**。ACON 可以整段重寫，PAIR 只改對應段。對 production 系統，後者更安全（不會 regress 其他段）。Rowlet 的 HEARTBEAT.md / MEMORY.md 等 template 應該明確分 section，prompt adaptation 只動一節。
5. **零樣本跨模型 transfer 是新基準**。PAIR 證明學到的「什麼該留」對不同 backbone 都有用。對未來要把 Rowlet 換 backbone 的情境，這是直接的安全網。
6. **Counterfactual 需要 controlled replay**。PAIR 的 protocol 要求「restore environment state to pre-compression」。對真實 cron 任務，這意味著需要 **deterministic checkpoint** 才能做同樣診斷。建議在 Rowlet 內部加一個 mini-checkpoint facility。

---

## 與其他 wiki 條目的關係

- **[[acon-2025-kang]]**：直接 predecessor。PAIR 是 ACON 的「causal attribution upgrade」。
- **[[memgpt-2024-packer]]**：MemGPT 是 paging-based 系統，PAIR 是 prompt-based 適配。兩者**互補**：MemGPT 決定 page-in 哪些 block，PAIR 決定 page-in 後**是否還要再壓、怎麼壓**。
- **[[lost-in-the-middle-2023-liu]]**：Liu 證明 long context 注意力不均。PAIR 從 execution 角度證明 long context **還會讓 reliability 變 flaky**。兩個發現互相強化：「不只是失焦，是失穩」。
- **[[context-engineering-2025-mei]]**：Mei survey 把 compression 列為 asymmetry problem 對策。PAIR 提供了**因果式** reference implementation。
- **[[agentic-context-mgmt-dadhich-2026]]**：PAIR 是 lifecycle 中 **Compacting & Consolidation** 階段的更精細實作 — 不只驗證 fidelity，還 **causally 驗證每個 boundary**。

---

## 討論問題（值得團隊討論）

1. **Counterfactual 成本**：PAIR 需要為每個 boundary 跑兩條 rollout 才能估 (ΔR, ΔL)。對 production，這是 **2× rollout cost during adaptation**。可以 batch boundary evaluation 嗎？或用 cheaper proxy？
2. **Sectioned template 怎麼決定？** PAIR 假設 template 有「固定 section」結構。但對 first-time 部署，要先 bootstrap section 結構。ACON 的 free-form optimization 是不是可以拿來「先生成 structure，再切換到 PAIR 做精修」？
3. **Pass3 是不是太嚴？** 3 次全過才算。對 stochastic 環境，這可能 under-count legitimate success。要不要用 **bootstrap confidence interval** 取代固定 3？
4. **Cross-model transfer 極限**：MiniMax-M3 是同代 model。轉到完全不同 family（e.g. Claude Sonnet、Qwen）PAIR 學到的「該留什麼」還適用嗎？structure 會不會 leak？
5. **與 RL 路線疊加**：PAIR 是 prompt-side。能不能在 PAIR 選出的 prompt 之上，再做 small RL fine-tune 讓 agent 適應「compressed context distribution」？這會是 ACON + CompactionRL 之外的第三條路。

---

## 備註

- PDF 已存：`raw/references/papers/ai/pair-2026-min/pair-2026-min.pdf` (1.37 MB)
- 文字版：`raw/references/papers/ai/pair-2026-min/pair-2026-min.txt` (2,784 行)
- Metadata：`raw/references/papers/ai/pair-2026-min/pair-2026-min.metadata.md`
- Pair 論文引用了 OpenClaw Contributors 2026a / 2026b — **我們在文獻裡被 cite 了** 🎉
- 9 天前 v1，建議觀察 v2 / code release，再做 follow-up
