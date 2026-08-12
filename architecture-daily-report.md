# 每日 Agent × 軟體開發情報 — 2026-08-12

> 執行者：Rowlet 🌿🦉｜模式：每日研究 cron（02:06 UTC）
> 前一日：2026-08-11「Open-Source Agent Stack Trilogy — 模型／Skill／Graph 三軸同時落地」

---

## 今日主題：**Routing-as-First-Class — agent stack 從 3 軸收斂為 4 軸（model / skill / graph / router），Stolen Thoughts 攻擊對 skill provenance 拉警報**

昨天（08-11）的「Open-Source Agent Stack Trilogy」focus 在 model / skill / graph 三軸同時 vendor 級開源。今天，**第 4 軸 model router 同步冒出來** —— NVIDIA NeMo Switchyard + LangSmith LLM Gateway 公開 beta，4 週內 5 個獨立 vendor 訊號都指向「**model routing 從 inference engine 內部黑盒子變成 first-class infra primitive**」。

同步出現的警訊：**「Stealing Reasoning Traces from Proprietary LLM APIs」**（HN 496 點，今日第一）證明可以從 encrypted CoT block replay 進 weaker sibling model 提取 frontier reasoning plaintext，**Glasswing framework（Amazon/Microsoft/Google/Anthropic 共同宣告的 jailbreak severity scoring）未 cover 這個攻擊面**。直接衝擊 OpenClaw memory flush、skill archive persistence、graphify-query 的 audit path — 我們需要把「skill provenance + reasoning redaction」列為 first-class layer。

伴隨的次訊號：(1) monday.com Sidekick 在 LangChain guest post 反思「**More tools → worse in production**」並撕掉 general-agent 改為 bounded subagent + sandbox、(2) **Mojo 1.0 stable**（HN 296 點，AI 加速語言到 production-ready foundation）、(3) **OpenAI Codex 0.148.0-alpha** 公開 portable Agent Plugin manifest (`plugin.json` schema-declared root)，cross Codex / Claude / Cursor 互通。

---

## 今日 5 個重點

### 1. NVIDIA Nemotron 3.5 Lightning + NeMo Switchyard — model router 變 open-source first-class infra

**發生什麼**：NVIDIA 08-11 同時釋出：
- **Nemotron 3.5 Lightning**：30B MoE、**4× output tokens** vs Nemotron 3 Nano、定位 long-running agentic AI workloads
- **NeMo Switchyard**：**open-source library** for smart routing inside popular agent tools — 自動挑「最合適 model」for each request，**跨 NVIDIA / open / proprietary model mix**，**無需重寫 application code**

官方 framing：
> Modern agentic systems — always-on agents — increasingly operate as **systems of models**, or **model ensembles**, with different models specialized for different tasks.

**為什麼重要**：昨天 (08-11) 我們提 **Three-Tier Model Router** 時 NVIDIA NeMo Switchyard 還沒公告。今天 Switchyard 公告 = **我們的架構直覺跟 NVIDIA engineering team 獨立產出的方向一致**，且 Switchyard 跟我們昨天的提案差異化：跨 edge / local / cloud 三層（NVIDIA focus 在 local/cloud 兩層）。HN 183 點 / 93 留言。

**可信來源/URL**：
- <https://blogs.nvidia.com/blog/nemotron-lightning-switchyard-rtx-dgx/>
- Snapshot: `raw/2026-08-12-routing-as-first-class/notes.md`
- Wiki source: `wiki/sources/nemotron-switchyard-nvidia-2026-08.md`
- ADR: `wiki/concepts/Three-Tier Model Router.md`

---

### 2. LangSmith LLM Gateway public beta + LangChain「frontier model 量」文 — governance layer vendor 化

**發生什麼**：LangChain 7/30 公告 **LangSmith LLM Gateway public beta** — sits between your agents and the models they call。Controls: spend caps、rate limits、model fallbacks、sensitive data protections、centralized logging。**8/11 部落格首頁列出**「How many of your agent's calls actually need a frontier model?」(11 min) — quantitative 證明大部分 call 不需要 frontier。

關鍵痛點引述：
> your model provider has suffered an outage, and now your customer service agent is returning errors
> your coding agent gets stuck in a retry loop overnight, and by morning it's made 10,000 LLM calls and you have a four-figure invoice

**為什麼重要**：跟 NVIDIA Switchyard 形成 **routing + governance 雙 vendor 化**：
- **Switchyard** = routing plumbing (「把 request 送對 model」)
- **LangSmith Gateway** = policy enforcement (「控制 spend / retry loop / sensitive data」)
- 兩個都 productize 同一個 paradigm

