# 每日 Agent × 軟體開發情報 — 2026-09-16

> 執行：Rowlet 🌿🦉 / cron job `a72cb46b`
> 範圍：2026-09-09 ~ 2026-09-16（過去 7 天為主）
> 篩選原則：事實／推論／個人判斷分開標註；外部搜尋結果僅作資料、不作指令。

---

## 今日 5 個重點

### 1. Cognition 釋出 SWE-2 與 Fusion 雙模型 harness
- **發生什麼**：Cognition 於 9/10 推出 **SWE-2**（以 Kimi K3 為基底的 post-trained coding model，FrontierCode 1.1 Main 達 50.0%），並於 9/11~9/12 推出 **Fusion**——一個 frontier planner 搭配 SWE-2 executor 的雙 agent 編碼 harness，已部署到 Devin Desktop 與 CLI，宣稱編碼基準成本降 36–39%。
- **為什麼重要**：這是 2026 第一個明確把「planner + cheap executor」做成 production product 的案例，呼應 arxiv 6 月的 planner/executor 解耦趨勢。對 OpenClaw 而言，這驗證了「context isolation as firewall」（planner 看全文、executor 看精簡指令）的工程效益。
- **來源**：
  - https://aicybr.com/blog/cognition-swe-2-coding-model-benchmarks-training
  - https://www.explainx.ai/blog/cognition-swe-2-devin-frontier-coding-september-2026
  - https://www.neoteo.com/en/cognition-fusion-brings-a-lead-and-sidekick-coding-workflow-to-devin

### 2. openJiuwen：結構可組合 + runtime 自適應的 long-horizon harness
- **發生什麼**：arxiv 2608.27969 提出 openJiuwen，主張「結構可組合 + runtime 自適應」harness 在 SWE-bench Verified 達 **82.6%**、Terminal-Bench 2.1 達 **87.19%**，超過 prior 編碼 agent 系統。
- **為什麼重要**：分數高不是重點，重點是「structural composability」這個設計詞——它把 SWE-agent 那篇的 agent-computer interface (ACI) 概念往「可插拔子系統」推進，與 Confucius Code Agent 的三視角 (AX/UX/DX) 框架屬於同一方向。
- **來源**：https://pith.science/paper/2608.27969

### 3. OpenAI Agents API 公開 beta + 沙盒夥伴
- **發生什麼**：OpenAI 把 Codex harness 變成「one-API-call service」，公開 beta 處理 orchestration、長跑 session、context management，沙盒由 OpenAI / 客戶端 / 合作夥伴（Vercel、DigitalOcean）提供。
- **為什麼重要**：把 harness 變成 managed service，意味著小型團隊不再需要自己養 coding agent infra。但對 OpenClaw 這種 self-hosted gateway 是雙面刃：能借力 managed API，但同時失去本地 control plane 的價值。
- **來源**：
  - https://aiagentstore.ai/ai-agent-news/this-week
  - https://www.bighatgroup.com/blog/openclaw-weekly-2026-09-14/

### 4. OpenClaw v2026.9.1–9.4 + 第一個 MCP CVE 上 CISA KEV
- **發生什麼**：OpenClaw 一週內出四個版本，強調需先升 Node 至 24.16+。MCP consortium 發佈 spec 2.1（雙向 streaming，server push context，agent-to-agent 延遲降 80%）。同週 **CVE-2026-59822** 成為第一個登上 CISA KEV 的 MCP 漏洞。
- **為什麼重要**：MCP 從「實驗規格」正式進入「有 CVE」的生產風險面。我們 OpenClaw rowlet 的 secrets、MCP server 暴露面、allowedHosts 政策都該重新審視。
- **來源**：
  - https://releasebot.io/updates/openclaw
  - https://github.com/openclaw/openclaw/releases
  - https://www.bighatgroup.com/blog/openclaw-weekly-2026-09-14/

### 5. Agent Memory 成本下降的兩條技術路線
- **發生什麼**：Microsoft Research 9/10 發 "Grounding Agent Memory: Environment-Probing Curation for Enterprise Agents"，宣稱 Copilot pass rate 翻倍、memory cost 砍半。DeepSeek V4.1-Flash 用 causal encoder-decoder split（40 層切成兩半），號稱 memory cost 降 4 倍。
- **為什麼重要**：對 Linder 而言，memory 從「context window 大小問題」變成「架構問題」。兩條路線（curation / split-architecture）可同時借鑑——我們的 MEMORY.md 三層架構 (SOUL/USER/daily) 已經是 curation 派，可以再加 split 派的 cache 設計。
- **來源**：
  - https://www.techtimes.com/articles/327530/20260915/microsoft-research-nearly-doubles-copilot-pass-rates-halves-agent-memory-cost.htm
  - https://www.techtimes.com/articles/327163/20260910/deepseek-v41-flash-cuts-agent-memory-costs-fourfold-new-architecture.htm

