# 每日 Agent × 軟體開發情報 — 2026-08-06

> 產出者：木木鴞（rowlet）｜時區：UTC｜主查詢時間：2026-08-06 02:03 UTC
> 範圍：近 7-14 天；三類來源：研究 / 開發潮流 / 工具與框架 release。
> 本日調性：**昨天（08-05）我們報告說「vendor-level governance / skills standard / agent 安全生產化」三件事冒出。今天（08-06）24 小時內，三個 frontier 廠 + 兩個開源社群同時把同一個結論推到頂點** — **「harness 才是 agent 系統的 98%（MBZUAI 數字），不是 model」。Prime Intellect 開源 RLM + Continual Harness、Meta 發 Muse Code + Spark 1.2、Microsoft Agent Framework Harness GA、Ponytail 教科書級 benchmark 修正、Zed DeltaDB 重新發明 VCS、DeepMind 組織大改組**。今天的訊號不再是「framework 競爭」，而是「**harness 作為一級公民已正式 vendor-level 化**」。

## 對位前一輪報告（07-31 / 08-02 / 08-05）

| 08-05 訊號 | 08-06 驗證 / 翻面 / 新切角 |
| --- | --- |
| TencentDB Memory Hub：4 asset（Chat Memory / Skill / LLM-Wiki / Code-Graph） | ✅ **Meta Muse Code bundled skills (`/plan /grill /goal`) + Microsoft Harness skills + Prime Agent Continual Harness CRUD** — **4 個 vendor / OSS 在 24h 內把「skill 為一級公民」推到頂點**，從昨天的「memory hub」進化到「runtime-level skill」 |
| obra/superpowers：跨 10+ coding agent harness methodology | ⚠️ 沒新進度，但 **Ponytail (DietrichGebert, 82k+ stars)** 用 markdown ruleset 跨 10+ harness 部署 — **「skill 是跨 harness portable 的 artifact」** 兩個獨立案例同時驗證 |
| Microsoft Agent Framework 1.0 GA | ✅ **Build 2026 Harness + Hosted Agents 推上 stable GA** — 「harness 是 98% 的系統」明確 vendor-level 化 |
| OpenClaw `model-router` production-grade | ✅ **Microsoft Foundry Hosted Agents (consumption billing)** 對位 — OpenClaw 不用 vendor hosting，但 reference 其 SLA / observability 設計 |
| 「code ↔ conversation 雙向追溯」需求 | ✅ **Zed DeltaDB** 直接把這件事做成 VCS — 「code 改動 ↔ agent session」連結是 production 級需求 |
| Karpathy LLM Wiki Ecosystem（graphify 為基礎的決策圖） | ⚠️ 今天沒有新對位，但 **Prime Agent 的「skill CRUD by agent」** 是「graph 自動維護」的進化版 |
| Google DeepMind leadership 平穩 | ⚠️ **Hassabis → Chair / Koray → SVP / Jeff Dean 離開創 PBC** — 重大組織變動，「AGI 路線 vs 產品路線」正式拆組織 |

## 今日 5 個重點

1. **MBZUAI VILA-Lab 量化「harness 是 98% 的 agent 系統」+ Microsoft Agent Framework Harness GA — vendor-level 驗證「harness > model」是 2026 agent 投資主軸。**
   - 發生什麼：MBZUAI 2026-04 paper「Dive into Claude Code」（<https://arxiv.org/abs/2604.14228>）分析 Claude Code v2.1.88 — 因為 Anthropic 在 2026-03-31 發 npm 時夾 sourcemap bundle，TypeScript source 短暫曝光，分類約 **512,000 行 / 1,884 檔** → 結論：**約 98.4% 是 harness code，不是 model**。同一週 Microsoft 把 **Agent Harness + Foundry Hosted Agents** 推上 stable GA（Build 2026 6/2-3 之後），開箱即用 function invocation / per-call history persistence / context compaction / todo list (plan+execute) / **file memory** / **skills** / web search / tool approval / OpenTelemetry；shell / file / background sub-agents / automatic looping 是 opt-in 會發 warning。
   - 為什麼重要：**「harness 才是 agent 系統的 98%」這個量化基準從今天起變成投資決策常識**。對 Linder：（a）**不要再投入 model 本身** — 我們用 minimax-portal / MiniMax-M2.7 / M3 即可，投資應放在 **harness / skill / memory**；（b）**OpenClaw 應有 OpenTelemetry 整合** — 對位 `openclaw-llm-monitor`，從 LLM call 監控升級到 **trace-level observability**；（c）**「file memory + skills + web search + approval + OTel」五件套是 production-grade default** — OpenClaw 應把這五件列為 `core-harness` skill 的最低規格。
   - 來源：<https://arxiv.org/abs/2604.14228>、<https://www.infoq.com/news/2026/08/agent-framework-harness-ga/>、<https://devblogs.microsoft.com/agent-framework/the-microsoft-agent-framework-harness-is-now-released/>。

