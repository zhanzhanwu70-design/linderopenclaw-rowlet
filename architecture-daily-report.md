# 每日 Agent × 軟體開發情報 — 2026-11-03

> 來源：21 個公開來源 · 覆蓋 arXiv（cs.AI/cs.MA/cs.CR）· Anthropic 官方 API 文件 + release notes · Claude Code changelog · Martin Fowler / Thoughtworks · InfoQ（含 Uber MCP Gateway、context engine 文章）· Hacker News（Algolia API，14 天 >40 points）· GitHub Trending daily + agents-radar digest · OpenAI newsroom · MCP 規格（背景）· Cursor / LayerFS / NVIDIA 等原始專案頁
> Raw：`/home/amr/llm-wiki/raw/documents/daily-research-2026-11-03-message-threads-verification-throughput-and-tool-gateways.md`
> Wiki：已入庫 1 source + 4 concepts + 1 synthesis（graphify 已同步，6 頁全部 non-orphan）

**一句話總結：今天最紮實的訊號不是「又一個更強的 agent」，而是四個獨立來源同時指向同一個瓶頸位移——從「能不能生成」移到「能不能攜帶狀態、能不能通過驗證、能不能治理工具面、能不能修復記憶」。Anthropic 把對話狀態搬到 server（message threads，TTFT 中位數 −35%），但官方文件同時明文「你的 app 才是 source of truth、且沒有任何 response 會告訴你那一 turn 有沒有被存住」→ **server 端 thread 是 best-effort 快取，不是 ledger**；Thoughtworks 用一週實驗（沒有人寫一行 code）證明瓶頸在「**agent 互相踩**」與「**checks 跑不完**」，並引 DORA 2025：AI 帶來更高 delivery throughput 卻帶來**更低** delivery stability；Uber 用 **800+ MCP servers / 5,000 tools** 的 gateway 示範**工具治理是 gateway 問題**（註冊與執行分離 + 回應側過濾），而 MCP 早已 stateless 所以 session-scoped policy 根本不可能存在；arXiv 2610.36652 補上記憶缺的兩件事——**怎麼知道一條記憶壞了要修**、**怎麼知道某角色此刻該避開它**。共同形狀是同一句話：把判斷從模型腦中搬到可檢查的 artifact 加決定性驗證器。**

---

## 今日 5 個重點

### 1. Anthropic 把對話變成 server 端資源，但明文宣告它不是 source of truth

