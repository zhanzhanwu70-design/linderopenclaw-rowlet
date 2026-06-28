---
title: "1.1 Uniprocessor Process Scheduling | Real-Time Systems 即時系統 | 郭大維"
type: source
tags: [real-time-systems, scheduling, embedded-systems, processor-scheduling, cpu]
status: completed
created: 2026-06-27
updated: 2026-06-27
source: https://www.youtube.com/watch?v=TOWSmjvQW8s
uploader: Tei-Wei Kuo 郭大維
duration: "1:20:58"
---

# 1.1 Uniprocessor Process Scheduling | 即時系統

## Summary
郭大維教授（台灣大學資訊工程系）的即時系統課程 Lecture 1.1，主題為單處理器程序排程（Uniprocessor Process Scheduling）。從 1973 年 Liu & Layland 的經典論文談起，涵蓋排程的基本問題、多項式時間複雜度、以及 Rate-Monotonic Scheduling。

## 內容要點

### 排程問題的起源
- 1973 年 Liu & Layland 發表「Independent Process Scheduling」（JNCM 1973）
- 論文提出用新方式思考「程序是否可排程」
- 核心問題：在時限內完成所有工作 + 在最短時間內完成所有工作

### 即時系統 vs 一般系統
- 一般系統：盡快完成工作（Throughput 最大化）
- 即時系統：**時限（Deadline）必需要滿足**
- Hard Real-Time：錯過時限 = 災難
- Soft Real-Time：錯過時限 = 效能下降

### Rate-Monotonic Scheduling（Rate Monotonic, RMS）
- 靜態優先級排程
- 週期越短（頻率越高）的任務優先級越高
- 可視為最佳靜態優先級分配
- 前提假設：搶占式優先級、任務週期性、上下文切換成本可忽略

### 排程可行性條件
Liu & Layland 證明：
- 对于 n 個週期任務，若 CPU 利用率 > n(2^(1/n) - 1)，則無法保證時限
- 當 n → ∞，臨界利用率趨近於 0.693（69.3%）

### 與一般排程的差異
| 維度 | 即時排程 | 一般排程（Unix/Linux CFS）|
|------|---------|------------------------|
| 目標 | 時限滿足 | 公平性、吞吐量 |
| 優先級 | 靜態或動態 | 動態（基於vruntime）|
| 錯過後果 | 確定性失敗 | 效能下降 |
| 分析方法 | 可預測性保證 | 統計分析 |

## Transcription
全文 2354 行：`raw/video/2026-06-27-TOWSmjvQW8s/audio.txt`

## Raw Files
- `raw/video/2026-06-27-TOWSmjvQW8s/audio.webm`（54.4 MB）
- `raw/video/2026-06-27-TOWSmjvQW8s/audio.wav`（152 MB）
- `raw/video/2026-06-27-TOWSmjvQW8s/audio.txt`（2354 行）
- `raw/video/2026-06-27-TOWSmjvQW8s/metadata.json`

## References
- Liu, C.L.; Layland, J.W. (1973). "Scheduling Algorithms for Multiprogramming in a Hard-Real-Time Environment". Journal of the ACM.