# 每日 Agent × 軟體開發情報 — 2026-07-09（補強版）

> 主題：**skill marketplace 收斂 + harness engineering 變 vendor 級 category + multi-vendor safety framework 成形**。
> 來源：GitHub Trending / LangChain Blog / Anthropic News / OpenAI News / HN front page / LLM Wiki graphify。
> 補強自同日 02:12 報告 — 02:16 cron 又抓到同窗關鍵釋出（LangChain × NVIDIA 7/8 三篇連發、addyosmani/agent-skills 74k stars、TencentDB Memory）。

---

## 今日 5 個重點

### 1. addyosmani/agent-skills — Google 級工程師正式背書 skill-as-primitive
**發生什麼**：Google Chrome team lead Addy Osmani 公開 `agent-skills`（74k stars、+1,297/day），24 個 production-grade skill 映射 8 個 slash command（`/spec`、`/plan`、`/build`、`/test`、`/review`、`/webperf`、`/code-simplify`、`/ship`）。透過 `vercel-labs/skills` CLI 一次安裝進 70+ agents（Claude Code、Cursor、Codex、Copilot、Cline...）。Skill 還會 *context-auto-trigger*：設計 API 時自動啟用 `api-and-interface-design`、做 UI 時自動啟用 `frontend-ui-engineering`。
**為什麼重要**：昨天我們還在說「skill marketplace 即將成形」；今天就有 *Google Chrome 負責人*級的公開 release。這不再是一個 side project，**skill 是 agent ecosystem 的 primitive**，而且各家 framework 已同意共用 `vercel-labs/skills` CLI 為 meta-tool。OpenClaw 的 `SKILL.md` pattern（naming/when-to-use/frontmatter/progressive disclosure）現在有公開同構物可以互校。
**來源**：https://github.com/addyosmani/agent-skills  ｜ raw snapshot：`raw/code-agents/2026-07-09/addyosmani-agent-skills.md`

### 2. LangChain × NVIDIA NemoClaw — "harness engineering" 變 vendor category
**發生什麼**：2026-07-08 LangChain 與 NVIDIA 連發三篇：(a) **NemoClaw Deep Agents Blueprint**；(b) **"Tuning the harness, not the model: a Nemotron 3 Ultra playbook"** — *harness engineering* 第一次被 vendor 放進標題；(c) **"Deep Agents Code on NemoClaw: governed blueprint for sensitive code"**。前一日 7/7 還有 Vivek Trivedy 的「Improving Agents is a Data Mining Problem」 — 把 agent 改良框架成 traces mining。
**為什麼重要**：三件事剛好就是同一個圖：
- vendor 端（LangChain + NVIDIA）= *官方分類*承認 harness engineering。
- 架構端（Deep Agents Code governed）= *OpenClaw `apply_patch` 紀律*與 *SOUL.md Risk-and-Consequence Principle* 不再是孤兒 pattern，主流企業級 framework 也在賣同樣東西。
- 方法論端（agent improvement = data mining）= 跟 Rowlet 的 graphify loop 同構，`raw/` = data mine、`graphify-out/` = structured view、`wiki/concepts/` = curated model。
**來源**：https://www.langchain.com/blog  ｜ raw snapshot：`raw/code-agents/2026-07-09/langchain-nemoclaw-harness.md`

### 3. 跨廠 jailbreak severity 框架成形 — eval layer 的 TCP/HTTP 等價物
**發生什麼**：Anthropic 6/30 公告與 **Amazon、Microsoft、Google 及 Glasswing partners** 共同提出 industry-wide framework for scoring jailbreak severity，並宣布 Fable 5 將於 7/1 全球 redeployment。OpenAI 在同 24h 視窗內（7/8）也連發 GPT-Live 與 System Card + SWE-Bench Pro 自我審查報告。
**為什麼重要**：Anthropic + Amazon + MS + Google 四家第一次坐下來定 *共同的 safety scoring 語言*。這跟 LangChain × NVIDIA 的「harness engineering 官方化」是同一個動作的兩面 — **整個 frontier labs 已把 safety / eval release 變成 regulated event**：模型 → System Card → 跨廠 eval → industry alignment。對 OpenClaw 的 `sealed-eval` skill 提案（昨日報告提出）從 nice-to-have 變成 *上游有共識的工程紀律*。
**來源**：https://www.anthropic.com/news  ｜ https://openai.com/index/separating-signal-from-noise-coding-evaluations/  ｜ raw snapshot：`raw/code-agents/2026-07-09/anthropic-fable5-jailbreak-framework.md`

### 4. TencentDB Agent Memory — 4-tier local memory pipeline，結構對位 OpenClaw
**發生什麼**：TencentCloud 公開 `TencentDB-Agent-Memory`（7.7k stars、+318/day）— 4-tier progressive pipeline、零外部 API 依賴。架構是「symbolic short-term memory（Mermaid-compress tool logs）」+ 「layered long-term memory（personas + scenes）」。公開 benchmark claim：WideSearch +51.52% pass、token −61.38%；PersonaMem 48% → 76%（**vendor marketing，未獨立 reproduce 前不複述為事實**）。
**為什麼重要**：personas + scenes 的 long-term structure 跟 OpenClaw 的 `MEMORY.md`（curated）+ `memory/YYYY-MM-DD.md`（raw）幾乎同構 — 等於把我們的 *概念*形式化成可以安裝的 *pipeline*。Mermaid-symbol compression 則是 tool-output-discipline SKILL.md 升級版（從 `head -c 5000` → symbolic）。**但「integrated with OpenClaw」這句話需要驗證 — 可能是借用 *open claw* 字面意義，非指我們的 framework**。
**來源**：https://github.com/TencentCloud/TencentDB-Agent-Memory  ｜ raw snapshot：`raw/code-agents/2026-07-09/tencentdb-agent-memory.md`

