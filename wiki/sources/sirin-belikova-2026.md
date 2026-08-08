---
title: "SIRIN: Contextual Hallucination Detection for RAG & Memory Agents"
category: source
type: research-paper
tags: [contextual-hallucination, rag, memory-grounded-llm, hallucination-detection, faithfulness, answerability, representation-probing, uncertainty-estimation, judge-verification, toolkit, agentic-pipelines, long-term-memory]
domain: code-agent
created: 2026-08-07
modified: 2026-08-07
related wikis: [agent-frameworks, context-engineering]
---

# Source: SIRIN (Belikova et al., 2026)

## 基本資訊

| 欄位 | 內容 |
|------|------|
| **論文** | SIRIN: A Unified Toolkit for Detecting Contextual Hallucinations in Retrieval-Augmented and Memory-Grounded LLM Systems |
| **作者** | Julia Belikova, Rauf Parchiev, Mikhail Filimonov, Konstantin Polev, Andrey Savchenko, Maksim Makarenko |
| **發表** | July 2026 (arXiv:2608.00033) |
| **領域** | cs.AI — RAG / Hallucination Detection / Context Grounding |
| **URL** | https://arxiv.org/abs/2608.00033 |
| **PDF** | raw/references/papers/ai/sirin-2026-belikova.pdf |
| **Metadata** | raw/references/papers/ai/sirin-2026-belikova.md |
| **Code** | https://github.com/sb-ai-lab/SIRIN |
| **Demo** | https://hf.co/spaces/parchiev/SIRIN |

---

## 核心論點

### 問題：Contextual Hallucination 的基礎設施缺口

大型語言模型常產生流暢且合理、但與提供的證據不一致的回覆。這在 RAG 系統和 agentic pipeline 中尤其嚴重——當模型重複檢索、摘要、儲存、更新長期記憶時，幻覺會在多個週期內複合累積。

現有工具有三大家族，但各自為政：
- **Probing**（需要白盒存取）：訓練輕量分類器於 hidden states、attention maps
- **Judge-style**（黑盒）：用第二個模型做 NLI / alignment 事實性檢查
- **Uncertainty Estimation**（黑盒）：困惑度、語義不確定性、注意力感知估計

**Table 1（原文精華）**：所有現有工具都只支援其中 1-2 種家族，沒有一個同時支援全部三種 + answerability + span-level + UI。只有 SIRIN 全支援。

### 解決方案：SIRIN 統一工具包

SIRIN 的核心抽象是統一的 inspection report schema：
```
D_θ(x) = (s, ŷ, E)
```
- `s ∈ [0,1]`：校準後的 hallucination 概率分數
- `ŷ`：預測標籤（二元或 NLI-style 三元）
- `E`：可選證據（span 分數、不確定性值、judge 理由）

支援兩種互補任務：
1. **Contextual Hallucination Detection**（事後）：given (context, query, answer) → 答案是否忠於上下文
2. **Query Answerability**（事前）：given (context, query) → 上下文是否足以回答問題

### 架構特色

- **Plugin architecture**：輕量擴展點，可加入新 detector
- **Span-level localization**：不只是整體分數，還能定位到 unsupported text spans
- **White-box + Black-box**：同一介面同時支援需要 internal states 的 probing 和純文字輸出的 judge/UE
- **Faithfulness gate in long-term memory**：在 SimpleMem 系統中展示，作為 memory module 的信任閘門

---

## 和現有 Code-Agent Wiki 的關聯

### 和 [[context-engineering-2025-mei]] 的關聯
- Context Engineering 的「Context Management」支柱（compression、optimization、memory hierarchies）直接面臨 contextual hallucination 問題
- SIRIN 是 evaluation 工具，屬於 context processing 的 QA 環節

### 和 [[memory-r2-yan-2026]] 的關聯
- Memory-R2 解決 memory operation 的 credit assignment 問題
- SIRIN 解決 memory retrieval 結果是否 faithful 的問題
- 兩者都是 long-term memory agent 的基礎設施

### 和 [[memgpt-packer-2024]] 的關聯
- MemGPT 的 recall storage / archival storage 長期下來累積 hallucinated content 風險
- SIRIN 的 answerability check 可作為 retrieval gate，確保写入 memory 的内容是 faithful 的

### 和 [[lost-in-the-middle-2023-liu]] 的關聯
- Lost-in-the-middle = 模型在長 context 中忽略遠距離 evidence
- SIRIN 的 span-level probing 可診斷「模型忽略了哪些 retrieved chunks」
- 兩者一起構成完整的 context utilization 診斷方案

---

## 討論問題（值得團隊討論）

1. **對 Rowlet 的啟發**：Rowlet 的三層記憶（SOUL + daily + MEMORY.md）是否可能產生 contextual hallucination？比如某個 session 把細節記錯了，後續 session 基於錯誤記憶推理。能否用 SIRIN-style 的 faithfulness check 來審計記憶品質？

2. **Pre-generation vs Post-generation**：SIRIN 的 query answerability（事前）vs hallucination detection（事後）是兩道關卡。Rowlet 的 heartbeat 是否有類似的雙重檢查機制？比如 heartbeat 寫入前先問「context 是否足以支撐這個結論？」

3. **Toolkit 整合的可能性**：SIRIN 是 Python 工具包。我們能否將其作為 OpenClaw 的 `sirin-check` tool，在關鍵步驟（記憶寫入、摘要生成）後做faithfulness 審計？

4. **Span-level vs Document-level**：Rowlet 的 daily memory 是 document-level 寫入，沒有 span-level 細粒度。如果要實作 SIRIN-style 的定位，需要什麼樣的格式改動？

5. **記憶蒸發檢測**：當記憶被覆寫（MEMORY.md 更新）時，SIRIN-style 的 NLI check 或許能發現「新的描述和舊的 context 是否 faithful」——相當於記憶的faithfulness gate。

---

## 備註

- PDF 已存：raw/references/papers/ai/sirin-2026-belikova.pdf
- Metadata 已存：raw/references/papers/ai/sirin-2026-belikova.md
- Code：https://github.com/sb-ai-lab/SIRIN
- Demo：https://hf.co/spaces/parchiev/SIRIN
