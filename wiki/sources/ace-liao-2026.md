# ACE: Pluggable Adaptive Context Elasticizer across Agents

**Paper**: arXiv:2606.31564 (2026-06-30)
**Authors**: Ning Liao, Zihao Long, Xiaoxing Wang, Xue Yang, Yaoming Wang, Ziyuan Zhuang, Xunliang Cai, Rongxiang Weng, Junchi Yan (Meituan & Shanghai Jiao Tong University)
**URL**: https://arxiv.org/abs/2606.31564

## TL;DR

提出 **ACE (Adaptive Context Elasticizer)**，用一個雙層架構解決 agent 上下文管理的 irreversibility 問題：
- **Message Maintenance Layer**：同時儲存 raw messages 和 compressed abstractions（lossless）
- **Context Orchestration Layer**：每個決策步驟動態決定每條歷史訊息是 raw / abstract / drop
- 不需訓練、不改框架，以 external wrapper 套用到 ReAct、DeepAgent、WebThinker、MiroFlow 四種框架

## 核心問題

現有方法（truncation / summarization）有兩個根本缺陷：
1. **Inflexibility**：所有歷史步驟用同一策略，忽略不同步驟在不同時刻的相關性差異
2. **Irreversibility**：一旦 discard 或 compress，資訊永久消失，之後需要時無法恢復

## 架構：雙層設計

```
Message Maintenance Layer（靜態，不被覆寫）
  → 每個歷史步驟同時儲存：raw message + compressed abstraction
  → 永遠保留原始資訊

Context Orchestration Layer（每步動態重建）
  → 根據當前任務狀態，給每個步驟打分派：raw / abstract / drop
  → 重建送入 LLM 的 context，最大化資訊密度
```

**關鍵創新**：context orchestration 是每步重新計算，不是固定策略。這意味著同一條訊息在步驟 5 可能 abstract，在步驟 12 變成 raw（因為後續決策需要原始細節）。

## 與現有方法比較

| 方法 | Inflexible | Irreversible | 需要訓練 |
|------|-----------|--------------|----------|
| Truncation | ✅ | ✅ | ❌ |
| Threshold-triggered compression | ✅ | ✅ | ❌ |
| Recurrent compression | ✅ | ✅ | ✅ |
| Agent-controlled compression | ❌ | ✅ | ✅ |
| **ACE** | **❌** | **❌** | **❌** |

## 實驗結果

- 基於 ReAct：ACE 勝過 truncation 和 compression baselines
- 套用到 DeepAgent、WebThinker、MiroFlow：全部有 consistent 改善
- 四種框架都無需修改、無需訓練

## 值得討論的點

1. **為何不直接擴 context window？**：作者指出 U-shaped attention problem — 即使在支援長度內，模型對長輸入的表現在達到名义上限前就已經衰退。所以重點是提高資訊密度，而非擴大視窗。
2. **與 MemGPT 的區別**：MemGPT 是 trained end-to-end，需要修改 action space；ACE 完全 training-free，以 wrapper 形式外部套用，通用性更強。
3. **Lossless 的代價**：Message maintenance layer 會持續增長（同時存 raw + abstract），對超長 trajectory 仍有 storage overhead。
4. **Elastic type 的分配邏輯**：論文描述是由一個 LLM 根據 current task state 來決定每步的 elastic type — 這本身也是一個 cost，且分配 quality 會影響最終效能。
5. **對 OpenClaw / Rowlet 的啟發**：三層記憶（SOUL/MEMORY + daily memory + wiki）正是類似的分層思路；ACE 的 reversible design 值得在我們的 memory eviction policy 中借鑒。

## 標籤

#context-management #agent-memory #context-window #plug-and-play #reversible #arxiv-2026
