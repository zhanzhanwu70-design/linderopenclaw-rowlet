# 每日 Agent × 軟體開發情報 — 2026-06-28

> 增強版（02:16 UTC 補完）。02:04 基礎版已存檔；本次新增 OpenClaw 自家 6.10/6.11 release 與 Google《New SDLC with Vibe Coding》白皮書兩個被忽略的強信號。

## 今日 5 個重點

### 1. OpenClaw 連發 6.10 / 6.11 — channel 控制、模型路由、fast-mode 全面強化
**發生什麼**：v2026.6.10（6/22 beta → 6/24 stable）加入「Automatic fast mode」(`/fast auto`)，短對話快啟、長任務自動 fallback，並在 status 顯示「effective state」而非 on/off；v2026.6.11（6/24）補上 Slack relay、原生 Mattermost `/oc_queue`、per-DM model overrides、`openclaw agent --message-file` 與 RAFT CLI wake bridge；official plugins 全面 externalize。
**為什麼重要**：OpenClaw 的工程重心明顯從「再加 provider」轉向「channel-aware routing + 快速對話 + 操作員 file/CLI workflow」。這直接影響 Skill 與 cron 的設計——per-DM model overrides 讓 specialist agent 調度更細緻。
**來源**：`https://github.com/openclaw/openclaw/releases/tag/v2026.6.11`、`https://github.com/openclaw/openclaw/releases/tag/v2026.6.10`

---

### 2. Google 發布《New SDLC with Vibe Coding》白皮書 —「Agent = Model + Harness」定調
**發生什麼**：Addy Osmani、Shubham Saboo、Sokratis Kartakis 共同撰寫，Google 發布。核心論點：agent 10% 是 model、90% 是 harness（rule files、MCP servers、sandboxes、orchestration、hooks、observability）。公開數據佐證：Terminal Bench 2.0 上某團隊只改 harness、不換 model，從 top 30 之外衝進 top 5。
**為什麼重要**：這是 2026 上半年最重要的「agent 架構宣言」——把業界敘事從「model race」轉回「harness engineering race」。對 OpenClaw 體系是直接背書：所有投在 skill、cron、hooks、log 上的工都是高槓桿投資。
**來源**：`https://addyosmani.com/blog/new-sdlc-vibe-coding/`（白皮書本體 `https://www.kaggle.com/whitepaper-the-new-SDLC-with-vibe-coding`，被 reCAPTCHA 擋）

---

### 3. mini-SWE-agent：100 行 Python，SWB-bench >74%，已進入 Meta/NVIDIA/IBM 產線
**發生什麼**：Princeton + Stanford SWE-agent 團隊發布 mini-SWE-agent，約 100 行 Python，於 SWE-bench verified 達 >74%，現已驅動 Ramp 內部 SWE workflow，並在 DeepSWE 評測擊敗 Claude Code 與 Codex。已被 Meta、NVIDIA、IBM、Essential AI 等採用。
**為什麼重要**：coding agent 的極簡化趨勢得到 production 驗證。100 行擊敗複雜系統這件事，配合 Google 白皮書的 10/90 框架，給出訊號：**對 OpenClaw skill 設計應全面反思「哪些複雜度真的有必要」**。
**來源**：`https://github.com/SWE-agent/mini-SWE-agent`

---

### 4. Open Interpreter 重寫為 Rust，主打「低價模型 + 跨 harness」
**發生什麼**：Open Interpreter 從 Python 全面遷移 Rust，提供 `i` 或 `interpreter` 命令。`/harness` 可切換 native / claude-code / kimi-cli / qwen-code / deepseek-tui / swe-agent / minimal 七種 harness；內建 QA skill 可操控瀏覽器與原生 app。
**為什麼重要**：coding agent 的執行層正在 Rust 化、harness 正在 pluggable 化。對 OpenClaw 啟示：若要本地 long-running agent runtime，Rust 是合理方向；harness pluggable 模式也是 OpenClaw skill 系統的演化方向。
**來源**：`https://github.com/openinterpreter/openinterpreter`

---

### 5. MCP 生態：10+ SDK 語言 + Cognee 推出 `@cognee/cognee-openclaw` 插件
**發生什麼**：Model Context Protocol 已有 TypeScript、Python、Java、Kotlin、C#、Go、PHP、Ruby、Rust、Swift 共 10 個官方 SDK。Cognee（開源 AI 記憶平台）發布 OpenClaw 專用插件，可直接接 LLM Wiki 圖譜。
**為什麼重要**：MCP 已成跨框架 tool 互通的事實標準；Cognee 主動為 OpenClaw 出插件代表外部生態正式認可 OpenClaw 作為 runtime。OpenClaw skill 系統值得規劃 MCP 化路徑。
**來源**：`https://github.com/modelcontextprotocol`、`https://github.com/topoteretes/cognee`

