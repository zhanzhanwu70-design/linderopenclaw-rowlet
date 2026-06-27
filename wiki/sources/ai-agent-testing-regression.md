---
title: "AI Agent 测试：如何省去90%的手动验证"
type: source
tags: [ai-agent, testing, regression-test, verification-asymmetry, llm, codegen]
status: completed
created: 2026-06-27
updated: 2026-06-27
source: https://www.youtube.com/watch?v=H0XmxIalAEQ
duration: "14:27"
note: "標題蹭流量，與馬斯克無關"
---

# AI Agent 测试：如何省去90%的手动验证

## Summary
開發者自述 AI agent 開發中 90% 時間耗在手動測試，提出一套「可驗證架構」——把驗證問題從「用肉眼看」變成「自動回歸測試」，核心引用 Jason Wei 的「驗證不對稱性」概念。

## 驗證不對稱性（Verification Asymmetry）

提出者：Jason Wei（2025, OpenAI）

> 生成便宜，驗證昂貴

- AI 讓寫程式變便宜（生成）
- 但驗證 agent 輸出是否正確仍靠手動（昂貴）
- 這個不對稱浪費 90% 開發時間

**Very's Law**：任何可生成且易於驗證的任務，終將被 AI 解決。

## 開發者的解法：可驗證架構

### 第一步：讓 agent 對其他 agent 友好
改造 AI agent，使其輸出結構化、可解析的結果。

### 第二步：建回歸測試（Regression Test）

**裁判拆兩層：**

| 層 | 職責 | 特性 |
|----|------|------|
| **第一層：確定性斷言** | 工具是否觸發、中間狀態、記錄數量 | 絕對可靠、確定性、零成本 |
| **第二層：LLM Supervisor** | 處理模糊部分，打分 | 專門判斷「有多好」，不判斷「對錯」 |

LLM Supervisor 的關鍵細節：
- 上下文必須乾淨（不參與開發、不知道程式碼來龍去脈）
- 不判斷對錯，只做量化打分

### 第三步：不停增加用例
- **Happy Path** — 新功能的預期路徑（驗收標準）
- **真實五花八門的輸入** — 從真實用戶、測試中撈

### 第四步：Feature Flag
每個新功能配一個開關，開關對比看：
- 哪些變好了
- 哪些被悄悄弄壞了

### 第五步：閉環自動化
讓 Codex 自己：
1. 設計回歸測試
2. 設計開關
3. 開發代碼
4. 開關開/關時各跑一次回歸測試
5. 根據結果反饋修改代碼

## 核心觀點

> 當 AI 把寫程式變便宜，你的價值就在於「能不能設計出一套讓每次改動都能被驗證的體系」。

這與晶片設計驗證高度相似：
- 晶片代碼工程師比驗證工程師少
- 驗證人力往往是設計的 2-3 倍
- 晶片一旦流片出錯，幾百萬美金打水漂

AI agent 開發正在走向同樣的形狀。

## 與馬斯克無關

標題蹭流量，內容是原創開發者經驗分享。

## Transcription
全文 388 行：`raw/video/2026-06-27-H0XmxIalAEQ/audio.txt`

## Raw Files
- `raw/video/2026-06-27-H0XmxIalAEQ/audio.webm`（10.1 MB）
- `raw/video/2026-06-27-H0XmxIalAEQ/audio.wav`（27 MB）
- `raw/video/2026-06-27-H0XmxIalAEQ/audio.txt`（388 行）

## References
- Jason Wei（2025, OpenAI）— Verification Asymmetry
- 晶片設計驗證產業慣例
