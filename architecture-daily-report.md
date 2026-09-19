# 每日 Agent × 軟體開發情報 — 2026-09-19

> 執行：Rowlet 🌿🦉（cron 每日任務）
> 主題：AI agent / 軟體架構 / 開發方法論 — 最近 7–14 天信號
> 覆蓋來源：本地 llm-wiki graph 命中「AI / Code 與 Agent 地圖」社群 + GitHub Trending + Anthropic / Microsoft / MCP 官方 release + arXiv + 社群深度文

---

## 今日 5 個重點

### 1. Anthropic 把 Claude Code 升級成「Projects + 平行 agent threads + shared memory」
- **發生什麼**：2026-09-17 Anthropic 公開 Claude Code Projects beta，把原本「一個 repo、一個 thread」的工作模型改成一顆 **coordinator** 切派多條 agent thread、共用一份 project memory + 一個共享 file/artifact library，並能跨 thread 驗收成果再組合。`OTEL_LOG_TOOL_DETAILS=1` 也跟著升級：cost / token metric 會帶上真實的 agent / skill / plugin / MCP server 名稱。
- **為什麼重要**：這是「harness 內建 multi-agent」第一次由主要 vendor 用 production 介面推出。對 OpenClaw 的意義：第三方 harness 開始把「共享狀態 + 排程 + 組裝結果」做成一等公民，OpenClaw 在「policy + audit gateway」這層的價值就更明顯（你不再需要自己當 coordinator，但你需要當 gatekeeper）。
- **可信來源**：https://releasebot.io/updates/anthropic/claude、https://venturebeat.com/orchestration/anthropic-launches-claude-code-projects-an-always-on-conversation-that-remembers-and-delegates-your-long-running-dev-work、https://www.unite.ai/anthropic-redesigns-claude-code-projects-to-coordinate-agent-threads/

### 2. MCP SEP-2640「Skills Extension」於 2026-09-13 落地 — Agent Skills 走 MCP Resources 標準化
- **發生什麼**：MCP 官方把 Skills Extension（`io.modelcontextprotocol/skills`）合併到 `modelcontextprotocol/modelcontextprotocol#2640`。Skill 變成 MCP resource，用 `skill://` URI + `skills/list` / `skills/get`（可選 `resources/directory/read`）發現與載入。Microsoft / Goose / schiste/toolhub-evolved / OniMods 等多個 host 都已在各自的 issue 上排程支援。
- **為什麼重要**：Skills 從「各 agent 自己用 markdown 載入」變成 MCP 標準資源。任何 MCP-aware client 都能 plug-and-play 拿到經策展的 skill pack，這正是 OpenClaw 一直在做的「skill workshop」模型下一步正規化。對 Linder 的啟發：未來 6 個月是「skill marketplace 化」的關鍵窗口。
- **可信來源**：https://github.com/microsoft/mcp/issues/3655、https://github.com/schiste/toolhub-evolved/issues/219、https://github.com/aaif-goose/goose/issues/12068、https://github.com/LIghtJUNction/OniMods/issues/30

### 3. Claude Code 2.1.265 修復「gateway 環境被誤導回 Cloud 登入」的 regression + 工具鏈細修
- **發生什麼**：9 月 patch 把 `CLAUDE_CODE_USE_GATEWAY` 在未配 `ANTHROPIC_BASE_URL` + `ANTHROPIC_AUTH_TOKEN` 時強迫走 Cloud-gateway 登入的 regression 修掉（影響自架 LLM gateway / proxy）。同時：artifact link 優先走 Artifact tool 而非 WebFetch、`rm` 危險指令 prompt 改用具名 `${VAR:?}` 提示、Bedrock / Vertex / Foundry 的 auto mode 暫時改用本地 classifier（`CLAUDE_CODE_AUTO_MODE_SERVER=1` 切回平台 classifier）。
- **為什麼重要**：企業部署 Claude Code 的人最容易踩到這個雷；本地 classifier 的回退說明 Anthropic 對「政策分類」這條產品線還在實驗。對 OpenClaw：不只 patch 內容，重點是**模型供應商對 gateway / proxy 的合規性變化要進 Risk & Consequence 評估**。
- **可信來源**：https://releasebot.io/updates/anthropic、https://releasebot.io/updates/anthropic/claude-code、https://github.com/anthropics/claude-code/releases

### 4. GitHub Trending 2026-09-19 確認「agent infrastructure」是今日主流
- **發生什麼**：`kouweizhu/agents-radar` 與多個 mirror 同步發出的 AI Open Source Trends issue 顯示：Claude Code 今日 +444 stars、`affaan-m/ECC`（Engineering Context Compressor）爆量、Tencent BrowserSkill、`Agent-Reach` 全數進榜。報告定調「生態從 prototype agents 走向 production-grade engineering skills 與 harness optimization」。
- **為什麼重要**：每天多個 mirror 同步驗證同樣的訊號代表這不是雜訊而是結構訊號。ECC（context compressor）的爆量剛好對應昨日重點 #3 NVIDIA SoL-Pi 的 4 機制——「context efficiency」是本週共同主題。
- **可信來源**：https://github.com/kouweizhu/agents-radar/issues/102、https://github.com/duanyytop/agents-radar/issues/3343、https://github.com/845421145-lang/agents-radar/issues/76、https://www.josedacruz.com/2026/09/17/top-10-trending-github-repos-this-week-september-9-september-15-2026/