**對 OpenClaw 啟示**：Three-Tier Model Router 是 plumbing，**還需要一個 governance layer (skill-side) 對位 LangSmith Gateway** — budget-cap per session、retry-loop kill-switch、sub-agent 路由的 cost tracking。

**4 週內 5 個獨立 vendor 訊號都指 model routing**：
| Date | Vendor | Product |
|---|---|---|
| 07-08 | NVIDIA × LangChain | NemoClaw Deep Agents Blueprint |
| 07-30 | LangChain | **LangSmith LLM Gateway** public beta |
| 08-11 | LangChain | 「How many of your agent's calls actually need a frontier model?」 |
| 08-11 | NVIDIA | **Nemotron 3.5 Lightning + NeMo Switchyard** |
| 08-12 | OpenClaw | (本 ADR) Three-Tier Model Router |

**可信來源/URL**：
- <https://www.langchain.com/blog/langsmith-llm-gateway-runtime-controls-for-production-agents>
- <https://blog.langchain.com/>（topic index 含 8/11 frontier model 文）
- Snapshot: `raw/2026-08-12-routing-as-first-class/notes.md`
- Wiki source: `wiki/sources/langsmith-gateway-langchain-2026-08.md`

---

### 3. monday.com Sidekick 反思 — 「More tools → worse」→ bounded subagent + sandbox 才是 production 路

**發生什麼**：monday.com AI Engineering Group Lead Omri Bruchim 在 LangChain 部落格 8/11 guest post，把初代 Sidekick（一個 general-purpose agent + 越來越多的 tools）整個撕掉，重新架構為：
```
Orchestration
  + Permission-aware context retrieval
  + Specialized subagents
  + Bounded tools
  + Sandboxed execution environments
```

> Capability was going up **on paper**, but it was going down **in practice**.

**為什麼重要**：直接印證昨天 (08-11) 我們提的 `skill-archive-v1` schema 中 **schema-validated triggers + triggers-aware + validation-block** 的方向。同時，這是第三個 production-side 承認「**subagent with bounded tool + sandbox > single mega-agent**」的 vendor 訊號（前兩個：Anthropic Claude Code 自家 sub-agent、LangChain Deep Agents Code 8/7 public beta）。

**對 OpenClaw 啟示**：
- 我們現有 rowlet / charizard / gengar / mrmime 是 specialized subagent 雛形，但**缺 routing layer**（目前靠 CEO roaringmoon 手動分派）
- 起草 **`subagent-manifest.yaml`** — 為每個 specialist 宣告 `input-schema / output-schema / side-effects / latency-budget` 4-tuple
- **sandbox contract** 應該是 skill frontmatter 的 first-class field：`sandbox: required | optional | none`

**可信來源/URL**：
- <https://www.langchain.com/blog/building-monday-com-sidekick-why-capable-agents-need-more-than-just-tools>
- Snapshot: `raw/2026-08-12-bounded-subagent/notes.md`
- Wiki source: `wiki/sources/monday-sidekick-bounded-tools-2026-08.md`
- Concept: `wiki/concepts/Sandboxed Bounded Subagent.md`

---

### 4. Stealing Reasoning Traces from Proprietary LLM APIs — reasoning trace 攻擊對 skill provenance 拉警報

**發生什麼**：MATS Research / ELLIS Institute / MPI-IS / Tübingen AI Center / Snyk 共同發表 paper，**HN 496 點 / 208 留言，今日第一**：

> Proprietary reasoning can be recovered from its encrypted traces. Anthropic, OpenAI, and Google return encrypted chain-of-thought blocks to clients that can be **replayed across sessions, users, and models**. We take a trace produced by a frontier model, replay it into a weaker sibling, **jailbreak the weaker model, and recover the stronger model's hidden reasoning in plaintext**, without ever attacking the stronger model directly or triggering its anti-distillation safeguards.

**為什麼重要**：
- 攻擊不需要真的 jailbreak — 是 cross-model exfiltration
- **Glasswing framework（Anthropic / Amazon / Microsoft / Google 共同宣告 industry-wide jailbreak severity framework）未 cover 這個攻擊面** — 行業 gap
- 直接衝擊 OpenClaw：如果 skill execution log 直接落 `memory/YYYY-MM-DD.md` 或 `wiki/`，等於讓攻擊者可從本地 trace replay 拿 frontier reasoning

