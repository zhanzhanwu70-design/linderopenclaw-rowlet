---
title: "AI Agent Frameworks"
category: overview
tags: [agent, framework, tools, comparison]
created: 2026-05-07
modified: 2026-05-07
sources: ["https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f", "https://www.mindstudio.ai/blog/claude-code-vs-openai-codex-comparison"]
---

# AI Agent Frameworks - 主流框架總覽

## 一句話定義

**AI Agent = 接收任務 → 自己拆解 → 持續執行 → 直到完成的 AI 系統。**

---

## 目前主流 Coding Agent

### Claude Code (Anthropic)

| 面向 | 描述 |
|------|------|
| **定位** | 深度代理能力，專業開發者工具 |
| **執行環境** | 直接在你的終端機運行，使用實際檔案與環境 |
| **特點** | 深度理解複雜程式碼庫，agentic 能力更強 |
| **優勢** | 重視深度而非廣度 |
| **適合** | 專業開發者處理複雜任務 |

**與傳統 IDE copilot 差異**：不只是自動完成，而是能規劃、執行、測試、迭代的完整代理。

---

### OpenAI Codex

| 面向 | 描述 |
|------|------|
| **定位** | 雲端 autonomous coding agent |
| **執行環境** | OpenAI 管理的隔離雲端容器 |
| **特點** | 雲端隔離環境，end-to-end 任務執行 |
| **適合** | 非技術用戶，不想管理環境者 |

---

### Cursor

| 面向 | 描述 |
|------|------|
| **定位** | IDE 深度整合的 AI 工具 |
| **特點** | 完整 IDE 體驗，深度代碼庫理解 |
| **優勢** | 與 VS Code 生態整合緊密 |
| **適合** | 已經習慣 VS Code 的開發者 |

---

### 其他值得关注的 Agent

| 工具 | 描述 |
|------|------|
| **Gemini CLI** | Google 的 CLI coding agent |
| **Copilot** | Microsoft，VS Code 深度整合 |
| **Windsurf** | 新興的 AI coding agent |
| **OpenClaw** | 開源的 agent 運行時框架 |

---

## Agent 的四大工程支柱

LLM Agent 要穩定運作在生產環境，需要四個工程模組：

### 1. 提示詞工程 (Prompt Engineering)

設計與優化 prompt，讓 agent 輸出：
- 夠穩定
- 符合預期
- 完成任務

### 2. 工作流管理 (Workflow Management)

將複雜任務串聯：
- 任務分解
- 順序控制
- 狀態管理
- 工具呼叫協調

### 3. 監控系統 (Monitoring)

觀察 agent 實際執行情形：
- 行為追蹤（Trace）
- 指標收集（Metrics）
- 異常偵測
- 長期趨勢

### 4. 自動修復 (Auto-fixing)

錯誤發生時自動處理：
- 錯誤偵測
- 自動重試
- 自我修正
- Fallback 機制

---

## 與傳統 RAG 的對比

| 面向 | 傳統做法 | Agent 做法 |
|------|---------|-----------|
| 知識獲取 | 每次重新搜尋 | 持續累積到 wiki |
| 錯誤處理 | 人工介入 | 自動重試與修正 |
| 系統維護 | 人力維護 | LLM 自動維護 |
| 複雜任務 | 一次性 prompt | 多步任務分解 |

---

## 如何選擇適合的 Agent

### 根據使用場景

| 場景 | 推薦工具 |
|------|----------|
| 專業開發，深度複雜任務 | Claude Code |
| 雲端隔離，不想管環境 | OpenAI Codex |
| 已經習慣 VS Code | Cursor + Copilot |
| 開源、可自架 | OpenClaw |
| 快速玩玩看 | Gemini CLI |

### 根據任務複雜度

```
簡單任務（單一檔案修改）
  → Copilot / Gemini CLI 即可

中等複雜（多檔案、簡單工作流）
  → Cursor / Windsurf

複雜任務（完整專案、測試、部署）
  → Claude Code / OpenAI Codex
```

---

## 與 LLM Wiki 的整合

AI Agent 是 LLM Wiki 的「操作者」：

```
你（策劃來源，引導分析）
  ↓
Agent（比如 Claude Code）
  ↓
根據 AGENTS.md 維護 wiki
  ↓
Ingest / Query / Lint 工作流
```

Agent 讓 wiki 維護成本趨近於零。

---

## 相關頁面

- [[karpathy-llm-wiki]] — LLM Wiki 核心概念
- [[harness-engineering]] — Agent 的四大工程支柱
- [[vibe-coding]] — AI 輔助開發的新方式

---

_tags: [agent, framework, tools, comparison]_
