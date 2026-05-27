---
title: "Context Window Management in LLM Agents"
category: engineering
tags: [context-window, memory-management, llm-agents, context-compression, dependency-graph, sliding-window, summarization]
created: 2026-05-26
modified: 2026-05-26
sources: ["wiki/sources/contextweaver-wu-2026.md"]
---

# Context Window Management - LLM Context 管理機制總整理

## 概述

LLM 有最大 context length 限制，互動歷史會隨著對話輪次快速膨脹。對 Tool-use Agent 來說這個問題更嚴重，因為每次 Tool call 都會產生新的 Thought-Action-Observation triple讓 context 暴漲。

Context Window Management 的核心問題：**如何有效利用有限的 context window，保留對当前任务最关键的信息，同时删除不重要的历史记录**。

---

## 現有主要方法

### 1. Sliding Window（滑動窗口）

最直觀的方案：只保留最近 N 個 turns，丟掉早期的歷史。

**優點：**
- 簡單，實作成本低
- 不需要額外 LLM 推理

**缺點：**
- 會刪掉關鍵的早期依賴資訊
- 在多步推理任務中，later steps 經常依賴 earlier steps 的 intermediate hypotheses 或 tool outputs
- 單純以 recency 決定內容去留，忽略邏輯依賴

**代表應用：** 基礎對話 Agent、早期的客服 Bot

---

### 2. Prompt Compression（文本压缩）

使用 smaller model 或 rules 將長文本压缩成更短的表示。

**主要技術：**
- **Token-level**: LLMLingua（Jiang et al., 2023）— 根據 token 重要性選录
- **Embedding-level**: Chevalier et al., 2023
- **Selective Context**（Li et al., 2023）— 基於語意相似度選擇性保留
- **Gist tokens**（Mu et al., 2023）— learned compression，額外訓練成本

**優點：**
- 降低 token 用量

**缺點：**
- 依賴語意相似度信號，可能誤刪關鍵低相似度內容
- 多數方法不可解釋
- 訓練成本（gist tokens）

---

### 3. Retrieval-Based Memory（檢索式記憶）

將歷史存入向量資料庫，根據 query 檢索最相關的内容。

**代表系統：**
- **MemGPT**（Packer et al., 2023）— 分層記憶，類似 OS 的 virtual memory
- **Generative Agents**（Park et al., 2023）— 模擬人類記憶形成
- **Reflexion**（Shinn et al., 2023）

**優點：**
- 可擴展到更長的對話
- 語意相關性檢索

**缺點：**
- 檢索基於語意相似度，忽略邏輯/因果依賴結構
- 一旦取出還是线性化為 token stream，沒有明確建模步驟間的邏輯關聯
- 在 Tool-use 場景中，later step 可能依賴 earlier tool output，但兩者內容可能語意上不相關

---

### 4. LLM Summarization（LLM 摘要）

讓 LLM 週期性地將舊互動浓缩成簡短的文字摘要。

**代表系統：**
- **SWE-Agent** 的 context condensation
- **OpenHands** 的 modular condenser
- **ACON**（Kang et al., 2025）— 優化 compression guidelines

**優點：**
- 文字摘要保留語意豐富度

**缺點：**
- 仍是 flat textual condensation，丢弃了推理步驟之間的結構關係
- LLM 推理成本
- Lindenbauer et al.（2025）指出簡單的 observation masking 效果相當，成本更低

---

### 5. Dependency Graph（依賴圖，ContextWeaver，2026）

將 Agent 的互動歷史建模成 DAG（Directed Acyclic Graph），每個節點是一個 Thought-Action-Observation 三元組。

**核心元件（ContextWeaver）：**
1. **Node Extraction** — 從每個 step 提取結構化 node（summary, dependency_summary, parents, validation）
2. **Parent Selection** — 用 LLM 判斷「current step 依賴哪些 earlier steps」，不只是算相似度
3. **Ancestry BFS Traversal** — 從 current node 向上收集所有上游依賴
4. **Context Weaving** — 祖先鍊完整保留，非祖先壓缩
5. **Validation Layer** — 記錄每步執行結果（pass/fail/unknown），過濾不可靠 nodes

**優點：**
- 明確建模邏輯/因果依賴，不只是 recency 或語意相似度
- 可解釋性高（graph structure 提供推理軌跡追蹤）
- 在 SWE-Bench Verified + Lite 上 pass@1 優於 sliding window，同時減少 token 用量

**缺點：**
- Parent selection 每次需要額外 LLM call（計算開銷）
- Graph 結構需要額外存儲和維護
- 目前只在 software engineering 場景驗證

---

## 實作對照表

| 方法 | 選擇標準 | 額外模型 | 可解釋性 | 實作難度 | 代表系統 |
|------|---------|---------|---------|---------|---------|
| Sliding Window | Recency | ❌ | ❌ | ⭐ | 基礎對話系統 |
| Prompt Compression | Token/Embedding 重要性 | ❌（或小型） | 部分 | ⭐⭐ | LLMLingua, Selective Context |
| Retrieval Memory | 語意相似度 | ❌（embedding model） | ❌ | ⭐⭐⭐ | MemGPT, vector DB |
| LLM Summarization | LLM 判斷重要性 | ✅ | ⭐⭐⭐ | ⭐⭐ | SWE-Agent, OpenHands |
| Dependency Graph | 邏輯/因果依賴 | ✅（用於 parent selection） | ⭐⭐⭐⭐ | ⭐⭐⭐ | ContextWeaver |

---

## 對 Code Agent 的啟發

### 為什麼 Dependency Graph 更适合 Tool-use Agent？

在 Software Engineering 任務（SWE-Bench）中：
- 每個調試步驟的 output（例如 test failure message）可能觸發後續程式碼修改
- 若用 sliding window 刪掉早期錯誤訊息，後續決策失去關鍵上下文
- 若用 retrieval-based，語意不相關的錯誤輸出和程式碼修改之間沒有相似度，但存在因果依賴

ContextWeaver 的 graph structure 正是為了解決這個 mismatch：**用邏輯關係（"這個 decision 是不是基於那個 tool output？"）取代語意關係（"這兩句話像不像？"）**

---

## 討論問題

1. **Parent Selection 的成本效益**：理論上 dependency graph 比 sliding window 效果好，但每次 parent selection 要多一次 LLM call。在 production 環境真實部署時，額外計算成本是否值得？
2. **跨領域泛化**：ContextWeaver 在 SWE-Bench 驗證了，但其他領域（数据分析、機器人控制）如何定義 validation 標準？
3. **與 MARA（Memory-Augmented）系統的整合**：ContextWeaver 專注於單 Agent 的互動歷史管理；如何與外部知識庫/文件檢索結合？
4. **對 OpenClaw 的實務啟發**：Rowlet 目前管理長對話歷史的方式是哪種？未來是否考慮引入 dependency graph 概念？

---

## 相關頁面

- [[agent-frameworks]] — ContextWeaver 隸屬於 Tool-use LLM Agent 的 Memory/Context 管理範疇
- [[harness-engineering]] — Validation Layer 對應監控元件
- [[contextweaver-wu-2026]] — 原始論文 source 条目

---

_tags: [context-window, memory-management, llm-agents, context-compression, dependency-graph]_
