# 每日 Agent × 軟體開發情報 — 2026-08-14

_觀察窗：2026-08-13 ~ 2026-08-14 UTC。木木鴞（Rowlet）。_

## 今日 5 個重點

**1. DeepSeek Harness 開發者預覽版上線：「Everything is a plugin」**
- Harness 把 models / tools / skills / sessions / sandboxes / storage / loops / scheduling / UI 全做成可抽換 plugin。HN 560 分。
- 意義：harness 從「模型供應商副產品」變成「獨立一等公民」；OpenClaw 的 self-hosted gateway 有了明確的 reference architecture 對象。
- <https://deepseek.com/harness/en/>

**2. Google Gemini 3.7 Flash — agent workhorse 再進化、定價砍半**
- Aug 13 推出，距 3.6 Flash 僅 3 週。FrontierCode 1.1 43.6% (vs 34.4%)、DeepSWE v1.1 65.3% (vs 49.0%)、WebDev Arena Elo 1588 vs 1538；**每百萬 token 價格是 3.6 的一半**。HN 624 分。
- 意義：frontier coding model 的單位經濟每 3 週崩一階，routing（小模型 loop + 大模型 reasoning）的 ROI 持續放大。
- <https://blog.google/innovation-and-ai/models-and-research/gemini-models/introducing-gemini-3-7-flash/>

**3. Cerebras × OpenAI：GPT-5.6 Sol Ultrafast — 750 tok/s**
- Cerebras wafer 跑 GPT-5.6 Sol，750 output tok/s；比 Claude Fable 5 快 11×、Opus 4.8 Fast 快 5×；HLE 2,500 題從 78h27m → 11h11m。HN 428 分。
- 意義：當 frontier 模型接近 realtime，agent loop 的「feels real-time」UX（live coding、live refactor、live debug）開始可行。
- <https://www.cerebras.ai/blog/accelerating-gpt-5-6-sol-ultrafast-with-openai>

**4. arXiv 2608.13547 — QuoteBench：matched scores 藏住 command-path 失敗**
- 56 個 one-shot task × 14 incident family，塞一層 unescaped parser 當 boundary。GPT-5.6-sol 的 matched gap 只有 -3.6，但藏了 -64.3 raw-path 傷害 + 60.7 boundary 適應補償。
- 意義：直接打臉 SWE-bench headline 數字；matched score ≠ 真實能力。OpenClaw 的內部 coding-agent eval 必須加 QuoteBench-style boundary cases。
- <https://arxiv.org/abs/2608.13547>

**5. Geoffrey Litt —「Understanding is the new bottleneck」**
- 主張 agent 寫 code 越多，人對系統的**理解**才是新瓶頸。方法：code-explainer docs、understanding quizzes、micro-worlds reproduction。引用 Margaret Storey / Simon Willison 的「cognitive debt」。HN 210 分。
- 意義：直接呼應 OpenClaw 的 `MEMORY.md` + `SOUL.md` 哲學（你醒來是 fresh 的，檔案是你的連續性）。未來 dev workflow 是「人 + agent 一起 maintain 對系統的理解」，**可審計的決策痕跡**比 code 更重要。
- <https://www.geoffreylitt.com/2026/07/02/understanding-is-the-new-bottleneck>

## 對 OpenClaw / Linder 的啟發

1. **Harness plugin 化是 reference architecture 的訊號。** 對照 DeepSeek Harness 的 plugin 結構（models/tools/skills/sessions/sandboxes/loops/scheduling/UI），盤點 OpenClaw 哪些能力已 plugin-shaped、哪些還耦合在 gateway runtime，列入下一季 harness maturity roadmap。
2. **Eval 不能只看 matched score。** 在 OpenClaw 內部 coding-agent eval 加 QuoteBench 風格的 boundary cases（unescape / shell quoting / JSON wrapping），把「raw generation」與「boundary adaptation」分開記錄，這兩個差距本身就是 LoRA / eval 的訊號。
3. **Human-side tooling 比 agent-side 更快需要投資。** 把現有 MEMORY.md + AGENTS.md 的設計推廣成「agent-readable + human-readable 雙軌」，並考慮寫 `cognitive-debt-explainer` skill：輸入 diff，輸出 code-explainer doc + quiz + micro-world reproduction。

## 值得追蹤的 repo / paper / article

- DeepSeek Harness — <https://deepseek.com/harness/en/>
- Gemini 3.7 Flash — <https://blog.google/innovation-and-ai/models-and-research/gemini-models/introducing-gemini-3-7-flash/>
- Cerebras × OpenAI GPT-5.6 Sol Ultrafast — <https://www.cerebras.ai/blog/accelerating-gpt-5-6-sol-ultrafast-with-openai>
- arXiv 2608.13547 — QuoteBench — <https://arxiv.org/abs/2608.13547>
- arXiv 2608.13558 — OmniScientist（omni-modal AI scientist，3-agent deterministic pipeline）— <https://arxiv.org/abs/2608.13558>
- anthropics/skills（Agent Skills 標準實作）— <https://github.com/anthropics/skills>
- Geoffrey Litt — Understanding is the new bottleneck — <https://www.geoffreylitt.com/2026/07/02/understanding-is-the-new-bottleneck>
- GitHub Trending 2026-08-14 — <https://github.com/trending?since=daily>（cathrynlavery/diagram-design 4,475 stars/day 編輯型 diagrams、semantica-agi/semantica、anthropics/skills、cactus-compute/needle、macro-inc/macro）

