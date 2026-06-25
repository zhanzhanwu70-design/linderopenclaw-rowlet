# 每日 Agent × 軟體開發情報 — 2026-06-25

> 報告者：木木鴞（Rowlet）  
> 模式：Wiki-first + 多源交叉  
> 重點時段：最近 7-14 天（2026-06-11 ~ 2026-06-25）  
> 涵蓋類型：coding agent framework、AI 工程研究、software architecture、AI infra chip

---

## 今日 5 個重點

### 1. OpenAI × Broadcom 推出 LLM 推論自製晶片「Jalapeno」
**發生什麼**：OpenAI 與 Broadcom 聯合發表第一顆 LLM-optimized inference chip，代號 Jalapeno。TechCrunch 報導 537 點、OpenAI 官網 blog 同步發文（141 點）。這是 OpenAI 第一次公開自有 inference 硬體，採用 Broadcom 的網路與客製化晶片設計能力。
**為什麼重要**：從 model API → inference 垂直整合。這意味 OpenAI 把 unit-cost-of-inference 主導權拿回自己手裡，中長期會壓低 OpenAI 端 API 價格、改變 Sora / GPT-5 之類 frontier model 的 economics。對 OpenClaw / Linder 來說，coding agent 的 token economics 進入下一輪 — `spend predictability` 不再只是 prompt cache 問題，而會延伸到 inference-tier 問題。
**來源**：
- TechCrunch：https://techcrunch.com/2026/06/24/openai-unveils-its-first-custom-chip-built-by-broadcom/
- OpenAI 官方：https://openai.com/index/openai-broadcom-jalapeno-inference-chip/

### 2. Cursor 推出「Customize Cursor」+ Marketplace leaderboard + /automate skill
**發生什麼**：Cursor 在 06-18 一次推出多項重大更新 ——
- **Customize 頁面**：把 plugins, skills, MCPs, subagents, rules, commands, hooks 全部收進單一管理介面，且支援 user / team / workspace 三層 scope。
- **Marketplace leaderboard**：team 內可看到最熱門 plugin/skill/MCP 排行，一鍵安裝。
- **Team marketplaces**：支援從 GitLab、BitBucket、Azure DevOps 匯入 plugin repo 給整個 team 使用。
- **/automate skill**：在 local agent session 直接用 plain language 描述要自動化的任務，Cursor 會自動設定 triggers / instructions / tools。
- **Plugin canvases**：Hex Canvas（資料視覺化）、Atlassian Canvas（即時 issues/projects/documents 視圖）。
- **New GitHub triggers** for Automations：Issue comment、PR review comment、PR review submitted 等 5 種新觸發。
- **Slack emoji trigger**：用 emoji reaction 觸發 automation。
**為什麼重要**：Cursor 把「coding agent customization + skill ecosystem」正式 productize — 這是 LangChain 一直想做但沒做好的「skill marketplace」路線的首次實裝驗證。三層 scope（user / team / workspace）明確區分個人化與組織化，對企業導入 coding agent 是關鍵設計模式。**對 OpenClaw 最直接的啟發**：我們現在 skills 是 single-host，缺少 team/workspace 隔離與 marketplace 概念。
**來源**：https://cursor.com/changelog（06-18 區段）+ https://cursor.com/docs/plugins

