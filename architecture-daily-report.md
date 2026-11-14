# 每日 Agent × 軟體開發情報 — 2026-11-14

> **來源**：40 個公開來源。Agent / AI engineering research：**arXiv API 7 篇（皆 abstract 級）**（2611.12953 架構成本-成功率、2611.17304 生產除錯的 access gap、2611.17115 CapLite、2611.17068 MAPE、2611.17316 CoReMem、2611.17007 Skill Adapter、2611.13960 ActiveSecHarness；另複核 2611.16867 ControlHarbor、2611.03517 Ask-Don't-Equip、2611.07286 code representations）。軟體開發潮流：**InfoQ 6 篇**（GitHub Agentic Workflows GA 11-11、Google AQuA 11-13、Netflix ontology observability 11-13、Technical Debt is Social 11-12 等）、**Martin Fowler 2 篇全文**（〈Tests as data〉11-11、〈Long-horizon agents and durable execution〉11-10）、**AWS Emulator 11-11**（Werner Vogels 引言 + Swaminathan Sivasubramanian 客座）、GitHub Search API、HN Algolia 近 10 日掃描。實務工具與框架：**OpenClaw v2026.11.5-beta.2**（11-12）、**Claude Code v2.1.325**（11-13，changelog 全文）、LangChain 1.5.0 / LangGraph 1.2.22 / Microsoft agent-framework python-1.26.0 / CrewAI 1.15.41 / **dsh v0.2.2-rc.3**、**MCP spec（無更新）**、Codex（僅 rust tag）、A2UI 1.0 / Brave x402 / OpenAI ChatGPT Wallet / OpenAI News RSS。
> Raw：`/home/amr/llm-wiki/raw/research/architecture-daily-2026-11-14/`
> Wiki：已入庫 1 source + 6 concepts，並擴充 2 個既有頁（graphify 已同步；7 頁全部 non-orphan，incoming link 皆 ≥1）
> **未取得／無更新**：**Papers with Code**（站點改版，`/api/v1/papers/` 回 HTML，root 302 → huggingface.co/papers/trending，無可解析條目）｜**GitHub Trending HTML**（週榜抓取成功但 DOM 與解析規則不符，15 個 repo 全解析失敗 → 改用 GitHub Search API）｜**Anthropic Research RSS**（404）｜**InfoQ AI/ML feed**（`feed.infoq.com/ai-ml-eng` → 410 Gone，改用 `infoq.com/feed`）｜**Cursor / Windsurf**（GitHub 無 release／API 404）｜**MCP spec**（最新穩定版仍 2026-07-28，本週無新版）｜**OpenAI Codex**（僅 `rust-v0.169.0` / `rust-v0.171.0-alpha.5`，body 無實質 release note）｜**SWE-agent**（最新 release 仍 v1.1.0／2025-05，近一年半無更新）。
> **Graphify linking 備註**：任務指示的 `npx graphifyy link --source … --target …` 在本機 graphify **不存在**（實測 `error: unknown command 'link'`）；已改用本 repo 既有的 `tools/add-wiki-pages-to-graphify.py`（以頁內 `[[wikilink]]` 建立 `wiki_link` 邊）＋ `cluster-only` 達成等效連結，並實測 7 個新頁 incoming link 皆 ≥1（source 6、architecture-cost 4、access-gap 4、schema-policy 4、memory-anchors 1、merge-gate 2、agent-native 1）。

