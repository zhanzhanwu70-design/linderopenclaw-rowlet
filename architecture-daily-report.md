# 每日 Agent × 軟體開發情報 — 2026-08-11

> 執行者：Rowlet 🌿🦉｜模式：每日研究 cron（02:02 UTC）
> 前一日：2026-08-10「Memory-as-Product & OSS Infrastructure Crisis」

---

## 今日主題：**Open-Source Agent Stack Trilogy — 模型／Skill／Graph 三軸同時落地**

今天同時出現了**三條獨立但互補的 vendor / frontier級釋出**，共同構成「Open agent stack 收斂成形」的訊號：

1. **Meta Muse Glimmer 30B**（Apache 2.0 open weights）— **model card 直接把 OpenClaw 列為 scaffold-compatible orchestration pattern**（與 Hermes Agent 並列）。
2. **Cactus Needle 2**（Apache 2.0, 14MB binary）— 證明 **function-call 在 2-bit 45M parameters 即可匹敵 f16 270M+ 模型**，因為「schema-as-grammar」把世界知識的需求歸零。
3. **GitHub Trending 四重奏**：semantica-agi/semantica（graph-governance under LLM, +970/天）+ addyosmani/agent-skills（Google Chrome 主管的 skill 標準化, 85k stars, +659）+ PrimeIntellect-ai/prime-agent（self-improving RLM, +2642）+ paperclipai/paperclip（agent manager app）。

伴隨的次訊號：Prime Intellect 發表 **「Recursive Language Models: the paradigm of 2026」** 部落格，把 RLM（context as variables, sub-agent as function call, persistent REPL）定位為 2026 年的典範轉移——直接對位我們每天都在用的「SOUL + memory + REPL」結構。

---

## 今日 5 個重點

### 1. Meta Muse Glimmer 30B 開源 + model card 寫了 OpenClaw

**發生什麼**：08-10 Meta Superintelligence Labs 釋出 Muse Glimmer 30B（Apache 2.0），dense causal transformer + dedicated perception encoder，可在 Mac/PC single GPU 上跑。HN 1045 點 / 579 留言，FT 頭版報導。**Model card 原文**：
> "Scaffold Compatibility. Muse Glimmer works across OpenClaw, Hermes Agent, and other agentic orchestration patterns."

Capabilities：end-to-end agentic task completion（DeepSearch QA、MCP-Atlas、τ-Bench、SWE-Bench）、reliable tool use、multi-step reasoning、**failure recovery**、multimodal（text+image）、**controllable effort**（可選 reasoning strength）、100+ languages。llama.cpp / MLX / ExecuTorch 整合數日內落地。

**為什麼重要**：**首次有 frontier-grade 開源模型把「OpenClaw」寫進 official model card 的 scaffold-compatibility section**。不是 blog 文案，是 vendor 級的架構認可。同時開源 + 30B + MCP-Atlas-tuned + failure recovery + multimodal = **「local Claude Code replacement」的硬體門檻正式降低**。對我們的意義：
- 評估 Muse Glimmer 作為 OpenClaw 的本地主模型（不再依賴雲端 MiniMax-M3）
- **Controllable Effort** 這個維度應該被 skill 引用（不只是 model 層）
- Failure recovery → 對位 `auto-retry` skill

**可信來源/URL**：
- <https://research.meta.ai/blog/introducing-muse-glimmer-open-agentic-model>
- <https://huggingface.co/meta-models/Muse-Glimmer-30B>（model card）
- HN: <https://news.ycombinator.com/item?id=49241679>（1045 點 / 579 留言）
- Snapshot: `/home/node/.openclaw/workspace/llm-wiki/raw/2026-08-11-muse-glimmer/`
- Wiki source: `wiki/sources/muse-glimmer-meta-2026-08.md`

---

### 2. Cactus Needle 2 — 14MB / 45M function-call 模型，奠定 edge agent 的可行性

**發生什麼**：Cactus Compute 發布 Needle 2：45M parameter、2-bit 壓縮（CQ2-bit）、整個 binary **14MB**、session RAM **~28MB**。Show HN 178 點。Sophomore of Needle 1。建立在自家 Simple Attention Network（arXiv:2607.18363）：常規 transformer 164 MFLOPs/token → 87 → **Needle 70 MFLOPs/token**，比最小 performant LLMs 少 7-85× MFLOPs/token。

**為什麼重要**：官方 framing 直接挑戰主流：
> "When we structure intelligence for consumer devices as functions with typed parameters, the only hard part is mapping a messy sentence onto them; which function, with which values. **The problem needs no world knowledge and no open-ended prose**, which is why 45M parameters suffice where chat needs billions."

