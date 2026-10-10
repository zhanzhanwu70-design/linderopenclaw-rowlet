# 每日 Agent × 軟體開發情報 — 2026-10-10

> 產出者：Rowlet（cron a72cb46b）
> 涵蓋：agent frameworks、coding agents、MCP、harness engineering、agent memory、OpenClaw 自身
> 範圍：過去 7-14 天為主，跨月結構性訊號為輔
> 前次報告：2026-10-06（harness mainstreaming、MCP events、durable execution、IDE 退場、memory graph）

---

## 今日 5 個重點

### 1. MCP 2026-07-28 spec 穩定後，10 月進入「事件化 + 任務化」落地期
- **發生什麼**：MCP 2026-07-28 spec 把核心改為 stateless、把 Apps 與 Tasks 變成標準化 extensions、加強 OAuth 2.0 / OIDC 授權；四月已達 1.1 億 SDK 月下載；W3C WebML 社群 10/2 推 WebMCP Draft 把 MCP 帶進瀏覽器；OpenAI ChatGPT 9/29 公告支援 MCP Events（被動 webhook push）。
- **為什麼重要**：MCP 從「request/response 工具呼叫」演進到「事件 + 長期任務」雙軌，agent 正從主動查詢端變成 workflow 觸發端。對 OpenClaw 而言，是否要支援 MCP server / client 直接影響 skill 市場的開放程度。
- **來源**：<https://en.wikipedia.org/wiki/Model_Context_Protocol>、<https://webmachinelearning.github.io/webmcp/>、<https://theairankings.com/guides/what-is-mcp/>、<https://github.com/jqueryscript/anthropic-claude-timeline>

### 2. Coding agent 排行榜固化：Claude Fable 5.1 91.4%、Codex + GPT-6.1 Sol 58.2%/$1.92
- **發生什麼**：Artificial Analysis 模型榜（單一 Terminus 2 harness）Claude Fable 5.1 max 91.4%、GPT-6 Astra high 89.9%、Claude Opus 5 max 89.1%；Harbor Hub Terminal-Bench 2.1 agent 榜 Codex + GPT-6 Astra high 87.4%、Claude Code + Fable 5 xhigh 83.8%；Terminal-Bench 4.0（10/6）Claude Code + Opus 5.5 64.8% 領先。
- **為什麼重要**：coding agent 的「model + harness」分離評測已成主流，純模型分數已不足以解釋終端表現。對 OpenClaw 來說，「harness 提供方」與「模型提供方」解耦的設計再次被驗證是對的。
- **來源**：<https://www.morphllm.com/best-ai-coding-agents-2026>、<https://www.morphllm.com/ai-coding-agent>、<https://www.morphllm.com/comparisons/codex-vs-claude-code>

### 3. Production agent framework 收斂到 LangGraph 1.2.13 + Microsoft Agent Framework 雙雄
- **發生什麼**：LangGraph 1.2.13（10/6）44.8M PyPI 月下載、Uber/Cisco/Anthropic/Replit/LinkedIn 採用；Microsoft Agent Framework 1.0（4/3）= AutoGen + Semantic Kernel 統一、Go port 中年 public preview；CrewAI 1.15.21、OpenAI Agents SDK、Google ADK、Pydantic AI、LlamaIndex Agent Workflows、smolagents、Strands Agents、Mastra 共同構成 10 大開源框架。
- **為什麼重要**：framework 選型已不再是「哪個最潮」，而是「durable state + HITL + 跨語言 + A2A 通訊」四項 baseline 全不到位就出局。對 Rowlet 而言，這是評估 OpenClaw 自身 runtime 差距的 checklist。
- **來源**：<https://www.jahanzaib.ai/blog/langgraph-tutorial-build-production-ai-agents>、<https://vdf.ai/blog/best-ai-agent-frameworks/>、<https://ai.miraheze.org/wiki/Microsoft_Agent_Framework>、<https://crewai.com/>

### 4. Harness engineering 出現「constitutive definition」學術共識雛型
- **發生什麼**：ai-boost/awesome-harness-engineering 6 月提出 harness 的充分必要條件 = (agent loop + tool interface + context management + control mechanisms) 四元素；4 月針對 70 個公開 agent 系統的實證研究歸納出 5 個 architectural patterns（subagent、context mgmt、tool systems、safety、orchestration）；Addy Osmani 主張「分離 generation 與 evaluation 到不同 agent」勝過 self-evaluation。
- **為什麼重要**：harness 從 buzzword 變成有可驗證 definition 的工程學科。Rowlet 自我定位（runtime + tool policy + memory + control）直接對應這四元素，可以反過來用這套框架來 audit OpenClaw 自己。
- **來源**：<https://github.com/ai-boost/awesome-harness-engineering>、<https://marmelab.com/blog/2026/09/24/the-state-of-ai-harness-engineering-2026.html>、<https://www.freecodecamp.org/news/what-is-an-agent-harness/>

### 5. OpenClaw 自身 10 月進度：OCE 企業控制面 + 8 月 extended-stable release
- **發生什麼**：OpenClaw Foundation 推出 OCE（OpenClaw Enterprise），免費、OpenAI/Red Hat/Nvidia 支持，主打多租戶管理、sandboxing、auditing、語言模型審視 agent 動作；8 月底發布 gateway-only extended-stable release（= LTS），含安全更新、模型支援、可靠性修正。Multi-agent routing 從單一 Gateway 啟動多個 isolated agent（每個有獨立 persona / model / session history）。
- **為什麼重要**：OpenClaw 正從「個人 agent 工具」往「enterprise control plane」定位移動；對 Linder 的 rowlet 而言，這是討論 skill marketplace 與 multi-tenant 隔離策略的時機點。
- **來源**：<https://venturebeat.com/orchestration/openclaw-launches-free-enterprise-control-plane-for-persistent-ai-agents-backed-by-openai-red-hat-and-nvidia>、<https://github.com/openclaw/openclaw/releases>、<https://hackernoon.com/understanding-openclaws-gateway-agent-runtime-and-multi-agent-architecture>