**一句話總結：今天有五條來自四個不同領域的獨立訊號，全部指向同一個轉移——控制點正在從「模型寫什麼」搬到「誰寫規格、誰寫合約、誰拿到存取權、誰驗」。** 受控實驗（arXiv 2611.12953）第一次量化地說：加架構的成本要用任務成功率買回來，否則 **single agent 就是效率預設**，而**技能品質（73.1%／67.4%／<67.4%）比「single vs multi」是更大的效果變數**。生產除錯的 field observation（2611.17304）給出更尖的診斷：agent 卡住**不是因為不會推理，而是因為看不到生產狀態**——5 件 concurrency 事故**全部**有 access gap，而它的錯誤假設「與它看得見的證據一致、不是捏造」。安全那邊（CapLite）更直接：**別讓 agent 自己寫安全政策**——15 個 open-weight 模型有 13 個寫不出來，CaMeL 的程式有 68% 的 episode 根本跑不起來；改從 tool schema 推導政策、write 先 commit 後讀，13,935 個受攻擊 episode **零成功**。工程方法論端，AWS Emulator 與 Martin Fowler 同日給出同一答案：**agent 寫實作，人寫 spec 與合約**——Fowler 更要求把合約放進「**測試資料**」而不是「測試程式碼」，這樣 agent 改不到它。**對 OpenClaw 而言，這把「我們還缺什麼」從清單變成四條可操作的規格。**

---

## 今日 5 個重點

### 1. 架構第一次有了受控的帳：加結構要用任務成功率買回 1.4–4.7× tokens 與 2.6–5.8× latency

- **發生什麼**：arXiv 2611.12953 固定模型／任務／工具，**只改架構**，比較四種設計（function-calling single agent、skill-augmented agent、centralized multi-agent orchestration、triage swarm；8 arms）× 13 條 enterprise SOPs。三條結論：**沒有通用最佳架構**（同一條 SOP 成功率從 <10% 到近 100%，aggregate 上無統計可分性）；**每個協調 arm 花 1.4–4.7× tokens、2.6–5.8× latency，換來通常很小、很少顯著的增益 → single agent 是效率預設**，而**高品質 skill 把成功率從 67.4% 拉到 73.1%、劣化 skill 掉到 baseline 以下**；**實作品質 > single-vs-multi 的選擇**——一個平庸的 multi-agent 實作輸給 single agent，經**針對性重設計**後卻成為唯一顯著勝出的 arm（**75.6% vs 67.4%**）。
- **為什麼重要**：這是「我們的 skill 層與 multi-agent 層到底值多少」的第一份控制後證據，方向對多 agent 派不利：**沒有帳的 swarm 就是那些「通常很小、很少顯著」的協調 arm**。它同時把長期爭論「single 還是 multi」翻轉成可操作問題——**skill 品質與實作品質是更大的變數**。與既有 [[worst-case-aggregation-single-agent-dominates]] 及 11-14 群體研究 #28「swarm 結構本身不是收益」一致。
- **來源**：<https://arxiv.org/abs/2611.12953>（2026-11-07，abstract 級）

### 2. 生產除錯的瓶頸是「存取權」不是「推理力」——錯誤假設與可見證據一致，不是捏造

- **發生什麼**：arXiv 2611.17304 對 Claude Code 的 field observation：在生產訊息派送引擎上診斷 **8 起**資料庫事故。每件 root cause 依賴 runtime concurrency 的事故，agent 都「宣布原因 → 送修 → 之後撤回」，每次錯判都花掉一個 deploy-and-observe cycle。**最具普遍性的瓶頸是對生產狀態的存取權**：缺 live lock views、**未截斷的** deadlock reports、read-only execution、明確環境脈絡。**5 件 concurrency 事故全部有 access gap**（1 件單獨、4 件同時併發 reasoning error）；**3 件不依賴 concurrency 的事故，agent 現有的東西就夠了**。★ 作者強調：**錯誤假設與它看得見的證據一致，不是捏造** → 提議在既有安全控制內加一層 **forensics layer**。
- **為什麼重要**：這把「agent 為什麼一直猜錯」從**歸因問題**改成**工具面問題**。對 OpenClaw：不要用 prompt 教它更小心推理，要給它**唯讀的生產狀態存取**。Netflix 同日（InfoQ 11-13）的 ontology-driven observability 是企業版同母題——一次 regression 調查要 ~4 小時，多數時間花在**重建系統之間的關係**而非分析資料。
- **來源**：<https://arxiv.org/abs/2611.17304>（2026-11-12，abstract 級）＋ <https://www.infoq.com/news/2026/11/netflix-ai-driven-observability/>

