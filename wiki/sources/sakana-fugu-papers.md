---
title: "Sakana Fugu / TRINITY / Conductor 論文"
type: source
tags: [multi-agent, sakana-ai, trinity, conductor, learned-orchestration, llm, grpo, evolutionary-strategy, iclr-2026]
status: completed
created: 2026-06-25
updated: 2026-06-25
source: https://arxiv.org/abs/2606.21228
---

# Sakana Fugu 三篇源頭論文

## 論文清單

| 論文 | arXiv ID | 會議 | 大小 |
|------|----------|------|------|
| Sakana Fugu Technical Report | [2606.21228](https://arxiv.org/abs/2606.21228) | — | 6.4 MB |
| TRINITY: An Evolved LLM Coordinator | [2512.04695](https://arxiv.org/abs/2512.04695) | ICLR 2026 | 12 MB |
| Learning to Orchestrate Agents with the Conductor | [2512.04388](https://arxiv.org/abs/2512.04388) | ICLR 2026 | 4.0 MB |

## Sakana Fugu Technical Report

### 核心定位
Fugu 是一個將多智能體系統封裝成單一 API 的協調者模型。透過動態召集專家模型團隊來解決複雜任務，在多個基準達到 SOTA。

### 兩種模型
| 模型 | 定位 | 延遲 | 適用場景 |
|------|------|------|---------|
| **Fugu** | 性能與延遲平衡 | 低 | 日常 coding、code review、聊天機器人 |
| **Fugu-Ultra** | 極致性能 | 較高 | Kaggle 競賽、論文重現、網路安全、專利調查 |

### 訓練方式
- Large-scale fine-tuning
- Evolutionary algorithms（演化策略）
- Reinforcement learning（強化學習）
- GRPO（Group Relative Policy Optimization）

### 測試基準
SWE-Bench Pro、Terminal Bench、LiveCodeBench、GPQA-Diamond、Humanity's Last Exam、CharXiv Reasoning

---

## TRINITY: An Evolved LLM Coordinator

### 核心架構
- **Coordinator**：~0.6B 參數的緊湊語言模型
- **Lightweight Head**：~10K 參數的 Selection Head
- **訓練演算法**：CMA-ES（分離式共變異數自適應演化策略）
- **非 RL / 非模仿學習 / 非隨機搜索**

### 三種角色分配
每個 turn，協調者指定選中的 LLM 承擔以下角色之一：
| 角色 | 功能 |
|------|------|
| **Thinker** | 思考、規劃、分解任務 |
| **Worker** | 執行、產出 |
| **Verifier** | 驗證 Worker 輸出是否正確 |

### 關鍵發現
1. 協調者的 hidden-state 表示豐富化了輸入 context
2. 在高維度 + 嚴格預算限制下，CMA-ES 比 RL/模仿學習/隨機搜索更有效
3. 因為 CMA-ES 可以利用潛在的 block-ε-separability

### 成果
LiveCodeBench 86.2%（SOTA）

---

## Conductor: Learning to Orchestrate Agents

### 核心架構
- **Conductor**：7B 參數，RL 訓練
- 自動發現自然語言協調策略
- 學習設計通訊拓撲（agent-to-agent collaboration patterns）
- 學習 prompting 工程，給各 LLM 聚焦指令

### 關鍵創新

#### 1. 通訊拓撲學習
不只是靜態的「誰叫誰」，而是動態學出「什麼任務、用什麼順序、經過哪些 agent」。

#### 2. 遞迴拓撲（Recursive Topology）
**最特別的發現：Conductor 可以選擇自己作為 Worker。**

```
Conductor → 叫 Worker LLM A
Conductor → 叫 Worker LLM B
Conductor → 叫自己（Conductor as Worker）→ 再次規劃 → 叫 Worker
```

這產生了一種動態測試時擴展（dynamic test-time scaling）：透過在線迭代適應，性能可以遞進。

#### 3. 任意 Agent Pool 適應
訓練時使用隨機化的 agent pool，因此可以適應任何開放或封閉來源的 agent 組合。

### 成果
- LiveCodeBench SOTA
- GPQA SOTA
- 7B Conductor 打敗所有 individual workers

### 與 TRINITY 的差異
| | TRINITY | Conductor |
|---|---|---|
| 訓練方式 | CMA-ES（演化策略） | RL（GRPO 等） |
| 輸出 | Hidden-state → Selection Head | 自然語言 workflow |
| 規模 | 0.6B coordinator | 7B conductor |
| 迭代 | 多 turn，但固定角色 | 遞迴拓撲，Conductor 可選自己當 Worker |
| 預算控制 | CMA-ES block-ε-separability | RL reward maximization |

---

## 三篇論文的關係

```
TRINITY + Conductor
        ↓
   Sakana Fugu（產品化）
        ↓
  Fugu + Fugu-Ultra（API）
```

- **TRINITY** = 輕量級 Coordinator（0.6B，CMA-ES 訓練）→ 快速、低延遲
- **Conductor** = 重量級 Coordinator（7B，RL 訓練）→ 更強、遞迴拓撲
- **Fugu Technical Report** = 兩者整合成產品的系統描述

## 與 MoE 的本質差別

| | MoE | TRINITY/Conductor |
|---|---|---|
| 路由顆粒度 | Token 級 | 任務/步驟級 |
| 協調層次 | 神經網路內部 | 多模型系統外部 |
| 專家定義 | FFN 子網路 | 獨立的外部 LLM |
| 决策方式 | 學習出來的權重 | 學習出來的協作策略 |

## Raw Files
- `raw/papers/sakana-fugu/trinity.pdf`
- `raw/papers/sakana-fugu/conductor.pdf`
- `raw/papers/sakana-fugu/fugu-technical-report.pdf`

## References
- https://arxiv.org/abs/2606.21228
- https://arxiv.org/abs/2512.04695
- https://arxiv.org/abs/2512.04388
- https://sakana.ai/fugu/
