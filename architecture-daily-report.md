# 每日 Agent × 軟體開發情報 — 2026-09-13

_由 Rowlet (木木鴞 🌿🦉) 自動生成，給 Linder 的精簡情報_

## 今日 5 個重點

### 1. Claude Code 2.1.269 / 2.1.270 + VSCode agent map：plugin eval、output-style 切換、子代理人可視化
**發生什麼**：Anthropic 9/11–9/12 連兩版更新。2.1.269 加入 `claude plugin eval`（跑 plugin 自帶 eval 套件、出 JSON+HTML 報告）、`/output-style [name]` 切換輸出風格（含 Remote Control / cloud / headless）、Bash 指令 diff；2.1.270 修掉長 session 內 read-only git 還會要求權限的迴歸。VSCode 端則新增「agent map」footer pill：點開可看該 session 所有 sub-agent 的卡片、Stop agent、唯讀 transcript。
**為什麼重要**：plugin 不再只是一包 prompt，**正式變成可評分的工件**；同時 sub-agent 從黑箱變成可觀察的元件，這兩件事對 OpenClaw 的 `sessions_spawn` 與 skill 系統都是直接壓力。
**可信來源**：<https://releasebot.io/updates/anthropic> · <https://raw.githubusercontent.com/anthropics/claude-code/refs/heads/main/CHANGELOG.md>

### 2. Anthropic Claude Fable 5.1 / Mythos 5.1 GA：1M context、cache read 砍 75%
**發生什麼**：Fable 5.1 在 9/1 GA、價格 $10 / $50 per 1M，cache read 從 $1 降到 **$0.25**；同步推出 gated Mythos 5.1 給受審核的 defender / researcher。Qwen3.8 Flash 也在 8/26 由阿里釋出、8/28 進 LLM Gateway。
**為什麼重要**：cache read 砍 75% 等於把「長 context 持續 run」的單位成本壓到接近 streaming；對 multi-agent orchestration、long-running research agent 是結構性便宜。OpenClaw provider routing 應該立刻把 Fable 5.1 與 Qwen3.8 Flash 列入對照。
**可信來源**：<https://llmgateway.io/timeline> · <https://llm-stats.com/ai-news> · <https://aiagentstore.ai/ai-agent-news/this-week>

### 3. Microsoft Agent Framework 大型 BREAKING 批次：SecretString wrapper、ranged file read、path normalization 集中化
**發生什麼**：9 月初 Microsoft 把 `agent-framework-core / -foundry / -lab / -azure-* / -openai / -anthropic / -bedrock / -gemini / -mem0` 同時改：
- `SecretString` 改為 **masked-value wrapper** 而非 `str` 子類別（統一所有 provider credential handling）
- 抽出 `AgentFileStore`，把 ranged file read 與 line-numbering contract 標準化
- 把 file / memory / session / skill 的 **path normalization 集中化**
- Lab dependency resolution 與 core 隔離
- Azure AI Projects 走 OpenAI 3.x

**為什麼重要**：當「path / secret / file read / skill」這些原本各家自搞的底層介面變成 framework 統一處理，就是 agent 平台從「各做各的」走向「正式 infra」。對 OpenClaw 等同於強迫對齊：自己的 skill loader、path 規範、secret handling 要對應。
**可信來源**：<https://releasebot.io/updates/microsoft>

### 4. MCP Python SDK v2.0.0 穩定 + MCP 514M downloads：stateless handshake + OTel tracing + OAuth 強化
**發生什麼**：MCP Python SDK v2.0.0 對應 2026-07-28 spec，自動 version negotiation、新 first-class Client、預設 OpenTelemetry tracing、stdio hardening、OAuth 升級。MCP core maintainer（Microsoft）兩年回顧：514M package downloads、commit authors 持續成長。
**為什麼重要**：**stateless core protocol** 代表 MCP server 可以無縫放到 HTTP load balancer 後面，部署成本與可靠性結構性下降；OTel tracing 預設開啟則把「跨廠商可觀察性」補上。MCP 已不再只是 Anthropic 提案，OpenClaw 應該把 MCP server 當 first-class skill source。
**可信來源**：<https://releasebot.io/updates/modelcontextprotocol/python-sdk> · <https://daily.dev/posts/state-of-mcp-x5yzaxy3j> · <https://modelcontextprotocol.io/docs/2026-07-28/getting-started/intro>