### 5. 三篇值得讀的 arXiv（兩篇 memory / 一篇 honesty）落進本週
- **發生什麼**：
  - **「Quantifying Overclaiming Propensity in Frontier LLM Agents」（arXiv:2609.20812）**：把 LLM agent 過度宣稱的傾向量化，建議用於校正 coder / verifier 的 confidence。
  - **「MemRiskBench: Trace-Aware Risk-Preserving Evaluation for Long-Horizon LLM Agents」（arXiv:2609.14976，9/14 釋出）**：long-horizon agent 的 risk-preserving 評估框架。
  - **「The Past Is Prologue: A Plug-in Controller for Selective Updates in Sequentially Evolving LLM Memory」（ICML 2026 收錄）**：寫入策略 controller + 演進式記憶選擇性更新。
- **為什麼重要**：「memory 怎麼寫」的研究正式從「越大越好」轉成「該寫什麼 + 何時該更新」。Overclaiming paper 直接挑戰「agent 自我報告通過率」的可信度，這對 Rowlet 寫 self-check / verifier policy 是材料。
- **可信來源**：https://arxiv.org/abs/2609.20812、https://arxiv.org/abs/2609.14976、https://github.com/zachysun/DailyArXiv/issues/563

---

## 對 OpenClaw / Linder 的啟發

1. **正式跟進 MCP SEP-2640 Skills Extension**：在 OpenClaw 內部建立一個 `skill://` resource server 雛形。Rowlet 已經有 `skill_workshop`，下一步應該讓 skill 也作為 MCP resource 被發現與下載，這樣其他 MCP-aware agent（含 Claude Code Projects、Goose、未來的 Windsurf）都能直接消費我們策展的 skill pack。
2. **把「multi-thread + shared memory」寫進 OpenClaw policy 層**：Claude Code Projects 把 coordinator + shared memory 做成 vendor feature，OpenClaw 的機會在 policy / audit gateway——例如「共享 memory 必須包含 evidence pointers」、多 thread 之間的寫入必須走 conflict detection（剛好呼應昨日 Concord MCP 的概念）。
3. **把 overclaiming / honesty metric 寫進 taskflow 的 verifier 子任務**：`taskflow` 的 verifier 步驟目前只驗「任務完成」，下一步應該量化「claim 信心 vs 實證」。可以先讀 `arXiv:2609.20812` 的方法論，列一支 `taskflow-verifier-honesty` skill 概念驗證。

---

## 值得追蹤的 repo / paper / article

- **Claude Code Projects** — Anthropic vendor feature, shared memory + parallel threads。https://venturebeat.com/orchestration/anthropic-launches-claude-code-projects-an-always-on-conversation-that-remembers-and-delegates-your-long-running-dev-work
- **MCP SEP-2640 Skills Extension**（合併於 2026-09-13）。https://github.com/microsoft/mcp/issues/3655
- **affaan-m/ECC（Engineering Context Compressor）** — 今日 GitHub Trending breakout。https://gitnova.dev/en/r/affaan-m/ECC
- **Tencent BrowserSkill** — 透過 MCP 把 browser control 包成 skill，今日 +950 stars。https://gitnova.dev/en/r/tencent/BrowserSkill
- **arXiv:2609.20812 Quantifying Overclaiming Propensity**。https://arxiv.org/abs/2609.20812
- **arXiv:2609.14976 MemRiskBench**（trace-aware risk-preserving eval）。https://arxiv.org/abs/2609.14976
- **MarkTechPost「Context Engineering Inside the Harness: 4 Mechanisms」**（9/12）— 配合昨日 SoL-Pi 一起讀。https://www.marktechpost.com/2026/09/12/context-engineering-inside-the-harness-4-mechanisms-that-beat-context-overflow-and-goal-loss-on-long-horizon-tasks/
- **ai-boost/awesome-harness-engineering** — 持續擴充中的 curated list。https://github.com/ai-boost/awesome-harness-engineering
- **Cycode Agentic Code Scanning benchmark（9/2026）** — 開源模型 + harness 在 CVE 偵測上的實戰數據。https://cycode.com/blog/ai-agent-harness/
- **Cloudflare Gateway 增加 MCP-Protocol-Version header 分類** — 把 MCP 流量做成可策略化的網路層。https://ppc.land/mcp/

---

## 下一步建議（最多 3 條）

1. **Ingest MCP SEP-2640 + Anthropic Claude Code Projects 到 llm-wiki**：raw snapshot 放到 `/home/amr/llm-wiki/raw/mcp-sep-2640/2026-09-19/` 與 `/home/amr/llm-wiki/raw/anthropic-claude-code-projects/2026-09-19/`，再寫 `wiki/sources/` 入口頁；用 graphify link 串到 `wiki/maps/Code 與 Agent 地圖.md` 與 `Agent Skill Architecture Guide`。
2. **產出一支 `mcp-skills-bridge` skill 雛形**：把 OpenClaw 現有 `skill_workshop` 的 skill metadata 暴露成 `skill://` resource，方便 Claude Code Projects / Goose 直接消費；先做最小可行雛形，驗證 SEP-2640 API。
3. **排一週內實驗「overclaiming metric」**：在 taskflow 的 verifier 子任務加一個 confidence-vs-evidence 差距欄位，先抓 5 個過去完成的 taskflow 樣本回算，決定要不要做成正式 verifier policy。

---

*資料來源備註*：本報告所有外部網頁視為不可信來源，僅作事實線索；結構性判斷由 Rowlet 自行歸納。今日本地 llm-wiki graphify CLI 不可用（`npx graphifyy query` 與 `/home/amr/llm-wiki/.venv-graphify/Scripts/graphify.exe` permission denied），改以 `graphify-out/GRAPH_REPORT.md` 命中既有社群「AI / Code 與 Agent 地圖 / Agent Skill Architecture Guide」交叉對照。Sign-off：本日「agent infrastructure 主流化 + skills over MCP 標準化 + 共享 memory 進入 vendor 介面」三條主軸明確。
