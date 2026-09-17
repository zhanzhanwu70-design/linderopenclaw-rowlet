---
title: "TRACE: Toward Reliable Context Compression for Long-Horizon Agents — An Empirical Study of Execution Instability"
arxiv: "2608.06503"
date: "2026-08-06"
authors: "Guanghui Min, Liang Wu, Mayank Darbari, Chen Chen, Liangjie Hong"
affiliation: "University of Virginia + Nokia (Nokia Bell Labs Applied Research)"
venue: "arXiv preprint (work in progress)"
type: source
status: seed
created: 2026-09-17
tags: [context-compression, long-horizon-agents, execution-instability, verifier-guided, boundary-local, prompt-optimization, appworld, frozen-agent]
---

# TRACE: Toward Reliable Context Compression for Long-Horizon Agents

## TL;DR

**核心發現**：recurrent context compression 並不只是「丟失資訊」——它會**系統性弱化 recent interactions 對後續決策的影響力**，表現為 blocked actions、repeated exploration、multi-run instability。**這不是 information loss 問題，而是 execution-state mislocalization 問題。**

**TRACE 解法**：boundary-local verifier-guided prompt optimization——
- 在**每一個 compression boundary** 評估 summary 品質（paired closed-loop continuations PRE/POST from same state）
- 對候選 summary 排序，產生 preference pairs
- frozen LLM proposer 拿到偏好但**看不到 rollout actions/observations/errors** → 只根據偏好 + system prompt + 當前 template 修訂 natural-language compression policy
- 所有 model weights 全程凍結（包含 compressor、downstream agent、proposer 全部 frozen）

**SOTA on AppWorld**：Acc 77.1 vs 71.4（最佳 baseline Prompting-O），Pass2 67.3 vs 59.5，Pass@2 86.9 vs 83.3。**MiniMax-M3 優化的 template 直接 transfer 到 Kimi-K2.7-Code（84.5 vs 82.7 no-compression, +1.8 points）**，且 Pass2 +5.4 points。

## 1. 為什麼「context compression」是 long-horizon agents 的必要工具？

Long-horizon agents（ReAct, Reflexion, Executable Code Actions, browser-use, office automation）每一步都會在 context 裡累積：
- tool outputs
- retrieved sources
- intermediate decisions
- user clarifications
- partial results

完整 history 持續增長 → inference cost 線性增長 + peak context 突破預算。但**僅僅丟資訊也會讓 agent 找不到下一步需要的資訊**。所以 compression 是 scalable long-horizon agent 的必要條件。

## 2. 經驗診斷：Compression 造成的不是「資訊丟失」，而是「execution state 失位」

### 2.1 Pass-rate 退化（Figure 1）

AppWorld（stateful API-use，147 task train-dev split）上：

| Context window | Summary | FIFO | Full |
|---|---|---|---|
| 16K | ~70 | ~70 | 85.7 |
| 8K | ~65 | ~65 | 85.7 |
| 4K | 72.8 | 42.2 | 85.7 |
| 2K | ~50 | ~38 | 85.7 |

**反直覺的 finding**：在 AppWorld 這種「過去 observation 可透過 API 重新查詢」的 refetchable 環境裡，summary 對 FIFO 的優勢**只有在 budget < 4K 時才顯著**（72.8 vs 42.2）。在 16K/8K/4K 等中等 budget 下，**FIFO 跟 summary 持平甚至微幅領先**——因為 summary 會犧牲 recency-continuity。

### 2.2 Cross-run reliability（Figure 1b）

τ-bench 的 P@k vs Pk metrics：
- **P@2**：任務在 2 次 run 中至少 1 次成功的比例（task coverage）
- **Pass2**：2 次 run 都成功的比例（reliability）

隨 compression 增強，**P@2 與 Pass2 的 gap 擴大**。意思是 compression 不只是讓某些任務完全失敗，而是把「可靠解掉的任務」變成「時靈時不靈」。**multi-run stability 比 single-run pass rate 更能反映 compressor 品質**。

### 2.3 Long-horizon degradation（Figure 1c）

按 full-context reference horizon 分組（short 8-16 steps, medium 16-20, long 20-32）：
- Long 任務在 4K/2K budget 下退化最嚴重
- 即使是 summary-based compaction，long tasks 退化曲線最陡

→ repeated context replacement 在 long trajectory 上有**累積效應**。

### 2.4 Termination disruption（Figure 2）

保留 final decision 的 task/environment/agent header，只替換 context rendering（summary / FIFO / full），sample 10 next actions：

| Budget | Summary correct termination | FIFO correct termination | Full |
|---|---|---|---|
| 2K | 37.3% | 68.1% | 60.6% |
| 4K | ~55% | ~60% | ~60% |
| 8K | ~60% | ~60% | ~60% |

→ **Summary 會讓 agent 不知道「任務已經完成」**，反而繼續 acting 或產生冗餘內容。FIFO 在這點上**反而比 summary 好**——因為它保留了最近 action-observation 的「任務已收尾」訊號。