### 3. LangChain 6 月「Agent Architecture」系列密集發布 — agent 進入 production 化階段
**發生什麼**：LangChain / LangGraph / LangSmith blog 在 2026-06-04 ~ 2026-06-24 三週內連發 9 篇深度文：
- **Jun 24**: How To Give Your Agent Memory — agentic memory 設計模式
- **Jun 18**: LangGraph 1.2.6 — 修正 nested subgraph inherits parent checkpoint_ns (1.2.3 regression)
- **Jun 16**: The Art of Loop Engineering — 迴圈工程（agent loop 結構化）
- **Jun 16**: Why Fleet Has Both General Purpose Chat and Specialized Agents — general vs specialized 取捨
- **Jun 15**: Building a 100x Cheaper Trace Judge with Fireworks — 評測成本降低 100x
- **Jun 15**: How We Made Coding Agent Spend Predictable — coding agent spend 管理
- **Jun 12**: Building Box AI: How an Enterprise Content Platform Went AI-Native with Deep Agents — Deep Agents 在 Box 的企業落地
- **Jun 12**: How to Choose the Right Sandbox for Your Agent — sandbox 選型框架
- **Jun 11**: How Benchling builds agents when the smartest AI isn't smart enough — 領域專業 agent
- **Jun 10**: The Missing Link Between Agents and Applications — agent 與應用整合 gap
- **Jun 10**: Full Text Search in SmithDB — SmithDB 倒排索引設計
- **Jun 5**: Give your agent its own computer — agent 與 OS / 容器分離
- **Jun 4**: Why Model Neutrality Matters More Than Cloud Neutrality — model neutrality 議題
**為什麼重要**：這不是「單篇 tutorial」，是「production agent engineering 整套方法論」的系統化發表。Loop engineering、memory 設計、sandbox 選型、spend predictability、verifier 設計 — 五大主題構成企業級 agent 的工程 checklist。**對 OpenClaw / Linder 的直接啟發**：我們現在的 skill / workflow 設計是直覺式，這套 checklist 是把它 formalize 的範本。特別是「spend predictability」與「loop engineering」直接對應 cron 監控與 agent loop 結構議題。
**來源**：https://www.langchain.com/blog

### 4. Claude Code v2.1.191 修正「background agents resurrecting after being stopped」
**發生什麼**：Anthropic 6/24 釋出 v2.1.191，重要的修正與功能：
- 新增 `/rewind` — 把對話從 `/clear` 之前的狀態復原
- **Fixed background agents resurrecting after being stopped** — 在 tasks panel 停止 agent 是永久性的（這之前有 bug，停止的 agent 會復活）
- 其他 UX bug fix（scroll 跳動、voice policy 訊息、login URL、Windows Terminal、Cmd+click in Ghostty）

**為什麼重要**：background agent 復活 bug 是 coding agent reliability 的關鍵痛點 — 你以為停了但其實還在跑、繼續消耗 token。**對 OpenClaw / Linder 來說，這直接對應 Rowlet SOUL.md 已記載的「sessions_send 是 fire-and-forget」議題**。永久性 kill 需要明確的 lifecycle control（明確 status: stopped, 確認 thread/task 已 kill, 不能從未完成 state 復活）。可以當作 `sessions_send` 改進與 OpenClaw `cron` agent 終止流程的設計參考。
**來源**：https://github.com/anthropics/claude-code/releases/tag/v2.1.191

### 5. arXiv 6 月 agent 論文潮：評測、診斷、red-teaming 進入精細化
**發生什麼**：arXiv cs.AI / cs.CL 在 2026-06-24 一天就出現多篇 agent 專用論文：
- **Metis: Bridging Text and Code Memory for Self-Evolving Agents** — text + code memory 雙軌 self-evolving
- **Escaping the Self-Confirmation Trap: An Execute-Distill-Verify Paradigm for Agentic Experience Learning** — 防 agent 自己驗證自己造成 confirmation bias
- **NatureBench: Can Coding Agents Match the Published SOTA of Nature-Family Papers?** — 拿 coding agent 跑頂會論文 SOTA
- **MEMPROBE: Probing Long-Term Agent Memory via Hidden User-State Recovery** — 探測 agent 長期記憶是否還能 recover 隱藏 user state
- **SHERLOC: Structured Diagnostic Localization for Code Repair Agents** — code repair agent 的結構化診斷定位
- **Bayesian control for coding agents** — Bayesian 控制 coding agent
- **RIFT-Bench: Dynamic Red-teaming For Agentic AI Systems** — agentic system 動態 red-teaming
- **Are We Ready For An Agent-Native Memory System?** — agent-native memory system 反思
- **When Retrieval Metrics Mislead: Measuring Policy Signal in Long-Horizon Tool-Use Agents** — long-horizon tool-use 的 retrieval metric 誤導問題
- **Qwen-AgentWorld: Language World Models for General Agents** — Qwen 的語言 world model
**為什麼重要**：agent 評測從「整體成功率」進入「精細診斷」階段 — memory probe、diagnostic localization、red-team benchmark、retrieval metric 反思 — 這是 agent 真正進入產品化、工程化前的必要成熟。**對 OpenClaw / Linder 來說**：MEMPROBE / SHERLOC / When Retrieval Metrics Mislead 直接對應我們 rowlet-self-reproduction 的「驗證 memory 是否還在」、與 llm-wiki retrieval quality 議題。
**來源**：https://rss.arxiv.org/atom/cs.AI + https://rss.arxiv.org/atom/cs.CL

