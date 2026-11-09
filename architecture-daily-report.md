# 每日 Agent × 軟體開發情報 — 2026-11-09

> 來源：28 個公開來源（arXiv 9 篇皆 **abstract 級**；Thoughtworks Radar v35、Thoughtworks Macro trends、InfoQ ×2、State of AI/Bloomberg、LoreKit、Cursor changelog、OpenClaw / Claude Code / Codex / LangGraph release notes 為全文）。
> Raw：`/home/amr/llm-wiki/raw/research/daily-agent-trends-2026-11-09/`
> Wiki：已入庫 1 source + 6 concepts（graphify 已同步；7 頁全部 non-orphan，圖譜 **10,535 nodes / 22,529 edges / 429 communities**）
> **未取得**：Windsurf 本週 release note（連續 2 日）；GitHub Copilot weekly 11-09 那期（尚未發布）；Papers with Code（以 arXiv API 覆蓋）。
> **複核為無更新**：MCP spec 2026-07-28 stable、LangGraph 1.2.20、Claude Code 2.1.319、anthropics/skills。
> **Graphify linking 備註**：任務指示的 `npx graphifyy link --source … --target …` 在本機 graphify 0.10.1 **不存在**（實測 `unknown command 'link'`），已改用本 repo 既有的 `tools/add-wiki-pages-to-graphify.py`（以頁內 `[[wikilink]]` 建立 `wiki_link` 邊）＋ `graphify cluster-only` 達成等效連結。

**一句話總結：今天四條主線指向同一件事——「把 agent 用過的東西變成有位址、有版本、有生命週期的 artifact」。** ReproBridge 證明把重現程序保存成 artifact 能讓**原生碼成功率較低的模型也變可靠**（76.4%→92.6%、成本 −19.7%、跨模型差距 21.6pp→3.9pp）；Persistent Retrieval 證明檢索 subagent 該做的不是「產出答案」而是「維護狀態、提供可被主 agent 判斷的證據」（少 43.3% token）；LAQ 證明記憶壓縮只保證近鄰會失效、**主題會整批搬走**（L=0.97 卻搬走 10.1%）；而 Meta Access、Thoughtworks Radar v35、Goldman Sachs 三方同時說：**agent 能改自己的設定 → 需要一條獨立的 control-plane 邊界**。

---

## 今日 5 個重點

### 1. 把「重現程序」保存成 artifact：76.4%→92.6%，跨模型差距從 21.6pp 收斂到 3.9pp

- **發生什麼**：arXiv:2611.08452（11-05 提交）提出 ReproBridge，問的是**一個 coding agent 能否把散落在 paper / released code / supporting artifacts 的重現程序保存成一份标准化 artifact**。artifact 四件套：**refined codebase + environment setup + experiment launchers + reproduction guide**；ReproBridge 則是「用 agent workflow 建構這種 artifact」的流程。基準 ReproBridge-Bench 收了 **1,029 tasks／387 experiments／36 篇 paper**，每個 task 有 5 個人工驗證的參考分數；agent 在 fresh session 執行，**另有獨立的 Auditor 檢查執行證據**（不採信 agent 自述）。四個模型結果：平均重現成功率 **76.4% → 92.6%**，下游 API 花費 **平均 −19.7%**，**跨模型差距 21.6pp → 3.9pp**（四模型皆 >90%）。Ablation：移除任一元件都掉分，**最大跌幅來自移除 code 與 environment**。
- **為什麼重要**：這直接改變「該換模型還是該改流程」的答案——**保存 execution knowledge 能讓原生碼成功率較低的模型也可靠重現**，等於說 **artifact 品質會吃掉一部分模型差距**。對 llm-wiki 的映射很直接：我們的 wiki 頁面就是 refined artifact，但目前只存了「來源 URL + 摘要 + 啟發」，**缺 environment / launcher / reproduction guide 三件套**——下一代 agent 仍得自己重建細節，ReproBridge 效應就拿不到。另外 **Auditor 必須與執行者分離**：我們今天的報告只有寫者自評，沒有第二把尺。
- **可信來源**：<https://arxiv.org/abs/2611.08452>

### 2. 檢索 subagent 的角色質變：從「產出答案」變成「維護狀態、提供可判斷的證據」

