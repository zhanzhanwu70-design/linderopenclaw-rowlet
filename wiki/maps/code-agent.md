---
title: "Code-Agent Map"
category: map
type: knowledge-map
created: 2026-06-11
modified: 2026-06-19
---

# Code-Agent Map

此頁整理與 code-agent / tool-use agent 相關的論文與概念，特別關注 context processing、long-term memory、retrieval、workflow control。

## Agent Context Processing / Memory

### [[context-engineering-2025-mei]] — unified taxonomy of context engineering

**必讀 survey（166 pages, 1411 citations）**。將 Context Engineering 分為三大 Foundational Components：
1. **Context Retrieval and Generation**（prompt engineering、external knowledge retrieval、dynamic context assembly）
2. **Context Processing**（long sequence processing、self-refinement、multimodal/structured context）
3. **Context Management**（memory hierarchies、compression、optimization）

以及四大 System Implementations：RAG（modular/agentic/graph-enhanced）、Memory Systems、Tool-Integrated Reasoning、Multi-Agent Systems。

**核心 research gap（值得重視）**：Asymmetry Problem — LLMs 善於理解複雜 context，但生成同等複雜長文輸出的能力嚴重不足。

### [[memgpt-packer-2024]] — virtual context management

MemGPT 將 LLM context window 視為有限主記憶體，透過 working context、FIFO queue、recall storage、archival storage 與 function calls 進行 self-directed memory management。對 code-agent 的啟發是：不要把互動歷史當 append-only prompt，而要建立分層記憶與 paging policy。

關鍵概念：
- main context vs external context
- recursive summary + searchable recall storage
- memory pressure warning
- function chaining / heartbeat-style multi-step retrieval
- long-term conversational memory 與 large-document QA

### [[contextweaver-wu-2026]] — dependency-structured context

ContextWeaver 將 tool-use interaction trace 建成 dependency graph，避免 sliding window / semantic retrieval 丟失邏輯依賴。適合 SWE-Bench 類多步 coding agent 任務。

### [[memory-r2-yan-2026]] — training memory operations

Memory-R2 處理 long-horizon memory-augmented agents 的 credit assignment 問題，重點在訓練期間如何公平評估 memory write/update/delete 對後續結果的影響。

### [[organize-then-retrieve-2026-hsu]] — hierarchical memory navigation (HORMA)

HORMA 將經驗組織成檔案系統式階層結構，summarized entities 連結到 raw trajectories。區分「資訊遺漏導致失敗」vs「誤導/過載導致失敗」兩種 failure modes，用 RL-trained navigation module 選擇最小但足夠的 context。在長任務中僅需 22.17% baseline token 用量。

### [[lost-in-the-middle-2023-liu]] — empirical foundation: U-shaped long-context curve

Liu et al. (TACL 2023) 對 MPT-30B、LongChat-13B/16K、GPT-3.5-Turbo、Claude-1.3 做 controlled experiment，系統性展示 LLM 對 long context 的利用是 **U-shaped**：relevant information 放在 context 開頭或結尾表現最好，放在中段會掉到接近 random baseline。**Long-context fine-tuned model (LongChat-13B) 與 closed SOTA (GPT-3.5, Claude) 都不能免疫**。這篇是後續所有 selective retrieval / virtual context / memory paging 路線的經驗地基 — 它直接回答「為什麼我們不該把全部 history 塞進 context」。

## Synthesis

目前六篇形成一個互補堆疊：

1. **Lost in the Middle**：經驗基礎 — 證明「context 越長 ≠ 表現越好」，U-shaped curve，middle 會被忽略。
2. **Context Engineering Survey**：統一 taxonomy，回答「整個領域怎麼分類」的問題，是其餘四篇的上層框架。
3. **MemGPT**：runtime memory tiers + virtual context paging，直接繞過 stuffing。
4. **ContextWeaver**：dependency-aware selection，讓取回的 context 保留因果/邏輯結構。
5. **Memory-R2**：training-time credit assignment，讓 agent 學會更好的 memory operations。
6. **HORMA**：hierarchical organize-then-retrieve，用 RL navigation 選擇最小 sufficient context。

對 OpenClaw / Rowlet 類 agent，可映射為：

- `SOUL.md` / `USER.md` / `MEMORY.md`：高價值 working context / stable memory — 放在 prompt 開頭正好踩在 primacy bias 上。
- `memory/YYYY-MM-DD.md`：episodic recall storage。
- `wiki/sources/` 與 `raw/references/`：archival storage。
- Graphify / wiki query：retrieval layer — 直接回應 lost-in-the-middle：不把全部塞進 context，先 query 取出最相關少數 nodes。
- Cron / heartbeat / tool events：interrupt-driven control flow。
- RL-based context selection：未來可探索的方向。
- **Position engineering**：把 critical instructions 重複出現在 prompt 兩端（duplicate-the-edges）是抵禦 U-shaped curve 的便宜手段，值得實驗。

### 對我們自己的工程提醒

根據 [[lost-in-the-middle-2023-liu]] 的 finding，目前架構有兩個潛在風險：

1. **Mid-prompt 衰減**：當 heartbeat 把 `memory/YYYY-MM-DD.md` + 多個 tool 結果 + wiki dumps 串進對話中段，重要的 earlier tool result 可能掉進 U-shape 谷底。
2. **Long-session 退化**：多 session 串接的 conversation，舊 session 的關鍵資訊一旦被新 session 推到中段，就會被模型忽略。需倚賴 [[memgpt-packer-2024]] 的 recall storage 或 [[organize-then-retrieve-2026-hsu]] 的 hierarchical summary 來主動 page-in。