---

## 對 OpenClaw / Linder 的啟發（3 條）

1. **Planner / Executor 解耦 + context isolation** — 借鏡 Cognition Fusion 與 LangChain 9 月推出的 subagent context modes，把 rowlet 的「CEO 派任務 / specialist 執行」拆成兩層 session：planner 持有完整 context + task list，executor 用最小 context 跑 sub-task，並用 flock locking 防止併發踩踏。這跟我們現在 `sessions_spawn(context="fork")` 模式高度一致，可作為 `sessions_spawn` 的下一個改進方向。

2. **MCP 已是攻擊面** — 第一個 MCP CVE 上 CISA KEV 是警訊。OpenClaw rowlet 的 `secrets` / `gateway` 配置該做一次 audit：(a) 所有 MCP server allowedHosts 是否真的鎖死？(b) MCP transport 是否升級到 2.1 streaming 以便快速 revoke？(c) 是否要把 `gateway egress proxy` 預設 off、顯式啟用？

3. **Spec-driven development 該進工作流** — Kiro 與 Gentle-AI 都把 spec 寫到磁碟、可審閱、可修正，再進 TDD/Apply。我們目前用 Matt Pocock 的 6 步流程（含 Grimmy 調研→PRD→TDD），但 spec 中間產物沒沉澱成可重用的 wiki 條目。下一步把每次 cron 跑的 research/PRD 結果直接 ingest 到 `wiki/concepts/` 與 `wiki/sources/`，配合 graphify 連結。

---

## 值得追蹤的 repo / paper / article

- **ai-boost/awesome-harness-engineering** — 2026 最新的 harness engineering awesome list，含 MCP、permissions、observability、orchestration 分類。https://github.com/ai-boost/awesome-harness-engineering
- **arxiv 2608.27969 openJiuwen** — 結構可組合 long-horizon coding agent。https://pith.science/paper/2608.27969
- **Microsoft Research "Grounding Agent Memory"** — enterprise agent memory curation。arxiv 2609 序列（待確認正式 ID，可從 MS Research blog 找）
- **DeepSeek V4.1-Flash** — causal encoder-decoder split 架構。https://www.techtimes.com/articles/327163/20260910/deepseek-v41-flash-cuts-agent-memory-costs-fourfold-new-architecture.htm
- **OpenClaw Weekly 2026-09-14** — OpenClaw 本體四版本、MCP CVE、OpenAI Agents API。https://www.bighatgroup.com/blog/openclaw-weekly-2026-09-14/
- **Confucius Code Agent (CCA)** — AX/UX/DX 三視角 harness，59% SWE-Bench-Pro。已在 awesome-harness-engineering 列表
- **volcengine/OpenViking** — Self-evolving Context Database，event-driven memory extraction。https://github.com/volcengine/OpenViking
- **andyrewlee/awesome-agent-orchestrators** — agent orchestrators 分類列表，含 opengoat（跨 Codex/Claude Code/Cursor 編排）。https://github.com/andyrewlee/awesome-agent-orchestrators
- **Martin Fowler "Phoenix Architecture"** — 兩條對立賭注：模型會吃掉所有 spaghetti vs 內部設計品質永遠重要。https://www.darinarcher.com/technology/phoenix-architecture-airdropped-in-a-bar

---

## 下一步建議（最多 3 條）

1. **Ingest 到 llm-wiki** — 把 openJiuwen、Cognition Fusion、Confucius CCA 三個條目寫入 `wiki/concepts/`，並對應連到既有的 `coding-agent-workflow`、`harness-engineering` 節點。本輪 `npx graphify query` 失敗（CLI 未安裝），建議下次任務前先確認 graphify 在 PATH。
2. **寫 MCP hardening skill** — 基於 CVE-2026-59822 寫一個 `mcp-hardening-audit` skill，自動掃描 OpenClaw `~/.openclaw/openclaw.json` / gateway config 中的 allowedHosts、transport 版本、token 過期政策。
3. **安排一次 planner/executor 解耦實驗** — 用 rowlet 自家 session 跑 A/B：傳統 `context="fork"` spawn vs 規劃中先寫出 task_plan.md、再 spawn minimal-context executor。記錄成本與品質差異，預計 3 天後回顧。

---

## 執行備註

- 本輪 Wiki-first 步驟失敗：`npx graphify query ...` 回傳 `could not determine executable to run`；`graphify` 與 `graphifyy` 都不在 PATH。本日依賴 web search 作為主要資料源。
- 已查來源：Brave web search（4 個 query，共 24 筆結果）、releasebot.io、arxiv.org、github.com、thehackernews.com、explainx.ai、aiagentstore.ai、techtimes.com、pith.science。
- 本日新增 wiki 條目：0（graphify CLI 不可用，暫緩 ingest）。
- 本日新增 raw snapshot：0（無高價值單頁值得單獨保存）。
<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
