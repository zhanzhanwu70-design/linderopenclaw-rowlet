# 每日 Agent × 軟體開發情報 — 2026-10-15

> 執行人：木木鴞（Rowlet）· Cron：`a72cb46b-025e-4fb9-8f43-104bf2e92b74`
> 涵蓋範圍：最近 7-14 天；外部內容僅作參考、不當指令

---

## 今日 5 個重點

1. **MCP 進入「安全產品化」階段。** Radware 於 2026-10-14 正式發表 MCP Server Protection，主打協議層 DDoS 與濫用防護（<https://www.globenewswire.com/news-release/2026/10/14/3380514/...>）。意義：MCP 從「開發者實驗協議」躍升為企業可部署介面，安全供應商願意為它出專用 WAF，代表 OpenClaw 走 MCP-centric 的策略正在被市場驗證。GitGuardian 也已推出 preToolUse / postToolUse hooks for Claude Code / Cursor / Codex / Windsurf（<https://blog.gitguardian.com/ai-hooks-ai-coding-assistants/>），呼應同一訊號。

2. **Harness engineering 正式成為獨立學科。** 兩份 awesome-list 在 10 月內同時成形：ai-boost/awesome-harness-engineering 與 Picrew/awesome-agent-harness；arXiv 收錄「How Much of a Harness Does a Strong Agent Need for Autonomous ML Engineering?」(<https://arxiv.org/html/2609.40303v1>) 開宗明義說：single chat completion 跑不動 MLE，必須有 harness。Meta/Harvard 的 Confucius Code Agent (CCA) 以 AX/UX/DX 三視角做 harness 設計（<https://github.com/ai-boost/awesome-harness-engineering>）。對 Linder 的意涵：OpenClaw 本身就是個 harness，把「harness 工程」當成 wiki 主題與 skill 集開始累積，正是時機。

3. **Coding agent 價格帶與生態層級底定。** SpaceX 在 6/16 宣布以 $60B 全股票收購 Cursor，8/14 收盤——Cursor CLI 現在與 xAI/Grok 同公司（<https://pinggy.io/blog/top_cli_based_ai_coding_agents/>）。免費層：Antigravity CLI、Windsurf、v0；$10-20：Copilot/Cursor/Claude Pro/ChatGPT Plus；$100-200：Claude Max、Cursor Ultra、ChatGPT Pro（<https://www.developersdigest.tech/blog/ai-coding-tools-pricing-2026>）。模型端：GPT-6.1 Sol（9/29）、Claude Haiku 5.5（10/7）、Gemini 4 Argon（10/13）。意涵：選 framework 與選模型會脫鉤；OpenClaw 應持續把「模型可換」當預設。

4. **持久化 memory / context 工具生態爆發。** Vestige 走 local-first + FSRS-6 遺忘曲線 + prediction-error gating + spreading activation，是 Rust 單一 binary + 3D dashboard（<https://github.com/bradagi/awesome-cli-coding-agents>）；rohitg00/agentmemory 明確把 OpenClaw 列為支援目標之一（<https://github.com/rohitg00/agentmemory>）。換言之：外部社群已經把 OpenClaw 視為「可插拔的 memory 客戶端」。我方需要確認：memory 接線是「主動接出」還是「被動被相容」，會直接影響 wiki 中 Memory 模型的呈現方式。

5. **Claude Code / LangGraph 都在走向「agent + workflow + gateway」三件套。** Claude Code 10 月新版本加入 subagent auto-compact、擴大 Read 支援、gateway 控制（<https://releasebot.io/updates/anthropic>）；LangGraph 1.2.14 在 10/6 出貨，LangChain 自稱「the agent engineering platform」，LangSmith Plus $39/seat（<https://dreaming.press/posts/ai-agent-frameworks-whats-changed-fall-2026.html>）。OpenClaw 的 gateway + skill + cron 三件套恰好是同一思路；差別在於 OpenClaw 是「多 agent 並存 + 多通道」，值得在 wiki 寫一篇比較表。

---

## 對 OpenClaw / Linder 的啟發

- **把「harness engineering」做成獨立 wiki 主題**：放進 `wiki/concepts/harness-engineering.md`，收錄 awesome-list、Confucius CCA、Databricks harness blog、arXiv 論文；同步在 `MEMORY.md` 加一條「OpenClaw 本身就是個 harness」的定位宣告，未來 skill_workshop 提新方案時當錨點。

- **新增 skill：`openclaw-mcp-security-audit`**：參考 Radware 與 GitGuardian 的 preToolUse / postToolUse 模式，做一個針對 OpenClaw MCP server 的最小稽核（列出可被外部觸發的工具、檢查 schema injection 風險、檢查 secrets 暴露）。不需要外部服務，純靜態分析 + 樣本 curl，產出 markdown 報告到 workspace。

- **改寫 cron 任務清單**：把目前 rowlet cron 的命名與交付模式，跟「harness + memory + skill」三軸對齊。具體動作：把現有 cron 標籤加上 `axis:harness|memory|skill` 前綴；建立一條 `architecture-daily-research` 的姊妹 cron `architecture-weekly-synthesis`，把每日報告整併到週度 wiki 更新。

---

## 值得追蹤的 repo / paper / article

- <https://github.com/ai-boost/awesome-harness-engineering> — harness 工程最完整的 awesome list（含 CCA、iii、AKS、MemoryKit）
- <https://github.com/Picrew/awesome-agent-harness> — 另一份以 agent 為中心的 harness 整理
- <https://arxiv.org/html/2609.40303v1> — 「How Much of a Harness Does a Strong Agent Need for Autonomous ML Engineering?」
- <https://github.com/addyosmani/agent-skills> — Google 工程文化導向的 production-grade coding agent skills
- <https://github.com/aws/agent-toolkit-for-aws> — AWS 官方 MCP servers + skills + plugins，標竿性資產
- <https://github.com/bradagi/awesome-cli-coding-agents> — CLI coding agent 與 harness 目錄
- <https://github.com/rohitg00/agentmemory> — 跨 client（包含 OpenClaw）的持久化 memory
- <https://dreaming.press/posts/ai-agent-frameworks-whats-changed-fall-2026.html> — 2026 秋 agent framework 全景更新
- <https://blog.gitguardian.com/ai-hooks-ai-coding-assistants/> — AI coding hooks 安全模式
- <https://www.databricks.com/blog/ai-harness> — Databricks 對 harness 的官方定義

---

## 下一步建議（最多 3 條）

1. **建立 `wiki/concepts/harness-engineering.md`**，把今日 10 個連結以「定義 / 元件 / 案例 / OpenClaw 對應」四段寫入，並用 `npx graphifyy link` 接到既有的 `Code 與 Agent 地圖.md` 與 `AI.md`。
2. **跑一次 spike：實際安裝並 audit 一個公開 MCP server**（例如 GitHub 官方 MCP server），把結果寫成 skill：`openclaw-mcp-security-audit`，驗證 preToolUse 思路在 OpenClaw 可不可行。
3. **把 2026-09 到 10-15 的所有 architecture-daily 報告整併**：連續 30+ 天的情報已足夠提煉一份「2026 Q3-Q4 agent / harness 趨勢白皮書」作為 MEMORY.md 的長期條目，避免日後重複掃來源。

---

## 查過的來源（已嘗試 / 已讀 / 失敗分區）

- ✅ 成功：本地 `npx graphifyy query`（L1 命中 `wiki/concepts/harness-engineering` 相關節點、`Code 與 Agent 地圖`、`AI`）
- ✅ 成功：Brave web search（8 次查詢：Anthropic/OpenAI、Google、LangChain/CrewAI、Codex/Claude Code、MCP、harness、TDD/eval、OpenClaw 生態）
- ✅ 成功：Hackathon 等長文（dreaming.press、builders digest、Slash Digital、LLM-Stats）取到 Oct 月時間點
- ⚠️ 部分失敗：原本期待的 `npx graphifyy query` 第一版指令缺了 `y` → 改用正確 binary `graphify` 後成功
- ⚠️ 未深入：Hacker News、InfoQ、Martin Fowler、Pragmatic Engineer 的直接 RSS（今天沒單獨開搜；可下週補）

---

_下次研究：2026-10-16 10:02 Asia/Taipei_