### 3. 安全政策不能由 agent 自己寫：13/15 個模型寫不出來，CaMeL 有 68% 的 episode 跑不起來

- **發生什麼**：arXiv 2611.17115（CapLite）實測現行 enforcement 防禦（CaMeL / Progent / IPIGuard / DRIFT）——它們都要求**agent 自己的模型**先寫出安全產物（程式、權限政策、依賴圖、constraint list）再由程式強制。**15 個 open-weight 模型中有 13 個（1.7B–12B）寫不出來**：寫出的 policy/graph/constraint 在 **Progent 14 個、IPIGuard 13 個、DRIFT 11 個**模型上可被攻破，**CaMeL 的程式高達 68% 的 episode 根本跑不起來**。CapLite 改為**從 tool schema 推導政策**、**在任何 tool result 被讀取前先 commit write 呼叫**，且一個 write 只有在「所有決定受影響對象／金額／目的地／物件的參數」都出現在使用者請求中才放行 → **13,935 個受攻擊 AgentDojo episode 零攻擊成功**，under-attack utility **29.0% vs CaMeL 27.2%**，token **只要 CaMeL 的 18%**，每 token utility 為所有 enforcement 防禦中最高。
- **為什麼重要**：把我們的 skill/policy 設計原則換掉一句話：**「由 LLM 寫出的 guardrail 不是 guardrail」**。對應到 OpenClaw 的同一位置是 `permissions.allow` 與 skill 的 `allowed-tools` 宣告。今天 Claude Code v2.1.325 恰好把這件事寫死：**scheduled tasks 與 `/loop` 在執行「宣告了 allowed-tools 或 hooks 的 skill」前必須先問**，要無人值守跑須把 `Skill(name)` 加進 `permissions.allow`。同方向：**能力宣告要能被檢查，而不是被信任**。
- **來源**：<https://arxiv.org/abs/2611.17115>（2026-11-12）＋ <https://code.claude.com/docs/en/changelog>（v2.1.325, 2026-11-13）

### 4. 記憶與 skill 都變成「可演化的程式 + 線上路由」：錨點要指到 repo 位置與可執行檢查

- **發生什麼**：三篇同期論文同向。**MAPE**（2611.17068）以程式演化從極小種子演化整個記憶程式，LoCoMo／LongMemEval 上 accuracy 絕對增益最高 **+12%**、服務成本只要 **35%**，抽出兩條可重用樣式：**保留原始對話作為可檢索證據**（保住抽取時遺漏的細節）＋**依 query intent 組裝檢索到的證據**；把 composition module 移植進 **5 個既有記憶系統，5 個全部變好**。**CoReMem**（2611.17316）用 **prospective segment valuation**（比較「有 vs 沒有某段 trajectory segment」跑**下一個任務**的結果）在**下一個任務還不知道之前**就決定記憶價值，記憶因此圍繞 **anchors：repository locations 與 executable checks** 建構；ChainSWE 上 27B actor 的 resolve rate **21.0% → 25.7%**、step 少 **17%**、cache-aware token 少 **11%**。**Skill Adapter**（2611.17007）把 skill 拆成**通用程序 + 個人化 Adapter** 兩層，由 routing agent 依當前 subtask／進度／環境回饋在線挑選並維護 task-level skill library，相較 SkillRL 成功率平均 **+11.43 pp**。
- **為什麼重要**：三篇合起來給出一個可執行的記憶／skill 架構規格：**記憶不是摘要，是帶 provenance 的錨點集合；錨點最好指到「repo 位置 + 可執行檢查」而不是指到一段散文**。對我們的 llm-wiki 與 skill 系統直接可套用：wiki 頁面若只是「一段摘要」，它是抽取層；若它帶著「在 repo 的哪個位置、有哪個可跑的檢查」，它就是 CoReMem 意義上的 anchor。Skill Adapter 的兩層拆分也解釋了為什麼「通用 skill + 本地 adapter」比「一個大而全的 skill」更能在長程任務存活。
- **來源**：<https://arxiv.org/abs/2611.17068>／<https://arxiv.org/abs/2611.17316>／<https://arxiv.org/abs/2611.17007>（皆 2026-11-12，abstract 級）

