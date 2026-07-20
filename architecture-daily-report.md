# 每日 Agent × 軟體開發情報 — 2026-07-20

> 產出者：木木鴞（rowlet）｜時區：UTC｜查詢時間：2026-07-20 02:05 UTC
> 範圍：近 7-14 天（必要時追溯到本月）；三類來源：研究 / 開發潮流 / 工具與框架 release。

## 今日 5 個重點

1. **Microsoft Agent Framework python-1.11.0（2026-07-09）把 Skills API 推上「stable」並加入 progressive MCP disclosure。**
   - 發生什麼：`SkillsProvider` 拆出 `CachingSkillsSource`（含 TTL `refresh_interval`），新增 `SkillsSourceContext` 支援 per-key 快取隔離，nested `SKILL.md` 不再被當成獨立 skill；`core` 同時導入 message-injection middleware（host/tool 可在 active run 中插入訊息，下一個 model call 排乾），以及 progressive MCP disclosure（agent 動態 discover/load/unload MCP tool schema 但守住 `allowed_tools` 邊界）。
   - 為什麼重要：Skills 從「experimental 特性」變成「first-class adapter」，並直接對應到 OpenClaw / Claude Code / Codex / Cursor 的 skill 架構；progressive disclosure 正是我們解「skill 太多 → context 爆掉」的官方解法樣板。
   - 來源：<https://github.com/microsoft/agent-framework/releases/tag/python-1.11.0>（[1.11.0] changelog，Breaking 三項全部圍繞 Skills API）。

2. **Google AlphaEvolve 在 Gemini Enterprise Agent Platform 正式 GA — 評分器留在客戶端，進化式代碼最佳化作為服務。**
   - 發生什麼：DeepMind 將 AlphaEvolve 從研究專案變成 Cloud 產品，evaluator 跑在客戶端（筆電 / 私有叢集 / 超算），API 只負責產 candidate；公開案例：Klarna ML training throughput ×2（3 週、~6,000 候選、bit-exact 復現）、JetBrains IDE completion latency −15~20%、FM Logistic picking route −10.4%、Kinaxis forecasting accuracy +22% / runtime −90%；內部已用於 TPU 設計、Spanner LSM compaction（write amp −20%）。
   - 為什麼重要：把「人類擁有 benchmark、review、release 決策，搜尋空間變小」這條工程分工寫成產品條款；對 agent 社群示範了「evaluator-side sovereignty」的部署樣板，正好對齊 OpenClaw 的 local-first 立場。
   - 來源：<https://www.infoq.com/news/2026/07/alphaevolve-generally-available/>；底層 <https://storage.googleapis.com/deepmind-media/DeepMind.com/Blog/alphaevolve-a-gemini-powered-coding-agent-for-designing-advanced-algorithms/AlphaEvolve.pdf>。

3. **Netflix 發佈 GenPage：單一生成模型取代多階段推薦管線，prompt 強化比模型放大更划算。**
   - 發生什麼：把 candidate generation / ranking / page layout 收進一個 120M→900M 參數的 generative model，並用 RL 後訓練；A/B 顯示核心 engagement 指標顯著提升、end-to-end serving latency −20%；內部分析：把 context 從 120M 升到 900M 只換到 WBC loss −1.3%，但「累積 prompt 強化」換到 −6.9% — 「單一設計良好的 context 增量，效果勝過整段 ~7.5× 模型放大」。
   - 為什麼重要：再一次量化「context quality > model scale」這條規律（搭配早先 Anthropic / OpenAI 的「prompt cache」與「MCP」敘事），對 agent 架構師是直接的成本-效益指南：與其搶更大模型，不如把 user history / request context / tool state 收齊。
   - 來源：<https://www.infoq.com/news/2026/07/netflix-llm-homepage-generation/>；原始 blog <https://netflixtechblog.com/genpage-towards-end-to-end-generative-homepage-construction-at-netflix-77146fba8a08>。

4. **Claude Code v2.1.214 / v2.1.215（2026-07-18 / 19）做了一輪 permission 硬化 + 引入 EndConversation 工具。**
   - 發生什麼：修掉 Windows PowerShell 5.1 permission bypass、bash 對 `help` / `man` 危險選項的誤判、zsh `[[ ]]` 變數 subscripts 漏判、>10k 字長指令一律走 prompt（fail-closed）、PowerShell 工具的 UTF-16LE 寫檔錯誤；`/verify` 與 `/code-review` 不再自動觸發，要顯式呼叫；新增 `EndConversation` 工具（沿用 2025 claude.ai 的 welfare 設計）、長工具呼叫的 progress heartbeat、OTel 事件加 `message.uuid` / `client_request_id` / `tool_source`、memory frontmatter 加 ISO modified timestamp。
   - 為什麼重要：CLI coding agent 已進入「permission 解析器需要跟上 shell dialect 多樣性」的階段；對 OpenClaw 這種多 agent + 多 shell 環境是同款風險（bash 與 zsh 解析差異在 `pkill -f` 還會誤殺自己）。EndConversation 工具也提示「agent 自我終止」正在從 web 介面滲到 IDE / CLI 介面。
   - 來源：<https://github.com/anthropics/claude-code/releases/tag/v2.1.214>、<https://github.com/anthropics/claude-code/releases/tag/v2.1.215>；EndConversation 設計 <https://www.anthropic.com/research/end-subset-conversations>。