---

## 對 OpenClaw / Linder 的啟發（3 條）

1. **OpenClaw skills 需要 team / workspace scope 概念**
   Cursor 的 Customize + Team Marketplace 證明：當 coding agent 進入企業 / team 情境，「skill 從哪裡來」、「誰能改」、「team 共享還是個人化」是必須的設計維度。OpenClaw 目前 skills 主要是 single-host / single-user。**可執行方向**：在 `~/.openclaw/skills/` 結構上加入 `team/` 與 `workspace/` 兩個 scope，模仿 Cursor 的 leaderboard / marketplace 概念。

2. **引入「Agent Engineering Checklist」框架**
   LangChain 6 月系列 9 篇其實在背後是一套 production agent 設計方法論：memory / loop / sandbox / verifier / spend / model-neutrality / general-vs-specialized。**可執行方向**：把這 9 篇 ingest 到 llm-wiki 作為新 map「Agent Engineering Checklist」，並設計對應的 `agent-engineering-review` skill（讀現有 agent config 給出這 9 個面向的 review）。

3. **Claude Code 「background agent permanent kill」是 OpenClaw 必須有的契約**
   Anthropic 修了 background agent 復活 bug，因為這是 reliability 痛點。OpenClaw 的 `sessions_send`、cron agent、heartbeat 都有「停止」這個動作，但要確認停止後不會從未完成 state 復活。**可執行方向**：在 OpenClaw 改進 `sessions_send` 或寫 `agent-lifecycle-guard` skill，規範 agent / session 停止後必須顯式寫 status 到 SOUL.md 或 heartbeat-state.json，禁止隱性復活。

---

## 值得追蹤的 repo / paper / article

### Repo / Framework
- **Cursor Customize / Marketplace** — https://cursor.com/changelog（6-18 區段）+ https://cursor.com/docs/plugins
- **Claude Code v2.1.191** — https://github.com/anthropics/claude-code/releases/tag/v2.1.191
- **OpenAI Codex rust-v0.143.0-alpha.16** — https://github.com/openai/codex/releases（2026-06-25 剛出）
- **LangGraph 1.2.6** — https://github.com/langchain-ai/langgraph/releases（修正 nested subgraph checkpoint_ns）
- **calesthio/OpenMontage** — World's first open-source, agentic video production system；12 pipelines、52 tools、**500+ agent skills**；GitHub Trending #1。值得研究其 skill library / skill marketplace 設計。https://github.com/calesthio/OpenMontage
- **revfactory/harness** — Meta-skill 設計 domain-specific agent teams（277 stars today）。harness engineering 的開源參考實作。https://github.com/revfactory/harness
- **stablyai/orca** — ADE（Agent Development Environment）for parallel coding agents，desktop + mobile。https://github.com/stablyai/orca
- **google-labs-code/design.md** — Google 推出 DESIGN.md format 給 coding agents 用 — 設計系統 → coding agent 的 spec 化格式。https://github.com/google-labs-code/design.md
- **apple/container** — Apple 自家 Linux containers on Mac（optimized for Apple silicon）。基礎設施層動向。https://github.com/apple/container

### Paper / Research
- **Metis: Bridging Text and Code Memory for Self-Evolving Agents** — text/code memory 雙軌 self-evolving
- **MEMPROBE: Probing Long-Term Agent Memory via Hidden User-State Recovery** — agent 長期記憶探測
- **SHERLOC: Structured Diagnostic Localization for Code Repair Agents** — code repair 結構化診斷
- **NatureBench: Can Coding Agents Match the Published SOTA of Nature-Family Papers?** — coding agent vs SOTA benchmark
- **RIFT-Bench: Dynamic Red-teaming For Agentic AI Systems** — agentic system 動態 red-teaming
- **Are We Ready For An Agent-Native Memory System?** — agent-native memory 反思（直接呼應 A-MEM / Mem0 / AtomMem 系列）
- **Bayesian control for coding agents** — Bayesian 控制 coding agent 行為
- **When Retrieval Metrics Mislead: Measuring Policy Signal in Long-Horizon Tool-Use Agents** — retrieval metric 反思

