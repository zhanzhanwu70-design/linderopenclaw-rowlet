# 架構師每日情報 2026-06-01

## 本日重點發現

1. **Skill optimization 正式變成「訓練外部文字狀態」問題**：SkillOpt 把 skill document 當成 frozen agent 的外部可訓練狀態，用 rollout、bounded edit、held-out validation gate、rejected-edit buffer 進行穩定優化。這比單純 prompt tuning 更接近可審計、可遷移的 domain adaptation。
2. **Skill lifecycle 從生成走向治理：creation / memory / management / evaluation / refinement**：MUSE-Autoskill 把 skill 視為長期資產，加入 skill-level memory、unit tests、runtime feedback 與 cross-agent transfer。這是 OpenClaw skill 系統下一階段最值得吸收的方向。
3. **Skill internalization RL 開始處理「依賴 skill」與「真正學會」的差異**：SkillC 用 skill-injected / skill-free paired rollouts 做 contrastive credit assignment，避免模型只在外部 skill 存在時表現好。
4. **Harness engineering 的邊界愈來愈清楚：模型之外的 scaffolding 才是可靠 agent 的核心**：OpenHarness 與 awesome-harness-engineering 都把 tool-use、skills、memory、permissions、subagent delegation、cost tracking、hooks、observability 視為 agent harness 基礎層。
5. **Agent 論文追蹤重點轉向 eval / trace / safety / orchestration 資料結構**：VoltAgent 的 2026 agent papers collection 顯示，browser agents、trajectory anomaly detection、claim-level evaluation、agentic uncertainty 等題目快速增加；可 replay 的 trajectory trace 會成為後續訓練與治理燃料。

## 詳細內容

### 1. SkillOpt：Executive Strategy for Self-Evolving Agent Skills

- 連結：https://arxiv.org/abs/2605.23904
- 類型：arXiv paper（2026-05-22 v1；2026-05-25 v2）
- 摘要：SkillOpt 將 skill 文件視為 frozen agent 的外部狀態，由 optimizer model 根據 scored rollouts 提出 bounded add/delete/replace edits；只有在 held-out validation score 嚴格提升時才接受更新。它還使用 textual learning-rate budget、rejected-edit buffer、epoch-wise slow/meta update 來穩定訓練。
- 重要數據：論文聲稱在 6 個 benchmark、7 個 target models、3 種 execution harness（direct chat、Codex、Claude Code）共 52 個 cell 中全部 best 或 tied-best；GPT-5.5 direct chat 平均 no-skill accuracy 提升 +23.5 points，Codex loop +24.8，Claude Code loop +19.1。
- 架構價值：skill 不只是 prompt，而是可版本化、可驗證、可移植的 domain adaptation artifact。對 OpenClaw 來說，skill repo 應加入 eval split、rollback、accepted/rejected edit log。

### 2. MUSE-Autoskill：Self-Evolving Agents via Skill Creation, Memory, Management, and Evaluation

- 連結：https://arxiv.org/abs/2605.27366
- 類型：arXiv paper（2026-05-26）
- 摘要：MUSE-Autoskill 將 skill 系統拆成 creation、memory、management、evaluation、refinement 五階段。它在 agent runtime loop 內建立 skill_create tool，加入 short-term / long-term / skill-level memory，並以 unit tests 與 runtime feedback 觸發 refinement。
- 重要數據：SkillsBench 上，MUSE-Autoskill with-skills overall 68.40%，比 no-skills baseline +15.21 pp；自生成 skills 在成功生成的 35 個 tasks 上達 87.94%；注入另一個 agent（Hermes）後提升 +10.51 pp。
- 架構價值：最關鍵不是「自動寫 skill」，而是每個 skill 有自己的經驗記憶、測試、失敗回饋與跨代理轉移能力。這能解決目前 skill 靜態化、無驗證、無生命週期的問題。

### 3. SkillC：Learning Autonomous Skill Internalization in LLM Agents via Contrastive Credit Assignment

- 連結：https://arxiv.org/abs/2605.27899
- 類型：arXiv paper（2026-05-27）
- 摘要：SkillC 針對 skill-internalization RL。它在同一次 policy update 中採樣 skill-injected 與 skill-free paired rollouts，用 Contrastive Skill Credit Assignment 將「有 skill 才成功」與「無 skill 也成功」分開計分，並用 dual-stream advantage estimator 引導模型往 skill-free success 靠近。
- 重要數據：在 ALFWorld 與 WebShop，不使用 runtime skill access 時分別超過 prior skill-internalization baseline 5.5% 與 4.4%。
- 架構價值：如果 OpenClaw 未來做 skill 強化，不應只量測 with-skill success。必須保留撤除測試：with-skill、without-skill、degraded-skill 三組對照，否則會訓練出依賴外掛的假能力。

### 4. OpenHarness：open agent harness with built-in personal agent ohmo

- 連結：https://github.com/HKUDS/OpenHarness
- 類型：GitHub repository / agent harness
- 摘要：OpenHarness 宣稱提供 lightweight agent infrastructure：tool-use、skills、memory、multi-agent coordination。README 將 agent harness 定義為讓 LLM 變成 functional agent 的完整外部基礎設施，包含 streaming tool-call cycle、API retry、parallel tool execution、token/cost tracking、43 tools、on-demand skill loading、plugin ecosystem、context compression、persistent memory、permission rules、hooks、approval dialogs、subagent spawning、team registry 與 background task lifecycle。
- 架構價值：OpenHarness 把 OpenClaw 類系統的元件名稱化：engine、toolkit、persistent context、permissions、multi-agent。這證明 harness 層已經形成共同語彙；後續比較框架時應按這些 capability matrix 評估，而不是只看 model 或 chat UI。

### 5. awesome-harness-engineering / VoltAgent agent papers：情報索引本身變成架構資產

- 連結：https://github.com/ai-boost/awesome-harness-engineering
- 連結：https://github.com/VoltAgent/awesome-ai-agent-papers
- 類型：curated repository / research index
- 摘要：awesome-harness-engineering 將 harness engineering 定義為 context delivery、tool interfaces、planning artifacts、verification loops、memory systems、sandboxes 等 scaffolding 的設計 discipline，並按 foundations、agent loop、planning、context compaction、tools、skills & MCP、permissions、memory、orchestration、verification、observability、human-in-the-loop 分類。VoltAgent 的 2026 agent papers collection 則聚合 agent engineering、memory、evaluation、workflows、autonomous systems 等研究。
- 架構價值：這類 curated index 不只是閱讀清單，而是 taxonomy。可用來反推本地 agent stack 的缺口：是否有 permissions layer、eval harness、trace observability、memory lifecycle、skill governance、task runner、human approval boundary。

## 執行狀態

- 任務完成時間：2026-06-01T18:03:00Z
- 消耗 token：OpenClaw `session_status` 未提供本次精確 token；狀態顯示 context 0/1.0m，5h quota 剩餘 88%。
- 搜尋／擷取狀態：已使用 web_search 與 web_fetch 擷取 arXiv、GitHub 內容；本環境未偵測到 `graphifyy` / `graphify` CLI，因此以 web_search + web_fetch + 既有 Graphify 報告輔助。
- Wiki 同步：已同步至 `/home/node/.openclaw/workspace-rowlet/wiki/sources/architecture-daily-intel-2026-06-01.md`。