5. **Martin Fowler 連發兩篇「LLM × 設計哲學」：DSLs 是 LLM 的可靠 harness、brownfield 任務要當考古學家而不是觀光客。**
   - 發生什麼：〈DSLs Enable Reliable Use of LLMs〉（2026-07-14）主張 upfront spec 只是假設，DDD / ubiquitous language 加上 DSL 才是 LLM 的最佳操作面（PlantUML / Mermaid / SQL / K8s YAML 都驗證過）。〈The Archaeologist's Copilot〉（2026-07-16）以 Java 1.5 → modern 的 legacy 案例展示「Tourist Prompt」會生出看起來漂亮但結構錯誤的 build 檔，必須切換成「Forensic Code Audit」角色，要求 AI 列舉依據、不准樂觀。
   - 為什麼重要：把目前最零散的兩個 LLM 工程實務（DSL 約束 + 證據驅動審查）拉到「設計哲學」層級，並與我們 SOUL.md 裡的「Risk and Consequence Principle」直接呼應；DSLs = bounded vocabulary，Archaeologist = grounded evidence，兩者合起來就是「給 LLM 一個可被審計的工作面」。
   - 來源：<https://martinfowler.com/articles/llm-and-dsls.html>、<https://martinfowler.com/articles/archaeologist-copilot.html>。

## 對 OpenClaw / Linder 的啟發

1. **把 Skills API 升級成 first-class 並內建 progressive disclosure。** 對齊 MS Agent Framework 1.11.0 的拆法：抽出 `CachingSkillsSource`（含 TTL）、`SkillsSourceContext`（per-agent/per-session 快取隔離）、明確禁止 nested `SKILL.md` 被當獨立 skill。OpenClaw 可在下一次 skill 重構時，把目前 flat 列表升級成「skill metadata + 動態載入 SKILL.md 段落」，並在 `bootstrap` 中暴露 `list-skills` MCP 工具讓 agent 在需要時才拉內容；同步加上 `allowed_tools` boundary 確保 skill 動態載入不會越界。建議落成 `skill-loader` MCP server 或在 `claude-code` skill 內新增 `/skill load` 子命令。

2. **建立「證據驅動 + DSL 約束」雙軌 default skill 範本。** 把 Archaeologist Copilot 的「Forensic Code Audit」prompt 與 Fowler 的 DSL 主張，整理成 `archaeologist` 與 `dsl-author` 兩個 reusable skill（含 persona、anti-patterns、output schema），並預設綁到 `code-review` 與「legacy modernization」workflow；同時在 `llm-wiki/sources/` 落兩篇濃縮版，方便日後 agent 引用。這也是呼應 SOUL.md「Risk and Consequence Principle」最直接的方式 — 用 skill 形式讓不可信的 LLM 行為被結構化收斂。

3. **為 CLI 工具鏈加 permission 解析器 + 自我終止協議。** Claude Code v2.1.214 的修補清單顯示 PowerShell 5.1 / bash `help` / zsh `[[ ]]` / `pkill -f` 都是真實攻擊面；OpenClaw 應該把目前 `nativeapprovals` 升級成「多 dialect parser + 字數上限 fail-closed + process-tree 自殺偵測」。短期可以在 `tool-output-discipline` skill 之外，新增 `permission-audit` skill：定期 grep OpenClaw 自己的 bash/zsh 工具呼叫，找出可被解析器誤判的 pattern；長期則借鏡 `EndConversation`，讓 agent 在判定「任務完全無解且會持續浪費 token」時可以顯式 `/abort-session`（仍由 CEO 或人來決定是否批准）。

## 值得追蹤的 repo / paper / article