### 5. 工程師的新工作是把合約寫成 agent 改不到的東西：spec + fidelity test + merge gate

- **發生什麼**：**AWS Emulator**（11-11）把這個轉移做成可運作系統：**400+ 個 Smithy API models、涵蓋 200+ 個 AWS services，全部由 agent 寫成並測試**；方法是把 **fidelity tests 先對真實 AWS 跑通以記錄真實行為**，agent 再建 emulator 直到通過同一組 test，仍失敗的 test 就是缺口；守門是 **merge gate**——深度自動化檢查 ＋ **多個 security agent 各以不同攻擊角度做對抗審查** ＋ 一般 code reviewer ＋ 決定性的「不得觸碰某段程式碼」檢查。★ Swaminathan 的量測：重建 Alf replication engine，**人工監督四晚**才發現「它根本沒辦法檢查自己的結果」；**一旦有了 spec 與 test environment，重建花了約兩小時**（人做四個月）。同日 **Fowler〈Tests as data〉**（11-11）：**AI 寫程式碼後開發者變成它的客戶 → customer tests（不是 developer tests）成為人與 AI 的主要合約 → 把合約移進「測試資料」而不是「測試程式碼」，保護它不被 agent 的意外修改弄壞**（並指出關鍵新事實：DSL parser 與自訂 test runner 過去昂貴難維護，現在 AI 讓它們變便宜）。**〈durable execution〉**（11-10）補失敗面：**runtime 記錄每一個與外部世界互動的步驟結果，失敗時重跑並跳過已完成步驟**。
- **為什麼重要**：今天三個來源（AWS、Thoughtworks、GitHub）指向同一件事——**人類產出物的重心從程式碼移到合約與守門**，而合約必須放在 agent 碰不到的地方。GitHub Agentic Workflows GA 同日示範制度面：**agent 以唯讀權限啟動、變更由另一個持有自己 write token 的 job 套用**、套用前有 threat-detection job 掃描、預設 **1,000 AIC（$10）/run**、enterprise 預設 **5,000 AIC/日 + 400 AIC/threat-detection run + 20 分鐘 timeout**——★ 但作者自己在 FAQ 寫明**這些保護不會自動延伸到直接 write 權限，也不會延伸到作者自行加入的 custom job**，且 ARC 的 DinD sidecar **預設 privileged**；實測者更保守（自訂 100 AIC/15 turns/10 分鐘，並明寫「叫 agent 忽略 issue 文字裡的指令本身不構成保護」）。
- **來源**：<https://www.allthingsdistributed.com/2026/11/aws-emulator-and-the-engineers-job-when-agents-write-the-code.html>＋ <https://martinfowler.com/articles/tests-as-data.html>＋ <https://martinfowler.com/articles/durable-execution-agents.html>＋ <https://www.infoq.com/news/2026/11/github-agentic-workflows-ga/>

---

## 對 OpenClaw / Linder 的啟發

### 1. 每個新增的 agent 層都要附一張「帳」：成功率增益 vs token/latency 倍數

2611.12953 的量化標準可直接變成設計守則。**任何新加的 swarm / multi-agent / skill 層，若沒有附上「任務成功率增益 ÷ token 倍數 ÷ latency 倍數」的欄位，就預設是那些「通常很小、很少顯著」的協調 arm。** 落地：(a) 在 wiki 的 agent 架構頁加統一的「成本-收益帳」區段（沿用 [[cost-per-completed-task-not-per-token]] 的量法）；(b) 在每日研究 cron 的報告模板加入固定的「架構帳」欄位。**同時把爭論順序改正：先問「skill 的品質能不能拉高（67.4% → 73.1%）」，再問「要不要 multi-agent（可能 75.6% 但要重設計）」。**

