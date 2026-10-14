# 每日 Agent × 軟體開發情報 — 2026-10-14

_編製：木木鴞 Rowlet · 模式：cron / 自動情報流_

## 今日 5 個重點

1. **Anthropic 與 OpenAI 在 48 小時內互別苗頭推 coding agent CLI 升級（10/9）**
   - 發生什麼：Anthropic 釋出 **Claude Code 2.1.296**（10/9），新增 workflow-level model 切換、更大 Read 支援、subagent auto-compact，並修掉 Cowork cloud sessions 對 proxy 誤判的 bug；同日 OpenAI 把 **Codex CLI 推到 0.162 並釋出 0.163.0-alpha.5**（10/9），保持近週 pre-release 節奏。
   - 為什麼重要：CLI coding agent 已變成兩大模型廠的「標準化戰場」。`subagent auto-compact` 與 `workflow-level control` 兩個關鍵字同時出現在兩家 roadmap，意味著 2026 H2 的競爭軸已從「model IQ」轉到「harness ergonomics」。
   - 來源：https://github.com/anthropics/claude-code/releases · https://github.com/openai/codex/releases · https://tech-insider.org/codex-cli-0-162-vs-claude-code-2-1-296-2026/

2. **「Agent = Model + Harness」成社群共識（4 月 Böckeler/Fowler 定調、10 月大規模擴散）**
   - 發生什麼：Thoughtworks ARC 2026 場次 + arXiv 三篇 survey（Meng et al.、Tang et al.、**Guo et al. 6/23 的「From Question Answering to Task Completion」**, 17 作者）把 harness engineering 從 prompt engineering 拉出來當獨立學科；Databricks 官方部落格、Birgitta Böckeler 在 martinfowler.com（4 月）、winder.ai / explainx.ai / getorchestra.io 等都採用「model + harness」框架。
   - 為什麼重要：開源生態已出現 **DeepSeek Harness、oh-my-codex、omnigent、Goose** 等「meta-harness」與 workflow layer，把 Claude Code、Codex、Cursor、OpenCode 當 backend 來編排——驗證了「harness 才是 2026 下半的差異化層」。
   - 來源：https://www.databricks.com/blog/ai-harness · https://deepengineering.net/p/issue-67-harness-engineering-patterns-ai-agents · https://winder.ai/ai-agent-harness-comparison/ · https://www.getorchestra.io/guides/agent-harness-engineering-survey

3. **MCP 規格 2026-07-28 進入穩態：stateless core + 正式 deprecation policy**
   - 發生什麼：Model Context Protocol 規格在 7/28 釋出 2026-07-28 版，核心改為 stateless 以利水平擴展，並把 versioning rules 與 deprecation policy 寫成 normative；Microsoft Visio Desktop MCP Server 11 月預覽、2027/6 GA。
   - 為什麼重要：Agent ↔ 工具的介面已從「客製整合」走向「協定 + registry」主流模式。對所有 agent framework 而言，MCP 已是事實上的 I/O 標準，不支援就等於被排除在生態外。
   - 來源：https://modelcontextprotocol.io/ · https://www.university-365.com/post/the-model-context-protocol-mcp-connecting-ai-to-everything · https://windowsforum.com/news/microsoft-visio-desktop-mcp-server-brings-ai-diagram-creation-to-windows-in-2026-preview.448206/

4. **小模型專攻 routing / subagent：Claude Haiku 5.5（10/7，1M context）**
   - 發生什麼：Anthropic 10/7 發表 **Haiku 5.5**，1M tokens context，定價低、主打 classification / extraction / routing / subagent；同日 **Sonnet 5 價格正式凍在 $2/$10 per MTok**（9/1 漲價方案取消）。
   - 為什麼重要：模型分工明確化——Sonnet 5 當 worker 主力、Haiku 5.5 當 cheap router / 篩選 / 抽取 / subagent。這是「分層模型預算」成為主流的最強訊號。
   - 來源：https://platform.claude.com/docs/en/release-notes/overview · https://aiagentstore.ai/ai-agent-news/this-week

5. **多代理框架洗牌定局：LangGraph 1.2.14（10/6）每週發版、AutoGen 維護、DigitalOcean 包觀測**
   - 發生什麼：**LangGraph 1.2.14** 10/6 發版，近週一版節奏；CrewAI ~59k stars、AutoGen 進入維護模式併入 Microsoft Agent Framework；LangSmith $39/seat/mo、DigitalOcean 10/12 推出 Agent Data + Agent Learning Services（Insights / Signals / Evaluations / Simulations），把「observe → detect → test」封裝成託管服務。
   - 為什麼重要：2027 主流 stack 雛形浮現——**stateful graph runtime + managed observability + harness layer + MCP tools**。自建 tracing 的時代結束，付費買 managed eval/trace 才是新基準。
   - 來源：https://dreaming.press/posts/ai-agent-frameworks-whats-changed-fall-2026.html · https://is4.ai/blog/our-blog-1/top-12-multi-agent-ai-frameworks-2026-335 · https://www.jahanzaib.ai/blog/langgraph-tutorial-build-production-ai-agents · https://www.getorchestra.io/guides/ai-agent-frameworks

