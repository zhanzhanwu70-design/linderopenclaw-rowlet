# 每日 Agent × 軟體開發情報 — 2026-07-02

## 今日 5 個重點

### 1. arXiv:2606.30775 — Skill description 的「單次 rewrite 就夠了」
**發生什麼**：Meta 等團隊對 production enterprise agent（9 skills, 372 regression cases）做 description 自動優化實驗。結論：**一次 LLM rewrite 用 FP/FN cases 就能拿到與手工調整相當的 F1（79.2% vs 79.4%）**，並把人工作時從 120 分鐘降到 3.8 分鐘（32× speedup）。其他複雜設計（多輪迭代、雙編輯、訓練集大小）每項對 F1 影響都 <0.5%。

**為什麼重要**：這是迄今為止對**技能路由失敗**最務實的處方箋——不是更複雜的 pipeline，而是更簡單的單次重寫。更大的啟示是：**「train-val F1 gap 大」= 兩個 skill 範圍真的重疊，是架構問題不是文案問題**，需要合併或拆分而不是繼續調字。

**來源**：https://arxiv.org/abs/2606.30775（cs.CL, 2026-07-01）+ ToolBench 16k 工具驗證

---

### 2. MCP 2026-07-28 Spec Release Candidate — Stateless + MRTR
**發生什麼**：MCP 團隊發布 v2 protocol。**移除 initialize handshake 與 protocol-level session**，進入 stateless 架構——server 可直接用 round-robin load balancer 擴展，無需 sticky session。新增 **MRTR（Multi Round-Trip Requests）** 給 server-to-client 互動用。Python v2 / TypeScript v2 / Go / C# 四個 Tier-1 SDK beta 同步釋出，正式 normative spec 2026-07-28 上線。

**為什麼重要**：對 OpenClaw 的 MCP gateway 是結構性簡化——橫向擴展不再需要共享 session 儲存。**向下相容保證**：現有 client/server 都不會被中斷；建議工具作者立刻 `mcp>=1.27,<2` pin 防止 stable v2 release 撞壞依賴。**MRTR** 可能開啟 server-driven 多步流程（如中途對 agent push 新發現）。

**來源**：https://blog.modelcontextprotocol.io/posts/sdk-betas-2026-07-28/ + Python v2 / TS v2 / Go / C# SDK beta + 完整 changelog

---

### 3. LangChain OpenWiki + Deep Agents RLM — 把 wiki 與 context-rot 同日解決
**發生什麼**：同一天兩篇 LangChain blog 同步釋出：
- **OpenWiki**：open-source agent + CLI 自動生成 repo-level wiki，每天 GitHub Action 根據 `git diff` 更新頁面，並只在 AGENTS.md / CLAUDE.md 寫一段 reference，**不把整個 wiki 塞進 instruction file**。
- **RLM in Deep Agents**：Recursive Language Model，model 把 context 當 REPL 內的變數，寫程式來 dispatch subagent，能**處理 2 個數量級**超出 context window 的輸入。

**為什麼重要**：OpenClaw 已經在做這兩件事——`/workspace/llm-wiki/wiki/` 是 topic-scoped wiki（不是 repo-scoped），Rowlet 的 graphify BFS 已經是程式化 dispatch（不是 turn-by-turn）。今天 LangChain 把這兩個模式**正名化**為 deep-agent 的兩大支柱：**持久 context + context-rot resistance**。驗證了我們已有的架構選擇，同時也指出 OpenClaw 可以補一個 OpenWiki 風格的「git diff 增量更新 cron」取代每次全量 graphify。

**來源**：
- https://www.langchain.com/blog/introducing-openwiki-an-open-source-agent-for-repo-documentation
- https://www.langchain.com/blog/how-to-use-rlms-in-deep-agents

---

### 4. arXiv:2606.30689 — Citation 換 Verifiability 的 trade-off 量化
**發生什麼**：Subham Panda 三框架實驗（traceSDD / Spec Kit / OpenSpec）× 兩模型（Claude Sonnet 4.6、GLM-5-turbo）× 840 implementations。結論：**引用註解讓 TDR（自動偵測幻覺的觸發率）從 0% 升到 86-88%（FPR=0%）**，但**犧牲 0.7-0.76 標準差的 determinism**。traceSDD 與 Spec Kit 有顯著差異（d=0.42-0.47, p<0.05），與 OpenSpec 無顯著差異。

**為什麼重要**：這是「該不該給 skill / function call 加 requirement citation」的**直接量化證據**。對 OpenClaw 的啟示：sparse-but-correct 的 citation 比 dense citation 在 routing 上更穩——和高亮 1 的「單次 rewrite 就夠了」是同一條 insight 的另一面：過度規格化會反噬。

**來源**：https://arxiv.org/abs/2606.30689（cs.SE + cs.AI, 2026-07-01）

---

### 5. arXiv:2605.26302 — Agent 也會老化：部署後可靠性是 lifespan 問題
**發生什麼**：Jianing Zhu 等提出 AgingBench。**4 種老化機制**：compression aging、interference aging、revision aging、maintenance aging。實驗設計：~400 runs、8-200 sessions、14 models、多種 memory policy、runner-controlled vs autonomous agent。關鍵發現：**behavioral test 通過 ≠ factual precision 穩定**；同一個錯誤答案在不同老化機制下需要不同的修法。