### Article / Blog
- **OpenAI 官方**：OpenAI × Broadcom Jalapeno inference chip — https://openai.com/index/openai-broadcom-jalapeno-inference-chip/
- **LangChain blog 系列**（Jun 4 ~ Jun 24）— https://www.langchain.com/blog
- **TechCrunch OpenAI chip** — https://techcrunch.com/2026/06/24/openai-unveils-its-first-custom-chip-built-by-broadcom/
- **Thoughtworks Technology Radar Vol 32** — 主題：「The challenge of evaluating technology in an agentic world」；提到 **spec-driven development** vs **harness engineering** 的 semantic diffusion 問題。https://www.thoughtworks.com/radar
- **Reuters：Anthropic says Alibaba illicitly extracted Claude AI model capabilities**（53 pts on HN）— Alibaba 蒸餾 Claude 的智財事件，是 frontier model 保護策略的新案例

---

## 下一步建議（最多 3 條）

1. **將 LangChain 6 月 Agent Architecture 9 篇 ingest 到 llm-wiki**
   - 目標頁面：`wiki/maps/Agent Engineering Checklist.md`（新 map）
   - 同時把 Cursor Customize 與 Anthropic Claude Code background agent fix 各建立一個 wiki source/concept 條目
   - 更新 `wiki/index.md` 與 `wiki/log.md`

2. **寫 `agent-release-monitor` skill**
   - 自動 cron 每週 / 每日抓 openai/codex、anthropics/claude-code、langchain-ai/langgraph、cursor/changelog RSS
   - 比較本次與上次 release 的 diff，找出對 OpenClaw 有影響的 breaking change
   - 整合進 heartbeat / pipeline，自動推送「release 變化摘要」到 rowlet heartbeat channel

3. **跟 Linder 討論 OpenClaw skill 的 team / workspace scope 提案**
   - 提問：是否要把 `~/.openclaw/skills/` 結構擴展為 user / team / workspace 三層 scope
   - 準備材料：Cursor Customize 文件 + OpenMontage 500+ skills 的 skill library 設計 + revfactory/harness 的 meta-skill 概念
   - 預期產出：skill 結構設計草案 v0.1

---

## 來源清單（已查 / 失敗 / 不可讀）

### 已查
- `/home/node/.openclaw/workspace/llm-wiki` graph + Code Agent map（9420 nodes，已用 graphify query）
- Hacker News front page（OpenAI chip 537 pts, Anthropic Alibaba 53 pts）
- HN Algolia search_by_date（coding agent / multi-agent / context engineering）
- GitHub Trending daily（OpenMontage / apple/container / revfactory/harness / stablyai/orca / google-labs-code/design.md 等）
- arXiv cs.AI / cs.CL RSS（June 24 entries）
- LangChain blog（June 4 ~ June 24 完整列表）
- Cursor changelog（06-18 Customize + Automations）
- Claude Code release atom feed（v2.1.191）
- OpenAI Codex release atom feed（rust-v0.143.0-alpha.16）
- LangGraph release atom feed（1.2.6）
- Thoughtworks Tech Radar Vol 32（agentic world 主題）
- TechCrunch OpenAI Broadcom 文章
- OpenAI 官方 blog（Jalapeno inference chip）

### 失敗 / 受限
- arXiv export API（http timeout，繞道 RSS）
- Martin Fowler articles/index.html（404，sitemap 變動）
- Anthropic /news（拿到奇怪的 "Fable 5 / Mythos 5 export control" 內容，疑為 mock，標註為不可信，未採用）
- HN Algolia 帶引號精確搜尋 `hits: 0`（API 解析問題，改用一般詞搜尋）

### 未深入
- Martin Fowler、Pragmatic Engineer 等個人 blog 未抓到 RSS（URL 404）
- Microsoft / Google DeepMind / Apple Research 等 blog 沒時間逐個查
- 大量 Show HN 項目（Cplt, Modulus, SmolVM, Mozzie, Pocket, Continue CI 等）值得單獨深入
