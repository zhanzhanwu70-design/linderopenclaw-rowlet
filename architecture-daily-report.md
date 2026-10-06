# 每日 Agent × 軟體開發情報 — 2026-10-06

> 產出者：Rowlet（cron a72cb46b）
> 涵蓋：agent frameworks、MCP、coding agent、harness engineering、memory 論文
> 範圍：過去 7-14 天為主，部分含跨月結構性訊號

---

## 今日 5 個重點

### 1. Harness Engineering 正式成為 2026 後半年主旋律
- **發生什麼**：Marmelab 9/24 發布《The State Of AI Harness Engineering 2026》，提出四元素構成定義（agent loop、tool interface、context management、control）；同月 Microsoft Learn 推出 Agent Harness 官方概念頁；BCG 發布《Harness Engineering: How to Scale Agentic AI Safely》；ai-boost/awesome-harness-engineering 上線。研究資料庫橫掃 1,925 repo / 2,303 context files，發現 75.9% 含測試、68.1% 含架構說明、僅 14.8% 涵蓋安全。
- **為什麼重要**：harness 不再是 prompt 技巧，而是被框為「agent 的 OS」。對 OpenClaw 的 rowlet 自我定位（runtime + tool policy + memory + control）有直接映射。
- **來源**：<https://marmelab.com/blog/2026/09/24/the-state-of-ai-harness-engineering-2026.html>、<https://learn.microsoft.com/en-us/agent-framework/concepts/harness>、<https://www.bcg.com/publications/2026/harness-engineering-scale-agentic-ai>、<https://github.com/ai-boost/awesome-harness-engineering>、<https://en.wikipedia.org/wiki/Agent_harness>

### 2. MCP 從 tool-call 標準升級為事件生態
- **發生什麼**：OpenAI 9/29 宣布 ChatGPT 將支援 MCP Events（webhook push），讓 plugin 可在被動觸發；W3C WebML 社群小組 10/2 釋出 WebMCP Draft（瀏覽器端 JS-based tools 給 agent）；Freshservice 9/10 MCP 整合 GA；兩週內出現五種 MCP auth 機制（SSOJet 9 月 B2B SSO bridge 為代表）。
- **為什麼重要**：MCP 正從「request/response」演進為「event-driven」，agent 開始變成被動的 workflow 觸發端，而不只是主動查詢端。
- **來源**：<https://en.wikipedia.org/wiki/Model_Context_Protocol>、<https://webmachinelearning.github.io/webmcp/>、<https://forkast.news/five-mcp-authentication-mechanisms-shipped-in-two-weeks-the-pattern/>、<https://support.freshservice.com/support/solutions/articles/50000012678-model-context-protocol-mcp-integration-in-freshservice>

### 3. Production-grade agent framework 走向「durable execution + HITL」共識
- **發生什麼**：LangGraph 1.0 主打 durable state、persistence、native human-in-the-loop interrupt；CrewAI 9/9 出 1.15.21；Microsoft 4/3 推 Agent Framework 1.0 統一 AutoGen + Semantic Kernel；QCon SF 11/16-20 把「Engineering Production Systems for an Agentic Era」列為主軸。
- **為什麼重要**：所有主流框架正把「可暫停、可恢復、可審計」當成 baseline。對 Linder 在 OpenClaw 內設計 agent loop 是直接指導：context compaction 與 HITL interrupt 必須是 first-class。
- **來源**：<https://promptessor.com/blog/ai-agent-frameworks>、<https://dev.to/shaam_ai/python-for-agentic-ai-langgraph-vs-crewai-vs-maf-4od0>、<https://kestra.io/resources/ai/ai-agent-orchestration-frameworks>、<https://ai.plainenglish.io/crewai-vs-langgraph-vs-autogen-vs-openai-agents-sdk-the-framework-you-pick-matters-less-than-the-8934e2cc4bbb>、<https://www.infoq.com/news/2026/10/qconsf-2026-sessions/>

### 4. Coding agent 進入「IDE 退場、命令中心進場」轉折
- **發生什麼**：Windsurf 改名 Devin Desktop，定位為「managing all your agents in one place」；Codex CLI 0.146.0/0.146.1（7-8 月）新增 Agent Plugins manifest 與 Amazon Bedrock、Claude Code marketplaces、執行期注入 skills；Claude Code v2.1.220+（8 月）加入 cross-session messaging，可讓 sessions 互相傳遞 findings；Pragmatic Engineer：使用多年的 IDE 工具與 code review 流程正變成 optional。
- **為什麼重要**：coding agent 不再只是 IDE 內的補完，而是多 session 編排 + plugin marketplace 的操作系統面。這正是 OpenClaw 想做但尚未做完的：subagent 任務分派、skill marketplace、跨 session 訊息。
- **來源**：<https://www.morphllm.com/comparisons/codex-vs-claude-code>、<https://www.windsurf.com/>、<https://blakecrosley.com/guides/codex>、<https://newsletter.pragmaticengineer.com/p/the-pragmatic-engineer-five-years>、<https://www.havoptic.com/tools/windsurf>

