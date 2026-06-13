# 架構師每日情報 2026-06-13

## 本日重點發現

1. **AI Agents Stack 2026 Edition 出爐** — O'Reilly 發布六層架構更新，MCP 成為標準工具層，Memory 升級為第一級架構原語
2. **Harness Engineering 框架亮相** — Microsoft 將 AutoGen + Semantic Kernel 合併為 Microsoft Agent Framework，並有專門的 Harness 概念（agent team architecture factory）
3. **Multi-Agent 四種協調模式趨於穩定** — Orchestrator-worker、Sequential handoff、Group conversation、Graph-based state machine 成為canonical patterns
4. **Skill Evolution RL 化 — SAGE/ARISE 新進展** — 結合 GRPO 讓 agent 學習並創造可重用技能，克服獨立 rollout 的限制
5. **LangGraph 2.0 發布** — type-safe streaming、Deploy CLI、統一 agent primitives（Router/Supervisor/Subagent）

---

## 詳細內容

### 1. AI Agents Stack (2026 Edition)
**來源：** [O'Reilly Radar](https://www.oreilly.com/radar/the-ai-agents-stack-2026-edition/) | 5天前

**六層架構：**
- Layer 1: Models and inference（推理模型改變了 agents 的自主能力）
- Layer 2: Protocols and tools（MCP 已標準化，97M monthly SDK downloads）
- Layer 3: Memory and knowledge（晉升為第一級架構原語，不再只是 vector DB）
- Layer 4: Reasoning（推理模型讓單一 call agents 取代部分 multistep chains）
- Layer 5: Frameworks（LangGraph、CrewAI、AutoGen 各有定位）
- Layer 6: Eval + Guardrails（gap 最大，需優先投資）

**重要觀點：**
- 推理模型（o1/o3/DeepSeek R1）讓單一呼叫就能完成過去需要多步的工作
- Open weight 模型（Llama 3.3、DeepSeek V3、Qwen 2.5）已縮小質量差距，「先用閉源做 prototype、再用開源部署」成主流
- MCP 安全問題：82% 的 MCP servers 有 path traversal 風險，67% 有 code injection 風險

---

### 2. Multi-Agent Systems Guide 2026
**來源：** [Jobsbyculture](https://jobsbyculture.com/blog/multi-agent-systems-guide-2026) | 2天前

**四種協調模式：**

| Pattern | 特色 | 適用場景 |
|---------|------|----------|
| Orchestrator-worker | lead planner + 平行 sub-agents | 研究、多來源分析 |
| Sequential handoff | 明確的 phase transition | 客服 triage、文件流程 |
| Group conversation | 共享對話 thread，selector 決定發言者 | 代碼 critic、研究辯論 |
| Graph-based state machine | 可檢查狀態、checkpoint、time-travel | 金融流程、受監管工作流 |

**成本警示：** 5-agent group conversation 可產生 5-10x 單一 agent 的成本。Sequential handoff 最便宜但 latency 堆疊。Orchestrator-worker 最小成本取決於 lead spawn 多少 sub-agents。

**框架選擇邏輯：**
- LangGraph → 有狀態的生產工作流
- CrewAI → 最快 demo → working prototype
- AutoGen/AG2 → 對話式 agent 團隊
- OpenAI Agents SDK / Claude Agent SDK → 想要第一方簡潔性

---

### 3. Agent Skill Evolution: RL-Driven 趨勢
**來源：** [arXiv 2606.11435](https://arxiv.org/html/2606.11435) | 3天前

**Skill 四元組定義：** S = (C, π, T, R)
- C: condition（觀測→目標映射到技能相關性）
- π: execution policy（編碼程序）
- T: termination criterion
- R: reusable interface（組合其他技能的介面）

**Skill Evolution 四範式：**
1. Execution feedback
2. Trajectory distillation
3. Compression
4. **Reinforcement Learning**（重點）

**RL 進展：**
- **SAGE (2025):** 基於 GRPO，利用 group tasks 的 reusable rewards，鼓勵 agent 學習並創造可重用技能
- **ARISE (2026):** 保留成功推理模式，克服 GRPO 將 rollouts 獨立處理的限制

**Skill Usage 三機制：**
- Retrieval: 從大 skill pool 取出候選集
- Routing: 決定哪個 skill 在哪步執行
- Management: 保持 organized、up-to-date、safe

---

### 4. Harness Engineering 生態系形成
**來源：** [GitHub ai-boost/awesome-harness-engineering](https://github.com/ai-boost/awesome-harness-engineering) | 3天前

**Harness 定義：** 設計特定領域 agent 團隊、定義專業化 agents、生成他們使用的 skills 的 meta-skill

**重要資源：**
- `awesome-harness-engineering`: 工具、模式、evals、memory、MCP、permissions、observability、orchestration 的彙整
- `agents-best-practices`: 生產多 agent harness 設計的 conference tutorial
- **Harness vs Archon 區分：** Archon 生成確定性 runtime 配置（Runtime-Configuration Factory），Harness 生成 agent 團隊架構（Team-Architecture Factory）

---

### 5. LangGraph 2.0 + Microsoft Agent Framework
**來源：** [GitHub LangGraph](https://github.com/langchain/langgraph) + [MorphLLM](https://www.morphllm.com/ai-agent-framework) | 3-4天前

**LangGraph 2.0 新功能：**
- Type-safe streaming
- Deploy CLI for managed hosting
- 統一 agent primitives: Router、Supervisor、Subagent（不再需要手寫協調邏輯）

**Microsoft Agent Framework:**
- 由 AutoGen + Semantic Kernel 合併而來
- Graph-based workflows：sequential、concurrent、handoff、group collaboration
- 內建 checkpointing、streaming、human-in-the-loop、time-travel

---

### 6. Agent Skills 生態持續擴展
**來源：** 多個 GitHub repos | 2-3天前

| Repo | 特色 |
|------|------|
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | 生產級工程 skills，含 Hyrum's Law、Chesterton's Fence、Shift Left 等 |
| [VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) | 1000+ agent skills，相容 Claude Code、Codex、Gemini CLI、Cursor |
| [leonxlnx/taste-skill](https://github.com/leonxlnx/taste-skill) | 阻止 AI 生成無聊的 generic slop，定位為「給 AI 好品味」 |
| [github/awesome-copilot](https://github.com/github/awesome-copilot/blob/main/docs/README.skills.md) | OWASP ASI 2026 安全合規 skill |

---

## 執行狀態

- **任務完成時間：** 2026-06-13 06:32 UTC
- **資訊來源：** Web search × 3 queries, Web fetch × 4 URLs
- **覆蓋領域：** Agent architecture、Multi-agent orchestration、Harness engineering、Skill RL optimization
- **注意：** MCP 安全問題（82% servers 有 path traversal）應列入安全審查清單