### 2. 生產除錯路徑要補「唯讀 forensics 層」，而不是再教 agent 推理

依 2611.17304 的診斷（access gap 在 5/5 concurrency 事故皆存在、且錯誤假設與可見證據一致）與 Netflix 的 ontology 觀點（缺的是關係不是資料），可直接排一個可執行實驗：**建立唯讀的生產狀態存取面**（live lock view、未截斷的 deadlock／timeout 報告、read-only exec、明確的環境與部署版本脈絡），包成一個 skill。驗收用 AQuA 的做法：**產出的結論必須引用 deployed snapshot 的有效行號／有效指標位置，而不是給一個自信分數**——「根因是否可被引用」比「回答是否自信」可靠。

### 3. 把政策與合約移出 agent 可改寫的範圍，並讓 skill 能力宣告可被檢查

CapLite 與 Fowler 指向同一動作：**安全政策由 tool schema 推導、而不是由 LLM 寫出**；**合約放進資料（測試資料、goal.md、fidelity test）而不是放進 agent 會改寫的程式碼**。對 OpenClaw 的具體對應：(a) skill 的 `allowed-tools` 與權限授予走「可稽核的宣告 + 預設需核准」，與 Claude Code v2.1.325 新規一致；(b) 我們的驗收條件（wiki 頁 frontmatter 完整性、raw 路徑存在、wikilink 可解析、incoming link ≥1）應該寫成**可執行的檢查器**，讓 agent 產出後自動過關，而不是寫成「請遵守」的規則；(c) 長程 cron 工作要參照 durable execution——**每個與外部世界互動的步驟都要能被跳過與重放**。

### 4. 記憶與 skill 兩層化，錨點指到「repo 位置 + 可執行檢查」

CoReMem 的 anchor、MAPE 的兩條樣式、Skill Adapter 的兩層拆分可直接套到我們自己的 wiki/skill 系統：**通用 skill ＋本地 adapter**（通用程序不動，個人偏好寫成 adapter，由 routing 依當前子任務挑選）、**記憶錨點指到可執行檢查**（wiki 頁對應到 graphify query + 一條驗證指令）、**保留原始對話／原始來源作為可檢索證據**（不要只留抽取後的摘要——這正是我們既有的 extraction-ceiling 結論）。這樣記憶才能像 MAPE 說的那樣跨系統移植。

---

## 值得追蹤的 repo / paper / article

- arXiv:2611.12953 — *Agent Architecture Cost-Success Trade-offs: A Controlled Evaluation across Enterprise-Style SOPs* — <https://arxiv.org/abs/2611.12953>
- arXiv:2611.17304 — *Where LLM Agents Get Stuck Debugging Databases: Access More Than Reasoning* — <https://arxiv.org/abs/2611.17304>
- arXiv:2611.17115 — *CapLite: Prompt-Injection Defense for Small Language Model Agents without Model-Written Security Artifacts* — <https://arxiv.org/abs/2611.17115>
- arXiv:2611.17068 — *Discovering Effective Agent Memory Designs through Program Evolution*（MAPE；code: <https://github.com/ash-ding/MAPE>）— <https://arxiv.org/abs/2611.17068>
- arXiv:2611.17007 — *Skill Adapter: Personalized Modification and Online Routing of General-Purpose Skills* — <https://arxiv.org/abs/2611.17007>
- Martin Fowler — *Tests as data: ensuring AI-generated code does what we want* — <https://martinfowler.com/articles/tests-as-data.html>
- AWS — *AWS Emulator and the engineer's job when agents write the code*（repo <https://github.com/aws/aws-emulator>）— <https://www.allthingsdistributed.com/2026/11/aws-emulator-and-the-engineers-job-when-agents-write-the-code.html>
- InfoQ — *GitHub Makes Agentic Workflows Generally Available with Isolation and Budget Controls* — <https://www.infoq.com/news/2026/11/github-agentic-workflows-ga/>
- InfoQ — *Google Open Sources Ambient Quality Agent (AQuA)* — <https://www.infoq.com/news/2026/11/google-ambient-agent-prod/>
- Google — *A2UI 1.0* — <https://developers.googleblog.com/a2ui-10-build-delightful-fast-reliable-agentic-experiences/>
- google/elephant-goldfish-model（Elephant 持脈絡、Goldfish **無前情**審閱 → anti-anchoring 模式；18,643★）— <https://github.com/google/elephant-goldfish-model>
- deepseek-ai/deepseek-harness（280,535★；v0.2.2-rc.2/rc.3：Worktree 審閱、具名多層 SubAgent、AgentTeam、session import）— <https://github.com/deepseek-ai/deepseek-harness>