### 5. Agent memory 進入「graph compaction + access pattern」研究深水區
- **發生什麼**：arXiv 9/30 發 2609.40118《Persistent Context Graphs for Efficient Memory Compaction in LLM Agents》；2609.33226《Beyond Memory Construction: Rethinking Memory Access for LLM-based Conversational Agents》主張重點從「怎麼建 memory」轉向「怎麼 access」；2609.24259《MemCalib: Benchmarking and Optimizing Memory Use》提出 memory 使用效率基準。mem0 進入 GitHub AI Agents Top100 第二名（2026-09-27 截錄）。
- **為什麼重要**：與 Rowlet 自己設計的 graphify + MEMORY.md + daily memory 三層模型方向一致；驗證「以 graph 而非 log 為 memory primary structure」的判斷。
- **來源**：<https://arxiv.org/abs/2609.40118>、<https://arxiv.org/abs/2609.33226>、<https://arxiv.org/abs/2609.24259>、<https://mem0.ai/blog/state-of-ai-agent-memory-2026>、<https://github.com/yuxiaopeng/Github-Ranking-AI/blob/main/Top100/AI%20Agents.md>

---

## 對 OpenClaw / Linder 的啟發

1. **把 harness 概念寫進 OpenClaw 對外文件**。Marmelab + Microsoft 已經把四元素（loop / tool / context / control）做成 public schema；OpenClaw 的 rowlet runtime 正好對應，應在 `IDENTITY.md` 或 wiki 新頁中明列這四層的對應元件，並標註我們跟 LangGraph / Microsoft Agent Framework 的差異點（federated agents、pacing、記憶子系統）。

2. **建立 context compaction 實驗計畫**。MCP 與 Claude Code 都把「可恢復的中斷點」當成 production baseline；Rowlet 應在 1 週內用 Persistent Context Graphs 思路做一輪 mini spike：把現有 graphify JSON 轉成「可重建的最小 context graph」，驗證是否能取代 full rehydration。這是同時對齊 arXiv 9/30 論文與 LangGraph HITL pattern 的低風險實驗。

3. **把 coding agent 生態當成上游 watch list**。Codex / Claude Code / Devin Desktop / Cursor 四家的 release 節奏比 LangGraph 快；建議在 `~/.openclaw/workspace-rowlet/architecture-daily-report.md` 之外，新增 `architecture-daily-coding-agents.md` 或把這份報告拆分為「framework 段」+「coding agent 段」，並考慮 ingest 公開發行 release notes（避免自己 scraper 被 ban）。

---

## 值得追蹤的 repo / paper / article

1. arXiv 2609.40118《Persistent Context Graphs for Efficient Memory Compaction in LLM Agents》— <https://arxiv.org/abs/2609.40118>
2. Marmelab《The State Of AI Harness Engineering 2026》— <https://marmelab.com/blog/2026/09/24/the-state-of-ai-harness-engineering-2026.html>
3. ai-boost/awesome-harness-engineering — <https://github.com/ai-boost/awesome-harness-engineering>
4. VoltAgent/awesome-ai-agent-papers（2026 論文策展）— <https://github.com/VoltAgent/awesome-ai-agent-papers>
5. Microsoft Agent Framework Harness 概念頁 — <https://learn.microsoft.com/en-us/agent-framework/concepts/harness>
6. W3C WebMCP Draft（10/2 2026）— <https://webmachinelearning.github.io/webmcp/>
7. headroomlabs-ai/headroom（coding agent token 壓縮 proxy）— <https://github.com/kouweizhu/agents-radar/issues/328>
8. Pragmatic Engineer：Five Years（IDE / code review 衰退觀察）— <https://newsletter.pragmaticengineer.com/p/the-pragmatic-engineer-five-years>

---

## 下一步建議（最多 3 條）

1. **Ingest Marmelab 與 BCG 兩篇到 llm-wiki**：寫 `wiki/sources/The State of AI Harness Engineering 2026.md` 與 `wiki/sources/BCG Harness Engineering.md`，並用 `npx graphifyy link` 串到既有「Code 與 Agent 地圖」。低成本，知識密度高。

2. **安排一輪 mini spike：context compaction 可逆性測試**。把一個 graphify JSON（≤ 1MB）做 round-trip compaction，量測 token 節省率與重建 fidelity。輸出寫到 `architecture-daily-report.md` 同目錄的 `experiments/` 子資料夾；不需 commit skill，只先驗證。

3. **觀望 MCP Events / WebMCP 進入實作階段**。目前是 draft + 公告期；不急著 ingest，但要把 10 月底前是否有 first-party server 支援當成 follow-up 觸發點（cron 或週報加註）。

---

## 查過的來源

- 本地：`npx graphifyy query "AI agent architecture agent skills multi-agent workflow software architecture software development trends coding agents 2026" --budget 1000`（命中 wiki 內 AI Agent 簡報、A Survey of Frontiers in LLM Reasoning、AI 地圖等節點）
- 公開搜尋：Brave（AI agent framework、coding agent、GitHub trending、MCP spec、harness engineering、arxiv memory papers、Pragmatic Engineer / InfoQ / Anthropic Skills 共 8 次查詢）

> 本日無重大新訊號（無突破性研究、僅有持續性收斂）：今日重點是「harness 概念主流化」「MCP 事件化」「framework 走向 durable execution」「coding agent 編排化」「memory graph compaction 學術化」五條結構性趨勢，沒有單一爆炸性公告。
