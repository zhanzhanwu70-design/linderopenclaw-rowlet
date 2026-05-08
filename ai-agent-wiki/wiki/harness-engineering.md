---
title: "Harness Engineering"
category: engineering
tags: [harness, prompt-engineering, workflow, monitoring, auto-fixing]
created: 2026-05-07
modified: 2026-05-07
sources: []
---

# Harness Engineering - AI Agent 的四大工程支柱

## 一句話定義

**Harness = 讓 AI Agent 在生產環境穩定運作的所有周邊工程。**

---

## 為什麼需要 Harness？

```text
沒有 Harness 的 Agent：
  Prompt + LLM = 就結束了
  每次回答品質飄逸
  錯誤難以追蹤
  只能處理簡單任務

有 Harness 的 Agent：
  穩定的輸出
  錯誤可追蹤、可修正
  可處理複雜多步任務
  真正的自動化系統
```

---

## 四大模組

```
┌─────────────────────────────────────┐
│           AI Agent Harness          │
├──────────┬──────────┬─────────┬──────┤
│  提示詞   │  工作流   │  監控   │ 自我 │
│  工程    │  管理    │  系統   │ 修復 │
└──────────┴──────────┴─────────┴──────┘
```

---

## 1. 提示詞工程 (Prompt Engineering)

### 在做什麼
設計、測試、優化傳給 LLM 的 prompt。

### 主要工作

| 工作 | 說明 |
|------|------|
| **Prompt 設計** | 怎麼說 agent 才聽得懂 |
| **版本管理** | Prompt 也是 code，要追蹤版本 |
| **測試驗收** | 建立 benchmark dataset |
| **安全防護** | injection 防禦、輸出邊界控制 |
| **持續優化** | 隨模型更新調整 |

### 核心原則
```
壞的 Prompt：幫我整理這些文件
好的 Prompt：
你是一份文件整理助理。請：
1. 找出所有 PDF
2. 按日期由新到舊排列
3. 輸出 Markdown 清單
4. 忽略任何超過 50MB 的檔案
```

---

## 2. 工作流管理 (Workflow Management)

### 在做什麼
把多步任務串起來，讓 agent 按順序、條件、分支執行。

### 主要能力

| 能力 | 說明 |
|------|------|
| **任務分解** | 複雜任務切成子任務鏈 |
| **順序控制** | 一步一步執行，不能跳步 |
| **條件分支** | 滿足條件才做某事 |
| **並行執行** | 獨立步驟同時處理 |
| **狀態維護** | 跨步共享 context |

### 常見框架
- LangGraph
- AutoGen
- CrewAI
- OpenAI Assistants API
- 自建 State Machine

---

## 3. 監控系統 (Monitoring System)

### 在做什麼
觀察 agent 實際執行情形。

### 四個層次

| 層次 | 內容 |
|------|------|
| **Trace** | 每次操作記錄：輸入、工具呼叫、輸出、時間 |
| **Metrics** | 成功率、執行時間、token 消耗 |
| **Anomaly** | 輸出偏離、成功率下降、穩定失敗 |
| **Trend** | 系統退化、版本效果差異 |

### 常見工具
```
LangSmith
Weights & Biases
Phoenix (Arize)
OpenTelemetry + 自建 Dashboard
```

---

## 4. 自動修復 (Auto-fixing / Self-healing)

### 在做什麼
錯誤發生時，自動嘗試修正，不需人工介入。

### 三層機制

```
錯誤偵測
    ↓
自動重試（backoff）
    ↓
失敗 → 分析原因 → 修正 → 重試
    或 → Fallback 備案
```

### 常見策略

| 策略 | 說明 |
|------|------|
| **Retry** | 網路 timeout 等可重試錯誤 |
| **Self-correction** | 讓 LLM 自己檢討錯誤並修正 |
| **Fallback** | 主要方法失敗時切換備案 |
| **Max Iteration** | 限制重試次數，避免無限期 |

---

## 四個模組的協作關係

```
使用者提出任務
        ↓
┌───────────────────┐
│    提示詞工程      │  ← 讓 AI 聽得懂任務
└────────┬──────────┘
         ↓
┌───────────────────┐
│    工作流管理      │  ← 把任務拆解成步驟
└────────┬──────────┘
         ↓
┌───────────────────┐
│   執行 + 工具呼叫   │
└────────┬──────────┘
         ↓
┌───────────────────┐
│    監控系統        │  ← 觀察有沒有做對
└────────┬──────────┘
         ↓
┌───────────────────┐
│    自我修復        │  ← 出錯時自動修正
└────────┬──────────┘
         ↓
      任務完成
```

---

## 比喻版總結

| 模組 | 比喻 |
|------|------|
| **提示詞工程** | 教新人怎麼聽懂指令 |
| **工作流管理** | 給新人排行程表 |
| **監控系統** | 給新人裝行車記錄器 |
| **自動修復** | 給新人訓練突發狀況處理 |

---

## 相關頁面

- [[agent-frameworks]] — 各框架的實際應用
- [[karpathy-llm-wiki]] — 與 wiki 系統的整合

---

_tags: [harness, prompt-engineering, workflow, monitoring, auto-fixing]_
