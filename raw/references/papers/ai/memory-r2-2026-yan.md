---
title: "Memory-R2: Fair Credit Assignment for Long-Horizon Memory-Augmented LLM Agents"
category: source
type: research-paper
tags: [memory-augmented-llm, credit-assignment, reinforcement-learning, multi-session, long-horizon-agents, loGo-GRPO]
domain: code-agent
created: 2026-06-08
modified: 2026-07-17
arXiv: "2605.21768"
authors: ["Sikuan Yan", "Ahmed Bahloul", "Ercong Nie", "Susanna Schwarzmann", "Riccardo Trivisonno", "Volker Tresp", "Yunpu Ma"]
submitted: "2026-05-20"
---

# Metadata

| 欄位 | 內容 |
|------|------|
| **論文** | Memory-R2: Fair Credit Assignment for Long-Horizon Memory-Augmented LLM Agents |
| **作者** | Sikuan Yan, Ahmed Bahloul, Ercong Nie, Susanna Schwarzmann, Riccardo Trivisonno, Volker Tresp, Yunpu Ma (LMU Munich / Munich Center for Machine Learning / Huawei Heisenberg Research Center / TUM) |
| **發表** | May 2026 (arXiv:2605.21768) |
| **領域** | cs.LG / cs.MA — Long-term Memory for Agents / Reinforcement Learning |
| **URL** | https://arxiv.org/abs/2605.21768 |
| **PDF** | raw/references/papers/ai/memory-r2-2026-yan.pdf |
| **Code** | https://github.com/ahmedehabb/Memory-R2 |

# 核心貢獻

## 1. 問題：為什麼現有 RL 方法無法公平訓練 Memory Agent？

在 multi-session RL 訓練中，memory 讓環境變得**非穩態（non-stationary）**：

- Rollout A 在 Session 1 寫入了一組記憶，M_A
- Rollout B 在 Session 1 寫入了不同的記憶，M_B
- 到 Session 2 時，兩個 rollouts 已經有不同的 memory state
- 但 GRPO 之類的 group-relative 方法，預設所有 rollouts 來自「同一個 effective environment」，因此會把 reward 放在同一組內做 normalize——這在記憶分叉後就不成立了

這導致：
1. 軌跡級 reward（trajectory-level reward）無法準確歸因到具體的 memory operation
2. 當下游失敗時，無法判斷是：當前 session 的 memory operation 錯誤，還是早期 session 的記憶被汙染，還是後期覆寫覆蓋了有用資訊

## 2. LoGo-GRPO：Local + Global Group-Relative Optimization

核心演算法，結合兩層優化：

- **Global objective**：保留 trajectory-level reward，做端到端的長視野優化
- **Local rerollouts**：在相同的 intermediate memory state 起點，重新 roll out 不同 memory operation，進行公平比較

這解決了「記憶分叉後不公平比較」的問題——local rerollout 保證所有候選 action 都在同一個 memory 起点上。

## 3. Shared-Parameter Extractor–Manager 架構

兩個協作角色共享同一個 LLM backbone（但用 role-specific prompts）：

- **Fact Extractor**：從對話中萃取 salient information
- **Memory Manager**：根據萃取內容 + 當前 memory state，決定 INSERT/UPDATE/DELETE 等操作

這樣的設計：
- 參數效率高（共享 backbone）
- 兩個角色緊密協調（extract 和 edit 決策同時優化）

## 4. Chunk-wise Memory Construction

session 不再被視為單一過渡，而是切成 K 個 chunks：
- 每個 chunk 都會經過 Extractor → Manager 的輪次
- 隨著更多 evidence 到來，memory construction 可以逐步修正
- 讓 RL 信號可以在顆粒度更細的尺度上更新策略

## 5. Progressive Curriculum

訓練時從短 horizon 逐步擴展：
- 8 sessions → 16 sessions → 32 sessions
- 先讓模型在短視野建立可靠的 memory 行為，再適應長上下文挑戰
- 解決長視野 RL 的訓練不穩定性

# 與現有工作的關係

- 承接 [[sources/memgpt-towards-llms-as-operating-systems|MemGPT]] 的 OS-style 階層式記憶方向
- 和 [[sources/a-mem-agentic-memory|A-MEM]] 同樣用 atomic units，但 Memory-R2 用 RL 而非 heuristic 決定存取
- 和 [[sources/ECHO-selective-turn-memory-2606|ECHO]] 同樣解決 credit assignment，但 ECHO 是 selective reconstruction + RL，Memory-R2 是 LoGo-GRPO + 共享 backbone
- 和 [[sources/VISTA — LLM Agents Are Latent Context Managers|VISTA]] 互補：VISTA 解決「模型感受不到自己 context 狀態」的問題，Memory-R2 解決「RL 訓練時 memory 狀態分叉」的問題
- 與 [[sources/atomem-2026-yao|AtomMem]] 共享 atomic fact 概念，但 Memory-R2 的貢獻是 credit assignment 演算法，不是記憶表示

# 值得討論的點

1. **Local rerollout 的實作代價**：每次更新都要重新 roll out 不同 action from 同一 memory state，訓練成本可能很高——論文的 efficiency claim（只靠 2 個 training conversations 就超越 baseline）是否真的因為演算法，還是只是因為 multi-step chunking + curriculum？
2. **LoGo-GRPO 的 scale 問題**：Local rerollout 在 session 數量增加時，指數成長的比較組合是否會變成 bottleneck？
3. **Extractor-Manager 之間的 gradient conflict**：兩個角色共享參數，但目標可能衝突——Extractor 想要提取更多資訊，Manager 想要保持記憶精簡。論文怎麼平衡？
4. **這個 credit assignment 框架能否遷移到非 RL 設定？** 如果不用 GRPO，ECHO 的 selective reconstruction + source-pointer 方法是否更實際？
5. **Memory as part of environment state**：這篇論文的核心洞察「memory turns agent's past actions into future environment」是一個優雅的 formalization——在其他 agent 框架中怎麼應用？