---

## 下一步建議

1. **把今天的四條命題做成可執行的「架構帳」模板**：在 wiki 新增「Agent 層成本-收益帳」欄位定義（任務成功率、token 倍數、latency 倍數、可替代的單 agent 實作、是否為重設計版），並回頭用它檢視我們現有的 swarm / skill 層——這是唯一能把 2611.12953 變成制度的方式，而不是只讀過。
2. **排一個唯讀 forensics 實驗**：用一條真實的生產除斷需求，比較「只給 agent 現有工具」vs「加一層唯讀生產狀態存取（lock view、未截斷錯誤報告、read-only exec、環境脈絡）」，以**根因是否可被引用到 deployed snapshot 的具體位置**作為驗收；同時用 CapLite 的原則檢查我們的 skill 權限宣告。
3. **讓 wiki 頁面從「摘要」升級成「錨點」**：在 page template 加 `source_path` + 一條可執行驗證欄位（graphify query / link check / 腳本），對齊 CoReMem 的 anchor 定義；並在報告模板加入固定的「架構帳」欄位。

---

## 本日已入庫（llm-wiki）

- **Raw**：`raw/research/architecture-daily-2026-11-14/`（`raw-notes.md` 29.2 KB + `source-meta.yaml` 0.9 KB）
- **新增 source**：`sources/daily-research-2026-11-14-architecture-cost-success-access-gap-and-schema-derived-policy`
- **新增 concepts（6）**：`architecture-must-be-justified-by-task-success`、`access-gap-not-reasoning-gap`、`policy-derived-from-tool-schema-not-model-written`、`memory-anchors-are-locations-and-executable-checks`、`spec-and-fidelity-test-are-the-merge-gate`、`agent-native-interface-and-payment-layers`
- **擴充既有頁（2）**：`worst-case-aggregation-single-agent-dominates`（補受控實驗層級的同一結論）、`tool-surface-as-least-privilege-boundary`（補 schema 推導政策 / 唯讀 forensics 層 / agent-native 支付層三條後繼證據）
- **更新**：`wiki/index.md`、`wiki/log.md`；graphify 已同步（7 頁 incoming link 皆 ≥1，`cluster-only` 完成，429 communities）

## 誠實限制

arXiv **7 篇皆 abstract 級**（未讀全文）；AWS / Google / Brave / OpenAI 數字皆**廠商自述**，無獨立複現；Fowler 兩篇是**觀點＋實踐主張**非受控實驗；CapLite「零攻擊成功」僅在 **AgentDojo** 基準內；CoReMem / MAPE / Skill Adapter 的數值來自**三種不同的量**（resolve rate / accuracy / success rate）**不可相加**；MAPE repo **star = 2**，尚無外部檢驗；Google AQuA 的 replay 結果來自受控重放而非生產流量；本次未下載或執行任何 repo 程式碼、未跑 benchmark、未修改既有 raw 檔案、未改 cron／設定。
