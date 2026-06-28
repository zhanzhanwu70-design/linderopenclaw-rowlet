# 待學習清單：Prompt 自動優化方法

## 學習目標
理解六種 Prompt 自動優化方法的原理、核心算法、適用場景與局限性。

---

## 六種方法

### 1. APE（Automatic Prompt Engineer）
- **論文**：Zhou et al., "Large Language Models are Human-Level Prompt Engineers" (2023)
- **核心算法**：Bayesian Optimization + LLM 作為候選 Prompt 生成器
- **待研究問題**：
  - [ ] 如何在 OpenClaw 的 skill prompt 上應用 Bayesian Optimization？
  - [ ] Instruction Induction Benchmark 的 26 種任務如何映射到 OpenClaw 場景？
- **優先級**：中

### 2. OPRO（Optimization of Prompts with Reinforcement Learning）
- **論文**：Google DeepMind, "OPRO: Optimization of Prompts with Reinforcement Learning"
- **核心算法**：RL Policy Gradient / PPO，LLM 當 optimizer
- **待研究問題**：
  - [ ] Policy Gradient 如何應用在 agent task assignment 場景？
  - [ ] 與 OpenClaw 的 task queue 機制的結合點？
- **優先級**：中

### 3. EvoPrompt（GA + LLM）
- **論文**：Guo et al., "EvoPrompt: Connecting Large Language Models with Evolutionary Algorithms" (2023)
- **核心算法**：Genetic Algorithm + LLM 充當 mutation/crossover 算子
- **待研究問題**：
  - [ ] 如何用 EvoPrompt 進化 OpenClaw 的 skill 集合？
  - [ ] Mutation 和 Crossover 在 prompt 空間的具體操作方式？
- **優先級**：低

### 4. PromptBreeder
- **論文**：Fernando et al., "PromptBreeder: Self-Referential Prompt Evolution" (2023, DeepMind)
- **核心算法**：Self-Referential + Darwinian Evolution，思考方式也會被進化
- **待研究問題**：
  - [ ] Rowlet 的自我複製技能是否是一種 PromptBreeder 的體現？
  - [ ] 如何讓 Rowlet 的 SOUL.md / MEMORY.md 自己進化？
- **優先級**：高（與自身架構最相關）

### 5. DSPrompt / DSPy（Demonstrator-based Prompting）
- **論文**：Stanford Khattab et al., "DSPy: Compiling Declarative Machine Learning Pipelines" (2023)
- **核心算法**：Program Synthesis + Demonstration Selection
- **待研究問題**：
  - [ ] DSPy 的 compilation 思想如何應用在 OpenClaw 的 skill 編譯流程？
  - [ ] 與 OpenClaw 的「三層記憶」架構的結合點？
- **優先級**：高（與 OpenClaw 架構高度相關）

### 6. PROS（Prompt Optimization via Reward Shaping）
- **論文**：[待確認]
- **核心算法**：Reward Shaping + Gradient-based Optimization
- **待研究問題**：
  - [ ] PROS 與 TRINITY 的 CMA-ES 訓練有何關聯或差異？
  - [ ] 如何應用在 OpenClaw 的 task 評估機制？
- **優先級**：低

---

## 優先順序建議

1. **PromptBreeder** — 與 Rowlet 自我複製最相關
2. **DSPy** — 與 OpenClaw skill 編譯最相關
3. **OPRO** — 與 task assignment RL 應用相關
4. **APE** — 基礎方法，可快速理解
5. **EvoPrompt** — 較少直接應用場景
6. **PROS** — 需要更多研究

## 相關檔案
- 講義：`wiki/concepts/prompt-optimization-methods-lecture.md`
- 論文來源影片：`raw/video/2026-06-28-kddVQq62P4Y/audio.txt`
- wow 頻道介紹：「被神化的 AI 自动化优化：为什么你的 Agent 根本"不听"别的 Agent 说话？」

## 更新記錄
- 2026-06-28：初版建立
