---
title: "Sakana Fugu：多智能體協同如何超越單一巨型模型"
type: source
tags: [multi-agent, sakana-ai, collective-intelligence, llm, agentic]
status: completed
created: 2026-06-25
updated: 2026-06-25
source: https://vocus.cc/article/6a3a82a2fd89780001e18884
author: "TN科技筆記(TechNotes)"
---

# Sakana Fugu：多智能體協同如何超越單一巨型模型

## Summary
Sakana AI 的 Sakana Fugu 商業化 API 產品，一個將多智能體系統封裝成單一 API 的協調者模型。動態串聯全球頂尖語言模型執行任務，在多項指標上超越單一巨型模型。

## 核心概念

### 為何需要群體智慧？
- 單一巨型模型（GPT-5.5、Claude Opus 4.8、Gemini 3.1 Pro）面臨物理與經濟雙重邊際效益遞減
- 擴展模型體積的做法遇到瓶頸

### Sakana Fugu 兩種模式
| 版本 | 定位 | 適用場景 |
|------|------|---------|
| Fugu | 效能與延遲平衡 | 程式碼撰寫、程式碼審查、聊天機器人 |
| Fugu-Ultra | 極致效能，多專家代理池 | Kaggle 競賽、論文重現、網路安全、專利調查 |

## 技術架構

### Selection Head 機制
- 在語言模型最終隱藏層後附加輕量級 Selection Head
- 輸出 Logit 數值矩陣對各模型進行適合度評分
- 省去耗時的自迴歸解碼，延遲等同於呼叫單一模型

### 奇異值微調（SVFT）
- 不動原本主機板線路（保持正交分量）
- 只微調特定頻道的「音量推桿」（奇異值尺度）
- 大幅節省運算資源

### 與 The AI Scientist 的關係
- The AI Scientist：自動化機器學習研究生命週期，登上《Nature》
- Fugu：商業化 API，將多智能體封裝成單一端點
- 兩者基底相同，但面向不同市場

## 關鍵數據
- 自動審查系統平衡準確率：69%（媲美人類專家）
- 系統輸出論文在 ICLR 2025 ICBINB 工作坊獲得 6.33 平均分（超越 55% 人類作者）
- 科學發現存在縮放定律：更強的底層模型 → 更高品質論文輸出

## 相關研究
- ICLR 2026 論文入選（詳細技術報告）
- Sakana AI × 英屬哥倫比亞大學、Vector Institute、牛津大學

## References
- Sakana Fugu: https://sakana.ai/fugu/
- The AI Scientist: https://sakana.ai/ai-scientist/