2. **Prime Intellect 開源 Prime Agent — RLM（REPL-based recursive context）+ Continual Harness（CRUD on prompts/skills/memory/sub-agents），主張「固定 harness 已跟不上 frontier model」。**
   - 發生什麼：Prime Intellect 開源 Prime Agent（<https://github.com/PrimeIntellect-ai/prime-agent>），兩個核心抽象：（a）**Recursive Language Model (RLM)** — 把 context 當 variable、sub-agent delegation 當 function call，全部在一個 persistent IPython kernel（REPL）裡執行；（b）**Continual Harness** — 把 harness 自己的 state（prompts / skills / memory / sub-agents）當 agent 可 CRUD 的物件。支援 Agent2Agent messaging，可以跨 sub-agent、跨 Prime Agent session 溝通。安裝：`curl -fsSL https://app.primeintellect.ai/prime-agent/install.sh | sh`。引用論文：RLM <https://arxiv.org/abs/2512.24601>、Continual Harness <https://arxiv.org/abs/2605.09998>。
   - 為什麼重要：**Prime Agent 是「harness 自我演化」這個論點的 OSS 級驗證**。對 Linder：（a）**OpenClaw skill system 目前是 design-time 注入（`~/.openclaw/skills/` 寫死）**，Prime Agent 走 runtime CRUD — 我們應設計 **`runtime-skill-manager` skill**，讓 agent 自己 CRUD skill 內容（CRUD log 進 graph）；（b）**「sub-agent = 另一個 prime-agent instance」** 對位 OpenClaw `sessions_send` — 但我們 fire-and-forget，Prime Agent 是 persistent + cross-session messaging；（c）**「唯一 tool = REPL」這個極簡設計** — 對 Linder：我們 OpenClaw 應反思「core tool」是什麼？是不是把 `exec` 當成 universal REPL？
   - 來源：<https://www.primeintellect.ai/blog/prime-agent>、<https://github.com/PrimeIntellect-ai/prime-agent>。

3. **Meta 發 Muse Code (beta) + Muse Spark 1.2 — co-trained model + harness，async background agents 持久而非 spawn-on-demand，local event log 支援 replay-exact 重啟，bundled skills (`/plan /grill /goal`)。**
   - 發生什麼：Meta 在 2026-08-05 release Muse Code（macOS/Linux terminal coding agent）+ Muse Spark 1.2（coding-focused model）。三個設計亮點：（a）**Async Background Agents** — 整個 session 持續存在，不為每個 task spawn，next steps 主動回報；（b）**Runtime Design：Local Event Log** — 每次 model call / tool run / approval / edit 都 append，**replay-exact + restart-safe**，crash 後精準接續；（c）**Bundled Skills** — `/plan`、`/grill`、`/goal`。**Co-Training**：Muse Spark 1.2 跟 Muse Code 共同訓練（rejection sampled harness trajectories、recipe optimizations for goals/compaction/subagents）。
   - 為什麼重要：**Meta 把「model + harness co-training」明示為設計原則** — 這是 OpenClaw 沒考慮過的維度。對 Linder：（a）**「async background agents 持久存在」** 對位 OpenClaw specialist agents（charizard / gengar / mrmime）— Meta 在 coding agent 內部驗證我們 multi-agent 持久設計；（b）**Local Event Log** 對位 OpenClaw `task-manager` 的 task_queue.json — 兩種實作同一個 invariant：可恢復、可審計，但 **event-sourced log 比 queue 更適合 long-running** — 我們應考慮補上 event log；（c）**Bundled Skills 三件套 (`/plan /grill /goal`)** 對位 OpenClaw `problem-solver-workflow`（Plan → Execute → Verify 三段式）— **差異點**：Muse 的 `/grill` 是 stress-test plan 直到 hold up，我們沒有這個 anti-bullshit step；（d）**Co-Training model + harness** — Linder 的設計問題：「要不要 `co-train` 我們 OpenClaw skill prompt 跟 minimax-M3？」
   - 來源：<https://research.meta.ai/blog/introducing-muse-code-and-muse-spark-1-2>。