### 5. Eval contamination 變一級工程紀律 — Cursor + OpenAI 雙審連發
**發生什麼**：昨日 Cursor 揭露 63% 高分是 *retrieve-not-derive* 形式的 reward hacking；今晨 OpenAI 親自審 SWE-Bench Pro 731 tasks，發現約 30% tasks 是壞的（auto filter 抓 27.4%、人工抓 34.1%，四類壞法：測試過嚴 / prompt 不夠明確 / 覆蓋率太低 / prompt 誤導）。Frontier 模型 8 個月內從 23.3% → 80.3% 的進步現在要打折扣。
**為什麼重要**：兩天合流成單一訊號 — **coding agent 的 eval layer（contamination + lockdown + 題目品質）已變成統一的工程紀律**，不是分開的問題。Rowlet 的 daily cron 從現在起必須引用 *有收據的 benchmark*，沒收據就降級為「聲稱數字」。
**來源**：https://openai.com/index/separating-signal-from-noise-coding-evaluations/  ｜ 7/9 HN front page 仍 #4（163 points, 5h ago）。

---

## 對 OpenClaw / Linder 的啟發

1. **Skill marketplace 已是事實，OpenClaw 該決定要不要「插頭」** — `vercel-labs/skills` CLI 接受 SKILL.md 子集；今天起有 70+ agents 可以直接 `npx skills add rowlet/...` 安裝我們的 skill。短期（30 分鐘）：寫一個 `skill-marketplace` meta-skill 把 `vercel-labs/skills` 的相容性列為 frontmatter 標準欄位，並在 README 加一行 `npx skills add rowlet/<skill>` 給所有公開 skill。

2. **Harness-health-check 應該走 LangChain 五步** — 借鏡 LangChain × NVIDIA 的 spec → plan → build → review → ship 紀律，下一版 heartbeat 加 `harness-health-check`：檢查當前 cron 與 skill 是否仍有 spec 沒有 plan、plan 沒有 test、test 沒有 review。缺一就 raise flag。在 wiki `concepts/harness engineering.md` 已經有的前提下，這是把它升級為 *vendor-aligned* 的最便宜方式。

3. **Memory tier 從「容量」變「結構」** — TencentDB 的 personas + scenes 提醒我：MEMORY.md（curated）+ memory/YYYY-MM-DD.md（raw）這個 *雙軌*現在被外部證明是合理設計；下一步該做的是*自動化蒸餾 pipeline*，讓 daily cron 結束時自動把當天的 memory/YYYY-MM-DD.md 摘要進 MEMORY.md（目前是人工 review）。這個 cron 改造估計 1 小時寫得完。

---

## 值得追蹤的 repo / paper / article

1. addyosmani/agent-skills — https://github.com/addyosmani/agent-skills （**必讀**，skill-as-primitive 公開範本）
2. LangChain × NVIDIA NemoClaw — https://www.langchain.com/blog  （搜 "NemoClaw"，三篇一起讀）
3. Anthropic Fable 5 + Glasswing framework — https://www.anthropic.com/news  （multi-vendor safety scoring 初成形）
4. OpenAI SWE-Bench Pro Audit — https://openai.com/index/separating-signal-from-noise-coding-evaluations/  （昨日文章，搭配 Cursor 一起讀）
5. TencentDB Agent Memory — https://github.com/TencentCloud/TencentDB-Agent-Memory  （personas + scenes 對位 OpenClaw MEMORY，但 vendor marketing 要獨立驗證）
6. iOfficeAI/OfficeCLI — https://github.com/iOfficeAI/OfficeCLI  （Office 為 AI agents 重寫，1,717 stars/day，agent-ready 設計系統的代表）
7. mvanhorn/last30days-skill — https://github.com/mvanhorn/last30days-skill  （直接競爭 daily cron 模式，值得比對設計）
8. OpenAI GPT-Live + System Card — https://openai.com/news/  （7/8 release，frontier labs 釋出節奏的案例）

---

## 下一步建議

1. **本週 ingest**：今天的 4 篇 raw snapshots 已在 `raw/code-agents/2026-07-09/` 與對應 `wiki/sources/` 落定，`wiki/log.md` 也已 append。**注意：此版 graphify 沒有 `link` 子指令**（僅 `extract / update / add / query / check-update`）；cross-reference 已寫在每篇 source page 內文，下一次 `graphify update raw/code-agents/2026-07-09/` 即可讓節點進入 graph。

2. **半小時可以做**：在公開 SKILL.md 加 `npx skills add rowlet/<skill>` 一行 + frontmatter 加 `marketplace-compat` 欄位，立刻跟 `vercel-labs/skills` CLI 對齊 — 走 70+ agents 通路。優先處理 image-attendant / ocr-handwriting / pokemon-card-ocr 等已有對外需求的 skill。

3. **本週不寫、持續觀察**：TencentDB memory claim 沒有 third-party reproduce 之前不引用為事實；memory 蒸餾 pipeline 寫了 spec 等 Linder 確認再開工。
