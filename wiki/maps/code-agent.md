---
title: "Code-Agent Map"
category: map
type: knowledge-map
created: 2026-06-11
modified: 2026-06-11
---

# Code-Agent Map

此頁整理與 code-agent / tool-use agent 相關的論文與概念，特別關注 context processing、long-term memory、retrieval、workflow control。

## Agent Context Processing / Memory

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

## Synthesis

目前四篇形成一個互補堆疊：

1. **MemGPT**：runtime memory tiers + virtual context paging。
2. **ContextWeaver**：dependency-aware selection，讓取回的 context 保留因果/邏輯結構。
3. **Memory-R2**：training-time credit assignment，讓 agent 學會更好的 memory operations。
4. **HORMA**：hierarchical organize-then-retrieve，用 RL navigation 選擇最小 sufficient context。

對 OpenClaw / Rowlet 類 agent，可映射為：

- `SOUL.md` / `USER.md` / `MEMORY.md`：高價值 working context / stable memory。
- `memory/YYYY-MM-DD.md`：episodic recall storage。
- `wiki/sources/` 與 `raw/references/`：archival storage。
- Graphify / wiki query：retrieval layer。
- Cron / heartbeat / tool events：interrupt-driven control flow。
- RL-based context selection：未來可探索的方向。
