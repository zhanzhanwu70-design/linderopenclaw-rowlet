---
title: "Prompt 自動優化方法講義"
type: concept
tags: [prompt-optimization, ape, opro, evoprompt, promptbreeder, dsprompt, pros, llm, agent]
status: active
created: 2026-06-28
updated: 2026-06-28
---

# Prompt 自動優化方法講義

## 背景：Prompt 優化的三條路

| 方式 | 做法 | 現實狀態 |
|------|------|---------|
| **人工調優** | 工程師靠經驗寫 Prompt | 絕大多數團隊的真實狀態 |
| **自動化框架** | 框架輔助搜索更好 Prompt | 過去幾年最火，但效果參差不齊 |
| **Zero Shot** | 不做任何優化，直接用 | 基準線 |

論文「Prompt Optimization is Like Flipping a Coin」測試了六種自動化方法，結果 49% 低於 Zero Shot。

---

## 六種方法詳解

### 1. APE（Automatic Prompt Engineer）

**論文**：Zhou et al., "Large Language Models are Human-Level Prompt Engineers" (2023)

**核心算法**：Bayesian Optimization + LLM 作為候選 Prompt 生成器
- 用 LLM 生成一群候選 Prompt
- 在驗證集上跑，根據分數用 Bayesian Optimization 更新
- 迭代收斂

**評估任務**：Instruction Induction Benchmark（26 種簡單任務）

**關鍵洞察**：把 Prompt 當成「要優化的變量」，用搜尋而非人工填寫

---

### 2. OPRO（Optimization of Prompts with Reinforcement Learning）

**論文**：Google DeepMind, "Optimizing Prompts for Diverse Visual Reasoning" 延伸而來

**核心算法**：RL（Policy Gradient / PPO）
- 把 Prompt 當成 policy，LLM 輸出當成 action
- Reward = 任務準確率
- 用 LLM 自己生成新 Prompt，根據 reward 調整

**評估任務**：GSM8K、BigBench

**關鍵洞察**：讓 LLM 當 optimizer，而不是當 scorer

---

### 3. EvoPrompt（GA + LLM）

**論文**：Guo et al., "EvoPrompt: Connecting Large Language Models with Evolutionary Algorithms" (2023)

**核心算法**：Genetic Algorithm（遺傳演算法）+ LLM
- 每個 Prompt 是 chromosome
- Mutation、Crossover 由 LLM 生成
- Fitness = 任務分數
- 每代保留最好的，淘汰差的

**評估任務**：多種 NLP 任務（文字分類、情感分析、推理）

**關鍵洞察**：用 EA 的隨機搜尋能力探索 Prompt 空間，LLM 充當 mutation/crossover 算子

---

### 4. PromptBreeder

**論文**：Fernando et al., "PromptBreeder: Self-Referential Prompt Evolution" (2023, DeepMind)

**核心算法**：Self-Referential + Darwinian Evolution
- Prompt 可以突變（mutation）自己
- 每次迭代：生成 Prompt 變體 → 評估 → 淘汰差的
- 特別的是「思考方式」也會被進化，不只是內容

**評估任務**：BigBench、塗爾成年測試

**關鍵洞察**：Prompt 不是死的文字，是可以被進化的「思想」

---

### 5. DSPrompt / DSPy（Demonstrator-based Prompting）

**論文**：Stanford, Khattab et al., "DSPy: Compiling Declarative Machine Learning Pipelines" (2023)

**核心算法**：Program Synthesis + Demonstration Selection
- 把 Prompt 設計寫成宣告式程序（DSPy Program）
- 根據輸入自動選擇最好的 examples 當 demonstration
- 不只改 Prompt 內容，連「哪些 example 放進去」都是學出來的

**評估任務**：HotPotQA、TruthfulQA、GSM8K

**關鍵洞察**：Prompt 是程式，應該被編譯而不是被猜測

---

### 6. PROS（Prompt Optimization via Reward Shaping）

**論文**：[待確認]

**核心算法**：Reward Shaping + Gradient-based Optimization
- 把 reward 分成兩個層次：global（任務分數）+ local（Prompt 品質信號）
- 用 reward shaping 讓梯度更穩定
- 類似於 OPRO 但多了 reward shaping 層

**評估任務**：Instruction Induction

**關鍵洞察**：單純的 task reward 太稀疏，加 reward shaping 可以引導優化方向

---

## 横向比較

| 方法 | 核心算法 | 優化方向 | 突破點 |
|------|---------|---------|--------|
| **APE** | Bayesian Optimization | Prompt 文字 | 系統化搜尋 |
| **OPRO** | RL Policy Gradient | Prompt 文字 | 自己生成自己評估 |
| **EvoPrompt** | Genetic Algorithm | Prompt 文字 | EA + LLM 混合 |
| **PromptBreeder** | Self-referential EA | Prompt + 思考方式 | 進化思想本身 |
| **DSPrompt** | Program Synthesis | Prompt + Example Selection | 編譯式 Prompt |
| **PROS** | Reward Shaping | Prompt 文字 | 穩定梯度訊號 |

---

## 為何這些方法大多無效？

根據「Prompt Optimization is Like Flipping a Coin」論文，核心原因：

### 1. RLHF 使模型對 Prompt 詞彙變化免疫
- 模型被訓練成對語氣、格式、措辭變化脫敏
- 這導致 A×B 交互效應的方差貢獻僅 0.18%~2.15%
- 改 Prompt 的詞彙幾乎不影響輸出語意

### 2. 這些方法只在「能但不默認用」時有效
- 當 Zero Shot 輸出已經符合任務需求 → 優化是噪聲
- 當任務要求特定輸出格式但模型默認不輸出 → 優化有效
- Help Steer 2（6/6 方法全贏）就是後者

### 3. 經驗高度模型綁定
- High-Code：6/6 方法成功
- Nova Lite：1/6 方法成功
- 跨模型遷移沒有任何保證

---

## 實用建議：兩階段診斷流程

**第一階段：正交測試（~80美元）**
- 驗證不同 Agent 的 Prompt 是否需要聯合優化
- 如果 F<1，則不需要聯合優化，分別優化即可

**第二階段：空間測試（~5美元）**
- 比較最優 Prompt vs Zero Shot
- 差距 >2 分 → 有優化空間
- 差距 <2 分 → 繼續優化 = 抛硬幣

---

## 與 OpenClaw 的關聯

- **DSPrompt / DSPy 的思想** 與 OpenClaw 的 Skill 機制高度相關
- **PromptBreeder 的 self-referential** 思想類似於 Rowlet 的自我複製
- **兩階段診斷** 可以作為 OpenClaw 任何新 Agent pipeline 的標配流程

## References
- Zhou et al., "APE: Large Language Models are Human-Level Prompt Engineers"
- Google DeepMind, "OPRO"
- Guo et al., "EvoPrompt"
- Fernando et al., "PromptBreeder"
- Khattab et al., "DSPy"
- 論文「Prompt Optimization is Like Flipping a Coin」（wow 影片所介紹）