---
title: "Organize then Retrieve: Hierarchical Memory Navigation for Efficient Agents"
authors: ["Hao-Lun Hsu", "Nikki Lijing Kuang", "Boyi Liu", "Zhewei Yao", "Yuxiong He"]
year: 2026
arxiv: "2606.11680"
subjects: ["cs.AI", "cs.CL", "cs.LG"]
submitted: "2026-06-10"
file: "raw/references/papers/ai/organize-then-retrieve-2026-hsu.pdf"
tags: ["context-processing", "agent-memory", "hierarchical-memory", "rl", "retrieval"]
---

# Organize then Retrieve: Hierarchical Memory Navigation for Efficient Agents

## 論文摘要

LLM agents 在執行長期任務時會因為 statelessness 而遇到困難，需要把所有任務相關資訊塞進不斷增長的 input context，導致 reasoning quality 下降、inference cost 增加、latency 變高。

現有方法要不是採用有損壓縮（lossy compression）就是 similarity-based retrieval，但這些方法常常無法捕捉 multi-step agentic tasks 所需的 temporal structure 和 causal dependencies。

**HORMA (Hierarchical Organize-and-Retrieve Memory Agent)** 提出分層組織策略：
- 將經驗組織成類似檔案系統的階層結構
- Summarized entities 連結到對應的 raw trajectories
- 可有效存取資訊而不丟失詳細資訊

## 核心機制

### 兩階段工作記憶

1. **Construction Module（建構模組）**
   - 迭代式地精煉經驗的組織方式
   - 區分「資訊遺漏導致的失敗」vs「誤導/過載 context 導致的失敗」

2. **Navigation Module（導航模組）**
   - 透過遍歷階層結構取回任務相關 context
   - 使用 RL 訓練的 lightweight agent 來選擇「最小但足夠」的 context
   - 減少關鍵執行路徑上的延遲

## 實驗結果

- **ALFWorld, LoCoMo, LongMemEval** 三個 benchmark
- 在 constrained context budgets 下提升任務表現
- 在長對話任務中僅需最多 **22.17%** 的 baseline token 用量
- 在效率-表現權衡上 consistently 優於現有方法
- 能泛化到 unseen tasks

## 關鍵創新點

1. **檔案系統式階層結構**：不同於 flat memory 或简单 semantic retrieval
2. **區分 failure modes**：幫助 construction module 更準確地組織資訊
3. **RL-trained navigation**：學習何時該取回什麼，而不是暴力檢索全部
4. **Token efficiency**：22.17% baseline 這個數字非常有競爭力

## 對 OpenClaw / Rowlet 的啟發

- `memory/` 資料夾可以採用 hierarchical 组织（daily → topic → entity）
- RL-based context selection 可以學起來
- Construction vs Navigation 的分層值得參考