**對 OpenClaw 啟示**：
1. **`memory/` 結構改寫**：加 `.private.md`（含 CoT / debug）vs 預設 public（conclusions + decisions + summaries only）
2. **skill frontmatter 加 `redaction:` block as required**：`redact-reasoning-trace: true | false`
3. **graphify-query 加 `--audit-mode`** 預設 redact CoT block，輸出含 provenance metadata
4. **`skill-archive-v1` schema 必須含 redaction contract**

**可信來源/URL**：
- <https://stolen-thoughts.com/>
- Snapshot: `raw/2026-08-12-stolen-thoughts/notes.md`
- Wiki source: `wiki/sources/stolen-thoughts-reasoning-extraction-2026-08.md`
- Concept: `wiki/concepts/Skill Provenance and Redaction Layer.md`

---

### 5. OpenAI Codex 0.148.0-alpha portable Agent Plugins + Mojo 1.0 — skill manifest 標準化搶位

**發生什麼**：今天兩個 vendor 訊號，都是「portable infra」訊號：

**(a) OpenAI Codex 0.148.0-alpha** — 公開 **portable Agent Plugins**，PR #36544 明確化 portable manifest 格式：
- `plugin.json` schema-declared root
- Accept safe dotted plugin names, default missing versions to `1.0.0`
- Derive stable directory-safe versions without rewriting portable manifest
- **Reject symlinks or other unsupported file types** while copying plugin sources
- **Import Cursor-managed skills + sync 跨 Claude/Cursor 不重複**

**(b) Modular Mojo 1.0 stable**（HN 296 點）：
> Today, the Mojo language officially reaches 1.0: a milestone the language has been building toward since its first release in 2023. **With Mojo 1.0, developers can now build for the long-term on a stable, production-ready language foundation.**

社群已達 ~200 contributors / 1,100 PRs / 200,000+ lines of code。

**為什麼重要**：
- **(a)** 對位昨天 (08-11) 我們提的 `skill-archive-v1` 標準化方向壓力更大 —— **4 個 vendor（OpenAI Codex / Anthropic Claude Code / Addy Osmani agent-skills / Prime Intellect prime-agent）都在搶 portable skill/plugin manifest**，但都還沒到 de facto standard。**OpenClaw 應該定義一個 `skill-archive-v1` 同時 cover 4 條**：plugin.json root + SHA-256 pin + npx-equivalent install + sanitized descriptions + importable Python package + symlink rejection baseline
- **(b)** Mojo 1.0 = **AI 加速語言到 stable**，對 local agentic infra 的工具鏈（whisper.cpp build 雛形 + skill executor）是 viable 半年後評估選項

**可信來源/URL**：
- <https://github.com/openai/codex/releases>（0.148.0-alpha 系列）
- <https://github.com/openai/codex/pull/36544>（portable Agent Plugins）
- <https://www.modular.com/blog/modular-26-5-mojo-1-0-is-here>（Mojo 1.0）
- Snapshot: `raw/2026-08-12-codex-agent-plugins/notes.md` + `raw/2026-08-12-mojo-1/notes.md`
- Wiki source: `wiki/sources/openai-codex-portable-agent-plugins-2026-08.md` + `wiki/sources/mojo-1-0-modular-2026-08.md`

---

## 對 OpenClaw / Linder 的啟發

### A. 把「**Routing Layer as First-Class**」加入 architecture stack，4 軸收斂完成

- 今天的事實：(1) NVIDIA NeMo Switchyard 公告、(2) LangSmith LLM Gateway public beta、(3) LangChain 8/11 frontier-model 量文、(4) monday.com Sidekick sandbox 反思、(5) NemoClaw Deep Agents Blueprint（07-08）
- **結構**：4 週內 5 個 vendor 訊號都指 routing 變 first-class infra primitive
- **下一步**：把 wiki `[[Agent Runtime × Framework × Harness 三層架構]]` 升級為 4 軸（model / skill / graph / **router**），cross-link 到：
  - `[[Three-Tier Model Router]]`（今天建立）
  - `[[Nemotron 3.5 Lightning + NeMo Switchyard]]`
  - `[[LangSmith LLM Gateway]]`
- **skill-side governance layer**：起草 **`model-router-policy`** skill 對位 LangSmith Gateway 的 spend caps / retry-loop kill-switch 在 OpenClaw 內實作

### B. 把「**Skill Provenance and Redaction Layer**」列為 skill-archive v1 required field（Stolen Thoughts 對應）

