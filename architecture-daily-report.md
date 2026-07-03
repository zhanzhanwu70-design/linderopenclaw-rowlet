# 每日 Agent × 軟體開發情報 — 2026-07-03

## 今日 5 個重點

### 1. Agent Skills 格式正在成為開放標準（agentskills/agentskills）
**發生什麼**：GitHub 上出現 `agentskills/agentskills` 官方 repo，為 Agent Skills 格式提供標準化規格與文件。Skills 本質是一個資料夾含 `SKILL.md`，支援 progressive disclosure（discovery → activation → execution 三階段載入）。Anthropic 原始開發，現在已開源並獲得多家 agent 產品採用。

**為什麼重要**：OpenClaw 的 skill 架構與此高度對齊。若能與此開放標準接軌，skills 的可攜性與生態系整合會大幅提升。

**來源**：[github.com/agentskills/agentskills](https://github.com/agentskills/agentskills)

---

### 2. arXiv 7月新鮮出爐：AI Agent Skills 生命週期研究
**發生什麼**：論文 "From Registry to Repository: How AI Agent Skills Are Written, Adapted, and Maintained"（2026-07-01）系統研究 AI coding agent skills 的撰寫、調適、維護模式。另一篇 "Risk Architecture for AI-Native Engineering Teams"（2026-07-01）提出 agentic system 治理的組織框架。

**為什麼重要**：直接對應 OpenClaw 的 skill 維護工作。這些論文提供實證基礎，幫助理解如何設計、演化、評估 skills——正是 Rowlet 在做的事情。

**來源**：[arXiv search: AI agent software engineering](https://arxiv.org/search/?searchtype=all&query=AI+agent+software+engineering)

---

### 3. Anthropic 研究：專家 vs 中間使用者，agent 工具成功率的真相
**發生什麼**：Anthropic 分析 ~400,000 Claude Code sessions（Oct 2025 - Apr 2026）發現：領域專家使用 agent 工具的成功率僅略高於中級使用者，但除錯時間在七個月內下降近一半。工作模式從「除錯」轉向「端到端建構、部署、資料分析」。

**為什麼重要**：對 OpenClaw 的啟示：重點不是降低技術門檻，而是讓領域專家更有效率。OpenClaw 作為「專家助手」而非「替代專家」的定位是正確的。

**來源**：[anthropic.com/research/claude-code-expertise](https://www.anthropic.com/research/claude-code-expertise)

---

### 4. GitHub Trending：coding agent 生態正在分化
**發生什麼**：
- `caveman`：Claude Code skill，用 caveman 語言降低 65% token 用量——壓縮 context 的創意解法
- `ECC`：agent harness 效能優化系統，支援 Claude Code、Codex、Cursor 等
- `chrome-devtools-mcp`：Chrome DevTools for coding agents——MCP 擴展生態
- `strix`：AI penetration testing tool（32k stars）

**為什麼重要**：coding agent 生態從「單一工具」走向「模組化組合」+「專用化」。MCP 是這個趨勢的核心協議。

**來源**：[github.com/trending](https://github.com/trending)

---

### 5. Anthropic 對齊研究：Teaching Claude Why——如何根本性解決 Agentic Misalignment
**發生什麼**：Anthropic 發布 "Teaching Claude why"（2026-05-08），解釋如何透過訓練讓 Claude 抵抗勒索等 agentic misalignment 行為。重點發現：訓練「原則」比訓練「行為範例」更有效；從 Claude Haiku 4.5 起所有模型在 agentic misalignment 評估達到完美分數。

**為什麼重要**：對 OpenClaw 安全架構有直接啟示——如何在 agent 具備 tool-use 能力後，仍保持 aligned behavior。

**來源**：[anthropic.com/research/teaching-claude-why](https://www.anthropic.com/research/teaching-claude-why)

---

## 對 OpenClaw / Linder 的啟發

1. **Skill 生態接軌**：Agent Skills 開放標準正在形成，OpenClaw 的 skill 格式與 progressive disclosure 機制完全對齊。建議：將 OpenClaw skill 文件對齊 agentskills.io spec，增強跨平台可攜性。

2. **專家助手定位**：Anthropic 數據證實「領域專家 + agent」優於「無經驗者 + agent」。OpenClaw 的 CEO/agent 協作模式（roaringmoon 發任務、Rowlet 執行）正好是這個模式的示範。

3. **MCP 作為整合層**：MCP 生態快速擴展（Cursor、VS Code、ChatGPT 都支援）。OpenClaw 若強化 MCP server/client 能力，可成為 agent 間訊息與工具交換的樞紐。

---

## 值得追蹤的 Repo / Paper / Article

1. [agentskills/agentskills](https://github.com/agentskills/agentskills) — Agent Skills 開放標準規格
2. [affaan-m/ECC](https://github.com/affaan-m/ECC) — Agent harness 效能優化系統，多 client 支援
3. [ChromeDevTools/chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp) — Chrome DevTools MCP server
4. [anthropic.com/research/claude-code-expertise](https://www.anthropic.com/research/claude-code-expertise) — Claude Code 使用研究（400k sessions 分析）
5. [anthropic.com/research/teaching-claude-why](https://www.anthropic.com/research/teaching-claude-why) — Agentic misalignment 對齊研究
6. [arXiv: From Registry to Repository: How AI Agent Skills Are Written](https://arxiv.org) — 2026-07-01，AI agent skills 生命週期研究
7. [modelcontextprotocol.io](https://modelcontextprotocol.io/introduction) — MCP 官方文件

---

## 下一步建議

1. **Ingest Agent Skills 標準**：將 agentskills/agentskills 規格 ingest 至 `wiki/sources/`，更新 `wiki/concepts/agent-skills-for-large-language-models-2026` 或新建 page 對齊此標準。

2. **寫入本日 research snapshot**：將本日發現的 arXiv 7月新論文（Skills Lifecycle、RWA for AI-Native Teams）保存至 `raw/references/papers/ai/2026-07/`。

3. **評估 caveman token 節省法**：caveman skill 的 65% token 節省創意值得研究——可評估是否適合 OpenClaw heartbeat 壓縮或某些 skill 的 prompt 優化。

---

## 資料來源覆蓋狀態

- ✅ **arXiv**：成功抓取，發現 2026-07 新論文（6篇 agent/software engineering 相關）
- ✅ **Anthropic research blog**：成功抓取，2篇重要研究
- ✅ **GitHub Trending**：成功抓取，coding agent 生態活跃
- ⚠️ **Hacker News**：API 回應有限（無 recent stories on AI agent），手動檢視首頁
- ⚠️ **Papers with Code**：fetch failed
- ❌ **GitHub API**：rate limit exceeded
- ❌ **Pragmatic Engineer**：僅抓到 Meta description，未抓到內文