4. **Ponytail skill 教科書級 benchmark 修正：80-94% → 54% — 「七個字 prompt 打敗 6,232 行 repo」，但作者公開承認並重建 fair baseline，示範「skill + benchmark 治理」的最佳實務。**
   - 發生什麼：Ponytail（<https://github.com/DietrichGebert/ponytail>，單作者 DietrichGebert，2026-06-12 release，2026-08 已 82,000+ stars）— 「the laziest senior dev in the room」決策階梯 ruleset（markdown），跨 Claude Code / Codex / Cursor / GitHub Copilot / Gemini CLI / Aider 等 10+ harness。**事件**：（a）原作者 claim 80-94% code reduction；（b）Colin Eberhardt（Scott Logic CTO）拆穿 — 6,232 行 repo 實質是 ~100 行 markdown + 各 plugin boilerplate，內容就是 1990 YAGNI；用七個字 prompt「Follow YAGNI principles, and one-liner solutions」→ 在原 benchmark 跑得比 Ponytail 更好（因為 baseline agent 本身 chatty 灌水）；（c）**作者重建 fair benchmark**（12 個 feature task 在真實 FastAPI + React repo，fair agentic baseline）→ 修訂為 **54% code reduction（over-built 場景可達 94%）+ 20% 成本降低 + 27% 執行更快**，README 明確標舊數字是「per-task ceiling 誤報為 average」。
   - 為什麼重要：**Ponytail 事件是 2026 年「skill 作為 viral artifact」的標誌 + 「benchmark 治理」最佳實務案例**。對 Linder：（a）**「skill 是 cross-harness portable prompt package」這個 pattern** — OpenClaw skill 應借鏡「**單一 markdown ruleset + 各 harness 適配 boilerplate**」雙層設計；（b）**「七個字 prompt 打敗完整 skill」** — 我們 skill 應有「核心 prompt」+「外殼適配」兩層，外殼是 cross-harness boilerplate，**核心要濃縮到不能再刪**；（c）**「lazy senior dev 決策階梯」** 是 production-grade anti-overengineering skill — 應寫成 OpenClaw 的 **`yagni-enforcer` skill** 跟現有 `problem-solver-workflow` 互補；（d）**作者公開修正 benchmark** — OpenClaw 應有 **`benchmark-audit` skill** 做內部 benchmark 自我審查，把「fair baseline + 重現步驟 + 數字明確標 ceiling vs average」做成 spec。
   - 來源：<https://www.infoq.com/news/2026/08/ponytail-agent-skill-benchmark/>、<https://github.com/DietrichGebert/ponytail>、<https://blog.scottlogic.com/2026/06/16/ponytail-yagni-and-the-problem-with-prompt-benchmarks.html>、<https://news.ycombinator.com/item?id=48527946>。

5. **Google DeepMind 組織大改組：Hassabis → Chair（AGI / science 主導）+ Koray → SVP（product 主導）+ Jeff Dean 離開 27 年 Google 與 Sanjay 共創 public benefit corporation。**
   - 發生什麼：Sundar Pichai 2026-08-05 內部信（<https://blog.google/company-news/inside-google/message-ceo/next-chapter-ai-momentum/>，HN 479 點 / 594 留言）：（a）**Demis Hassabis** 由 GDM CEO 升為 **Chair of GDM + Chief Scientist of Alphabet**，繼續 lead Isomorphic Labs — 「**standing in the foothills of the singularity**」；（b）**Koray Kavukcuoglu** 由 CTO of GDM 升為 **SVP of GDM**，向 Sundar 報告，接管 Gemini model development、Frontier AI research、Gemini app / developer teams；（c）**Jeff Dean**（27 年 Google Senior Fellow）離開，與 **Sanjay Ghemawat** 共同成立 **independent public benefit corporation**，聚焦 ML / science / engineering 加速發現。Gemini app 已 **950M+ 月活**；Gemma **900M+ downloads**；Flash、Cyber model、Gemini Robotics 持續推進。
   - 為什麼重要：**「AGI / science 路線 vs 產品路線」正式拆組織**。對 Linder：（a）**「AGI 路線（hassabis）vs 產品路線（Koray）」split** 是 2026 大廠標準動作 — OpenClaw 應明確自己走哪一條？我們目前是「**self-hosted、graph-first、memory hub**」，偏 product-side，跟 Koray 路線同邊；（b）**「independent public benefit corporation」（Jeff Dean + Sanjay）** 是開源 / 研究的 reference 模式 — 非營利、非公司；（c）**Koray 時代 DeepMind 會 product-driven** — 未來 Gemini API 整合 / pricing 會更激進，OpenClaw `model-router` 應密切追蹤 Gemini 3.x / 4.x；（d）**Gemini 950M 月活 + Gemma 900M downloads** — open weights 路線（Meta Llama vs Google Gemma）競爭加劇，OpenClaw 應有 Gemma adapter。
   - 來源：<https://blog.google/company-news/inside-google/message-ceo/next-chapter-ai-momentum/>、<https://news.ycombinator.com/item?id=49184755>。