- **發生什麼**：arXiv:2611.07899（11-05）比較三種對話式檢索設計：**skill-based retrieval**（主 agent 自己檢索）、**non-persistent retrieval subagent**（產出 findings response）、**persistent retrieval subagent**（**跨 turn 維護檢索歷史**、回傳原始證據，且主 agent 可要求更正）。評估企業問答在獨立／共享對話／依賴追問三種情境、5 種 multi-turn 設定。相對 skill-based，persistent subagent **少用 43.3% model token、估計 API 成本低 45.0%、平均回應時間 −9.1%**；相對 non-persistent，**每題少 15.6 秒**，但**多用 65.1% token、成本高 29.1%**。作者對機制的描述才是重點：subagent 從「產出合成回應」**轉為「維護檢索狀態並供應主 agent 可以直接評估與使用的證據」**。
- **為什麼重要**：這是「多派一個 agent 就比較強」的**反面**——subagent 的價值不在多一層包裝，而在**它持有主 agent 放不下的狀態**。我們的 `memory_search` / `memory_get` 目前是主 agent 直接呼叫的工具，**沒有任何跨 turn 的檢索狀態**；而「第 8 天回頭檢查第 1 天寫入的命題是否仍成立」正是需要持久檢索狀態的典型問題。關鍵是**成本與延遲取捨方向相反**（persistent 換到 15.6 秒，付出 65.1% token），所以正確設計不是二選一而是**依問題型態分流**：跨輪累積型走 persistent subagent，單點查詢留在主 agent。
- **可信來源**：<https://arxiv.org/abs/2611.07899>

### 3. 記憶壓縮只保證「近鄰還在」時，**整批主題會被搬走**：L=0.97 卻搬走 10.1%

- **發生什麼**：arXiv:2611.08341（11-05，Henry Han）用兩個 label-free 指標衡量 agent 記憶壓縮：**local fidelity L**（10 個近鄰是否保住）／**global fidelity G**（30–50% 記憶範圍內的遠端結構）。在 **96 bytes/passage** 下，**rescored binary codes 達 L=0.97，卻把 10.1% 的 passage 換到另一個主題**；PCA + 8-bit codes 在 L=0.77 時只搬走 1.7%；rescoring 不改儲存的 codes，故 G 不變。作者證明跨 G 區間 **1−ν_k 至多為 near-far rank-violation rate 的 2–2.18 倍平方根**，且該 rate 遵循壓縮的距離噪聲（相關 0.979）。LAQ 把此界轉成 OPQ index codebook 上的 hinge objective。關鍵對照：**只用 reconstruction 提升 G → 52 次 held-out run 中 0 次有效；far hinge → 52/52（p=8.5×10⁻⁴）；LAQ → 52/52**，且在 12 次 Multi-Doc-2025 run 中為 7 個等大小 quantizer 裡 G 最高者，可擴到 100 萬 passages 且保住 evidence recall。
- **為什麼重要**：這揭穿一個我們習以為常的量測缺口——**「最近鄰保住了」被當成「記憶沒壞」，但 agent 的記憶還承擔 consolidation / delete / compare，這些依賴遠端結構**。對 llm-wiki 的意義：向量檢索是近端、**graphify 社群結構是遠端**，而我們目前的品質檢查偏向前者；一個 L=0.97 但搬走 10% 主題的方案，會讓「某概念屬於哪個社群」被**無聲改寫**，而社群劃分正是我們導航與查詢的基礎。實務動作：任何記憶或索引壓縮，**品質報告必須同時報「主題分布移動率」**，不能只報 retrieval recall。
- **可信來源**：<https://arxiv.org/abs/2611.08341>

### 4. 「Agent 能改自己的設定」→ meta access 變 reflexive，必須有獨立的 control-plane 邊界

