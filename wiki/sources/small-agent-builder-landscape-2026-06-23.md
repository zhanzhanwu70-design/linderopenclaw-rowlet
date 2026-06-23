---
title: Small Agent Builder 生態地圖 2026-06-23
description: 目前專門製作小型agent的工具與 framework 整理
date: 2026-06-23
tags: [agent, small-agent, agent-builder, micro-agent, no-code]
source: GitHub Topics research
---

# Small Agent Builder 生態地圖 2026-06-23

## 回答：目前是「靠現成 framework 組」居多，專門做小型agent skill 的不多

---

## 一、大型框架（主流選擇）

| 框架 | 特色 | 適合場景 |
|------|------|---------|
| **LangChain / LangGraph** | 生態最完整，文件最多 | 需要灵活组合的複雜工作流 |
| **AutoGen** (Microsoft) | 多agent對話協作 | 對話型多agent系統 |
| **CrewAI** | Role-based agent 組織 | 固定流程的自動化任務 |
| **Pydantic AI** | Pydantic 風格的型別安全 | 已有 Pydantic 習慣的團隊 |

---

## 二、專門做小型/Micro Agent 的框架

### 🤏 Smolagents（Hugging Face）
- **口號**：「Agents that think in code!」
- **核心**：一個 agent 邏輯約 1000 行 code，抽象極簡
- **支援**：CodeAgent（用 code 而非文字表達 action）、MCP tools、sandboxes（E2B/Blaxel/Modal/Docker）
- **優點**：極輕量、model-agnostic、可從 Hub 分享 agent

### 🔧 Tsugite
- **定義 agent 方式**：Markdown + YAML frontmatter
- **鏈接多個 steps、step 間傳遞數據**
- **支援**：OpenAI / Anthropic / Ollama
- **優點**：非技術背景也能寫 agent 設定檔

### ⚡ Micro-agent-template（BitteProtocol）
- TypeScript，smol agents 模板
- 重點在可組合的微小 agent 單元

### 🔬 Neural Computation Protocol (NCP)
- Rust 實作
- **Composable, sandboxed Bricks + graphs**
- 目標：可審計、可回放 的 agentic 系統

### 🐠 BitteProtocol / micro-agent-template
- TypeScript
- 定位：最小的 agent 模板

---

## 三、No-Code / Low-Code Agent Builder

| 平台 | 特色 |
|------|------|
| **DocsGPT** (Arc53) | Agent Builder + Deep research + 文檔分析 |
| **Inkeep Agents** | No-Code 視覺化建構 + TypeScript SDK |
| **GISELLE AI** | 開源 AI App Builder |
| **BettaFish** | 中文輿情分析助手（多Agent，不依賴任何框架）|
| **vibesurf** | AI 瀏覽器智能助手 |

---

## 四、趨勢觀察

### ✅ 兩條路線正在收斂

1. **「極簡框架」路線**（Smolagents、Tsugite、NCP）
   - 理念：框架只是薄層，真正的 logic 在 code 或設定檔
   - 小型 agent 應該用完即棄，不需 heavy framework

2. **「No-Code 平台」路線**（Inkeep、GISELLE）
   - 理念：agent 應該像填表一樣建立
   - 目標用戶：非工程師

### ⚠️ 「agent-builder skill」的缺口

目前**沒有**類似 `agent-maker` / `small-agent-skill` 的熱門 topic（GitHub 這兩個 topic 都是 0 個 repo）。

代表多數人的做法是：
- **用 LangChain / CrewAI 這類大框架**，再從中抽離/客製
- **自己寫輕量 script**，而非用專門的 builder tool

---

## 五、結論

> **多數人確實是用現成框架（LangChain、CrewAI、AutoGen）來組小型 agent。**
> 專門做小型/一次性 agent 的工具剛開始出現（Hugging Face Smolagents、Tsugite），但還不是主流。

**對 Rowlet 的啟示**：與其等專門的「agent skill builder」工具出現，不如熟悉一兩個輕量框架（Smolagents + Tsugite）的手動組合模式，這種彈性反而更符合多變的任務需求。

---

## 關鍵字
micro-agent, smolagent, tsugite, ncp, agent-builder, no-code-agent, agent-factory, pydantic-ai, openai-agents-sdk