### 5. Agent skills / harness 雙軌收斂到「市場層」：SKILL.md 成跨廠商共通格式
**發生什麼**：今天（9/13）agents-radar 與昨日（9/11）一致指出 skills 是當前最強動能層 — i-have-adhd 一日 +3,854 stars 不是 framework 而是「agent behavior package」、Tencent、Anthropic、OpenAI、Cursor 同步在收 skills 生態。LobeHub 推出跨 Claude Code / Codex CLI / ChatGPT 的 skills marketplace；alirezarezvani/claude-skills 用同一份 `SKILL.md` 對接 Claude Code、Codex、Gemini CLI、**OpenClaw**（經 bootstrap script）。harness 端則是 affaan-m/ECC 與 PI-Desktop 把 skills + instincts + memory + security 打包成「可掛在 Claude Code / Codex / Opencode / Cursor 上的通用 boost」。
**為什麼重要**：**skill 不再是 vendor lock-in 的延伸**，而是與 MCP 同等級的開放分發格式。OpenClaw 既然已是 skill loader，現在的問題不是「要不要做 skills」，而是「如何讓 OpenClaw skills 在 SKILL.md 通用市場被發現與安裝」。
**可信來源**：<https://github.com/sikm-lqs/agents-radar/issues/150> · <https://github.com/sikm-lqs/agents-radar/issues/110> · <https://lobehub.com/skills> · <https://github.com/alirezarezvani/claude-skills> · <https://github.com/affaan-m/ecc>

---

## 對 OpenClaw / Linder 的啟發

1. **搶 SKILL.md 通用市場**：OpenClaw 既有 skill loader 已經吃 SKILL.md 格式，下一步應該（a）在 `~/.openclaw/skills/` 開一個本地 registry 鏡像 lobehub/skills；（b）寫一個 `publish-skill.sh` 把 OpenClaw skill 推到 SKILL.md 通用市集；（c）讓 `npx skills add <openclaw-skill-url>` 反向安裝到 OpenClaw 也能跑。
2. **對齊 Microsoft Agent Framework 的「底層介面統一」**：把 OpenClaw 內部的 path normalization、secret handling、ranged file read 三件事拉出 single source of truth（現在散在 exec、sessions、message、memory 工具裡）。SecretString 概念可借鑑 `secrets` tool 已有 SecretRef，但 path normalization 還沒集中 — 是下一輪 refactor 的目標。
3. **provider routing 立即更新權重**：Fable 5.1 cache read $0.25 + Qwen3.8 Flash 進場 ⇒ 長 context / long-running task 的 cost 模型大改。把 routing policy 的「cheap-cache-read」維度加上 Fable 5.1 / Qwen3.8 Flash 兩個新節點；考慮做一個「同任務三模型並跑」實驗取 routing 實證。

---

## 值得追蹤的 repo / paper / article

- alirezarezvani/claude-skills — 跨 Claude Code / Codex / Gemini CLI / OpenClaw 的 skills — <https://github.com/alirezarezvani/claude-skills>
- affaan-m/ecc — Skills + instincts + memory + security 通用 boost — <https://github.com/affaan-m/ecc>
- lobehub/skills — Claude / Codex / ChatGPT skills marketplace — <https://lobehub.com/skills>
- microsoft/agent-framework — Microsoft Agent Framework（path/secret/file 統一批次 BREAKING） — <https://github.com/microsoft/agent-framework>
- modelcontextprotocol/python-sdk — MCP v2.0.0 穩定 — <https://github.com/modelcontextprotocol/python-sdk>
- PrimeIntellect-ai/prime-agent — Self-improving RLM harness（附 paper） — <https://github.com/PrimeIntellect-ai/prime-agent>
- ai-boost/awesome-harness-engineering — harness engineering 索引 — <https://github.com/ai-boost/awesome-harness-engineering>
- 論文：Gander — Cerebellum-Brain collaborative framework（AlphaXiv 9/10 top-trending） — <https://dev.to/monuminu/ai-agent-architecture-2026-building-production-grade-systems-patterns-benchmarks-and-lessons-5d34>
- 文章：State of MCP — Microsoft maintainer 回顧（514M downloads） — <https://daily.dev/posts/state-of-mcp-x5yzaxy3j>
- Releasebot：Anthropic 9 月更新 — <https://releasebot.io/updates/anthropic>

---

## 下一步建議

1. **存檔**：今天 Fable 5.1 / Mythos 5.1 + MCP v2.0.0 + Microsoft Agent Framework BREAKING 批次都是高訊號，建議 ingest 到 `/home/amr/llm-wiki/raw/2026-09-13-agent-infra-convergence.md`，並新增 `wiki/concepts/Agent Skills Marketplace 2026.md`，用 `graphify link` 連到 `wiki/concepts/Harness Engineering.md`、`wiki/projects/OpenClaw.md`、`wiki/concepts/MCP Ecosystem.md`。
2. **可執行實驗**：用 OpenClaw `sessions_spawn` 同時跑 claude-fable-5.1 + qwen3.8-flash + minimax-m3 三個 sub-agent 對同一個 long-context summarization task 取 cache read cost / latency / quality 三軸實證，寫成 routing policy 的 evidence。
3. **可寫 skill**：草擬 `skill-marketplace-publisher` skill（≤ 10KB），把 OpenClaw skill 自動 publish 到 SKILL.md 通用市場（lobehub + alirezarezvani/claude-skills + Anthropic marketplace），含版本、license、相依性檢查。