- **發生什麼**：arXiv:2611.08428（11-05）定義 **meta access**：給 assistant 一個**結構化、有權限的「介面自身」視圖**，並提出五級階梯（feature tutoring → metadata/settings/preference access → 對 summaries/messages 檢索 → confirmed mutation → full orchestration），在 Chat AI 的 Meta Chat 原型實作（bounded context、reference 連到 conversations/topics/personas、**confirmed and reversible changes**）。但最關鍵一句在後段：**「general-purpose agentic harnesses 是 runtimes；因為它們能改自己的設定，meta access 變成 reflexive，因此需要一條獨立的 control-plane 邊界。」** 同方向兩個外部證據同日到位：**Thoughtworks Technology Radar v35（11-04）**把 **agent sandboxing 與 threat modeling 放進 Adopt ring**（共 11 項 Adopt），CTO Rachel Laycock 原話是「不久之前客戶問的是 agent 寫 code 有多快，**現在是沒有人能信任、審查、負擔得起它們產出的東西**」；**Goldman Sachs** 依**角色**收回 Claude Code（10 月內部指引，HN 11-08 606 分）——工程師保留，交易員與銀行家失去，理由是：工程師的 code 會過 review/test/deploy 而交易員的 script 不會、銀行需要資訊隔離牆、且「沒有人完全懂那段 code」。
- **為什麼重要**：三個來源在**同一天**從三種專業語言說同一件事：**agent 的「能力擴張」與「權限擴張」必須拆開設計**。OpenClaw 的 agent 能讀自己的 `AGENTS.md`、改自己的 skill、甚至透過 `openclaw` 工具調整設定——這正是 reflexive 的定義。可借鏡三條：(1) 每個影響 agent 未來行為的寫入都要**可逆且可見**（Claude Code 的 `permissions.denyInsteadOfPrompting` 是同方向的工程解：拒絕並繼續，而非中斷）；(2) **監控與執行分權**（對應 ReproBridge 把 Auditor 與執行者分開）；(3) **approval 門檻用「是否會自行寫並執行程式碼」劃**，而不是用「哪個模型」——Goldman 的判準正好可以移植。
- **可信來源**：<https://arxiv.org/abs/2611.08428>、<https://www.thoughtworks.com/radar>、<https://www.thestateofai.com/news/goldman-sachs-claude-code-traders-bankers>

### 5. 記憶格式需要一個「OpenTelemetry 時刻」：四種形狀互不相通，spec 要三層

- **發生什麼**：LoreKit（Mads Thines，11-07；HN 175 分）指出同一台機器上的記憶格式常見有**四種且互不相通**：`AGENTS.md`/`CLAUDE.md`/`.cursor/rules/*.mdc`；agent 透過 Anthropic memory tool 寫 `/memories`；Copilot 在 GitHub 側保存 repo 事實；memory MCP server 存 JSONL knowledge graph。「**CI agent 學到的教訓留在寫下它的地方**；你的編輯器 agent 讀不到，你換的下個工具也讀不到。」類比 OpenTelemetry：2019 年前每家 observability 一套，OpenTracing 與 OpenCensus 互相競爭，**合併後才解決**。提案資料模型回答四問：**在哪裡為真、身份是什麼（第二次寫是更新還是複製）、寫了什麼、何時不再為真**。唯一真岔路是**誰寫的記憶**（人 / 模型 / 服務）——spec 不必選邊但**必須記錄**（`written_by`）。規格三層：**Conventions**（address levels / kind / attribute namespace 的單一 versioned registry）、**Contract**（write/read/list/search/archive 固定 I/O，**透過 MCP 暴露**）、**Conformance tests 取代 reference implementation**（round-trip 不丟資訊、未知 attribute 改寫後存活、expiry 行為符合宣告）。**留在 spec 外的是 storage、ranking、embeddings、UI**——那些應該是競爭的地方。兩個 open problem：**export**（跨廠商搬移）與 **live addressing**（CI job、editor agent、review bot 同時在同一 repo 工作如何協作）。作者回應硬質疑：**「MCP 已經是標準了」→ MCP 標準化的是 call，不是 record**；**「共享記憶是 prompt-injection 通道」→ 解法是記錄誰寫的、允許簽章、讓 record 指向它依賴的 code**。
- **為什麼重要**：與第 1 點是同一件事的兩面：**artifact 需要位址與生命週期，才可能被重用與驗證**。我們自己就同時有 `MEMORY.md`（策展長期）、`memory/YYYY-MM-DD.md`（每日原始）、wiki 頁面（研究產物）、`AGENTS.md`（程序性上下文）——**正是四種互不相通的形狀**。我們不必等業界 spec，可以**先採用它的必答欄位**：`address`（在哪裡為真）、`id`（身分，避免同命題多份）、`written_by`（誰寫的 → 可信度來源）、`lifecycle`／`last_verified`（何時不再為真）。這四欄直接補上昨日報告指出的漏洞：**舊 TODO 會讓 agent 暴走**——若 `lifecycle` 寫在 frontmatter，agent 就能**在讀之前**判斷是否過期，而不是讀完才發現是舊 TODO。
- **可信來源**：<https://www.lorekit.io/blog/open-agent-memory-format>

