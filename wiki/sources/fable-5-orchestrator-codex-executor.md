---
title: "Fable 5 Orchestrator + Codex 5.5 Executor — AI 開發團隊框架"
type: source
tags: [fable-5, orchestrator, codex, gemini, multi-agent, development-team, workflow, executor, reviewer]
status: completed
created: 2026-07-02
updated: 2026-07-02
source: https://x.com/kunchenguid/status/1951922548849664242
---

# Fable 5 Orchestrator + Codex 5.5 Executor

## 整體架構

多模型協作（Multi-Agent Orchestration）架構，採用「分工 + 驗收」模式。

| 角色 | 模型 | 職責 |
|------|------|------|
| **Orchestrator** | Fable 5 | 任務切割、規劃、定義驗收標準 |
| **Executor** | Codex 5.5 | 接收指令、產出程式碼 |
| **Reviewer** | Gemini 3.1 Pro | 從第三角度審查品質 |
| **Human** | 人類 | 需求決策、最終驗收 |

核心概念：**不是讓單一模型變更強，而是讓模型分工 + 互相驗收**。

## 工作流程（5 步驟迭代收斂）

```
① 定義任務              ② 執行實作
Fable 5 分析問題    →   Codex 5.5 /goal 模式
制定標準與驗收            自主驗證執行
     ↓                       ↓
⑤ 驗收收尾          ←   ③ 真實審核
Commit / Push           Gemini + Codex 雙審
     ↑                       ↓
④ 仲裁決策          
Fable 5 驗證證據
```

當標準未達成時，自動回到步驟 ② 重新執行，直到所有標準通過。

## 效益數據

| 指標 | 成果 |
|------|------|
| 總任務進度 | **3.2x 快** |
| 任務完成率 | **92%**（vs 傳統 35%）|
| 重大 Bug 漏掉率 | **-82%** |
| 卡關時間 | **-90%** |
| Token 總成本 | **-65%** |

## Token 分配優化

| 模式 | Fable 5 | Codex | Gemini |
|------|---------|-------|--------|
| 傳統模式 | 28% | 52% | 20% |
| **新模式** | **10%** | 60% | 15% |

Fable 5 用最少 Token 創造最大價值。

## 各模組功能

**Fable 5 Orchestrator：**
- 任務切割與規劃
- 定義驗收標準
- 審查停滯與進度
- 控制進度與記憶管理
- 最終品質把關

**Codex 5.5 Executor：**
- 接收 Fable 5 的精準工單
- 計算與執行
- 程式實作
- 測試驗證
- 回報完成報告

**Gemini 3.1 Pro Reviewer：**
- 真實角度審查
- 高 Recall 找問題
- 提出建議
- 不做最終決策

## 三大專案實戰成果

| 專案 | 速度提升 | Bug 減少 |
|------|---------|---------|
| reel-workflow-v2 | 3.5x | -85% |
| billing-system | 3.1x | -80% |
| voice-pipeline | 3.3x | -82% |

## 核心設計理念

> 不是單一模型變強，而是最強團隊的力量

- Fable 5 = 最擅長「指揮」
- Codex 5.5 = 最擅長「執行」
- Gemini 3.1 Pro = 最擅長「審核」
- 人類智慧 = 終極決策