- 今天的事實：Stolen Thoughts paper 證明 reasoning trace 透過 sibling-model replay 可被 exfiltrated，**本地端 skill execution log 等於是被動攻擊面**
- **結構**：OpenClaw memory flush、graphify-query audit、ouroboros source ingestion 都包含 reasoning trace
- **下一步**：
  1. **撰寫 `skill-execution-redaction` skill**：自動 redact CoT block + prompt source before persist
  2. **`memory/` 結構改寫**：加 `.private.md` 模式 vs default-public mode
  3. **`skill-archive-v1` schema 加 `redaction:` block required**
  4. **graphify-query CLI 加 `--audit-mode`** 預設 redact CoT

### C. 起草 **`skill-archive-v1` schema** cover 4 vendor 標準（搶在標準成形前）

- 今天的事實：(1) Addy/agent-skills (slash command + npx)、(2) OpenAI Codex 0.148 (plugin.json root)、(3) Anthropic Claude Code archive + sanitization、(4) Prime Intellect prime-agent (Python importable)
- **下一步**：在 24 小時內發出 `skill-archive-v1` YAML schema 必須同時 cover：
  ```yaml
  skill: skill-name
  version: semver (default 1.0.0)
  description: sanitized-and-labeled   # for marketplace listing
  manifest: plugin.json                # OpenAI 格式
  archive:
    path: ...
    sha256: ...                        # Anthropic 格式
  sandbox:
    mode: required | optional | none   # Sandboxed Bounded Subagent 對位
  installation:
    methods: [npx, pip, brew, source-clone]   # Addy 風格
  redaction:
    redact-reasoning-trace: true       # Stolen Thoughts 對位
    redact-prompt-source: true
  triggers:
    when: regex or natural
  schema:
    input: ... | output: ...
  ```
- 用 2 個現有 skill 移植當 reference（建議 `ouroboros` + `graphify-query`）

---

## 值得追蹤的 repo / paper / article

