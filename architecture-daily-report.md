# 架構師每日情報 2026-05-31

## 本日重點發現

1. **Skill 從「手寫提示」走向「可演化的上下文資產」**：Agent Skills for Context Engineering 把 skills 定位為跨平台的 context / harness engineering 單元，重點是啟動時只載入名稱與描述、需要時再載入完整內容，降低注意力浪費。
2. **Harness engineering 正在分層：runtime configuration 與 team architecture 開始分家**：revfactory/harness 將自身定義為 L3 Team-Architecture Factory，負責產生 agent team、skills、通訊協議與 review gates；而 Archon 類工具更偏 runtime determinism。這個分工值得吸收。
3. **企業級 multi-agent architecture 重心轉向 formal governance**：〈Architecting Agentic Communities using Design Patterns〉把系統分成 LLM Agent、Agentic AI、Agentic Community 三層，並用 ODP Enterprise Language 表達角色、義務、權限、禁止與責任鏈。
4. **Production agent lifecycle 逐漸收斂成 Build → Test → Deploy → Monitor**：LangChain 最新文章明確區分 agent frameworks、agent runtimes、agent harnesses，並把 durable execution、human-in-the-loop、sandbox、context hub、traces 視為生產級必備能力。
5. **Skill artifact optimization 的研究焦點從「檢索 skill」推進到「內化 skill」**：SkillC 透過 paired skill-injected / skill-free rollouts 與 contrastive credit assignment，讓 RL 直接獎勵「不用外部 skill 也能成功」；這比單純優化 skill prompt 更接近能力蒸餾。

## 詳細內容

### 1. Agent Skills for Context Engineering

- 連結：https://github.com/muratcankoylan/agent-skills-for-context-engineering
- 類型：GitHub skill collection / context engineering reference
- 摘要：此 repo 將 context engineering 定義為管理所有進入模型注意力預算的資訊：system prompts、tool definitions、retrieved documents、message history、tool outputs。它提供 context fundamentals、context degradation、context compression、multi-agent patterns、memory systems、tool design、filesystem context、evaluation、harness engineering 等技能。
- 架構價值：
  - skills 應採 **progressive disclosure**：先暴露 metadata，只有任務匹配時載入 SKILL.md。
  - context budget 的核心瓶頸不是 token 上限，而是 attention scarcity、lost-in-the-middle、context clash。
  - filesystem-context / hosted-agents / evaluation / harness-engineering 可組成一套長任務 agent operating system。
- 對本地設計啟示：OpenClaw skills 可以明確拆成「觸發 metadata」「操作流程」「參考資料」「測試／評估」，避免每次啟動灌入過多低訊號文字。

### 2. revfactory/harness：team-architecture factory

- 連結：https://github.com/revfactory/harness
- 類型：Claude Code plugin / meta-skill / harness factory
- 摘要：Harness 根據 domain description 自動產生 agent team definitions 與 skills，支援六種 team architecture：Pipeline、Fan-out/Fan-in、Expert Pool、Producer-Reviewer、Supervisor、Hierarchical Delegation。
- 重要細節：
  - 它自稱位於 L3 Meta-Factory / Team-Architecture Factory。
  - 明確區分與 Archon 的分工：Archon 偏 deterministic runtime configuration；Harness 偏 team architecture、message protocols、review gates。
  - 內建 validation：trigger verification、dry-run testing、with-skill vs without-skill comparison。
- 對本地設計啟示：不要把「子代理生成」「runtime 設定」「workflow orchestration」混在同一層。較佳切法：
  1. runtime/config factory；
  2. team architecture factory；
  3. skill artifact factory；
  4. eval / trace / rollback layer。

### 3. Architecting Agentic Communities using Design Patterns

- 連結：https://arxiv.org/html/2601.03624v3
- 類型：arXiv paper
- 摘要：論文提出三層分類：LLM Agents（任務型自動化）、Agentic AI（有 agency 的目標導向系統）、Agentic Communities（AI agents 與 humans 透過正式角色、協議、治理結構協作）。核心貢獻是用 ISO ODP Enterprise Language formalism 表達 multi-agent community 的 roles、normative constraints、contracts、accountability chains。
- 重要概念：
  - Autonomy ≠ Agency。LLM Agent 可自主執行任務，但未必有獨立目標形成與策略調整。
  - Agentic Community 必須有 traceability from actions to responsible parties。
  - Deontic governance：義務、權限、禁止可以形成可機器檢查的治理規格。
