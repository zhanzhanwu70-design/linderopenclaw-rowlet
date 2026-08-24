# OnePred: Next-Query Prediction via Recursive Intent Memory in Multi-Turn Conversations

**Paper**: [arXiv:2605.23668](https://arxiv.org/abs/2605.23668) | Chen et al., Tsinghua + Alibaba Qwen, May 2026

**TL;DR**: 對話 agent 的下一句預測 — 用遞迴意圖記憶（bounded text memory）取代完整對話歷史，Stage 1 RL 學預測、Stage 2 RL 學壓縮，22× token 節省的同時打敗 full-history baseline。

## Core Problem

Multi-turn LLM 對話系統都是被動的：等用戶打完才回應。下一句預測（next-query prediction）可以實現：
- 主動建議 follow-up 問題
- Speculative execution（預先抓文件、算候選答案）
- 提前 routing 到 specialized model

但有根本性的效率-品質 trade-off：
- **Full-history**：context window 線性成長，昂貴
- **Current-turn**：只取最新對話，丢失跨 turn 上下文

## Key Insight

預測不需要讀取完整 raw history，只需追蹤用戶的 **意圖鏈（intent chain）**：
- 正在討論的主題
- 未解決的需求
- 興趣漂移

意圖鏈以 free-form text 呈現（無固定 schema），由 RL 優化自發形成。

## Architecture: Recursive Intent Memory

```
mt, ˆq(1)
t , . . . , ˆq(N)
t  = fθ(mt−1, ot)
```

- `mt` = 上一個 turn 的 memory + 當前觀察 `(qt, rt)`
- 輸出：更新後的 memory + N 個候選預測
- Memory 有 max length k token cap（constant per-turn cost）
- 同一個 LLM 同時讀寫 memory（text-based，interpretable）

**vs. Full-history**：full-history 成本隨 T 線性成長；OnePred 的成本固定。

## Two-Stage RL Training Pipeline

### Stage 1: Full-History RL（學「預測什麼」）
- 給完整對話歷史，直接優化下一句預測
- 讓模型識別預測信號：topic shifts、unresolved questions
- 為 Stage 2 提供 strong initialization

### Stage 2: Agentic Memory RL（學「如何壓縮」）
- 移除歷史訪問，強迫模型只靠 bounded memory 預測
- 多步 trajectory reward broadcast：最終預測 reward 均勻廣播到所有前序 memory-update steps
- Stage 2 單獨也能帶來顯著提升（Base Qwen: 39.57→42.96）

### Reward Design
```
R = λ · Rjudge + (1 − λ) · Rformat
```
- `Rjudge`：LLM ensemble judge，majority vote，評估 intent equivalence（不用 BLEU/ROUGE）
- `Rformat`：penalize structural violations
- Best-of-N strategy：取 N 個候選中最高分

## NQP-Bench

第一個專為 open-ended next-query prediction 設計的 benchmark：
- **NQP-Priv**：真實用戶對話（noisy）
- **NQP-Wild**：公開長對話數據
- **NQP-Share**：跨來源，OOD generalization test
- 5.57 turns 平均長度
- LLM-judge evaluation validated against human annotators

## Main Results

| Model | Method | NQP-Priv | NQP-Wild | NQP-Share | Avg |
|-------|--------|----------|----------|-----------|-----|
| Gemini-3.1-Pro | Full-history | 40.81 | 48.81 | 46.30 | 45.31 |
| Gemini-3.1-Pro | **Ours** | **44.22** | **50.72** | **48.77** | **47.90** |
| RL Qwen-8B | Full-history | 40.79 | 44.35 | 42.16 | 42.43 |
| RL Qwen-8B | **Ours** | **42.15** | **46.00** | **43.84** | **44.00** |

- 22× token reduction vs full-history
- 在 9/9 全部實驗 cell 打敗 Full-history
- Human evaluation 與 LLM-judge 排名一致

## Ablation: Two-Stage Training

| Training | Judge | Human |
|----------|-------|-------|
| Base Qwen (no training) | 39.57 | 40.42 |
| + Stage 1 only | 43.82 | 44.63 |
| + Stage 2 only | 42.96 | 43.35 |
| + Stage 1 then Stage 2 | **46.00** | **47.27** |

## 對 OpenClaw Rowlet 的啟發

1. **意圖鏈 vs. 完整歷史**：我們的 `memory/YYYY-MM-DD.md` 就是一種意圖/事件記憶，但目前是 append-only。OnePred 暗示：經由 RL 或啟發式壓縮，memory 應該被主動重寫而非只做堆疊。

2. **Stage 1 → Stage 2 的課程學習**：先學「全局視角」（完整上下文），再學「壓縮視角」（bounded context），這個 curriculum 可能是讓 agent 學會取捨的關鍵。

3. **Text-based memory + 同一 LLM 讀寫**：等價於讓 LLM 自己管理自己的 context，這比 external retrieval module 更輕量。

4. **credit assignment broadcast**：在 Stage 2 中，最終預測 reward 均勻廣播到所有前序 steps — 這解決了 memory update 的 delayed reward 問題。對長期 agent 的 training/inference 都有借鑒意義。

5. **Proactive vs. Reactive**：目前 Rowlet 是被動響應，但 next-query prediction 暗示可以主動在用戶發問前準備答案或工具調用。

## Source

- Paper: `/home/amr/.openclaw/workspace-rowlet/raw/references/papers/ai/onepred-2026-chen.pdf`
- Code: https://github.com/ZBWpro/OnePred
- arXiv: https://arxiv.org/abs/2605.23668
