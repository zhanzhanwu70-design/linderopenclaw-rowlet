---
title: "什麼場景下用多 Agent 的系統"
type: source
tags: [multi-agent, single-agent, architecture, context-window, parallel-processing, latency, token-cost]
status: completed
created: 2026-06-28
updated: 2026-06-28
source: https://youtu.be/f1JomzdafGM
uploader: AI大模型小冉Agent
duration: "5:51"
---

# 什麼場景下用多 Agent 的系統

## Summary
面試熱題解析：多 agent 不是萬靈丹，90% 候選人死在過度設計。真正的判斷標準只有兩把尺：任務併發收益 + 單一上下文窗口能否裝下。

## 核心觀點

### 單 Agent 的適用場景
- **低延遲、低成本的閃電戰**
- 步驟清晰、嚴格串行的線性任務
- 總數據量不大，單一上下文可以容納

### 多 Agent 的適用場景
- **超越上下文限制 + 專業分工的陣地戰**
- 可並行的數據量巨大的複雜任務
- 單一模型的物理限制被觸發時

## 兩把判斷尺

### 第一把：任務的併發收益有多大？
- 如果各步驟有依賴關係（必須等上一步完成）→ 單 Agent
- 如果各步驟可以並行獨立執行 → 多 Agent

### 第二把：單一上下文窗口能不能裝得下？
- 裝得下 → 單 Agent
- 裝不下（物理限制）→ 多 Agent

## 案例一：電商智能客服（不該用多 Agent）

**場景**：查退款訂單進度

**步驟（嚴格串行）：**
1. 意圖識別 → 確定用戶想幹嘛
2. 提取訂單號 → 調用數據庫工具查訂單狀態
3. 自然語言總結回覆用戶

**分析**：
- 三步是嚴格串行依賴，不知道訂單號就沒法查數據庫
- 如果用多 Agent：查詢專員 → 回覆專員，多一次大模型請求
- 用戶等待時間：3 秒 → 10+ 秒
- **結論**：單 Agent + 幾個工具調用，效率最高、成本最低

## 案例二：企業級代碼安全審計（該用多 Agent）

**場景**：幾萬~幾十萬行代碼的巨型倉庫

**問題**：單 Agent 硬扛：
1. 代碼全塞進上下文 → 上下文窗口撐爆
2. 即使沒撐爆 → 大模型 Lost-in-the-Middle，看完後面忘了前面
3. 抓不住深層次安全隱患

**多 Agent 解法（三個並行）：**

| Agent | 職責 |
|-------|------|
| 安全檢測 Agent | 掃描 SQL 注入、跨站腳本漏洞 |
| 性能分析 Agent | 查記憶體洩漏、死循環 |
| 代碼規範 Agent | 扣命名、註釋風格 |

**三個 Agent 同時並發開工**，各自只加載相關的代碼切片，拿到結果後交給主控 Agent 合併生成報告。

## 多 Agent 的代價

| 問題 | 說明 |
|------|------|
| **延遲** | 每個 API 調用都是秒級網絡延遲，不是記憶體順發 |
| **成本** | 上下文在 Agent 間反覆傳遞，token 指數級飆升 |
| **Debug** | 滿屏日誌難以定位哪個 Agent 在幻覺 |

## 一句話總結

> 單 Agent 打低延遲低成本的閃電戰，多 Agent 打超越上下文限制的陣地戰。永遠先用單 Agent 跑通業務原型，驗證邏輯閉環，再考慮多 Agent。

## 實戰思考題（留給讀者）
業務不可避免必須採用多 Agent 架構時，用哪些具體策略或技術手段把居高不下的 token 成本和通信延遲打下來？

## Transcription
全文：`raw/video/2026-06-28-f1JomzdafGM/audio.txt`

## Raw Files
- `raw/video/2026-06-28-f1JomzdafGM/audio.webm`（4.73 MB）
- `raw/video/2026-06-28-f1JomzdafGM/audio.wav`（10.7 MB）
- `raw/video/2026-06-28-f1JomzdafGM/audio.txt`