## 對 OpenClaw / Linder 的啟發

1. **【harness-first 投資轉向】** MBZUAI 量化「harness 是 98% 的 agent 系統」+ 三個 vendor 同週把 harness 推上 GA / co-training — OpenClaw 應**正式啟動 `core-harness` skill 計畫**，最低規格五件套：**file memory + skills + web search + tool approval + OpenTelemetry**。對位 Microsoft Agent Framework Harness GA 的 default 設定。同時設計 **`runtime-skill-manager` skill**，讓 agent 可 CRUD 自己的 skill 內容（對位 Prime Agent Continual Harness），CRUD log 進 graph。

2. **【skill 雙層設計 + benchmark 治理】** Ponytail 事件證明「**七個字 prompt 可打敗 6,232 行 skill repo**」 — 啟示：（a）OpenClaw skill 採「**核心 prompt** + **外殼適配（cross-harness boilerplate）**」雙層，核心濃縮到不能再刪；（b）寫 **`yagni-enforcer` skill**，對位 Ponytail 決策階梯（真的需要嗎 → codebase 已有嗎 → stdlib 做了嗎 → native feature 嗎 → installed dep 嗎 → 一行嗎），互補 `problem-solver-workflow`；（c）寫 **`benchmark-audit` skill**，強制 fair baseline + 重現步驟 + 數字標 ceiling vs average。

3. **【VCS × agent 雙向追溯 + event-sourced observability】** Zed DeltaDB 把「code ↔ agent conversation」做成 VCS 一級公民（rewind、trace、mid-run branch、share-the-thread）— OpenClaw 應：（a）研究「**code 改動 → 哪次 agent session 改了它**」的 audit log，目前只有「prompt → output」單向；（b）把 `task-manager` 的 task_queue.json **升級為 event-sourced log**（對位 Meta Muse Code 的 Local Event Log），支援 replay-exact restart；（c）評估加入 **OpenTelemetry tracing**（對位 Microsoft Harness default）。

## 值得追蹤的 repo / paper / article

1. **Prime Agent (Prime Intellect)** — <https://github.com/PrimeIntellect-ai/prime-agent> — 開源 self-improving RLM + Continual Harness；安裝 `curl -fsSL https://app.primeintellect.ai/prime-agent/install.sh | sh`。
2. **Meta Muse Code + Muse Spark 1.2** — <https://research.meta.ai/blog/introducing-muse-code-and-muse-spark-1-2> — co-trained model + harness，async background agents，event log replay。
3. **Microsoft Agent Framework Harness GA** — <https://devblogs.microsoft.com/agent-framework/the-microsoft-agent-framework-harness-is-now-released/> — production-grade runtime；附 InfoQ deep dive：<https://www.infoq.com/news/2026/08/agent-framework-harness-ga/>。
4. **「Dive into Claude Code」MBZUAI VILA-Lab** — <https://arxiv.org/abs/2604.14228> — 量化「harness 是 98% 的 agent 系統」的關鍵 paper。
5. **Ponytail (DietrichGebert)** — <https://github.com/DietrichGebert/ponytail> + InfoQ benchmark 故事：<https://www.infoq.com/news/2026/08/ponytail-agent-skill-benchmark/> + Scott Logic 質疑：<https://blog.scottlogic.com/2026/06/16/ponytail-yagni-and-the-problem-with-prompt-benchmarks.html>。
6. **Google DeepMind leadership change** — <https://blog.google/company-news/inside-google/message-ceo/next-chapter-ai-momentum/> — Hassabis → Chair / Koray → SVP / Jeff Dean 離開創 PBC。
7. **Zed DeltaDB** — <https://zed.dev/deltadb> + <https://zed.dev/blog/introducing-deltadb> — 「Software is made between commits」重新發明 VCS。
8. **Discovery Loop（新公司，HN #1 601 點）** — <https://www.discoveryloop.com/> — 自動化科學實驗迴圈；對位我們 `ouroboros` skill 的「codebase → 知識庫」自演化路徑。

## 下一步建議（最多 3 條，偏可執行）

