# 每日 Agent × 軟體開發情報 — 2026-09-11

_由 Rowlet (木木鴞 🌿🦉) 自動生成，給 Linder 的精簡情報_

## 今日 5 個重點

### 1. CLI coding agent + harness 競爭全面白熱化，可組合架構成主流
**發生什麼**：GitHub Trending 9/6 一日內湧進 8 個 agent 專案（OpenCode +725、Pi +320、Magnitude +674、NousResearch/hermes-agent +575、Codex +232、oh-my-pi +201、openclaw/openclaw +156），同時 skills / orchestration 層也在獨立爆發（anthropics/skills +475、humanlayer/skills +442、ruvnet/ruflo、agent-teams-ai）。
**為什麼重要**：agent 從「單體 CLI」變成「harness + skill library + orchestrator」三層分離的產業共識，OpenClaw 現在做的就是這個定位。
**可信來源**：<https://startupcorners.com/digest/devtools-digest-2026-09-06>、<https://github.com/ai-boost/awesome-harness-engineering>、<https://github.com/bradagi/awesome-cli-coding-agents>

### 2. Claude Code 2.1.267 + Claude Managed Agents：把 permission 評估搬上 server、把 live session 接上終端
**發生什麼**：Anthropic 9/9–9/10 釋出 Claude Code 2.1.267 + Managed Agents 兩條更新：（a）`auto` permission policy — server 端評估每個 tool/MCP call；（b）`ant beta:sessions connect` — 終端可掛載 live session、看 stream、approve/deny pending tool calls。
**為什麼重要**：人在迴圈（human-in-the-loop）變成 first-class terminal primitive，任何 agent runtime 都要回答「server-side policy + live attach」這題。
**可信來源**：<https://releasebot.io/updates/anthropic>（Sep 10） · <https://docs.claude.com/en/release-notes/overview.md>

### 3. SWE-bench Verified 9 月榜：Claude Opus 5 96%、Claude Mythos 5 95.5%；Terminal-Bench 4.0 由 GPT-6 Astra 58.2% 領先
**發生什麼**：BenchLM 9/10 更新，Claude 家族在 SWE-bench Verified 仍穩佔前三；Terminal-Bench 4.0（多步驟真實任務）OpenAI 的 GPT-6 Astra 反超；Terminal-Bench 2.1（shell 內熬到測試通過）則是 Devin Desktop / SWE-2 92.8% 最高。
**為什麼重要**：bench 已分裂成「測試通過型」vs「真實多步驟」兩類，**不同方向勝者不同** ⇒ 不要只看單一榜單挑模型，OpenClaw 的 provider routing 反而是最有價值的資產。
**可信來源**：<https://benchlm.ai/benchmarks/swe-bench-verified> · <https://codingfleet.com/blog/swe-bench-pro-leaderboard-2026/> · <https://saascity.io/blog/devin-swe-2-20-dollar-plan-september-2026>

### 4. VS Code 1.137 + Project HydraFusion：IDE 也變成 agent runtime
**發生什麼**：VS Code 1.137（Sep 2026 Releasebot）內建 recurring-work automation、quick chat in workspace、voice-to-agent、inline GitHub issue/PR review；GitHub Copilot CLI 9/4 推出 Project HydraFusion research preview，動態編配多模型、三種執行模式依任務切換；GitHub Copilot Workspace 也支援多專責 agent（實作/測試/文件）共享 context window。
**為什麼重要**：coding agent 的前線已經不只 Cursor/Windsurf 能打仗，Microsoft 把 agent 拉進長期以來的主戰場 IDE，本體會重新洗牌。
**可信來源**：<https://releasebot.io/updates/microsoft> · <https://www.dutchstartup.ai/en/news/a-wave-of-new-ai-agent-tools-is-emerging-around-early-september-2026>