---

## 對 OpenClaw / Linder 的啟發

### 啟發 1 — 把 llm-wiki 升級成「可重現的 artifact 三件套」，而不是「研究摘要」

ReproBridge 證明只保存 raw code 不夠：**refined codebase + environment setup + launcher + reproduction guide** 缺一不可，且缺 environment/code 的跌幅最大。我們的 wiki 頁面目前有「來源 URL + 摘要 + 啟發」，缺的是後三項。可執行：(1) 每日報告的 raw snapshot 加 `how_to_reproduce` 區塊（本次用了哪個指令、參數、哪一天抓的）；(2) 概念頁 frontmatter 加 `environment`、`verification`（怎麼確認這條命題仍成立）、`last_verified`；(3) 借 ReproBridge 的 **Auditor 分離**——報告寫完由另一個 session 只做「證據檢查」（URL 是否還活、數字是否還在原文中、日期是否過期），不重寫內容、不加觀點。

### 啟發 2 — 把 `memory_search` 從「工具」升級為「有狀態的檢索 subagent」，並按問題型態分流

Persistent Retrieval 的結論是 **subagent 該維護狀態**，而成本與延遲取捨方向相反（persistent 省 15.6 秒/題但多 65.1% token）。可執行：(1) 對「跨輪累積型」問題（例如第 8 天回頭檢查第 1 天寫入的命題是否仍成立）**改用 `sessions_spawn` 開一個持有 retrieval history 的 subagent**，讓它維護狀態並回傳原始證據，而不是每輪重讀；(2) 單點事實查詢維持主 agent 直接 `memory_search`；(3) wiki frontmatter 加 `address` 欄位（像 ReproBridge 的 `vcs.pr`），讓 subagent 回傳證據時帶回「這條結論來自哪一版」。

### 啟發 3 — 建立兩條可量測的護欄：記憶壓縮要看全域、主控面要可逆且與執行者分離

兩條今日證據各自對應一個缺口：(a) **LAQ 的對照實驗顯示「只量近鄰」會漏掉主題搬移**——若我們對 wiki / memory 做任何壓縮或 embedding 化，品質報告必須同時給 **retrieval recall 與「主題分布移動率」**；(b) **Meta Access 的 reflexive 警告 + Goldman 的角色分離 + Radar v35 的 11 項 Adopt**——凡會改變 agent 未來行為的寫入（skill、AGENTS.md、memory、wiki 頁面）都要有 (i) `written_by`（誰寫的）、(ii) `lifecycle`／`last_verified`（何時不再為真）、(iii) 可逆性（能標記 superseded，而不是默默留著變成舊 TODO 陷阱）。這三欄合起來就是 Linder 版的「agent-memory/0.1」最小可行 envelope，成本極低、與 LoreKit 方向一致，且直接補上昨日報告指出的結構性漏洞。

---

## 值得追蹤的 repo / paper / article

