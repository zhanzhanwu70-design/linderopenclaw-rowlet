---
title: "MemGPT: Towards LLMs as Operating Systems"
category: source
type: research-paper
tags: [context-window, long-term-memory, llm-agents, virtual-context, conversation-history, rag, function-calling, memory-hierarchy]
domain: code-agent
created: 2026-06-11
modified: 2026-06-11
related wikis: [code-agent]
---

# Source: MemGPT (Packer et al., 2024)

## 基本資訊

| 欄位 | 內容 |
|------|------|
| **論文** | MemGPT: Towards LLMs as Operating Systems |
| **作者** | Charles Packer, Sarah Wooders, Kevin Lin, Vivian Fang, Shishir G. Patil, Ion Stoica, Joseph E. Gonzalez |
| **發表** | arXiv v1: 2023-10-12；v2: 2024-02-12 |
| **領域** | cs.AI — Long-term Memory / Context Window Management / Agent Memory |
| **URL** | https://arxiv.org/abs/2310.08560 |
| **PDF** | raw/references/papers/ai/memgpt-2024-packer.pdf |
| **Metadata** | raw/references/papers/ai/memgpt-2024-packer.md |

---

## 核心論點

### 問題背景

LLM 的 fixed context window 會限制長對話、長文件 QA、多文件推理。直接擴大 context window 有兩個問題：

- Transformer attention 成本隨長度擴張，計算與記憶體昂貴。
- 即使模型支援長 context，也不一定能有效利用中間位置資訊（lost-in-the-middle 類問題）。

MemGPT 的核心主張是：**不要只把 context window 當成更大的 prompt，而要把它當成有限的主記憶體資源，由 agent 主動管理。**

### 核心解法：Virtual Context Management

MemGPT 借用作業系統的 virtual memory / paging 概念：

- **Main context**：LLM 當前 prompt tokens，類似 RAM / physical memory。
- **External context**：不在 prompt 裡的長期資料，類似 disk / external storage。
- **Working context**：prompt 中可讀寫的固定區塊，保存 persona、使用者偏好、任務狀態等高價值資訊。
- **FIFO queue**：最近訊息與 tool/function call history；超出容量時會 flush 並生成 recursive summary。
- **Recall storage**：完整訊息資料庫，可搜尋過去 conversation。
- **Archival storage**：任意長文本物件資料庫，供 document QA / long-term memory 使用。

關鍵不是單純 RAG，而是讓 LLM 透過 function calls **自行決定何時儲存、搜尋、載入、修改記憶**。

### 控制流設計：Interrupts + Function Chaining

MemGPT 把外部事件（使用者訊息、系統 warning、定時事件）視為 interrupts，觸發 LLM inference。function call 可帶 `request_heartbeat=true`，讓 agent 在回覆使用者前連續執行多步 retrieval / memory edit。

這讓 agent 能做 multi-hop context construction：先搜尋，再載入，再繼續搜尋，最後才回答。

---

## 實驗重點

### 1. Multi-Session Chat：長期對話記憶

在 Deep Memory Retrieval (DMR) task 中，agent 需要回答前幾個 session 才提到的細節。MemGPT 明顯提升固定 context baseline：

- GPT-3.5 Turbo：38.7% → MemGPT 66.9%
- GPT-4：32.1% → MemGPT 92.5%
- GPT-4 Turbo：35.3% → MemGPT 93.4%

這支持一個工程觀察：**壓縮摘要不等於長期記憶**；當問題需要精確回溯時，可搜尋的 recall storage 更穩。

### 2. Conversation Opener：記憶帶來個人化互動

MemGPT 用累積的 persona / user facts 產生更貼近長期關係的開場。論文用 persona label similarity 與 human opener similarity 評估，顯示 working context 中保存的高價值資訊能提升 engagement。

### 3. Document QA / Nested KV：多步檢索能力

文件分析任務中，MemGPT 不靠一次塞滿 prompt，而是把文件放在 archival storage，透過 paginated search 拉入相關片段。

Nested key-value retrieval 則測試多跳查詢：value 可能又是下一個 key。固定模型在 nesting level 增加時快速失敗；MemGPT with GPT-4 能透過連續 function queries 維持表現，展示「可迭代 context construction」的重要性。

---

## 和現有 Code-Agent Wiki 的關聯

### 和 [[code-agent]] 的關聯

MemGPT 是 code-agent / tool-use agent 的基礎架構參考：

- 把 context window 視為有限資源，而不是無限 append-only log。
- 把 conversation history 分成不同 memory tier：近期訊息、遞迴摘要、工作記憶、可搜尋歷史、長期文件庫。
- 讓 agent 用工具主動管理記憶，而不是由外部系統單向塞 prompt。
- 支援 function chaining，適合需要多步 retrieval / inspection / tool execution 的 coding agent。

### 和 ContextWeaver / Memory-R2 的對比

- **MemGPT**：inference-time virtual memory architecture，重點在 memory tier 與 self-directed function calls。
- **ContextWeaver**：dependency-aware trace graph，重點在 tool-use 步驟之間的邏輯依賴。
- **Memory-R2**：training-time fair credit assignment，重點在 memory 操作如何被 RL 正確學習。

三者互補：MemGPT 提供「記憶層級與 paging」；ContextWeaver 提供「依賴結構」；Memory-R2 提供「學習 memory operations 的訓練機制」。

---

## 討論問題（值得團隊討論）

1. **Agent 是否該自己管理記憶？** MemGPT 把 memory edit/retrieval 交給 LLM function calls；這提高彈性，但也讓品質依賴模型判斷。production 系統是否應加入 policy guard / validator？
2. **Working context 應保存什麼？** 使用者偏好、人格設定、任務目標、專案狀態都可能競爭有限空間；需要明確的 eviction / consolidation policy。
3. **Recursive summary 的角色**：摘要適合維持 narrative continuity，但不適合精確查詢；是否應固定搭配 recall storage？
4. **對 OpenClaw/Rowlet 的啟發**：目前已有 `MEMORY.md`、daily memory、workspace wiki；可以把它們視為 MemGPT-style tiers，並補上更明確的 search/load/update protocol。
5. **和 dependency graph 的結合**：MemGPT 的 recall/archival search 若只靠語意檢索，仍可能漏掉邏輯依賴；可與 ContextWeaver 的 dependency graph 合併。

---

## 備註

- PDF 已存：raw/references/papers/ai/memgpt-2024-packer.pdf
- Metadata 已存：raw/references/papers/ai/memgpt-2024-packer.md
- 讀取來源：arXiv abstract/API + ar5iv HTML 版本