---

## 對 OpenClaw / Linder 的啟發

**1. Harness > Model — 把 90% 預算放在 skill/hook/cron/channel，不要再追 model swap**
Google 白皮書 + mini-SWE-agent 100 行勝出，這兩條獨立證據指向同一件事。OpenClaw 6.10/6.11 的 fast-mode、per-DM model、RAFT wake bridge 都是這個方向的工程落實。建議：以「harness change 能在 Terminal Bench 2.0 提升多少 rank」作為內部評估指標。

**2. Channel-aware routing 是下一個競爭點 — 善用 6.11 的 per-DM model override + /oc_queue**
Slack relay、Mattermost `/oc_queue`、per-DM model overrides 開啟了「同 session、不同 channel、不同 model」的可能性。對 Rowlet 而言：可以設計 channel-aware specialist routing（Discord → MiniMax-M3、Telegram → M2.7、CLI → 強模型），將 `~/.openclaw/skills/agent-builder-researcher/` 類的 specialist skill 落實到實際 channel 配置上。

**3. Memory 進化：Cognee graph + 既有 MEMORY.md 三層記憶互補**
Cognee 已是 OpenClaw 外部認可的持久化記憶方案。建議在 workspace-rowlet 建一個 pilot：每日 heartbeat 將 `memory/YYYY-MM-DD.md` 增量灌入 Cognee，query 時先用 graph recall、再 fallback 文字記憶。不要全替換，三層架構仍是主幹，graph 是 search 加速層。

---

## 值得追蹤的 Repo / Paper / Article

1. **OpenClaw v2026.6.11 release notes** — Slack relay、Mattermost /oc_queue、RAFT wake bridge
   `https://github.com/openclaw/openclaw/releases/tag/v2026.6.11`

2. **OpenClaw v2026.6.10 release notes** — Automatic fast mode + model routing
   `https://github.com/openclaw/openclaw/releases/tag/v2026.6.10`

3. **Google《New SDLC with Vibe Coding》**（Addy Osmani summary）— Agent = Model + Harness 宣言
   `https://addyosmani.com/blog/new-sdlc-vibe-coding/`

4. **mini-SWE-agent** — 100 行 Python，>74% SWE-bench verified
   `https://github.com/SWE-agent/mini-SWE-agent`

5. **Open Interpreter (Rust 重寫版)** — 7 種 harness 切換、coding agent 新執行層
   `https://github.com/openinterpreter/openinterpreter`

6. **Cognee** + `@cognee/cognee-openclaw` 插件 — 開源 AI 記憶平台
   `https://github.com/topoteretes/cognee`

7. **arXiv:2606.27188 — CUGA FLO Process Harness** — Agentic BPM 理論框架
   `https://arxiv.org/abs/2606.27188`

8. **arXiv:2606.27288 — Multi-Model LLM Systems** — 67 模型研究，MoA 增益天花板
   `https://arxiv.org/abs/2606.27288`

---

## 下一步建議

1. **Channel-aware model routing 實驗**：在 OpenClaw 6.11 的 per-DM model override 基礎上，把 Rowlet 的 specialist skill 綁定到 Discord/Telegram 不同 channel；寫一份 `channel-routing.md` 進 `wiki/concepts/`。這是把今日三個信號（harness > model / channel-aware / skill pluggable）一次性落實的最小實驗。

2. **Cognee graph pilot**：在 workspace-rowlet 開一個 `/memory-graph/` pilot，把昨天 memory 灌進 cognee，看看 query latency 與 recall 改善是否值得常駐。

3. **Ingest 進 llm-wiki**：把 OpenClaw 6.10/6.11 release notes、Google vibe coding 白皮書、mini-SWE-agent README 三份分別存到 `wiki/sources/`，並用 `npx graphifyy link` 建立「Code 與 Agent 地圖」與「Harness Engineering」concept 之間的邊。

---

## 查過的來源（透明度）

- 本地 llm-wiki graphify query（agent / skills / harness / multi-agent / coding agent 2026）✅
- GitHub Trending 2026-06-28 ✅
- arXiv cs.AI 2026-06（2606.x 區段）✅
- Hacker News frontpage top 10（含 AMD Strix Halo / OpenRA / 匿名 GitHub 大量丟卸款 / Fintech Handbook）✅
- OpenClaw releases API（v2026.6.9–6.11）✅
- Addy Osmani「The New Software Lifecycle」部落格 ✅
- MiniMax 新聞頁（內容極少）✅
- Kaggle 白皮書直連（reCAPTCHA 擋，採部落格二手）⚠️

**本日結論**：今日有兩個被前次快速版漏掉的強信號（OpenClaw 自家連發 + Google 白皮書），不是「無新訊號日」。harness > model 的業界敘事已正式成形，OpenClaw 6.10/6.11 是這個敘事的工程化身。