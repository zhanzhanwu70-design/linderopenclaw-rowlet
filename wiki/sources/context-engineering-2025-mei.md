---
title: "A Survey of Context Engineering for Large Language Models"
category: source
type: research-paper
tags: [context-engineering, context-window, context-management, context-compression, rag, memory-systems, multi-agent, llm-agents, long-context, context-retrieval, tool-integrated-reasoning]
domain: code-agent
created: 2026-06-15
modified: 2026-06-15
related wikis: [code-agent]
---

# Source: Context Engineering Survey (Mei et al., 2025)

## 基本資訊

| 欄位 | 內容 |
|------|------|
| **論文** | A Survey of Context Engineering for Large Language Models |
| **作者** | Lingrui Mei, Jiayu Yao, Yuyao Ge, Yiwei Wang, Baolong Bi, Yujun Cai, Jiazhi Liu, Mingyu Li, Zhong-Zhi Li, Duzhen Zhang, Chenlin Zhou, Jiayi Mao, Tianze Xia, Jiafeng Guo, Shenghua Liu et al. |
| **發表** | arXiv:2507.13334v2, 2025-07-21 |
| **領域** | cs.CL — Context Engineering / LLM Agent / Context Management |
| **URL** | https://arxiv.org/abs/2507.13334 |
| **PDF** | raw/references/papers/ai/context-engineering-2025-mei.pdf |
| **Code** | https://github.com/Meirtz/Awesome-Context-Engineering |
| **引用** | 1411+ citations |

---

## 核心論點

### 論文定位

這是一篇覆蓋範圍極廣的 survey（166 pages, 1411 citations），將 Context Engineering 定義為：
> 超越 prompt design 的正式學科，系統性優化 LLMs 的資訊負載。

論文將領域分為兩層：**Foundational Components**（基礎元件）與 **System Implementations**（系統實作）。

### 三大 Foundational Components

#### 1. Context Retrieval and Generation
- Prompt engineering & context generation
- External knowledge retrieval
- Dynamic context assembly

#### 2. Context Processing
- Long sequence processing（包含 sliding window、sparse attention 等）
- Contextual self-refinement and adaptation
- Multimodal context
- Relational and structured context

#### 3. Context Management
- Fundamental constraints（context window 限制、attention 成本）
- Memory hierarchies and storage architectures
- **Context compression**（ condensation、summarization、learned compression）
- Applications

### 四大 System Implementations

#### 1. Retrieval-Augmented Generation (RAG)
- Modular RAG architectures
- Agentic RAG systems
- Graph-enhanced RAG

#### 2. Memory Systems
- Memory architectures（equivalent to MemGPT-style tiers）
- Memory-enhanced agents
- Evaluation and challenges

#### 3. Tool-Integrated Reasoning
- Function calling mechanisms
- Tool-integrated reasoning
- Agent-environment interaction

#### 4. Multi-Agent Systems
- Communication protocols
- Orchestration mechanisms
- Coordination strategies

### 關鍵 research gap（重要發現）

> **Asymmetry Problem**：Current LLMs excel at *understanding* complex contexts, but are severely limited in *generating* equally sophisticated long-form outputs.

即：模型善於消費 context，但 context 生產能力（生成複雜長文、主動建構 context）遠遠落後。這是未來研究的首要優先方向。

---

## 和現有 Code-Agent Wiki 的關聯

### 和 [[code-agent]] 的關聯

這篇 survey 為整個 code-agent 領域提供了統一的 taxonomy：

- **Context Retrieval** → 对应 ContextWeaver 的 dependency-aware retrieval
- **Context Compression** → 对应 MemGPT 的 recursive summarization
- **Memory Hierarchies** → 对应 MemGPT 的 tiered memory（working/recall/archival）
- **RAG** → 與傳統 document retrieval 不同，agentic RAG 強調動態、迭代、多步檢索
- **Multi-Agent** → ContextWeaver 的 agent graph orchestration

### 和 ContextWeaver / MemGPT / Memory-R2 的對比

| 論文 | 重點 |
|------|------|
| **Context Engineering Survey** | 統一 taxonomy，涵蓋所有子領域 |
| **MemGPT** | Runtime virtual memory paging，讓 LLM 自己管理記憶 |
| **ContextWeaver** | Dependency-aware trace graph，tool-use 步驟邏輯依賴 |
| **Memory-R2** | Training-time fair credit assignment for memory operations |

### 對 OpenClaw/Rowlet 的啟發

1. **Asymmetry Problem**：我們一直在優化「如何給模型更好的 context」，但幾乎沒有研究「如何讓模型主動生成好的 context」。這是個值得關注的 research gap。
2. **Compression vs. Retrieval**：compression 適合維持敘事連貫性，retrieval 適合精確查詢。OpenClaw 目前有 `MEMORY.md` + daily memory files，屬於 compression/summary 路線，但缺乏可搜尋的 recall storage。
3. **Graph-enhanced RAG**：結構化知識（如 wiki 之間的 link graph）可以提升 retrieval 精確度，值得在 OpenClaw workspace 內實驗。

---

## 討論問題（值得團隊討論）

1. **Asymmetry Problem 是否已在影響我們？** 當 Rowlet 要主動建構 context（如 self-reflection、memory consolidation）時，是否感到模型生成能力不足？
2. **Compression + Retrieval 的最佳比例？** 目前 workspace 的 MEMORY.md 是 summary-based；但長期下來是否需要疊加 semantic search？
3. **Agentic RAG 在個人 agent 的可行性**：目前 RAG 主要用於企業知識庫；但個人 agent（如 Rowlet）是否也能受益於 modular/agentic RAG？
4. **Context Engineering 的實作優先順序**：若要改進 OpenClaw 的 context 管理，應該先從哪個元件下手——compression policy、recall storage、還是 dependency graph？

---

## 備註

- PDF 已存：raw/references/papers/ai/context-engineering-2025-mei.pdf
- 讀取來源：arXiv abstract + ar5iv HTML 版本
