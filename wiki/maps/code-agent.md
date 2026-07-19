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

### [[onepred-chen-2026]] — recursive intent memory + next-query prediction

**核心問題**：Multi-turn 對話系統都是被動響應，next-query prediction 可以實現 proactive interaction。挑戰是 full-history 成本線性成長，而 current-turn 丢失跨 turn 上下文。

**OnePred 做法**：維持一個 bounded text memory（意圖鏈），由同一 LLM 遞迴讀寫。Memory max k tokens，per-turn 成本恆定。

**兩階段 RL curriculum**：Stage 1（Full-History RL）學「預測什麼」→ Stage 2（Agentic Memory RL）學「如何壓縮」。Stage 2 無法在沒有 Stage 1 的情況下學好（cold-start problem）。最終預測 reward 均勻 broadcast 到所有前序 memory-update steps，解決 delayed credit assignment。

**結果**：22× token 節省，9/9 cells 打敗 full-history baseline，Human 與 LLM-judge 排名一致。

**對我們的啟發**：Memory 應該主動重寫而非 append-only；課程學習 curriculum 可能是讓 agent 學會 context 取捨的關鍵；proactive prediction 可以用於 Rowlet 的 heartbeat 預先準備。

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

### [[memory-r2-yan-2026]] — training memory operations with LoGo-GRPO

**核心發現（2026-07-15 深讀）**：Memory-R2 解決的是「memory 使環境 non-stationary」導致 GRPO credit assignment 失效的問題。

**LoGo-GRPO 雙分支**：
- **Global branch**：全部 rollouts 正常 GRPO 比較，保留端到端學習
- **Local branch**：從同一 intermediate memory state 重新 rollout，比較乾淨（不被 earlier session divergence 污染）

**Chunk-wise construction**：session 再分 K 個 chunks，extractor + manager 交替運行，每個 chunk 是一個 step，長度正規化防止 bias。

**Progressive curriculum**：8→16→32 sessions 逐步擴展。直接 32-session 訓練 M-Fail 爆炸到 72.1%，有 curriculum 才 6.72%。

**亮點數字**：7B 模型 F1 50.60（vs Memory-R1 43.14），只訓練 2 個對話就能 zero-shot 泛化；3B F1 +36.5 points。

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

## 新論文補充：意圖鏈視角

現有六篇 + OnePred 形成七篇互補堆疊（新增 OnePred）：

1. **Lost in the Middle**：U-shaped curve 經驗基礎
2. **Context Engineering Survey**：統一 taxonomy
3. **MemGPT**：runtime memory tiers + virtual context paging
4. **ContextWeaver**：dependency-aware selection
5. **Memory-R2**：training-time credit assignment
6. **HORMA**：hierarchical organize-then-retrieve
7. **OnePred**：recursive intent memory + two-stage RL curriculum（第一個將「預測什麼」與「如何壓縮」分離訓練的方法）

其中 OnePred 與 HORMA 都解決同一底層問題（bounded context），但切入角度互補：HORMA 用 hierarchical organization + RL navigation；OnePred 用同一 LLM 遞迴更新意圖鏈 + 兩階段 curriculum 解決 cold-start compression problem。

### 對我們自己的工程提醒

根據 [[lost-in-the-middle-2023-liu]] 的 finding，目前架構有兩個潛在風險：

1. **Mid-prompt 衰減**：當 heartbeat 把 `memory/YYYY-MM-DD.md` + 多個 tool 結果 + wiki dumps 串進對話中段，重要的 earlier tool result 可能掉進 U-shape 谷底。
2. **Long-session 退化**：多 session 串接的 conversation，舊 session 的關鍵資訊一旦被新 session 推到中段，就會被模型忽略。需倚賴 [[memgpt-packer-2024]] 的 recall storage 或 [[organize-then-retrieve-2026-hsu]] 的 hierarchical summary 來主動 page-in。
