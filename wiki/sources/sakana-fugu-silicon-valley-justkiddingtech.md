---
title: "Sakana Fugu 不訓練模型改當指揮官，效能直逼 Anthropic Fable 5？"
type: source
tags: [sakana-fugu, multi-agent, model-orchestration, sakana-ai, anthropic, openai, gemini, collective-intelligence]
status: completed
created: 2026-06-28
updated: 2026-06-28
source: https://youtu.be/BFNMNIPnnIk
uploader: 矽谷輕鬆談 Just Kidding Tech
duration: "21:42"
---

# Sakana Fugu 不訓練模型改當指揮官，效能直逼 Anthropic Fable 5？

## Summary
Kenji 解析 Sakana AI 這間日本新創的背景、Fugu Ultra 的運作原理、以及它為何選擇不自己做模型而是當指揮官。

## Sakana AI 公司背景

### 基本資訊
- 2023 年成立，總部東京
- 創辦人：
  - **David Ha** — 前 Google Brain（2016-2022），後在 Stability AI 做到管理職
  - **Llion Jones** — Transformer 論文（2017）八位共同作者之一
- 為何在日本？資源受限，無法與美國一線公司買 GPU 拼算力

### 核心哲學
- 不做更大更強的模型
- 利用**演化**和**集體智慧**把模型組合出新的能力
- 每個模型有各自擅長的領域（GPT 系列數學推理強、Opus 系列寫作和自然語言、Gemini 事實回應和科學研究好）

## Sakana Fugu 兩種模型

| 模型 | 定位 | 運作方式 |
|------|------|---------|
| **Fugu** | 簡單任務 | 從池子裡挑一個模型出來做 |
| **Fugu Ultra** | 複雜任務 | 多模型協作，指揮官統一調度 |

## Fugu Ultra 運作原理

### 架構
```
用戶請求（OpenAI API 格式）
    ↓
7B 參數指揮官模型（Conductor）
    ↓
調度 Opus 4.8 / GPT 5.5 / Gemini 3.1 Pro 三家模型
    ↓
各模型協作給出最終答案
```

### 指揮官模型輸出的工作流程包含三件事
1. **Subtask 任務清單** — 把請求拆成小的子任務
2. **Worker 分配** — 每個子任務交給哪個模型
3. **Context Access** — 每個子任務的模型可以看到前面哪些步驟的答案

### 具體例子
```
請求：寫某個程式
↓
Model A：Brainstorming + Planning
Model B：Verify plan 好不好
Model C：實作
Model D：驗證實作結果
Model E：統整給出答案
```

### 訓練方式
- **Reinforcement Learning（RL）** 訓練
- 目標不是輸出人類喜歡的答案，而是**產生好的工作流程**
- 端到端訓練，會根據 reward function 自己生出好的 prompt 給子任務模型

## 為何日本公司有優勢
- 可以自由使用中國和美國的模型，不受出口管制影響
- 地緣政治允許他們扮演「中立協調者」的角色

## 社群討論
- 很多人懷疑「真的可以達到 Fable 等級嗎？」
- Sakana 發了很多論文證明每個模型有各自的專長領域
- 直接諷刺 Fable 被出口管制封閉的現象

## 與 OpenClaw 的關聯
- Fugu Ultra 的 Conductor 架構類似 OpenClaw 的 CEO Agent（任務協調）
- 但 Fugu 是自然語言 workflow，OpenClaw 是直接 tool call
- OpenClaw 的 advantage：直接行動，不只是輸出描述

## Transcription
全文 719 行：`raw/video/2026-06-28-BFNMNIPnnIk/audio.txt`

## Raw Files
- `raw/video/2026-06-28-BFNMNIPnnIk/audio.webm`（19.9 MB）
- `raw/video/2026-06-28-BFNMNIPnnIk/audio.wav`（40.7 MB）
- `raw/video/2026-06-28-BFNMNIPnnIk/audio.txt`（719 行）

## References
- Sakana AI: https://sakana.ai/
- Fugu: https://sakana.ai/fugu/