**對 OpenClaw 的結構性啟示**：
- **function-call ≠ chat** — 對位我們 skill-archive 的 skill matching 應該是 schema-constrained grammar matching，不只是 description similarity
- **confidence-gated**：learned head + threshold + escalate below = 我們的 `skill-validate` 應該 layer 這個 pattern
- **架構提案**：**Needle 2 (45M local) → Muse Glimmer (30B local) → 雲端 frontier** 三層 fallback chain

**可信來源/URL**：
- <https://cactuscompute.com/needle>
- <https://github.com/cactus-compute/needle>
- HF: <https://huggingface.co/Cactus-Compute/needle2>
- HN: <https://news.ycombinator.com/item?id=49246804>
- Snapshot: `/home/node/.openclaw/workspace/llm-wiki/raw/2026-08-11-needle2/`
- Wiki source: `wiki/sources/needle-2-cactus-compute-2026-08.md`

---

### 3. semantica-agi/semantica +970 stars/天 — graph-governance 進入 vendor 級

**發生什麼**：`semantica-agi/semantica` 進入 GitHub trending，**單日 +970 stars**（總 4168）。Tagline：「Graph-Native Infrastructure for Context and Accountable AI Systems」。**sits underneath your LLM, vector store, and agent framework as a deterministic infrastructure layer — no LLM required for graph construction, reasoning, or provenance**。

核心 primitives：**W3C PROV-O provenance** on every fact（audit trail exportable JSON/CSV/RDF）、**SHACL constraints** + OWL generation + SKOS vocab editor、**Rete network + Datalog + SPARQL**（explainable paths, no black box）、**polyglot graph storage**（RDF = Oxigraph / Blazegraph / Jena / RDF4J；LPG = Neo4j / FalkorDB / Apache AGE / Neptune）、**native Databricks / Snowflake connectors**（Unity Catalog + Delta Lake, OAuth M2M）。

**為什麼重要**：直接挑戰今天 agent 缺可審計性的根本問題：
> "Most AI agents act without a trail. They store embeddings, not meaning: context that can't be explained, decisions that can't be audited. **In lending, that gap is a compliance exposure**, not an inconvenience."

對 Rowlet 的 gap：
- 我們的 graphify = KM-only（knowledge management），沒有 governance-grade
- **啟發**：graphify 應該加 **provenance metadata** + **SHACL-like constraint** 對 query 結果做 compliance check
- 我們應該評估 semantica 的 ontology/profile 命令是否可整合進 `ouroboros`

**可信來源/URL**：
- <https://github.com/semantica-agi/semantica>
- Snapshot: `/home/node/.openclaw/workspace/llm-wiki/raw/2026-08-11-github-trending-agent-infra/notes.md`

---

### 4. addyosmani/agent-skills + PrimeIntellect-ai/prime-agent + paperclip — skill / RLM / agent manager 三條 standardization 路線

**發生什麼**：
- **addyosmani/agent-skills**（Google Chrome team 的 Addy Osmani）：**85,776 stars**，**+659 今日**。8 slash commands (`/spec /plan /build /test /review /webperf /code-simplify /ship`) 對位完整 dev lifecycle，24 skills in repo，`npx skills add` 支援 70+ agents (Claude Code / Cursor / Codex / Copilot / Cline…)。
- **PrimeIntellect-ai/prime-agent**：**+2642 stars 今日**。兩個核心 abstraction：**Recursive Language Model (RLM)**（context 當變數、sub-agent 當 function call、persistent REPL）+ **Continual Harness**（durable state + `/refine` evidence-backed updates + immutable base prompt + snapshot rollback）。Skills as **importable Python packages**。Sessions daemon-backed reattachable。
- **paperclipai/paperclip**：76k stars，open-source「everyone uses to manage agents at work」app。

**為什麼重要**：
- Addy 把 skill standard 推到 **vendor-grade practice**（marketplace install + `npx` package）+ 公開 **Issue #361** 「per-skill install 路徑 missing」— **這個 gap 跟我們昨天的 `skill-pin` + Claude Code archive plugin source 是同一個問題的另一面**
- PrimeAgent 的 `/refine` + rollback = 我們 `extract-scenarios` / `extract-persona` 應該 layer 的 evidence-back + snapshot 機制
- paperclip = 「agent manager app」這個產品類別被建立了

**可信來源/URL**：
- <https://github.com/addyosmani/agent-skills>
- <https://github.com/PrimeIntellect-ai/prime-agent>
- <https://primeintellect.ai/blog/rlm>（「RLM: the paradigm of 2026」）
- <https://github.com/paperclipai/paperclip>
- Snapshot: `/home/node/.openclaw/workspace/llm-wiki/raw/2026-08-11-github-trending-agent-infra/notes.md`

---

### 5. Prime Intellect 部落格「Recursive Language Models: the paradigm of 2026」收斂 context-folding 文獻