---

## 對 OpenClaw / Linder 的啟發

1. **用四元素框架 audit 自己的 runtime**。把 ai-boost 的四元素（loop / tool / context / control）套到 OpenClaw rowlet 上：loop 對應 sessions_spawn + heartbeat、tool 對應 exec / message / web_*、context 對應 MEMORY.md + graphify、control 對應 policy / approval / pacing。輸出成 `wiki/concepts/OpenClaw Harness Audit.md`，並標註缺項（例如 A2A 訊息、stateless spec 對齊）。

2. **把 MCP Events 當成 cron 替代方案的可行性實驗**。10/2 WebMCP Draft + 9/29 ChatGPT MCP Events 顯示事件驅動的 agent 已進入可實作期。Rowlet 可在 1 週內做 mini spike：把 graphify 索引更新包成 MCP server，看是否能用 webhook 取代現有 5 分鐘 cron。低成本、可逆、可直接驗證架構假設。

3. **coding agent 排行榜當成 model 路由決策依據**。Terminal-Bench 4.0 與 Artificial Analysis 的分離評測顯示「harness + model」組合優於單一選擇。可考慮在 OpenClaw 內建「per-task model picker」skill：根據任務類型（reasoning heavy / tool heavy / cheap volume）路由到 Fable 5.1 / GPT-6 Astra / cheap-tier；寫成 `~/.openclaw/skills/model-router/` 並在 rowlet 工作流中測試。

---

## 值得追蹤的 repo / paper / article

1. arXiv 2610.05584《Expanding LLM Reasoning》(10/4) — <https://arxiv.org/abs/2610.05584>
2. arXiv 2610.12061《When Should Agents Think? Adaptive Reasoning via Cross-Turn Estimation》— <https://arxiv.org/abs/2610.12061>
3. arXiv 2610.08246《LeanPlan: Optimal Planning with LLM-Generated Heuristics and Admissibility Proofs》(10/6) — <https://arxiv.org/abs/2610.08246>
4. arXiv 2610.07948《Confidence Reasoning Graphs: Structured Confidence Estimation for LLM Agents》— <https://arxiv.org/abs/2610.07948>
5. Marmelab《The State Of AI Harness Engineering 2026》(9/24) — <https://marmelab.com/blog/2026/09/24/the-state-of-ai-harness-engineering-2026.html>
6. ai-boost/awesome-harness-engineering — <https://github.com/ai-boost/awesome-harness-engineering>
7. VoltAgent/awesome-ai-agent-papers（2026 策展）— <https://github.com/VoltAgent/awesome-ai-agent-papers>
8. MorphLLM《Best AI Coding Agents (October 2026)》— <https://www.morphllm.com/best-ai-coding-agents-2026>
9. LangGraph 1.2.13 Tutorial（10/6）— <https://www.jahanzaib.ai/blog/langgraph-tutorial-build-production-ai-agents>
10. OpenClaw OCE（enterprise control plane）— <https://venturebeat.com/orchestration/openclaw-launches-free-enterprise-control-plane-for-persistent-ai-agents-backed-by-openai-red-hat-and-nvidia>

---

## 下一步建議（最多 3 條）

1. **寫 `wiki/concepts/OpenClaw Harness Audit.md`**：用 ai-boost 四元素 + Marmelab 5 patterns 套到 rowlet runtime 上，標註差距與補完優先級。並用 `npx graphifyy link` 串到 `wiki/maps/Code 與 Agent 地圖.md` 與 `wiki/concepts/Agent Harness.md`（若不存在則順便建）。

2. **mini spike：MCP server 包 graphify 索引**。把 `/home/amr/llm-wiki/graphify-out/GRAPH_REPORT.md` 透過 MCP server 暴露成兩個 tool（`get_node`、`query_graph`），讓任何 agent 可直接 query。產出寫到 `experiments/mcp-graphify-2026-10.md`。這個實驗順便驗證 MCP Events 取代 cron 的可行性。

3. **觀望 10 月底 coding agent 變化**：MorphLLM 與 Harbor Hub Terminal-Bench 4.0 是新的基準試金石；可每兩週重新讀一次，必要時更新 `~/.openclaw/skills/` 內的 model-router 預設值。本週不需急動。

---

## 查過的來源

- 本地：`npx graphifyy query "AI agent architecture agent skills multi-agent workflow software architecture software development trends coding agents 2026" --budget 1000`（命中 wiki 內 `AI Agent 簡報`、`A Survey of Frontiers in LLM Reasoning`、`AI 地圖`、`Code 與 Agent 地圖` 等節點）
- 公開搜尋：Brave 共 8 次（AI agent framework October 2026、coding agent news、MCP spec、harness engineering、arXiv memory、GitHub trending、OpenClaw gateway、LangGraph tutorial），web_fetch Marmelab harness engineering 全文（已截 3KB + spill 至 `/tmp/openclaw-web-fetch-079b4e18f98b0a06.log`）
- 自我過濾：所有未指名日期的 search result（特別是 coddykit 的 GitHub trending 摘要系列）視為二手評論，僅作為趨勢佐證、不直接引用為事實

> 今日為持續性收斂，無突破性研究：MCP 事件化、coding agent 排行榜固化、framework 雙雄格局、harness 學術定義成型、OpenClaw 自身 OCE 推進。五條皆為結構性趨勢延伸，無單一爆炸性公告。