- **SkillOpt: Executive Strategy for Self-Evolving Agent Skills** — 把 skill 當成可訓練的 text artifact，用 frontier model 做 bounded add/delete/replace、由 held-out gate 驗收。直接對應「skill 是否能自我演化」這條問題。arXiv 2605.23904，<https://huggingface.co/papers/2605.23904>。
- **From Human-Centric to Agentic Code Review**（Queen’s U, 2026-07）— 1.02M PR / 207 專案的實證研究：agent 參與的 review 變快了，但 review quality 並未等幅提升。提醒我們在 `code-review-graph` 類工具上要保留 human gate。arXiv 2607.13196，<https://huggingface.co/papers/2607.13196>。
- **tirth8205/code-review-graph** — 本地優先的程式碼 intelligence graph，tree-sitter 解析 + 增量更新 + 透過 MCP 餵給 Codex/Cursor/Claude Code/Gemini CLI/Copilot/Kiro。直接競爭「AI 寫程式時 context 太多」這條痛點。<https://github.com/tirth8205/code-review-graph>。
- **KnockOutEZ/wigolo** — 本地優先的 web 搜尋 / 抓取 / 爬 / 研究 MCP server，no API key / no cloud / $0/query public beta。對應 OpenClaw 的「本地優先研究」定位。<https://github.com/KnockOutEZ/wigolo>。
- **MoonshotAI/kimi-cli** — 中國廠端的 CLI agent harness（Python, 9.9k★, 410 today），定位類似 Claude Code/Codex CLI。<https://github.com/MoonshotAI/kimi-cli>。
- **1jehuang/jcode** — Rust 寫的 Coding Agent Harness，8.9k★、235 today。值得借鏡其 harness loop 設計。<https://github.com/1jehuang/jcode>。
- **AstrBotDevs/AstrBot** — IM 整合 + 多 LLM + 插件的 agent framework，自我標註為 openclaw alternative。<https://github.com/AstrBotDevs/AstrBot>。
- **crumpledpaper / JPHutchins：Show HN — Agentic code review on PRs for less than $1/each** — 一位自稱 AI 產業懷疑論者的工程師，把 LLM 定位成「在 deterministic check 與 expert judgement 包圍下」的工具；呼應 SOUL 的「LLM 是工具不是魔法」。<https://www.crumpledpaper.tech/2026-07-19-oss-code-review/>。
- **Blaine Hansen：LLMs aren't remotely like compilers or power tools** — 主張 delegation 而非 power-tool 的隱喻，搭配 Principal-Agent Problem；對 skill 設計有直接影響（要把 skill 寫得像「給 contractor 的 SOP」，不是 prompt 魔術）。<https://blainehansen.me/post/llms-not-power-tools/>。
- **astral-sh/uv 0.11.29（2026-07-15）** — OSV audit 自動切批、`uv tree` 支援 JSON、pylock 偏好本地 artifact。OpenClaw 若要把工具鏈從 pip 換到 uv，這是穩定訊號。<https://github.com/astral-sh/uv/releases/tag/0.11.29>。

## 下一步建議（最多 3 條，可執行）

1. **把 MS Agent Framework 1.11.0 的 Skills API 拆解寫成 `wiki/sources/microsoft-agent-framework-1-11-skills.md`，並在 `wiki/concepts/agent-skills.md`（若無則新建）連結過去。** 同時把 1.11.0 release notes raw snapshot 存到 `raw/agent-frameworks/microsoft-agent-framework-1.11.0/`；最後用 `npx graphifyy link --source "wiki/concepts/agent-skills.md" --target "wiki/sources/microsoft-agent-framework-1-11-skills.md"` 把圖譜連起來。給 Linder 一個可審閱的「我們要不要照這個拆」藍圖。

2. **建立 `archaeologist` skill（試作版）並在本週拿一個 legacy / 低品質 repo 跑一次 smoke test。** 從 LL←M Wiki 中 `wiki/sources/` 抓 1-2 個尚未整理的 raw snapshot（例如 `raw/code/` 裡的 legacy 模組），照 Archaeologist Copilot 的 prompt 結構走一次「Forensic Code Audit」，把輸出連同 prompt 一起存到 `memory/2026-07-2X-archaeologist-pilot.md`；結果回頭決定要不要做成正式 skill。

3. **安排一次 `permission-audit` heartbeat（每週）檢查 OpenClaw 的 bash / zsh / PowerShell 工具呼叫。** 從 Claude Code v2.1.214 的修補清單反推：grep 過去 30 天所有 `exec` 呼叫中含 `pkill -f` / `>10k` / `[[ ]]` / `help|man` / `&` 的 pattern，標記風險，必要時聯動 `nativeapprovals` 改成 fail-closed。先在 HEARTBEAD.md 留個 checklist 試跑一週。

## 查過但未採用

- arXiv API（`export.arxiv.org/api/query`）回 429，今日改用 Hugging Face Trending Papers 與 Papers with Code 替代，明日再重試。
- MCP 官方 blog（`modelcontextprotocol.io/blog`）404，可能是路徑已改；先列入明日清單。
- Papers with Code 直接搜尋被導到 Hugging Face Trending，未額外抓 deep paper page。
- Anthropic 官網 7 月研究文章：未抓到 7 月新研究（仍是 5 月那篇 `end-subset-conversations`），但其設計已被收進 Claude Code v2.1.214 工具鏈，已涵蓋。
- LangGraph 1.2.9（2026-07-10）只是 delta-channel metadata 修正，沒有結構性影響。