**發生什麼**：Prime Intellect 部落格 Aug 2026 發表〈Recursive Language Models: the paradigm of 2026〉。把 2026 context-folding 文獻彙整成**單一 paradigm 命名**：
- Claude Code / Codex 用 **filesystem + LLM summarization at intervals** → 連續 agent with prompt + file state
- **Context folding**：continual growing rollout + manage context window itself（context rot 解方）
- 引用 arXiv:2510.11967 (Scaling Long-Horizon LLM Agent via Context-Folding, branching)、arXiv:2510.24699 (AgentFold, hierarchical summaries)、arXiv:2510.04618 (Agentic Context Engineering, 3-agent generator)
- RLM = persistent REPL + context-as-variables + sub-agent as function call

**為什麼重要**：把「context management 是 agent 最重要的能力」從 implicit 拉到 **named paradigm**。**直接對位 Rowlet 自身架構**：SOUL.md + daily memory + MEMORY.md + golden-hourly heartbeat 就是 hierarchical summary 的具體實作。同時 prime-agent 的 `/refine` = 我們的 `extract-scenarios`/`extract-persona` 雛形。

**可信來源/URL**：
- <https://www.primeintellect.ai/blog/rlm>
- Paper links: arXiv:2510.11967 / arXiv:2510.24699 / arXiv:2510.04618

---

## 對 OpenClaw / Linder 的啟發

### A. 把「**OpenClaw Local Three-Tier Router**」列為架構方向（對位 Muse Glimmer + Needle 2）

- 今天的事實：(1) Muse Glimmer 30B 本地可跑、(2) Needle 2 14MB 證明 function-call 不需要 LLM-scale、(3) **OpenClaw 被 model card 列為 scaffold**。
- **下一步**：起草 ADR「Three-Tier Model Router」，架構：
  ```
  Tier 0 — Needle 2 (45M local)  ── schema-constrained tool call, confidence-gated
        ↓ (escalate when confidence < threshold)
  Tier 1 — Muse Glimmer (30B local) ── multimodal + reasoning + failure recovery
        ↓ (escalate when frontier-only)
  Tier 2 — Cloud frontier (Anthropic / OpenAI / MiniMax) ── SWE-Bench-class
  ```
- 這對應 wiki 的 [[Agent Runtime × Framework × Harness 三層架構]]（升級為 model-tier × run-tier 雙軸）

### B. 起草 **`skill-archive-v1` spec**，搶 skill standard 正式成形前（對位 addyosmani + TencentDB + Anthropic + Prime Agent）

- 今天的事實：(1) Addy 24 skills + `npx skills add`、(2) TencentDB Skill（versioned + validated + trigger-aware）、(3) Anthropic Claude Code archive + SHA-256 pinning、(4) PrimeAgent skills = importable Python packages。
- **下一步**：在 24 小時內發出 `skill-archive-v1` YAML schema，定義：
  ```yaml
  skill: skill-name
  version: 0.1.0
  description: ...
  validation:
    - "rule"
  trigger:
    when: "regex or natural"
  schema:
    input: ...   # byte-level grammar 或 JSON Schema
    output: ...
  resources:
    - references/foo.md
  ```
- 用 1-2 個現有 skill 移植當 reference implementation（建議 `build-whispercpp` + `ouroboros`）。

### C. 把 graphify 升級為 **graphify-governance**（對位 semantica PROV-O + SHACL）

- 今天的事實：(1) semantica 證明「graph-governance as infrastructure layer」是可行的產品定位、(2) 4 個 8 月 vendor 都把 provenance / audit 列入 first-class primitive。
- **下一步**：
  1. 在 graphify-out 的 node metadata 加 **`provenance: {source, ingested_at, ingestor, license}`** 5-tuple
  2. 起草 `graphify check-constraints` 命令，容許使用者對 subgraph 寫 SHACL-like constraint（先用簡單 JSON schema）
  3. 建立 `wiki/concepts/Graph Provenance & Constraint Layer.md`（cross-link 到 [[ouroboros]] + [[Skill as Cross-Harness Portable Artifact]] + [[Recursive Language Model]]）

---

## 值得追蹤的 repo / paper / article

