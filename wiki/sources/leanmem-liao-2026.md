---
title: "LeanMem: Simple and Efficient Long-Term Memory for LLM Agents"
authors: ["Yuxin Liao", "Le Wu", "Min Hou", "Hao Liu", "Han Wu", "Zishu Wang"]
year: 2026
arxiv: "2608.03463"
submitted: "2026-08-04"
category: paper
tags: [llm-agents, long-term-memory, context-management, memory-architecture, retrieval]
related:
  - "[[ace-liao-2026]] — elastic reversible context orchestration"
  - "[[memgpt-packer-2024]] — virtual context management"
  - "[[lost-in-the-middle-2023-liu]] — U-shaped long-context curve"
  - "[[organize-then-retrieve-2026-hsu]] — HORMA hierarchical memory"
---

# LeanMem: Simple and Efficient Long-Term Memory for LLM Agents

## 核心問題

現有 memory 系統用統一 pipeline（summarization + retrieval）處理所有對話內容，導致：
- **過度 token 消耗**：每段對話都用 LLM 處理，construction cost 線性成長
- **不可逆的資訊丟失**：壓縮後 fine-grained evidence 無法恢復

## 核心主張

**對話資訊本質上並不相同**：
- 有些段落資訊量低 → 可以忽略（greetings, acknowledgements）
- 有些是穩定用戶屬性/偏好 → 應該用緊湊結構化格式儲存
- 有些是動態變化的事件 → 需要時間戳 + 狀態追蹤
- 有些是密集細節（list、plan、step-by-step）→ aggressive summarization 會丟失重要證據

因此，**一個 memory 系統不應該對所有對話內容應用相同的建構策略**。

## 三層 Pipeline

### Stage 1: Controlled Memory Writing

**Key Utterance Filtering**：規則過濾低資訊量 turns（問候語、確認語、複述）。用戶 utterance 是主要 routing anchor（承載偏好、狀態變化），assistant responses 不獨立保留。

**Topic Segmentation**：使用 cosine similarity + valley depth 演算法自動偵測 topic boundary，解決「session 太粗、turn 太細」的粒度問題。

**Write Scheduling**：四種 action：`ignore` / `profile` / `event` / `record`
- `profile`：穩定用戶屬性和偏好 → 緊湊結構化儲存
- `event`：狀態變化資訊 → 帶時間錨的 event memory
- `record`：密集細節 → 輕量 index + 指標指向原始對話，便於回溯
- `ignore`：低價值內容 → 節省 construction cost

目標：最小化 cost C(y, Si)，同時保證 evidence loss L(y, Si) ≤ ε

### Stage 2: Selective Memory Evolution

**只對 event memory 做 evolution**：
- 跨 session 分組相關 events
- 合併成時間狀態表示（temporal state representations）
- 將 multi-hop temporal query 的 evidence integration 從 query time 移到 construction time

**不做 profile memory 的 evolution**（穩定）和 record memory 的 evolution（不可變）。

### Stage 3: Adaptive Evidence Composition

**Query-conditioned retrieval**：
- 根據查詢類型動態選擇 memory types
- 根據查詢需求分配 retrieval budget
- 按需組裝相關 evidence

避免對每個查詢都做昂貴的 multi-hop retrieval。

## 實驗結果

在 LoCoMo 和 LongMemEval-S 上，用 GPT-4.1-mini 和 Qwen3-8B 測試：
- Accuracy 比最强 baseline 高達 **+15.1 points**
- Memory construction tokens 減少高達 **17.24×**
- Inference tokens 減少高達 **8.41×**

## 與其他方法的關鍵差異

| 方法 | 問題 |
|------|------|
| Eager summarization | 高 fidelity 但高 cost |
| Aggressive compression | 低 cost 但 irreversible info loss |
| Iterative retrieval | 高 fidelity 但高 latency |
| **LeanMem** | 按資訊類型差異化處理，兼顧效率與 fidelity |

## 對 Rowlet / OpenClaw 的啟發

Rowlet 的三層記憶系統（SOUL.md / daily / MEMORY.md）已經體現了類似的分層思想，但 LeanMem 帶來幾個具體啟發：

1. **按資訊類型差異化儲存**：目前的 daily memory 是統一格式，未區分 stable profile vs evolving events vs dense records。可以借鑒 LeanMem 的三類型 memory（profile/event/record）來結構化 daily memory 的內容。

2. **Query-conditional retrieval**：目前的 retrieval（如 graphify query）是 uniform。可以借鑒 Stage 3 的查詢條件 budget allocation 機制，對不同類型的問題分配不同的 context 量。

3. **Valley-depth topic segmentation**：LeanMem 的自動 topic boundary detection 方法（基於 cosine similarity）可以用於自動識別 daily memory 中的 topic shifts，而不需要手動 session boundary。

4. **Source-grounded record memory**：record memory 保留指標回原始對話的能力對於需要 trace evidence 的場景很有價值。可以考慮在我們的 wiki sources 中維持 source grounding。

## PDF 位置

`raw/references/papers/ai/2608.03463-leanmem.pdf`