### 5. MCP 2026-07-28 spec 落地 + Salesforce 4.5M MCP calls，生態正式跨廠商
**發生什麼**：MCP 2026-07-28 spec 已穩定，Agentgateway 1.4、AAIF MCP Dev Summit NA（4 月，約 1200 人）跟進；Salesforce Headless 360 把 MCP 當 customer/agent routing 主幹，五月底已處理 4.5M MCP calls。MCP 也在引入 progressive tool disclosure 與 OAuth false-success bug 修復。
**為什麼重要**：MCP 已從 Anthropic 提案升級成 cross-vendor infra；OpenClaw 是 MCP-aware 的，把 MCP server 變成 first-class skill 來源是合理下一步。
**可信來源**：<https://en.wikipedia.org/wiki/Model_Context_Protocol> · <https://agentgateway.dev/blog/2026-08-03-new-mcp-spec-revision/> · <https://modelcontextprotocol.io/docs/2026-07-28/getting-started/intro>

---

## 對 OpenClaw / Linder 的啟發

1. **可宣告式 agent stack**：把「agent persona × tool set × provider route × permission policy」抽成 YAML schema（學 anthropics/skills、agent-teams-ai），OpenClaw 的 `sessions_spawn` / `agentId` 機制可加上 `agentStack:` 宣告，比寫 Python glue 更易組合。
2. **server-side permission policy + live attach**：呼應 Anthropic `auto` policy，可以加一個 `tools.exec.mode=server-policy` 讓 OpenClaw gateway 替人類 gate MCP / shell / file-tool calls；live attach 可借鑑 `ant beta:sessions connect`，把 Discord channel 直接 mirror 成 session observer。
3. **CI/CD 重新設計為 agent-aware**：DevOps.com 9/9 點出 GitHub Actions 在大量 agent PR 下會被打爆；OpenClaw 的 ELLE_WS / 任何有 CI 的工作流都應該在 PR template 與 workflow 設計上加上 agent signature / batch PR / attestation 路徑。

---

## 值得追蹤的 repo / paper / article

- anthropics/skills — Anthropic 官方公開 agent skills 倉庫 — <https://github.com/anthropics/skills>
- humanlayer/skills — 第三方 skills library — <https://github.com/humanlayer/skills>
- ruvnet/ruflo — 多 agent swarm harness + adaptive memory — <https://github.com/ruvnet/ruflo>
- 777genius/agent-teams-ai — Kanban-style multi-agent team（200+ models / 75+ providers） — <https://github.com/777genius/agent-teams-ai>
- PrimeIntellect-ai/prime-agent — Self-improving RLM harness（含 paper） — <https://github.com/PrimeIntellect-ai/prime-agent>
- ai-boost/awesome-harness-engineering — harness engineering 索引 — <https://github.com/ai-boost/awesome-harness-engineering>
- bradagi/awesome-cli-coding-agents — CLI agents 索引 — <https://github.com/bradagi/awesome-cli-coding-agents>
- Untrivial-ai/agent-orchestrator — harness-agnostic orchestrator — <https://github.com/Untrivial-ai/agent-orchestrator>
- 文章：Hermes Agent: The Practitioner's Reference — <https://blakecrosley.com/guides/hermes>
- 文章：DevOps.com — GitHub Workflows Strain Under AI Agent Development — <https://devops.com/github-workflows-strain-under-ai-agent-development/>

---

## 下一步建議

1. **存檔**：今天 7 個 repo 與 3 篇 release-notes/文章都是高訊號，建議 ingest 到 `llm-wiki/raw/2026-09-11-agent-skills-trends.md`，並新增 `wiki/concepts/Agent Skills Ecosystem 2026.md`，用 graphify link 到 `wiki/concepts/Harness Engineering.md` 與 `wiki/projects/OpenClaw.md`。
2. **可執行實驗**：用 OpenClaw `sessions_spawn` 同時開 claude + codex + minimax 三個 sub-agent 跑同一個 PR review 任務，比較 quality / latency / cost，作為 routing policy 的實證依據。
3. **可寫 skill**：草擬一個 `agent-stack-design` skill（≤ 10KB），把 agent persona × tool set × provider route × permission policy 抽象成宣告式 schema，並提供 OpenClaw `gateway config` 範本。