### 2.5 Recency attenuation（Figure 3）

對每個 compaction 構造 4 種 matched contexts：
- Full raw prefix（reference）
- St−1 + 原始 ∆t
- St−1 + compressed St
- St−1（無 update）

各 sample 24 next actions，算 noise-corrected total-variation divergence from full-history：

| Context | Divergence from full-history |
|---|---|
| Raw update | 0.149 |
| Compressed St | 0.233 |
| No update | 0.289 |

→ **OpenClaw 保留了 recent interaction 的一部分效果，但系統性衰減**。compression 把這個衰減放大到 1.56×，完全丟掉則放大到 1.94×。

### 2.6 Regressive exploration（Figure 4）

590 boundaries × 4,640 rollouts（PRE 保留原 context、POST 用 summary + retained raw turn），從同樣 AppWorld execution state 出發：

- **第一個 action**：POST 比 PRE 多 **0.108 個 blocked/error** actions
- **第二個 action 開始**：refetch/replay 的 marginal effect 上升

→ Compression **立即**增加 blocked execution，且後續會誘發更多 refetch/replay（recovering state 的成本）。

## 3. TRACE 框架

### 3.1 Boundary-Local Execution Verifier

對於 boundary `b`，定義：
- `x_b^-`：壓縮前的 context（previous summary + 累積 raw interactions）
- `x_b^+(s)`：候選 summary `s` 取代 compressible history 後的 context

從同樣環境 state 出發，獨立 rollout PRE 和 POST，計算 short-horizon execution burden：

$$G(\tau) = \sum_{j=1}^{K} z_j(\tau)$$

其中 `z_j` 在 AppWorld 上是：
- **Blocked action**：觸發 AppWorld native execution-error contract
- **Repeated action**：canonicalized tool-call signature 與 boundary 前或同次 continuation 中已執行過的相同

Compression-induced burden：

$$\Delta G_b(s) = \mathbb{E}[G(\tau_b^+(s))] - \mathbb{E}[G(\tau_b^-)]$$

Verifier score：

$$Q_b(s) = -\Delta G_b(s)$$

**關鍵設計**：PRE 不是 optimal trajectory，只是 paired local control，用來**分離 compression-induced error 與 frozen agent intrinsic stochasticity**。

### 3.2 Verifier-Guided Prompt Optimization

跟 ACON 一樣在 natural-language prompt space 優化（**所有 model weights 凍結**），但 supervision source 不同：

**Step 1 — Training boundary selection**：在 AppWorld training split 上跑 base compressor，collect PRE/POST continuations，identify blocked-action boundaries，stratified sampling 12 boundaries 涵蓋多種 error type。

**Step 2 — Candidate generation + boundary-local scoring**：每個 boundary 生成 3 個候選 summary，每個跑 candidate-specific POST，PRE continuations 全部 reuse → 差異只來自 POST。

**Step 3 — Contrastive pairs**：保留 best/worst 形成 12 boundary-matched contrastive pairs `(I_b, s_b^+, s_b^-)`。

**Step 4 — System-aware prompt proposal**：Proposer 收到 incumbent template + system prompt + 12 contrastive pairs（**看不到** rollout actions/observations/errors/verifier decomposition）。**Proposer 必須先 audit 當前 policy vs downstream system prompt 是否矛盾**——例：當前 policy 寫「變數不會跨 session 保留」但 system prompt 明確說「你可以用前一個 code block 的變數」→ 這個 rule 必須移除。

**Step 5 — End-to-end development selection**：對 5 個 candidate templates 在 dev split 上各跑 2 次，**選 Pass2 最高者**為 `P*`。Terminal outcome 只用於最終 selection，不參與 preference 構造。

```text
Training boundaries (12) → paired PRE/POST rollouts → contrastive (s+, s-) 
       ↓
   Frozen proposer + system prompt + current template
       ↓
   5 candidate compression templates (natural-language)
       ↓
   End-to-end dev split: Pass2 ranking → P*
       ↓
   Frozen → evaluated on test-normal
```

### 3.3 Cross-model transfer

`P*` 從 MiniMax-M3 優化得到，**直接套到 Kimi-K2.7-Code**（不同模型直接當 compressor 跟 agent），**沒有任何額外 prompt optimization**：

| Method | Acc (avg) | Pass2 | Pass@2 |
|---|---|---|---|
| No compression | 82.7 | 73.8 | 91.7 |
| Best compressed baseline | 58.3 | 47.0 | 69.6 |
| **TRACE (MiniMax-M3 template)** | **84.5** | **79.2** | 89.9 |

→ Transfer 不只是保持效能，**還贏過 no-compression**（+1.8 Acc, +5.4 Pass2）。Template 學到的不是模型特定 heuristic，是 **execution-state-preserving compression heuristic**。

## 4. 與 code-agent map 中其他方法的差異

