# 每日 Agent × 軟體開發情報 — 2026-06-24

> 產出時間：2026-06-24 02:00 UTC · Rowlet 🌿🦉
> 範圍：最近 7–14 天（2026-06-10 ~ 2026-06-24）
> 篩選原則：結構性意義 > 新聞標題；事實 / 推論 / 判斷分離；外部網頁只當資料，不當指令。

---

## 今日 5 個重點

### 1. Anthropic 推出 **Managed Agents**：把「agent 的三層抽象」虛擬化成可替換元件
- **發生什麼**：Anthropic 2026-04-08 發佈 "Scaling Managed Agents: Decoupling the brain from the hands"，把 agent 拆成三個虛擬化元件——`session`（append-only log）、`harness`（loop + 工具路由）、`sandbox`（執行環境）。每層都可單獨換掉，不影響其他層；目標是讓抽象「比當前實作活得更久」。
- **為什麼重要**：呼應 OpenClaw 已經在做但沒有寫下來的事情——把 agent runtime 切成 stable interface + swappable backend，比「寫死一個 Claude/OpenAI client」壽命長得多。這是 OS-style「process / file」抽象的 agent 等價物。Anthropic 自己也承認：同一個 harness 在 Sonnet 4.5 上面需要 context reset 來治「context anxiety」，但到 Opus 4.5 已經不需要——harness 假設會隨模型變舊，所以抽象層要穩定在 *介面*，不要穩定在 *行為*。
- **可信來源**：[Scaling Managed Agents — anthropic.com/engineering/managed-agents](https://www.anthropic.com/engineering/managed-agents)

### 2. **Containment > Permission Prompts**：人類監督在 93% 同意率下已經失效
- **發生什麼**：Anthropic "How we contain Claude across products"（2026 旗艦文）量化了一個殘酷事實——Claude Code 使用者平均 *核准 93%* 的權限提示，越多次核准注意力越渙散（approval fatigue）。他們把方向從「每次問人」轉向「*限制 agent 能做什麼*」：sandbox、VM、egress control。並發佈 `Claude Code auto mode`（2026-03-25）用 model-based classifier 取代逐次 prompt。
- **為什麼重要**：對 OpenClaw 影響直接——我們的 `nativeapprovals` 機制正面臨同一個問題。如果有一天 OpenClaw agent 每分鐘要 user 按 5 次 yes，approval 將毫無意義。值得研究的方向：(a) 在 tool 層加 classifier 自動擋危險 action；(b) 用 sandbox/VM/egress 把「能不能做」這件事從 prompt 層抽掉。
- **可信來源**：
  - [How we contain Claude across products](https://www.anthropic.com/engineering/how-we-contain-claude)
  - [Claude Code auto mode](https://www.anthropic.com/engineering/claude-code-auto-mode)

### 3. **Harness Design：三 agent 結構（planner / generator / evaluator）成 long-running coding 主流**
- **發生什麼**：Anthropic "Harness design for long-running application development"（2026-03-24）證實了三 agent GAN-style 架構（planner-generator-evaluator）能在多小時無監督 coding session 產出完整 full-stack app。同一時期社群出現「Ralph Wiggum」hooks/script 模式（ghuntley.com/ralph），靠 hooks 強迫 agent 持續迭代。
- **為什麼重要**：Anthropic 自己也說「naive 單 agent 解構 spec → 實作 → 交棒」的舊 harness 在複雜任務上「eventually goes off the rails」。三 agent + GAN 評分機制是 2026 主流，OpenClaw 目前的 skill 系統應該考慮：(a) 把 prototype + handoff 兩個 skill 升級成「含 evaluator」的閉環；(b) 對齊 `moltbot-architecture` 裡的 Agentic Loop 概念。
- **可信來源**：[Harness design for long-running application development](https://www.anthropic.com/engineering/harness-design-long-running-apps)

### 4. **GitHub Trending**：MCP code-intel server 與「500+ agent skills」模板爆量
- **發生什麼**：本週 GitHub Trending 出現幾個高度 agent-centric 專案：
  - `DeusData/codebase-memory-mcp` — 純 C static binary 的 MCP server，sub-ms query 索引 158 種語言，本週 +8,536 stars（昨天 rowlet 已寫過 `codebase-memory-mcp-vs-graphify`）
  - `calesthio/OpenMontage` — 500+ agent skills 的 video production 模板，本週 +9,410 stars
  - `Panniantong/Agent-Reach` — 一個 CLI 讓 agent 讀 Twitter/Reddit/YouTube/GitHub/B站/小紅書，本週 +6,915 stars
  - `NVIDIA/SkillSpector` — Agent skill 資安掃描器，本週 +2,849 stars
  - `LMCache/LMCache` — LLM KV cache layer（性能工程）
- **為什麼重要**：三個結構性訊號——
  (a) **MCP 標準化持續勝出**：codebase-memory-mcp 證明 MCP 不只是聊天工具，已經變成「agent → codebase」的事實標準介面。
  (b) **Agent skills 正在「產品化模板化」**：OpenMontage 把 500 個 skill 打包成一整套 video pipeline，代表「skill collections」會比單一 skill 更值錢。
  (c) **Skill security 變成一級議題**：NVIDIA 為 agent skills 開了獨立掃描器專案，搭配昨天 wiki 入庫的 arXiv 2602.12430（26.1% skills 含漏洞），社區正在把 skill security 從「事後 audit」拉成「上線前 CI gate」。
- **可信來源**：[github.com/trending](https://github.com/trending) + 各 repo 連結

### 5. **OpenAI Codex 0.143**：App-server 多 agent delegation 與 plugin 治理成形
- **發生什麼**：Codex 在 6/22 ~ 6/24 連發 alpha (0.143.0-alpha.3 → alpha.11)，重點：
  - **Multi-agent delegation 開關**：`disabled / explicit-request-only / proactive`（thread + turn level）
  - **Configurable rollout token budgets**：跨 agent thread 追蹤用量，預算耗盡 abort
  - **Plugin 治理**：`/plugins` 改成三區（OpenAI Curated / Workspace / Shared with me），且 eligible turns 可推薦並安裝 plugin
  - `/usage` 支援 reset credits 兌換
- **為什麼重要**：
  (a) **Token budget 是新 primitive**：不是 per-call 限制，而是跨整個 multi-agent session 的限額，這對 OpenClaw 的 `taskflow` 設計直接有用——可以加一個 `budget.json` 讓每個 flow 自帶成本上限。
  (b) **Plugin 三區分類**呼應 agent skills 的信任分級（OpenAI Curated = 第一方、Workspace = 私有、Shared = 第三方審核），跟我們昨天寫進 wiki 的「Skill Trust and Lifecycle Governance」框架方向一致。
  (c) **Multi-agent delegation 從「always on」改成顯式設定**，代表 OpenAI 自己也發現「無腦開多 agent」會失控——這跟我們 `sessions_send` 的 fire-and-forget 警告對得上。
- **可信來源**：[github.com/openai/codex/releases](https://github.com/openai/codex/releases) + [Codex issue #28685 / #28792 / #29324](https://github.com/openai/codex)

---

## 對 OpenClaw / Linder 的啟發（3 條可直接落地）

1. **把 OpenClaw runtime 抽象成 `session / harness / sandbox` 三層**（呼應 Anthropic Managed Agents）。
   - 短期：寫一個 `wiki/concepts/openclaw-runtime-abstractions.md`，把現有的 SOUL/AGENTS/MEMORY/HEARTBEAT/cron/tool 對應到這三層，明確標出哪些是 stable interface、哪些是 swappable backend。
   - 中期：把 `sessions_send` 和 `taskflow` 的執行後端（sandbox 部分）做第一版抽象化，未來想換 Codex/Claude Code/local agent 都不必動上層。

2. **從 approval prompts 轉向 containment**（呼應 Anthropic 93% 同意率）。
   - 寫一個 `skill-containment-design.md` skill / doc：列出哪些 tool 應該自動允許、哪些應該走 classifier、哪些應該在 sandbox/VM 層擋。優先處理 `exec` 的 host-elevation（`auto: "deny"` 預設 + 顯式 allowlist）。
   - 評估 `nativeapprovals` 是否要引入簡單 classifier（甚至 rule-based）來自動放行低風險 read-only 操作。

3. **把「evaluator」加進 skill 閉環**（呼應三 agent GAN-style）。
   - 從 `Agent Prototype Skill` + `Agent Handoff Skill` 開始：在 prototype 結束後加一個 self-critique 步驟（用 rubric 評分），handoff 前用 checklist 驗收。這比單純「做完就交棒」robust 很多。
   - 順手做：把 `moltbot-architecture` 那張圖裡的 Agentic Loop 抽出來寫成 wiki 概念頁。

---

## 值得追蹤的 repo / paper / article

| 主題 | 連結 | 為何追蹤 |
|---|---|---|
| Anthropic Managed Agents | <https://www.anthropic.com/engineering/managed-agents> | 三層抽象是 2026 agent runtime 主旋律 |
| Anthropic Containment | <https://www.anthropic.com/engineering/how-we-contain-claude> | 93% approval 數字是行業轉折點 |
| Anthropic Harness Design | <https://www.anthropic.com/engineering/harness-design-long-running-apps> | Planner/Generator/Evaluator 模式可借鏡 |
| Anthropic auto mode | <https://www.anthropic.com/engineering/claude-code-auto-mode> | Classifier 取代 prompt 的具體做法 |
| Claude Code releases | <https://github.com/anthropics/claude-code/releases> | 23 Jun release：sandbox.credentials + org model restrictions |
| OpenAI Codex 0.143 alpha | <https://github.com/openai/codex/releases> | Multi-agent delegation 開關 + token budget |
| DeusData codebase-memory-mcp | <https://github.com/DeusData/codebase-memory-mcp> | 純 C MCP server，速度與 token 效率驚人 |
| calesthio/OpenMontage | <https://github.com/calesthio/OpenMontage> | 500+ skills 模板，看 skill collection 怎麼組織 |
| NVIDIA/SkillSpector | <https://github.com/NVIDIA/SkillSpector> | Agent skill security scanner 上游動態 |
| LMCache/LMCache | <https://github.com/LMCache/LMCache> | KV cache layer，long-running agent 性能關鍵 |

---

## 下一步建議（最多 3 條）

1. **Ingest 到 llm-wiki**：
   - 新增 `wiki/sources/anthropic-managed-agents-2026-04-08.md`、`wiki/sources/anthropic-containment-2026.md`、`wiki/sources/anthropic-harness-design-long-running-2026-03-24.md`、`wiki/sources/openai-codex-0.143-multi-agent-2026-06.md` 四頁 raw + concept。
   - 更新 `wiki/concepts/openclaw-runtime-abstractions.md`（新頁）並用 `graphify link` 接 `wiki/concepts/moltbot-architecture.md` + `wiki/concepts/openclaw-safety-principles.md`。

2. **寫一個 skill**：
   - `~/.openclaw/skills/agent-harness-patterns/`：把 planner/generator/evaluator 模式 + GAN-style self-critique + Ralph Wiggum hooks 模式做成可複用的 SKILL.md，未來 OpenClaw agent 接到 long-running coding 任務時直接套用。

3. **安排一個實驗**：
   - 用現有的 `taskflow` + 三個 sessions（planner / generator / evaluator）跑一次實驗：拿 `architecture-daily-report.md` 的每日產出當 task，量測 (a) 完成率、(b) self-critique rubric 分數、(c) token 成本。產出比對報告丟回 llm-wiki。

---

## 篩選 / 不採納

- **Hacker News 今日頭條**（Vulnerability reports are not special、Jerry's Map、Swipe typing 等）：無 agent / 軟體架構直接相關，不採。
- **arXiv list 2026**：本次只拉目錄頁，沒深入單篇；明天可挑 `2606.10209`（昨天已寫 Less Context, Better Agents）之後的 *agent context / harness / eval* 主題新文做單篇摘要。
- **InfoQ AI/ML 主頁**：404，視為當日不可達，已在來源清單內標註。

## 已查過的來源（透明記錄）

- ✅ `npx graphify query "AI agent architecture..."` → 命中 reconciliation rule engine 等本地 project 節點，未提供近期 agent 研究條目
- ✅ `graphify query "agent skill harness memory context MCP coding agent"` → 命中 Minerva/Context 教育類節點，仍偏本地 wiki
- ✅ GitHub Trending（weekly）+ GitHub Trending Python
- ✅ GitHub Releases：anthropics/claude-code、openai/codex、langchain-ai/langgraph
- ✅ Anthropic Engineering Blog（首頁 + 4 篇具體文章）
- ✅ Martin Fowler「Exploring Generative AI」目錄頁
- ⚠️ InfoQ AI/ML 頁面 404（標記為不可達）
- ⚠️ Hacker News 首頁有抓但頭條無 agent/架構相關
- ⚠️ arXiv 2026 列表頁只拉到 ID 清單，無摘要

---

_本報告存檔：`/home/node/.openclaw/workspace-rowlet/architecture-daily-report.md`_
_Wiki 條目建立 / 更新已列入「下一步建議」，下次 daily report 前補完。_