1. **meta-models/Muse-Glimmer-30B** — <https://huggingface.co/meta-models/Muse-Glimmer-30B> — 30B open agentic model，model card 寫 OpenClaw
2. **cactus-compute/needle** — <https://github.com/cactus-compute/needle> — 14MB edge agentic LLM，Simple Attention Network
3. **semantica-agi/semantica** — <https://github.com/semantica-agi/semantica> — graph-native governance infra（+970/日）
4. **addyosmani/agent-skills** — <https://github.com/addyosmani/agent-skills> — Google Chrome team 的 skill standard（85k stars）
5. **PrimeIntellect-ai/prime-agent** — <https://github.com/PrimeIntellect-ai/prime-agent> — RLM + continual harness（+2642/日）
6. **paperclipai/paperclip** — <https://github.com/paperclipai/paperclip> — open-source agent manager app
7. **Prime Intellect Blog: "RLM: the paradigm of 2026"** — <https://www.primeintellect.ai/blog/rlm> — context-folding 文獻匯整 + paradigm naming
8. **Claude Code releases** — <https://github.com/anthropics/claude-code/releases> — Remote Control by name + self-hosted-runner error hard exit + workspace trust prompt for `claude agents`
9. **FT: Meta returns to open models** — <https://www.ft.com/content/4e3957f8-ea7c-4c46-a3de-cdce8e526878>（Zuckerberg「attacks closed AI rivals」，370 點 HN）

---

## 下一步建議

1. **【高優先，今天內可做】起草 `wiki/concepts/Three-Tier Model Router.md`**：把 Needle 2 / Muse Glimmer / Cloud frontier 三層定義清楚，cross-link 到 [[Agent Runtime × Framework × Harness 三層架構]]。同步發 raw snapshot 已完成（`raw/2026-08-11-muse-glimmer/`、`raw/2026-08-11-needle2/`）。
2. **【高優先，24h 內可做】起草 `skill-archive-v1` YAML schema**（在 wiki concept 頁 + sample skill 移植）。這直接搶在 skill standard 成形前。
3. **【中優先，本週內】評估 graphify 增加 provenance + constraint layer**：把 semantica 與 [`ouroboros`] 對位，先決定 minimum viable upgrade path。

---

## 觀察

- **昨日（08-10）「Memory-as-Product & OSS Infrastructure Crisis」進入今日（08-11）「Open-Source Agent Stack Trilogy」**：從 **閉源 vendor memory hub** 轉向 **開源 agent stack 三軸（model / skill / graph）同時落地**。TencentDB 昨天的 vendor 級記憶設計，今天由 Meta / Cactus / semantica / Addy / PrimeAgent **用開源完成同樣的事**——market 結構正在 rapid rewire。
- **OpenClaw 被寫進 frontier model card**：從「我們設計給自己用」變成「**vendor 級模型兼容性列表的一員**」。這是 Linder 過去幾個月累積的架構工作被結構性認可的訊號。
- **「Open-weights 30B 在本地跑」** = 「agent 不再需要雲端」這件事的工程化條件終於成熟。但更重要的是：**「function call 在 14MB 完成」**顯示我們把 skill metadata 做得更精準（schema-constrained）就能用極小模型。
- **Recursive Language Model 被命名為「2026 典範」**：跟我們的 SOUL + memory + REPL 三層直接同構。我們不是「follow trend」，我們是「這 trend 的早期表達」。`extract-scenarios` / `extract-persona` 是 RLM paradigm 的具體實作，繼續做。
- **Skill standard 進入搶位時間**：Addy 的 marketplace + `npx skills` + 24 skills、TencentDB Skill with validation、Anthropic archive plugin source——三條路線都搶在「de facto standard 形成前」。**OpenClaw 是時候定一個 `skill-archive-v1`**，不要等別人定。
- **Graph-governance 成為獨立 layer**：semantica 顯示「graph under LLM as deterministic infra with provenance + constraints」是 viable product category。**我們現在是 KM 級 graphify；社區已經討論 governance 級**。gap 真實存在。

---

## 連結

- Wiki source（新建）：
  - `wiki/sources/muse-glimmer-meta-2026-08.md`
  - `wiki/sources/needle-2-cactus-compute-2026-08.md`
- Raw snapshots（已建立）：
  - `raw/2026-08-11-muse-glimmer/notes.md`
  - `raw/2026-08-11-needle2/notes.md`
  - `raw/2026-08-11-github-trending-agent-infra/notes.md`
- Wiki concept（待建立由 Linder approve 後）：
  - `wiki/concepts/Three-Tier Model Router.md`（Needle 2 / Muse Glimmer / Cloud）
  - `wiki/concepts/Skill Archive v1 Schema.md`
  - `wiki/concepts/Graph Provenance & Constraint Layer.md`
- Cross-link with existing:
  - [[Agent Runtime × Framework × Harness 三層架構]]
  - [[Skill as Cross-Harness Portable Artifact]]
  - [[ouroboros]]
  - [[TencentDB Agent Memory]]
  - [[Harness Engineering]]

_本報告已保存於 `/home/node/.openclaw/workspace-rowlet/architecture-daily-report.md`。3 個 raw snapshot 已建立，2 個 wiki source 條目已建立。下一個 graphify `extract` / `update` 會自動 ingest 新 wikilink edges（graphify CLI 在此版本無 `link` 子命令，以 extract cycle 代替）。_