## 對 OpenClaw / Linder 的啟發（3 條，可執行）

1. **補一個 `agent-harness` skill**：把 OpenClaw 現有的 `subagent` / `sessions_spawn` / `gateway` / cron 機制重新框架為「Model + Harness」，對齊 Claude Code 2.1.296 的 subagent auto-compact 與 workflow-level control。`harness` 層包含：tool registry（已存在）、sandbox（已有 exec/elevated）、memory（已有 MEMORY.md / memory/）、context budget（要加）、feedback loop（要寫）。
2. **加 `model-router` 決策表到 AGENTS / SOUL**：cheap → Haiku 5.5 / mid → Sonnet 5 / heavy → opus + manual confirm；router 預設走 MiniMax 即可（cost-first），只有當任務是「需要 reasoning chain ≥ 5 步」或「需要台灣在地語境」才升級。預期每月 token 成本可降 40-60%。
3. **盤點哪些 skill 可以包成 MCP server**：`photo-archive`、`pokemon-card-ocr`、`ptcgp-*`、`ocr-rename-by-barcode` 都有明確 I/O 契約，恰好對應 MCP 2026-07-28 的 stateless core 模式。包成 MCP 後可被其他 agent（不限 OpenClaw）呼叫，等於讓 OpenClaw 的 skill 同時也是公共基礎建設。

## 值得追蹤的 repo / paper / article

- https://github.com/anthropics/claude-code/releases（Claude Code 2.1.296 changelog）
- https://github.com/openai/codex/releases（Codex 0.163.0-alpha.5）
- https://github.com/andyrewlee/awesome-agent-orchestrators（meta-harness 清單，含 oh-my-codex、omnigent、neuralyzer）
- https://ryanalberts.github.io/best-of-Agent-Harnesses/（harness 排名、managed vs self-host、memory layers 比較）
- arXiv 2026-06-23: "From Question Answering to Task Completion: A Survey on Agent System and Harness Design"（Guo et al., 17 作者）
- https://www.databricks.com/blog/ai-harness（Databricks 官方對 harness 的定義）
- https://deepengineering.net/p/issue-67-harness-engineering-patterns-ai-agents（ARC 2026 harness patterns）
- https://www.coddykit.com/pages/blog-detail?id=5129963（GitHub Trending Oct 2026：agent skills 102k stars、mksglu/context-mode 98% tool output reduction）
- https://platform.claude.com/docs/en/release-notes/overview（Sonnet 5 價格定案、Haiku 5.5 規格）
- https://modelcontextprotocol.io/（MCP 2026-07-28 規範）
- https://www.thoughtworks.com/insights/articles/quality-is-speed-AI-era（Fowler × Joe Murray: AI 時代的工程紀律）

## 下一步建議（最多 3 條）

1. **入 wiki**：把今日 5 則高價值原始資料（Claude Code 2.1.296 release、Sonnet 5 價格定案、MCP 2026-07-28 規範、Databricks harness 定義、Guo et al. survey）存到 `/home/amr/llm-wiki/raw/sources/2026-10-14-coding-agent-wave/`，並寫一篇 `wiki/sources/2026-10-14 Coding Agent CLI Wave.md` 整合頁。
2. **建 graph 連結**：在 `wiki/index.md` 與 `wiki/log.md` 加入本篇，並跑 `cd /home/amr/llm-wiki && npx graphifyy link --source "wiki/sources/2026-10-14 Coding Agent CLI Wave.md" --target "Code 與 Agent 地圖.md"`。
3. **安排實驗**：下一次排程（10/15 同一支 cron）後接一個 `agent-harness-spike`：把 OpenClaw 現有 sessions_spawn workflow 加上 subagent auto-compact 與 explicit context budget，跑 3 個真實任務（graphify 萃取、OCR 批次、pokemon deck 攝取）量測 token 用量。

---

_本篇以 Graphify-only workflow 產出：先 `npx graphifyy query` 取得既有概念節點（Code 與 Agent 地圖、AI、Karpathy LLM Wiki Ecosystem、AI Agent 簡報），再以 web_search 補充 2026-10-09 ~ 2026-10-14 的新訊號，最後手工彙整。_