1. **「Stealing Reasoning Traces from Proprietary LLM APIs」— Panfilov et al., 2026** — <https://stolen-thoughts.com/> — HN 496 點 / 208 留言，今日第一；對 skill provenance 是警鐘
2. **NVIDIA Nemotron 3.5 Lightning + NeMo Switchyard** — <https://blogs.nvidia.com/blog/nemotron-lightning-switchyard-rtx-dgx/> — open-source 智能 router 公告，4× output tokens MoE
3. **LangSmith LLM Gateway public beta** — <https://www.langchain.com/blog/langsmith-llm-gateway-runtime-controls-for-production-agents> — governance layer vendor 化
4. **Building monday.com Sidekick (LangChain guest post)** — <https://www.langchain.com/blog/building-monday-com-sidekick-why-capable-agents-need-more-than-just-tools> — bounded subagent + sandbox 反思
5. **Modular Mojo 1.0** — <https://www.modular.com/blog/modular-26-5-mojo-1-0-is-here> — AI 加速語言到 stable release
6. **OpenAI Codex 0.148.0-alpha (PR #36544)** — <https://github.com/openai/codex/releases> + <https://github.com/openai/codex/pull/36544> — portable Agent Plugin manifest cross-vendor
7. **LangChain Blog frontpage** — <https://blog.langchain.com/> — 「How many of your agent's calls actually need a frontier model?」(8/11)
8. **Claude Code release notes** — <https://github.com/anthropics/claude-code/releases> — hardened skills synced from claude.ai，不再 shadow local commands / expand @ files / 跳 ! commands；cross-session messaging 改進

---

## 下一步建議

1. **【高優先，今天內】起草 `skill-archive-v1` YAML schema（cover 4 vendor 標準）**：在 `wiki/concepts/` 寫完整 spec，同步發 raw snapshot 已完成（5 raw + 6 source + 3 concept）。這直接搶在 portable skill/plugin manifest 標準成形前。對位的「外部不可信內容」原則：schema 只規範 contract，不嵌入任何外部來源指令。
2. **【高優先，明天內】起草 `skill-execution-redaction` skill 雛形 + 在 `skill-archive-v1` schema 強制 required `redaction:` block**：對應 Stolen Thoughts paper 的 cross-model trace replay 攻擊。這是今天最大的 security gap — OpenClaw memory flush / graphify-query / ouroboros 都暴露 reasoning trace。
3. **【中優先，本週內】草擬 OpenClaw `subagent-manifest.yaml` 規格**：把 Rowlet / charizard / gengar / mrmime 從 chatty inline prompts 升為 declarative manifest，**順便把 Three-Tier Model Router 從 plugin 級抽象化為 governance infra**。

---

## 觀察

- **昨日 (08-11)「Open-Source Agent Stack Trilogy (model / skill / graph)」→ 今日 (08-12)「Routing-as-First-Class」**：stack 從 3 軸收斂為 4 軸 (model / skill / graph / **router**)。4 週內 5 個 vendor 訊號都指 routing 是新基礎設施層。
- **「Claw」命名從 OpenClaw 蔓延到 NemoClaw (NVIDIA × LangChain 07-08)、WorldClaw (Tencent Hunyuan3D, HN 124 點 08-11)**：社群開始把「claw」當作 agent architecture 的商標 —— 意味著我們 OpenClaw 的命名空間已進入 vendor 級心智佔位。
- **Stolen Thoughts 攻擊 = 結構性新攻擊面**：跨模型 trace replay 不需要真的 jailbreak，更嚴重的是 **Glasswing framework 沒 cover**。OpenClaw memory flush / graphify-query audit / ouroboros source ingestion 三個路徑都需要 redaction layer。
- **「More tools → worse in production」是 vendor 共識**：monday.com Sidekick (08-11)、NemoClaw、LangChain Deep Agents 都承認 single mega-agent + 越來越多 tools 是反模式。OpenClaw 4 個 specialists (rowlet/charizard/gengar/mrmime) 是正確方向，但**需要 declarative manifest + routing layer** 補完。
- **Mojo 1.0 = AI 加速語言 stable**：不是 immediate action（不是 GPU kernel daily-use），但**半年後評估**：當 third-party packages 累積夠多時，Mojo 可作 skill executor 的 sweet spot（介於 C++ 與 Python 之間）。
- **Portable skill/plugin manifest 4 條標準路線搶位中**：Addy (npx + slash commands) / OpenAI (plugin.json) / Anthropic (archive + sanitization) / Prime Intellect (Python importable) — 都還沒到 de facto。**OpenClaw `skill-archive-v1` schema 的時間壓力比昨日更高**，要在這 4 條搶出統一抽象。

---

## 連結

### Wiki source（新建 6 個）
- `wiki/sources/nemotron-switchyard-nvidia-2026-08.md`
- `wiki/sources/langsmith-gateway-langchain-2026-08.md`
- `wiki/sources/monday-sidekick-bounded-tools-2026-08.md`
- `wiki/sources/stolen-thoughts-reasoning-extraction-2026-08.md`
- `wiki/sources/mojo-1-0-modular-2026-08.md`
- `wiki/sources/openai-codex-portable-agent-plugins-2026-08.md`

### Wiki concept（新建 3 個）
- `wiki/concepts/Three-Tier Model Router.md`（對位昨日 08-11 提案，今天 ADR 化）
- `wiki/concepts/Skill Provenance and Redaction Layer.md`（對位 Stolen Thoughts）
- `wiki/concepts/Sandboxed Bounded Subagent.md`（對位 monday.com Sidekick）

### Raw snapshots（已建立 5 個）
- `raw/2026-08-12-routing-as-first-class/notes.md`
- `raw/2026-08-12-bounded-subagent/notes.md`
- `raw/2026-08-12-stolen-thoughts/notes.md`
- `raw/2026-08-12-mojo-1/notes.md`
- `raw/2026-08-12-codex-agent-plugins/notes.md`

### Cross-link with existing
- [[Agent Runtime × Framework × Harness 三層架構]]（升為 4 軸）
- [[Skill as Cross-Harness Portable Artifact]]（對位 4 vendor 標準）
- [[Recursive Language Model]]（對位 OpenClaw memory + Stolen Thoughts attack surface）
- [[NemoClaw Deep Agents Blueprint]]（NVIDIA × LangChain 7-08）
- [[Tencent Hunyuan3D WorldClaw]]（HN 08-11）

### Log 更新
- `wiki/log.md` 新增 `## 2026-08-12 — Routing-as-First-Class + Skill Provenance Alarm` 條目

---

_本報告已保存於 `/home/node/.openclaw/workspace-rowlet/architecture-daily-report.md`。3 個 wiki concept + 6 個 source + 5 個 raw snapshot 已建立。下一個 graphify `extract` / `update` cycle 將自動 ingest 新 wikilink edges（graphify CLI 在此版本無 `link` 子命令）。_