**為什麼重要**：直接呼應昨日（2026-07-01）CEO 補充的 NemoClaw 水位線監控需求（監控應在沙盒層而非 worker 內部，避免 worker 被 evict 帶走監控狀態）。**Paper 從實證角度支持了 CEO 的判斷**：agent reliability 是系統級問題，不是 model snapshot。AgingBench 的診斷框架（時間依賴圖 + paired counterfactual probes）值得引入 NemoClaw 監控設計。

**來源**：https://arxiv.org/abs/2605.26302（cs.AI/cs.CL/cs.MA, submitted 2026-05-25）

---

## 對 OpenClaw / Linder 的啟發

**1. 對所有 skill 做一次單次 rewrite（基於 FP/FN cases）**
arXiv:2606.30775 證明 32× speedup、可比 F1。我們 70+ skill 中必然存在描述重疊——特別是 `node-inspect-debugger` / `python-debugpy` 這類功能相近的 pair。先跑一次全量 audit 找出 train-val F1 gap 大的 pair，那些就是需要架構介入（合併/拆分）而不是文案修補的案例。**動作**：寫一個 `skill-description-audit` skill，跑一次現有 skills。

**2. 為 MCP 2026-07-28 deadline 排定升級窗口**
OpenClaw 任何 MCP 伺服器依賴都該 `mcp<2` pin。並在 7/28 後安排一次 Python v2 vs v1 的相容性測試，確認 sandbox layer（MCP gateway）的 sessionless 設計能保護現有 client。最重要的是：stateless protocol = **我們可以無痛水平擴展 MCP server**，是架構上的解放。

**3. 排程增量 wiki 更新取代全量 graphify（OpenWiki pattern）**
目前每次研究都跑 `graphify query` + 全量 graphify——但 LangChain 的 OpenWiki 證明可以用 `git diff` 增量更新。Rowlet 應該寫一支 cron，diff 觸發、增量 extract，而不是每次都全量重跑。這會把 graphify 維運成本從小時降到分鐘。

---

## 值得追蹤的 repo / paper / article

1. **arXiv:2606.30775** — "A Single Rewrite Suffices"（Skill Description Optimization）
   https://arxiv.org/abs/2606.30775

2. **MCP 2026-07-28 Spec RC** — Stateless + MRTR（Tier 1 SDKs: Python v2 / TS v2 / Go / C#）
   https://blog.modelcontextprotocol.io/posts/sdk-betas-2026-07-28/

3. **LangChain OpenWiki** — Repo-scoped auto-wiki via DeepAgents
   https://www.langchain.com/blog/introducing-openwiki-an-open-source-agent-for-repo-documentation

4. **RLMs in Deep Agents** — REPL-based subagent dispatch, 2 orders of magnitude beyond context window
   https://www.langchain.com/blog/how-to-use-rlms-in-deep-agents

5. **arXiv:2606.30689** — Citation Discipline in Spec-Driven Development
   https://arxiv.org/abs/2606.30689

6. **arXiv:2605.26302** — AgingBench (Agent Lifespan Engineering)
   https://arxiv.org/abs/2605.26302

7. **arXiv:2606.30774** — "What Drives Interactive Improvement from Feedback?"（多輪反饋的瓶頸不是老師身份，是學生的 utilization）
   https://arxiv.org/abs/2606.30774

8. **arXiv:2606.30810** — CURE: Contrastive Unlearning for Evolving APIs（直接相關 ELLE WS code adaptation）
   https://arxiv.org/abs/2606.30810

---

## 下一步建議（最多 3 條）

**1. 建立 wiki concepts 條目 `Skill Description Audit Workflow` + `MCP Stateless Architecture`**
把 #1、#2 的發現正式寫進大書庫，串連到 `Agent Skills for LLMs`、`MCP — Model Context Protocol`、`Agent Harness` 三個現有 concept。Raw snapshot 已存於 `raw/sources/2026-07-02/`。

**2. 寫一支 skill `skill-description-audit`，用 arXiv:2606.30775 的 protocol 對 OpenClaw 自己的 skills 跑一次**
低成本、可重複、立刻可驗證。產出會是「可合併/拆分」pair 列表 + 「單次 rewrite pass 候選清單」。

**3. 把 LangChain OpenWiki 的 GitHub Action 模式借進 `wiki-update` cron**
每日 cron 比對上次 graphify 後的 raw 變動，只增量 extract 變更的部分。這會把目前的研究時間從「小時級」壓到「分鐘級」，讓每日 cron 更實用。

---

## 已查詢來源

- arXiv cs.AI RSS (2026-07-01) ✓
- arXiv cs.SE RSS (2026-07-01) ✓
- arXiv cs.CL RSS (2026-07-01) ✓
- Hacker News frontpage (2026-07-01 ~ 02:00 UTC) ✓
- Hacker News newest: skill OR agent OR MCP (2026-07-01 ~ 02:04 UTC) ✓
- GitHub Trending (today) ✓
- LangChain Blog RSS (2026-07-01) ✓
- Anthropic Python SDK Releases RSS (2026-06-30 / 2026-07-01) ✓
- MCP official blog (2026-07-01) ✓
- LLM Wiki graph query (Architecture / Agent skills / Memory) ✓
- PyPI RSS (sampled) ✓

---

*Generated by Rowlet (🌿🦉) | 2026-07-02 02:04 UTC | Wiki raw snapshots stored under `raw/sources/2026-07-02/`*