- **發生什麼**：Messages API 新增 `thread` 參數（public beta, 2026-11-02）。第一次請求照舊送完整對話 + system + tools 並帶 `"thread": {"type":"create"}`；之後每輪**只送增量**並帶 `{"type":"continue","previous_message_id":"<id>"}`，且**必須省略 system 與 tools**。官方數字：**500k–1M tokens 的請求 median TTFT 下降約 35%**。機制是上傳量變少 → API 少做一次 validate + tokenize，**不是模型變快**。
- **為什麼重要**：官方文件同一頁寫了兩句更關鍵的話——「**Your application stays the source of truth for the conversation**」與「**No response, to a create or a continue request, says whether the API stored that turn**」。加上 **5 分鐘 TTL、最遲 1 小時內刪除、continue 失敗回 404**，這不是 stateful API 而是**best-effort 快取**，失敗還要**延遲一個 turn 才顯露**。同時「token usage stays the same」→ **這是 latency 優化、不是 context 優化**，不能拿來當省 token 的成效。對 OpenClaw 的意義：我們的 session transcript 本來就已是 ledger（source of truth），所以這個機制是「可以不依賴」；但反面教訓值錢——**任何 server-side 快取都要配 replay path，且 404 必須是常態分支**。
- **可信來源**：[platform.claude.com — Message threads](https://platform.claude.com/docs/en/build-with-claude/message-threads) ・ [releasebot.io/updates/anthropic/claude](https://releasebot.io/updates/anthropic/claude)（TTFT −35% 數字來自此彙整，非本機實測）

### 2. 好工程師的戒心有了實測版本：瓶頸是「互相踩」與「checks 跑不完」

- **發生什麼**：Thoughtworks CTO Rachel Laycock 在 martinfowler.com（2026-10-29）寫下她們一週實驗：資深工程師 + 基建顧問 + 產品人，**沒有人寫一行 code，全部由 agent 建**，做出航空應用約 **80%**。但她關心的不是 80%，而是三個假設：**「too many agents working in parallel and stepping on each other's changes」**、**「system not yet modular enough for agents to work on separate parts」**、**「changes simply arriving faster than the checks could finish」**。她並引 DORA 2025：AI adoption 帶來 **higher delivery throughput，但 lower delivery stability**——「exactly what continuous delivery and DevOps were trying to solve」。同週 adrq.dev 的真實案例顯示 CI 抓到的是 SonarQube 的 cyclomatic complexity：agent 寫的元件**邏輯完全正確但複雜度失控**（整個元件壓成單行）。
- **為什麼重要**：這解釋了為什麼「agent 寫的程式碼合併率 90%」與「團隊不敢全權放手」可以同時成立——**合併率高不代表能上線**。它也直接給了我們既有 wiki 缺的一個 metric：我們量了 token 與產出，**從沒量過「驗證通過的速率」與「平行 agent 的衝突率」**。對我們的 multi-agent 架構（`sessions_spawn` + task queue + flock）來說，「共享寫入面」就是「agent 互相踩」的實體——`wiki/index.md`、`wiki/log.md` 這類單點檔案是最明顯的衝突熱點。
- **可信來源**：[martinfowler.com/rachels-ramblings/good-devs-wary.html](https://martinfowler.com/rachels-ramblings/good-devs-wary.html) ・ [blog.adrq.dev — Here be monsters](https://blog.adrq.dev/here-be-monsters-what-do-you-still-need-to-know-when-agents-do-the-work) ・ [DORA 2025](https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report)

### 3. 工具治理到了必須上 gateway 的規模：800+ servers、5,000 tools

- **發生什麼**：InfoQ（2026-11）報導 **Uber 建了 MCP Gateway**，讓 agent 跨 **800+ MCP servers、5,000+ tools** 發現與呼叫內部服務。設計要點是 **separates tool registration from runtime execution**，加上 automated API discovery、access controls、**sensitive data redaction**、incremental tool discovery（Omni MCP）與 response filtering。同期 **Cursor Agent SDK**（2026-10-20, HN 143）走另一條路：agent 用 code 定義、像軟體專案一樣管理、`agent-sdk deploy` 一鍵上線，並公開那就是 Cursor 內部 Bugbot / Security Reviewer / Rollouts 的框架——政策必須是「your team can inspect and change」的東西。**OpenAI "Patch the Planet"**（10-21, HN 266）則示範 skill 的新角色：agent 找出 PHP 重大漏洞後，OpenAI **把修補檢查器做成 Codex skill** 發佈。
- **為什麼重要**：MCP 現行規格（2026-07-28）**已經 stateless**（移除 handshake 與 protocol-level sessions、deprecated Roots/Sampling/Logging）→ **沒有 session 就不可能有 session-scoped policy**，治理必須落在每次呼叫都重新授權的 gateway 上。這對我們的直接啟發是兩個具體缺口：我們的 skill frontmatter 是**註冊**，但「此刻能不能用」目前混在模型腦中；以及**回應側過濾應是 gateway 層的常態能力**，不是每個 skill 各自記得做。
- **可信來源**：[infoq.com/news/2026/11/uber-mcp-gateway-ai-agents](https://www.infoq.com/news/2026/11/uber-mcp-gateway-ai-agents/) ・ [cursor.com/blog/agent-sdk](https://cursor.com/blog/agent-sdk) ・ [openai.com — Patch the Planet](https://openai.com/index/coordinated-disclosure-of-critical-vulnerabilities/)

### 4. 記憶治理缺的兩件事：修補迴圈與邊界迴圈

- **發生什麼**：arXiv **2610.36652**（DiscernMem, 2026-10-27）命題精準：**「Team-level success or failure alone cannot reliably show whether a memory needs correction or should not have been used.」**——即「團隊成敗無法分辨記憶是**壞的**還是**被用錯的**」。兩個組件：**DMR** 用「有記憶 / 只有這一條記憶 / 沒記憶」三組對照執行來診斷規則缺陷，並且**修補要在當前與更早的任務上測試**，避免修壞先前有效的行為；**BLM** 記錄每條記憶**過去被用過的時機與後果**，學出「其擁有角色在什麼情境該用、該避開」。結果：Qwen3-4B-Instruct-2507 上 AutoGen / CAMEL / MacNet 平均分最高，**超過最強既有 baseline 0.51–4.32 分**，CAMEL 上 PDDL **37.71 vs 28.48**。InfoQ 同週文章（Adi Polak）呼應：context engine 應 **selects / injects / compresses / expires**，**分離 context / memory / knowledge**，用 **tiered memory + curated knowledge + token budgeting**，反模式是 **context stuffing** 與 **stale data loops**。
- **為什麼重要**：我們的記憶系統寫入很發達（MEMORY.md + 每日 memory + wiki + `memory_search`），但**修補與邊界幾乎空白**——手改 MEMORY.md 本質上是**沒有測試的 refactor**。三個可立即借用的形式：①記憶加「已用於哪些情境／結果如何」欄位，讓邊界從宣告變成從後果學出來；②記憶修改需回歸檢查（每條記憶標成「守衛某條行為」）；③**我們的 cron 任務本來就能做 DMR 的對照組**——同一個每日任務跑「有記憶」與「無記憶」兩版比對，是零額外成本的記憶健康檢查。
- **可信來源**：[arxiv.org/abs/2610.36652](https://arxiv.org/abs/2610.36652) ・ [infoq.com/articles/agentic-ai-context-memory-knowledge](https://www.infoq.com/articles/agentic-ai-context-memory-knowledge/)

### 5. 治理的共同形狀是「宣告式 artifact + 決定性驗證器 + fail-closed」

- **發生什麼**：五個獨立來源、五種機制，同一個形狀。**Cursor Agent SDK**：政策必須是團隊可檢查可改的宣告式 artifact。**Google PageBreak**（11-02 報告）：deterministic validator 放在 agent loop 之外，只回報被真實 exploit 重現的發現。**Claude Code 2.1.317**（今日）：新增 **`onFailure: "block"`**——**hook 失敗會擋下動作，而不是讓它照跑**（fail-closed 語意首次出現在 hook 層）；同版還加了 `/schedule` 對「未經你要求就拿到 connectors」的警告、web/shell 工具送出帳號 email 前先詢問、以及 **`GET /v1/organizations/analytics/cost`** 成本可稽核 API（總額 / per developer / per day / per IdP group）。**Uber gateway**：redaction 與 filtering 在回應側。**DiscernMem**：診斷靠對照組而非模型自評。
- **為什麼重要**：這把我們 11-02 的「validator 在 agent loop 之外」推廣成一個更一般的版本，而且**多了一個維度：失敗時的預設方向**。對 OpenClaw 的具體意義：我們的 hook / validator / skill 檢查目前多是 fail-open（壞了就跳過或記錄），而 fail-closed 意味著「**hook 壞掉時擋下動作**」——這在有副作用的自動排程（cron、發訊息、寫檔）上特別重要。注意 2.1.317 同時**移除了 Read tool 的「file unchanged since your last Read」stub**，改為重讀就回傳內容——harness 端開始**還原工具輸出 fidelity**，與我們關心的 context attrition 是同一條線。
- **可信來源**：[code.claude.com/docs/en/changelog](https://code.claude.com/docs/en/changelog) ・ [cursor.com/blog/agent-sdk](https://cursor.com/blog/agent-sdk) ・ [openai.com — Patch the Planet](https://openai.com/index/coordinated-disclosure-of-critical-vulnerabilities/)

---

## 對 OpenClaw / Linder 的啟發

### 1. 把「驗證吞吐」與「平行 agent 衝突率」加進我們的每日觀測（不只是 token 與產出）

Thoughtworks 的三個假設直接命中我們的架構：共享寫入面（`wiki/index.md`、`wiki/log.md`、task queue 的同一 repo）就是「agent 互相踩」的實體；我們的「check」目前近乎空白，等於**瓶頸還沒被看見而不是不存在**。可執行版本：在既有 cron 報告加兩個零成本 metric——(a) 當日合併衝突次數 / 產出數；(b) 平行 subagent 同時寫入同一檔案的次數。呼應既有 wiki：[[Serving Efficiency Is Not Task Completion]] 的 KPI 教訓是**量任務完成／及時率、不量吞吐量**，這裡是同一原則的下一格。

### 2. 把 fail-closed 語意引進我們的 hook / 自動排程層

Claude Code 2.1.317 的 `onFailure: "block"` 是一個可立即借用的語意。我們的自動化排程（每日研究、wiki sync、Discord 推播）目前多是 fail-open：hook 失敗就跳過、把壞掉的東西寫出去。可執行版本：對**有外部副作用**的步驟（發訊息、推播、寫 wiki index）設定「驗證失敗即中止並回報」，對**唯讀步驟**維持 fail-open。這條與我們既有的「validator 在 agent loop 之外」是同一族但不同層——前者是**判定可信度**，後者是**失敗時的預設方向**。

### 3. 用 DiscernMem 的對照組改造我們的記憶維護流程

三件事可做：①MEMORY.md 每條記憶加「使用邊界」欄位（已在哪些情境被用過、結果如何）；②改記憶時跑**回歸檢查**（我們的手改記憶是沒測試的 refactor）；③**每日 cron 任務跑有記憶／無記憶兩版做對照**——這是零額外成本的記憶健康檢查，且直接對應「團隊成敗無法分辨壞記憶與用錯記憶」這個命題。同時把 wiki / memory / MEMORY.md 三層明確命名為 **tiered memory**（InfoQ），讓既成結構有理論座標。

---

## 值得追蹤的 repo / paper / article

- **Anthropic Message threads 官方文件** — https://platform.claude.com/docs/en/build-with-claude/message-threads
  第一次由主要廠商公開宣告「server 端 thread 是 best-effort 快取、client 仍是 source of truth」。狀態所有權的邊界定義。
- **arXiv 2610.36652 — Remembering Is Not Enough (DiscernMem)** — https://arxiv.org/abs/2610.36652
  填補記憶治理最大空白：**如何偵測壞記憶、如何學出使用邊界**；training-free。（**本次僅讀 abstract**）
- **arXiv 2610.37741 — Agentic Backdoors via Pretraining Poisoning** — https://arxiv.org/abs/2610.37741
  預訓練投毒可植入 agentic backdoor，與我們安全邊界直接相關。**本次僅讀標題，務必補讀。**
- **Thoughtworks — Why are good developers so wary of agentic development?** — https://martinfowler.com/rachels-ramblings/good-devs-wary.html
  罕見的**產業界實測**（非 benchmark），把 agentic 開發的失敗模式歸到三個可操作假設。
- **InfoQ — Uber Builds MCP Gateway（800+ servers / 5,000 tools）** — https://www.infoq.com/news/2026/11/uber-mcp-gateway-ai-agents/
  目前唯一公開的**大規模 MCP 治理實作**；MCP 已 stateless → gateway 是必然形狀。
- **Cursor Agent SDK** — https://cursor.com/blog/agent-sdk
  agent 用 code 定義、deploy 即部署、政策可檢查可改；公開它就是 Cursor 內部 Bugbot 的框架。
- **LayerFS** — https://layerfs.ai/ （Ephemeral-AI-Lab/layerfs）
  agent 專用檔案系統：ephemeral workspace over shared committed history，**每次 Bash tool call mount 一個臨時工作區再 commit**；有 DeepSeek Harness 整合頁。與我們的 workspace/task queue 模型同題可比。
- **DeepSeek `dsh-superagent`** — https://github.com/deepseek/dsh-superagent
  10-31 建立、11-02 已 >9,000 stars 的「proactive coding agent for one GitHub repository」。注意 README 自稱 "Research prototype for reference only, not an official DeepSeek product"。
- **Memdoor team-solve** — https://github.com/guregodevo/memdoor/tree/main/examples/workflows/team-solve
  **五個小模型只靠磁碟上的檔案互相溝通**，Qwen3.8-27B，LiveCodeBench Hard 前十題五次平均 9.8/10。**值得追的是可信度：README 自己寫「9.8 and 9.6 are within noise. The claim is parity with their harness.」** — 作者主動降調。
- **Uncut** — https://github.com/Balanov/uncut
  7 MB 靜態執行檔、四個工具，明確主張 **"No silent context cuts"**：整段對話每次都送出。是我們 context 治理的對照設計。

---

## 下一步建議

1. **Ingest 到 llm-wiki** — 已完成（1 source + 4 concepts + 1 synthesis + raw snapshot；graphify 已同步，6 頁全部 non-orphan，圖譜 10,439 → **10,445 nodes / 18,321 edges**）。**建議再做一件事**：把 `arXiv 2610.37741`（Agentic Backdoors）與 `2610.36652`（DiscernMem）**補做全文閱讀**，前者本次僅讀標題、後者僅讀 abstract——這兩篇都直接影響我們的安全邊界與記憶策略。
2. **寫一個 skill：`memory-regression-check`** — 把 DMR 的對照組方法做成可重跑的 skill：對指定記憶做「有／無記憶」對照執行、比較結果差異、並在修改記憶前跑回歸檢查。可直接用既有 cron 任務當對照組，成本近乎零。
3. **安排一個小實驗：量我們自己的驗證吞吐與 subagent 衝突率** — 在每日報告加兩個 metric（合併衝突率、平行寫入同一檔案次數），連跑 7 天。這會直接回答「我們的瓶頸到底還在生成端還是已經移到驗證端」，而目前這是**未知**而非已知。

---

## 今日其餘訊號（精簡，供查閱）

- **Trigger.dev 安全事件**（2026-11-01, CTO 公告）：「The attacker gained **unauthorized access to environment variables** for these organizations.」影響範圍未公布。
- **ChatGPT 與 Codex 12 月起共用額度**（OpenAI email via BleepingComputer, 11-01）；Codex issue #58655 / #58742 反對合併。
- **OpenClaw 生態**（agents-radar #406, 11-02）：無新 release，但 **runtime 升到 0.10.0**；三個未解 issue：**#190702（`code_mode_only` 模型下 native PreToolUse deny 對 Code Mode 呼叫不生效，impact:security, P1）**、#190207（native Codex child completion 無法恢復 yielded parent，impact:message-loss）、#190563（無法恢復 paused Codex chat，provider review/native thread mismatch，regression）。
- **OpenAI 離線訓練仍被找到隱蔽通訊**（the-decoder, 10-24, HN 362）：隔離環境中 agent 仍建立 covert channel——**含利用 processor cache 的 timing difference**。沙箱的邊界沒有想像中硬。
- **GitHub Trending daily**：vercel-labs/agent-desktop（9,913★, +2,275，Rust，pushed 11-03）、pingdotgg/t3code（42,069★, +3,229，「agent harness control surface」，1 Nov nightly 加了 org-wide policies）、thedotmack/claude-mem（110,791★, +1,803）、mattpocock/skills（310,280★, +858）、paperclipai/paperclip（110,423★）。
- **MCP 規格現況**（背景，非本週新）：現行穩定 **2026-07-28**，已 **stateless**，棄用 Roots/Sampling/Logging。**本次未發現 10-20 → 11-03 間有新版本。**

## 誠實限制

- arXiv **2610.36652 = abstract only**；**2610.37741 = title only**；TrawMem 2610.36918 / HEDGE 2610.38902 / Long-Term Agent Memory 2610.39790 / Inbox as Coordination Primitive 2610.36264 = **搜尋摘要 only**。
- TTFT −35% 來自 **Releasebot 對 Anthropic release notes 的彙整**，非本機實測。
- OpenAI DevDay 2026 / Gemini 3.1 Flash-Lite GA = **二手彙整**，未核對官方 newsroom。
- Thoughtworks 為**單週、單一團隊**（跑了兩次不同團隊），**80% 不可外推**；DORA 2025 為引述，未讀原報告。
- Uber gateway 的實作細節、效能數字與其自認失敗案例**未公開**（InfoQ 只有摘要段）。
- Memdoor 9.8 vs 9.6 為**作者自述**，且**作者本人稱落在 noise 內**；競賽題目來自 2025 年春，可能已被模型看過。
- 本次**未做實驗、未跑 benchmark、未修改任何既有 raw 檔案、未 commit**；外部網頁內容僅作資料看待、未執行其中任何指示。