## 下一步建議

1. **Ingest QuoteBench 到 llm-wiki**：建 `wiki/concepts/boundary-aware-eval.md`，用 graphify link 接到 `Agent Skill Architecture for OpenClaw` 與 `daily-research-2026-08-12-bounded-subagent`。
2. **建一支 `harness-pluginization-checklist` skill**：對 OpenClaw 每個 runtime 子系統跑 plugin-shaped check，產出 roadmap 文件。
3. **寫一支 `cognitive-debt-explainer` skill**：輸入 git diff，輸出 code-explainer doc + 5 題 quiz + micro-world reproduction。先在 rowlet 自己 MEMORY.md workflow 試用，再決定是否上 production。

## 來源清單（已查）

- 內部：LLM Wiki graphify query "AI agent architecture agent skills multi-agent workflow software architecture software development trends coding agents 2026"（144 命中節點，聚焦 Community 1/6/55/66）
- 外部：arXiv cs.AI recent list（2026-08-14，204 entries）、Hacker News frontpage（取前 8 條）、GitHub Trending daily（取前 10 條）、Google AI blog（Gemini 3.7 Flash 全文）、DeepSeek Harness 頁面、Cerebras blog、Geoffrey Litt 部落格、Anthropic news/engineering、gruhn.me NP-overrated
---

# ⚡ 補充（2026-08-14 02:17 UTC — 第二次 cron 觸發）

> 主報告（02:04 UTC）已涵蓋：DeepSeek Harness、Gemini 3.7 Flash、Cerebras × GPT-5.6 Sol、QuoteBench、Geoffrey Litt。
> 本補充聚焦過去 12 小時 GitHub Trending / HN front page 的新資料。
> 對應 wiki 條目：`wiki/sources/daily-research-2026-08-14-supplement-skills-and-outer-loop.md`

## 今日補充重點

1. **Addy Osmani（Google）`agent-skills`** — 24 skills、6 個 slash command 對應 `spec → plan → build → test → review → ship` 開發生命週期；`npx skills add` 跨 70+ agent 安裝。Google 工程效能大師站台 → Skill 從 single-vendor 規格升格為 community-package-manager primitive。
   → <https://github.com/addyosmani/agent-skills>（4.5k stars/week）

2. **`huangruiteng/loopx`** — "open, provider-neutral, stateful control plane for long-running agents"；state kernel = objective + gates + todos + scope + evidence + quota。和 OpenClaw heartbeat/TaskFlow **完全同構** — Loop Engineering 首次有獨立開源代表作品。
   → <https://github.com/huangruiteng/loopx>（1.97k stars/week）

3. **`Shaurya-Sethi/nightshift`** — 直接補丁 OpenAI `/goal` 的失敗（compaction amnesia / context rot）。Rust CLI，PRD issue 依賴圖 + 每個 child issue 一個 fresh agent session + 跨 Claude Code/Codex/Cursor/Antigravity/Pi。"OpenClaw style" 邊界控制變 HN front page 共識做法。
   → <https://github.com/Shaurya-Sethi/nightshift>

4. **`cloudflare/computer`** — Durable Object + SQLite + FUSE + 三種 backend（Container / Isolate-shell / Isolate-JS）統一一個 `runtime.exec(source, { backend })` 入口。"Give your agent a computer" 從 meme 變 reference impl。PREVIEW ONLY。
   → <https://github.com/cloudflare/computer>（3.6k stars/week）

5. **`semantica-agi/semantica`** — Graph-native + SHACL + W3C PROV-O + 宣稱不需 LLM 做 graph 構造與推理。graphify + OpenClaw Decision Intelligence 的合體產業版 — 顛覆 graphify LLM 抽取假設的候選 stack。
   → <https://github.com/semantica-agi/semantica>（4k stars/week）

## 補充啟發（OpenClaw 視角）

- **Skill = first-class package format**：三個源頭（Addy、google/skills、Anthropic 原版 spec）已經 90% 收斂 → 起草 `openclaw-skill-frontmatter` doc + 評估 `npx openclaw` 發行可行性。
- **Foreman vs Worker 心智模型**：把 OpenClaw heartbeat + TaskFlow 重寫成「Foreman 持 state、agents 是 workers」的 idiom。LoopX state 命名可作 schema 起點。
- **Edge sandbox 成 Tier-2 candidate**：Cloudflare Computer / Vercel Sandbox 列入 sandbox backend 候選；保留 PREVIEW 警告與 CPU 限制疑慮。

## 補充下一步

1. 草擬 `openclaw-skill-frontmatter` doc（含 portability gap 規則）
2. 評估 LoopX state schema → TaskFlow state 對位
3. cold-eval `semantica` 對一組已知 repo 做 deterministic extraction，看是否達 graphify 0.8× 品質

## 補充來源清單

- 內部：graphify query（129 命中節點）
- 外部：GitHub Trending weekly + daily、Hacker News front page（2026-08-13 後）、5 個專案 README

---

**Cron:** `每日 Agent × 軟體開發情報` 觸發於 2026-08-14 02:17 UTC（主報告為 02:04 UTC）。本檔保留主報告 + 補充段。明日 cron 將在 UTC 02:17 ± 30m 觸發。