- 對本地設計啟示：multi-agent orchestration 不能只記「誰呼叫誰」。應記錄 delegation authority、approval boundary、responsibility chain、policy violation detection。

### 4. LangChain：The Agent Development Lifecycle

- 連結：https://www.langchain.com/blog/the-agent-development-lifecycle
- 類型：技術文章 / production lifecycle
- 摘要：文章把 agent 生產流程歸納為 Build → Test → Deploy → Monitor。它區分三層工具：agent frameworks（組合模型、tools、prompts、retrieval）、agent runtimes（state、control flow、durability、human intervention）、agent harnesses（prompts、skills、MCP servers、hooks、middleware、filesystem）。
- 重要細節：
  - Test 應從代表性任務資料集開始，再由 production traces 擴充。
  - Deploy 需要 durable execution、human-in-the-loop、sandbox / virtual filesystem、prompt/context hub。
  - Monitor 不只看 latency/cost/error，也要看 full trajectory traces：inputs、model calls、tool calls、outputs、final action。
- 對本地設計啟示：OpenClaw / local agents 應把 trace 變成 eval dataset 的原料，讓 cron、skills、subagents 的失敗樣本回流到測試集。

### 5. SkillC：Learning Autonomous Skill Internalization in LLM Agents via Contrastive Credit Assignment

- 連結：https://arxiv.org/html/2605.27899v1
- 類型：arXiv paper
- 摘要：SkillC 針對 skill-internalization RL。既有方法會逐步撤除 skills，但 policy update 無法分辨成功是依賴 skill 還是已經內化。SkillC 透過 paired skill-injected / skill-free rollouts，在同一 policy update 中估計 task-level contrastive gap，並用 dual-stream advantage estimator 把 credit 轉向 skill-free success。
- 數據：在 ALFWorld 與 WebShop 中，不使用 runtime skill access 的情況下，分別超過最強 prior skill-internalization baseline 5.5% 與 4.4%。
- 重要限制：效果依賴 contrastive signal quality；天花板任務或弱訊號任務可能退步。
- 對本地設計啟示：若要用 RL 或自動評估優化 skills，不應只評估「帶 skill 成功率」。應同步評估 without-skill performance，否則會製造 skill dependency，而不是真正提升 agent 能力。

### 6. RL for LLM-based Multi-Agent Systems through Orchestration Traces

- 連結：https://arxiv.org/abs/2605.02801
- 類型：arXiv paper
- 摘要：此文將 multi-agent RL 的學習對象定義為 orchestration traces：包含 sub-agent spawning、delegation、communication、tool use、return、aggregation、stopping decisions 的 temporal interaction graphs。
- 重要發現：
  - reward design 至少有八類，包括 parallelism speedup、split correctness、aggregation quality。
  - credit signal 可附著在 token 到 team 的八種單位上。
  - orchestration learning 可拆成五個決策：when to spawn、whom to delegate、how to communicate、how to aggregate、when to stop。
  - 截至 2026-05-04，作者在 curated pool 中未找到 explicit RL training method for stopping decision。
- 對本地設計啟示：subagent 系統的 trace schema 應先標準化。沒有 replayable orchestration traces，就無法做可靠的 RL / offline evaluation / failure attribution。

## 執行狀態

- 任務完成時間：2026-05-31 18:02:19 UTC
- 消耗 token：OpenClaw session_status 未提供本次精確 token；狀態顯示 context 0/1.0m，5h quota 剩餘 81%。
- 搜尋／擷取狀態：已使用 web_search 與 web_fetch；本環境未偵測到 `graphifyy` / `graphify` CLI，因此以可用搜尋工具替代。
- Wiki 同步：已準備同步至 `/home/node/.openclaw/workspace-rowlet/wiki/sources/architecture-daily-intel-2026-05-31.md`。