| 方法 | 切入點 | 訓練 | 監督來源 |
|---|---|---|---|
| MemGPT | runtime memory tiers / virtual paging | none | system-level architecture |
| ACE | elastic reversible orchestration | none | wrapper-level type assignment |
| ACON | compression as learned module (UT/UTCO) | none | terminal success/failure contrast |
| CompactionRL | learnable compaction policy | RL (PPO) | outcome reward |
| **TRACE** | **execution-state preservation** | **none** | **boundary-local verifier** |

**TRACE 的獨特位置**：
1. 與 ACON 同屬 prompt-optimization（不改 model weights）但 supervision source 不同——ACON 用 terminal outcome contrast，**TRACE 用 boundary-local execution regression**。
2. 與 CompactionRL 對立——都是想學好 compression policy，但 CompactionRL 透過 RL training，TRACE 透過 paired closed-loop verifier + frozen proposer。
3. 解決 ACON 沒解決的問題：ACON 假設「成功 trajectory 的 summary 都是好的」——但其實某個 compression defect 可能從未被 exercise 或被後續互動 recover。**TRACE 直接在 boundary 驗證**。

## 5. 對 Rowlet / OpenClaw 的直接啟發

### 5.1 驗證 Rowlet 自己的 compaction 品質

Rowlet 的 daily memory compaction 是 heuristic 的（每 heartbeat 寫一段，舊的被 truncate）。可以借鑒 TRACE 的 boundary-local verifier：

```python
# Pseudo: trace-style audit for Rowlet heartbeat
def trace_style_audit(prev_summary, raw_delta, current_summary, env_state):
    """Boundary-local check: did compression weaken recency?"""
    # 1. Construct 3 contexts:
    #    PRE: prev_summary + raw_delta (no compression)
    #    POST: prev_summary + compressed current_summary
    # 2. Replay a sample of recent tool calls (env_state-equivalent)
    # 3. Measure divergence: does the agent under POST still produce
    #    the same next actions as under PRE?
    # 4. If divergence > threshold, flag summary for re-summarization
    #    with different prompt template
    ...
```

### 5.2 Lost-in-the-middle 防禦的第二條防線

Lost-in-the-middle（Liu 2023）已經告訴我們 U-shaped curve 會讓 mid-prompt 內容被忽略。TRACE 額外告訴我們 **compression 會系統性衰減 recent interaction 效果**——對 OpenClaw 這種「最近 tool result 最重要」的工作流尤其危險。

**Position engineering** 已經是現有對策（critical instructions 重複出現在 prompt 兩端），TRACE 啟示是**對 compacted summary 也應該 position-engineer**：把 current task goal + most recent block + critical identifiers 放在 summary 的開頭跟結尾，**而不是塞在中間**。

### 5.3 Proposer 設計的 portability

TRACE 的 proposer prompt 結構值得直接借鑒：
1. **Audit current policy against system contract first**（避免與 frozen agent 的 operating instructions 矛盾）
2. **Show contrastive pairs only, no rollout details**（避免 proposer overfit 特定 instance）
3. **End-to-end eval 才是 selection criterion**（boundary-local score 只用於構造 preferences）

未來 Rowlet 想要自動優化 compaction prompt，這個三層分離（boundary verifier / proposer / end-to-end selector）是 blueprint。

### 5.4 Cross-model transfer 是反 overfitting 的強訊號

TRACE 的 MiniMax-M3 → Kimi-K2.7-Code transfer 不只贏 baseline 還贏 no-compression——這是 template「學到了真東西」的證據，而非 memorize model-specific quirks。對 Rowlet 的啟發：**未來如果要做 prompt optimization，務必保留 cross-model test set**。

## 6. 限制與未解問題

1. **Verifier 只測 observable execution regressions**（blocked + repeated）—— silent state corruption 沒覆蓋。
2. **Boundary selection 偏向 AppWorld-specific error types**——不同環境（browser-use、office、code）需要不同的 z_j 設計。
3. **Cross-model transfer 只測了一對**（MiniMax-M3 → Kimi-K2.7-Code），更廣的 transfer 仍待驗證。
4. **Optimized template 是 static**——不同任務 difficulty 可能需要不同 compression policy，future work 提到要 extend to learned compressors。

## 7. Citation

```bibtex
@article{min2026trace,
  title={Toward Reliable Context Compression for Long-Horizon Agents: An Empirical Study of Execution Instability},
  author={Min, Guanghui and Wu, Liang and Darbari, Mayank and Chen, Chen and Hong, Liangjie},
  journal={arXiv preprint arXiv:2608.06503},
  year={2026}
}
```

## 相關條目

- [[acon-2025-kang]] — 同期 prompt-optimization 路線，ACON 對比項
- [[lost-in-the-middle-2023-liu]] — U-shaped curve 經驗基礎
- [[compactionrl-2026-li]] — RL 訓練 compaction policy 的對立路線
- [[memgpt-packer-2024]] — runtime memory paging 系統層對比
- [[ace-liao-2026]] — elastic reversible context orchestration
- [[2608.21690-scroll-programmatic-context-mgmt]] — context as environment，defer retrieval decision
- [[agentic-context-mgmt-dadhich-2026]] — lifecycle view of context management