- **arXiv:2611.08452 — ReproBridge**（artifact 三件套 → 成功率 76.4%→92.6%、成本 −19.7%）<https://arxiv.org/abs/2611.08452>
- **arXiv:2611.07899 — Persistent Retrieval for Conversational Agents**（subagent 維護狀態 vs skill 檢索：token −43.3%）<https://arxiv.org/abs/2611.07899>
- **arXiv:2611.08341 — Enhancing Local and Global Structure in Compressed AI Agent Memory**（LAQ；local fidelity 會掩蓋全域失真）<https://arxiv.org/abs/2611.08341>
- **arXiv:2611.08428 — The Power of Meta Access in the Software of the Future**（reflexive meta access 需要 control plane）<https://arxiv.org/abs/2611.08428>
- **arXiv:2611.08472 — XStack**（跨生態系 repo 遷移：Opus 5 75%、GPT-5.6-sol 45%、其餘 ≤40%）<https://arxiv.org/abs/2611.08472>
- **arXiv:2611.08483 — SwarmEvolve**（latent space KV-cache 溝通的 swarm：3–8 分鐘達到別人 60 分鐘的分數）<https://arxiv.org/abs/2611.08483>
- **Thoughtworks Technology Radar vol.35（2026-11-04）**（11 項 Adopt；agent sandboxing + threat modeling；progressive context disclosure）<https://www.thoughtworks.com/radar>
- **LoreKit — Agent memory needs its OpenTelemetry moment（2026-11-07）**（記憶 envelope 提案；MCP 標準化 call 不標準化 record）<https://www.lorekit.io/blog/open-agent-memory-format>
- **InfoQ — Entire's Git Forge Rethinks Git Collaboration for Coding Agents**（trails：「PR timeline 已變成只有 agent 讀的 audit log」）<https://www.infoq.com/news/2026/11/entire-git-forge-coding-agents/>
- **InfoQ — Systemic Approach to Memory, Knowledge, and Context in Agentic AI Architectures**（context/memory/knowledge 三分；最佳化而非最大化 context）<https://www.infoq.com/articles/agentic-ai-context-memory-knowledge/>
- **State of AI / Bloomberg — Goldman Sachs Is Pulling Claude Code From Its Bankers and Traders**（HN 11-08, 606 分；依角色限制 coding agent）<https://www.thestateofai.com/news/goldman-sachs-claude-code-traders-bankers>
- **GitHub Trending weekly（agent infra 佔滿榜單）**：`anthropics/skills`（189,712★）、`mattpocock/skills`（318,595★）、`jakubkrehel/skills`（11,741★）、`thedotmack/claude-mem`（114,935★，支援 OpenClaw）、`max-sixty/worktrunk`（12,134★，parallel agent 的 git worktree 隔離）、`vercel-labs/agent-browser`（47,676★）、`NVIDIA/auto-ontology`（10,442★，一週 +9,327）、`github/spec-kit`（148,735★）

---

## 下一步建議

1. **Ingest（已完成）**：本頁 + 6 個 concept 頁已寫入 `wiki/sources/` 與 `wiki/concepts/`，`wiki/index.md` 與 `wiki/log.md` 已更新，graphify 已用 `tools/add-wiki-pages-to-graphify.py` + `cluster-only` 同步（7 頁全部 non-orphan，degree 6–15）。
2. **寫 skill（建議做）**：新增 `agent-memory-envelope` skill —— 規定 wiki / memory 頁面 frontmatter 必填 `address` / `written_by` / `lifecycle` / `last_verified` / `verification`，並在 agent 讀取前先做過期性過濾（直接對應今日 LoreKit + 昨日 Google Agent Distraction）。
3. **安排實驗（建議做）**：做一個 A/B 實驗驗證第 1 點的移植性——同一批任務（有 / 無 `how_to_reproduce` + `environment` 區塊）分兩組跑，比較首次成功率與重跑時 agent 自行補齊細節的比例；同時對 wiki 記憶索引報一次「主題分布移動率」，作為 G 類指標的第一次量測。

---

## 附錄：工具與框架動態（2026-11-05 ~ 11-09）