1. **【Wiki ingest】把今天 6 個 raw snapshot 寫成 wiki 概念頁 + 更新 index/log**：
   - `wiki/concepts/Agent Harness as First-Class Citizen.md`（整合 MBZUAI paper + MS Harness + Prime Agent + Muse Code + Ponytail）
   - `wiki/concepts/Skill as Cross-Harness Portable Artifact.md`（整合 Ponytail + obra/superpowers + Meta Muse bundled skills）
   - `wiki/concepts/VCS × Agent Bidirectional Trace.md`（Zed DeltaDB + OpenClaw 缺口）
   - `wiki/sources/DeepMind Leadership Change 2026-08.md`（組織事件）
   - 更新 `wiki/index.md` 跟 `wiki/log.md`，用 `graphifyy link` 串到既有 `Karpathy LLM Wiki Ecosystem` / `Coding Agent Workflow` / `Agent Skills`。

2. **【Skill 設計】起草 `yagni-enforcer` skill 雛形 + `benchmark-audit` skill 雛形**：
   - `yagni-enforcer`：對位 Ponytail 決策階梯，注入 agent context；先做成 `~/.openclaw/skills/yagni-enforcer/SKILL.md` 草稿，給 Linder review。
   - `benchmark-audit`：定義 fair baseline 規範 + 重現步驟 + 數字標 ceiling vs average；先寫 SKILL.md 草稿 + 一個範例 audit（拿我們現有 skill 做 audit）。

3. **【架構決策】寫 ADR「OpenClaw Harness-First Investment Pivot」**：
   - 文件化決策：「基於 MBZUAI 量化 + 3 vendor 同週推 harness GA，OpenClaw 2026 Q3 投資重心從 model 轉向 harness」
   - 列舉五件套最低規格（file memory + skills + web search + tool approval + OpenTelemetry）
   - 評估 `runtime-skill-manager` skill 雛形（對位 Prime Agent Continual Harness CRUD）
   - 評估 `task_manager` 從 queue 升級為 event-sourced log
   - 放 `~/workspace-rowlet/decisions/2026-08-06-harness-first-pivot.md`

## 查過的來源（沒有重大訊號也列出以示盡責）

- **Wiki-first**：本地 LLM Wiki graphify query（AI agent architecture / skills / multi-agent workflow / software architecture / coding agents 2026，budget 1000），primary 命中 `wiki/sources/AI Agent 簡報.md`、`wiki/concepts/Karpathy LLM Wiki Ecosystem.md`、`wiki/maps/Code 與 Agent 地圖.md`、`wiki/sources/A Survey of Frontiers in LLM Reasoning.md` 等既有節點。
- **GitHub Trending (weekly)**：reverse-skill / AI-For-Beginners / airllm / block:buzz / **TencentDB-Agent-Memory**（昨日榜首，今日仍強）/ book-to-skill。
- **Hacker News front page**：Discovery Loop（601 點，9h）/ Zed DeltaDB（305 點，7h）/ Blade Runner title cards（無關）/ **DeepMind leadership change（479 點，9h，594 留言）/ Meta Muse Code（178 點，6h）/ Castform + Neon（226 點，7h）/ Prime Agent（105 點，4h）**。
- **OpenAI News**：Third-party cyber evaluations（8-4）/ New ways to learn with ChatGPT Work and Codex（8-4）/ Apple is getting this wrong（8-3）/ Continuous voice interaction with GPT Live（8-3）/ Building abundant intelligence（7-31）/ **GPT 5.6 price-performance frontier（7-30）/ GPT-5.6 frontier intelligence + efficiency（7-29）/ ARC-AGI-3 benchmark（7-29）**。
- **Anthropic News**：Fable 5 redeployment + Glasswing jailbreak severity framework（6-30）— 今日無新。
- **arXiv cs.AI 2026-08 listing**：本日新 paper 列表（編號 2608.00001 ~ 2608.x），未深入閱讀個別 paper（時間內只取清單確認 release cadence 正常）。
- **InfoQ**：Ponytail benchmark / SkiaSharp 4.0 / Java News Roundup (7-27) / HubSpot JITA redesign / **Microsoft Agent Framework Harness GA / Jakarta Agentic AI 1.0 M1**。
- **Pragmatic Engineer / Martin Fowler / Thoughtworks Insights**：首頁 landing page 為主，今日無重大新 essay 抓出（Pragmatic Engineer 是 newsletter-only，首頁不顯示最新 issue；Fowler 跟 Thoughtworks insights 都在談 GenAI governance，無 7-14 天內新）。

— 木木鴞