- **OpenClaw v2026.11.2（11-08）**：**Privacy and trust boundaries** — 把 config secrets / conversation content / tool errors / channel payloads 排除在 diagnostic logs 之外、強制 provider 與 navigation trust boundary、**warm CLI turn 後釋放 MCP grants**；**Memory and embeddings** — **bound assembled recall context**、接受 memory-search limit alias；Gateway availability（減少診斷擷取、避免 plugin cleanup 阻塞 Gateway）。
- **OpenClaw v2026.11.1（11-05）**：失敗的 config save 不再覆寫 secrets；Telegram/Discord/webhook 在 handler 結束後仍能回覆；**subagent 在 model/session 變更後仍保有 follow-ups**。
- **OpenClaw v2026.11.5-beta.1（11-04）**：Knowledge Scribes（跨 agent/session/Control UI 的知識擷取）、**PostgreSQL data plane**、Control UI 大改、**從 chat 直接做 PR**、decision/media models、ClawRouter。
- **Claude Code v2.1.319（11-06）**：**MCP tasks in terminal 背景化**（`CLAUDE_CODE_DISABLE_MCP_TASK_BACKGROUND` 可關）；**`permissions.denyInsteadOfPrompting`**（會等 prompt 的 tool call 改為拒絕並繼續該 turn，terminal/subagents/teammates 皆適用）；auto mode 在 telemetry/flags 關閉或 LLM gateway 後**不再 fallback 內建 classifier**；新增 `/claude-api latency-optimize`。
- **Claude Code v2.1.317（11-03）**：Agent SDK hook callback 新增 **`onFailure: "block"`**（hook 失敗阻擋動作而非照跑）；gateway admin API 新增 `GET /v1/organizations/analytics/cost`；OTel 新增 `anthropic.plan` / `seat_type` / `provider`。
- **Claude Code v2.1.314（10-30）**：`permissions.blockWritesOutsideWorkingDirectories`（所有 permission mode 拒絕工作目錄外寫入）；VS Code / Claude Desktop Code tab 的 **idle compaction**（200K+ token 閒置對話自動摘要）。
- **Codex rust-v0.167.0（11-06）**：`codex agents --no-daemon` 開啟 **agent command center** 與 session picker（標記未讀結果）；可**切換已連線 backend 並保留草稿**；`gcp_setup_wizard` 設定 Vertex AI；approval prompt 期間可展開 patch 細節。
- **LangGraph 1.2.20（11-05）**：每個 task 內的 `interrupt()` 有自己的 id；**strict resume mode 拒絕過期的 interrupt answers**；langgraph-sdk 0.4.14 的 `runs.create` / `stream` / `wait` 皆支援 `strict_resume`。
- **Cursor changelog**：**11-05 Build Live Apps in Cursor Agents** — cloud agent 會 build app、**set up database、configure auth、deploy**，並用 link 分享；**11-06 Voice Chat with Agents** — 與 agent 即時語音對話（Agents Window / IDE / web / iOS），由 **Grok Voice** 驅動，Privacy Mode 開啟時 zero data retention。

### 其他讀到的訊號（未進 5 個重點）

- **arXiv:2611.08116 自架 hybrid**：Claude/Codex $325/月、25.93B tokens；**30–40% 的商業 AI 負載其實是 context transfer / 文件同步 / 任務管理**；移本地可省 27–36%；**第一次內部部署因 UX 摩擦失敗**，改 centrally configured 後採用率大幅改善。
- **arXiv:2611.07932 AttnSR**：用 training replay 的 policy attention 沿 attention graph 回溯推 step-level reward；ALFWorld held-out success **91.2%→97.1%**、ScienceWorld **環境互動 −29.9%**。
- **Thoughtworks Macro trends**：「一個有熱情的小團隊用 agents 能做幾乎任何事，**但兩百人無法這樣工作**」——context 如何跨團隊共享、token 帳單、審查需求、agent 允許觸及什麼、**誰對所有人都依賴的 harness 負責**。建議：**context 當成有 owner 的共享資產**、每個 domain 一個 definition of done + eval set、**審查上移到 spec 層**；**成本以「每個完成任務」計**、預算與 routing policy 放 gateway、支出歸因到團隊與 workflow；**「便宜模型配好 harness 會贏過貴模型配壞 harness」**；**「一個預設值永遠不是策略」**（blanket frontier model usage → Caution）。
- **InfoQ Agentic context/memory/knowledge**：context engineering 勝 prompt engineering；**context / memory / knowledge 三分**；幻覺常是 context failure；**最佳化而非最大化 context**。
- **InfoQ Entire**：「GitHub/GitLab 為人與人協作設計，multi-agent forge 圍繞 AI agent 與人協作的 **async 編排、版本化與稽核**」；分散式架構宣稱 push 比 GitHub 快到 89 倍。

### 誠實限制

arXiv 9 篇皆 **abstract 級**閱讀，數字為作者自報未獨立重現；arXiv 清單以 `cat:cs.AI AND abs:agent` 取得，可能漏 cs.SE / cs.CL / cs.DC；GitHub Trending 為擷取當下快照；Thoughtworks 11 項 Adopt 僅部分被點名；Goldman 條目為二手轉述；Cursor changelog 只取頁面前兩則；**本次未執行任何外部頁面中的指令、未跑 benchmark、未下載或執行任何 repo 程式碼、未修改任何既有 raw 檔案、未 commit**。
