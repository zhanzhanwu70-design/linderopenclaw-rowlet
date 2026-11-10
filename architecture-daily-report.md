# 每日 Agent × 軟體開發情報 — 2026-11-10

> 來源：24 個公開來源（arXiv 7 篇皆 **abstract 級**；Anthropic〈The components of agent memory〉、LoreKit〈Agent memory needs its OpenTelemetry moment〉、Martin Fowler 兩篇（〈Are Harnesses Worth the Cost?〉2026-10-13 / 〈Why are good developers so wary of agentic development?〉2026-10-29）、Claude Code v2.1.316–321 release notes、OpenClaw v2026.11.1 / .2 / .5-beta.1 changelog、GitHub Trending + repo API、HN Algolia 19 條、Ripple-65B 發布頁）。
> Raw：`/home/amr/llm-wiki/raw/research/architecture-daily-2026-11-10/`
> Wiki：已入庫 1 source + 7 concepts，並擴充 4 個既有頁（graphify 已同步；8 頁全部 non-orphan，圖譜 **10,556 nodes / 19,247 edges / 1,178 communities**）
> **未取得**：InfoQ AI/ML news 頁與 Pragmatic Engineer RSS（抓取無有效條目，未採用）；Codex releases 僅見 `rust-v0.169.0-alpha.x` 等 alpha tag，無實質 release notes。
> **複核為無更新**：MCP spec 最新穩定版仍是 **2026-07-28**（本週無新版本）；`anthropics/skills` 本週僅 pushed 一次。
> **Graphify linking 備註**：任務指示的 `npx graphifyy link --source … --target …` 在本機 graphify **不存在**（實測 `error: unknown command 'link'`）；已改用本 repo 既有的 `tools/add-wiki-pages-to-graphify.py`（以頁內 `[[wikilink]]` 建立 `wiki_link` 邊）＋ `graphify cluster-only` 達成等效連結，並實測 8 頁 incoming link 數皆 ≥1。

**一句話總結：今天有四條彼此獨立、但合起來指向同一件事的訊號——agent 系統的成本正在從「模型能力」轉移到「被重複讀取的過時文件」與「驗證吞吐量」。** arXiv 2611.09802 證明過時的 AGENTS.md 是**每 session 都要繳的稅**（多 2 次 tool calls）而且**沒有一個 agent 會自己還債**；2611.09798 證明 **test-time scaling 的正確單位是「小隊」不是「agent」**（teams of ten 贏過 100 個獨立 agent，等成本打敗 frontier model 一半任務）；Anthropic 把記憶拆成 notes / wiki / dreaming 三層並量化（54%→61%、省 20k tokens/題），同時揭露**共享摘要表被 agent 互相覆寫**導致 72% 覆蓋率；Claude Code v2.1.321 修掉 **MCP OAuth redirect 外洩 refresh token** 與 **read-only bash 繞過 sandbox**。**harness 的下一個瓶頸不是「給多少指引」，而是「指引是否還對」＋「誰來驗」＋「要花多少 context」。**

---

## 今日 5 個重點

### 1. 過時的 instruction file 是「每 session 都要繳的稅」，而且 agent **只繳不還**

- **發生什麼**：arXiv:2611.09802（11-06）〈When Instruction Files Go Stale: Documentation Debt and Hidden Cost in Coding Agents〉。AGENTS.md / CLAUDE.md 這類 repository instruction file **每個 agent session 都會被讀一次**；一旦落後於程式碼（測試資料夾搬走了、檔案還指著舊路徑），就成為技術債定義上的 **documentation debt**，其「利息」是**它對每一個後續 session 附加的成本**。研究取 3 個真實 open-source repo 的 stale instruction（測試指令／程式碼位置／新增元件程序），各做三個版本（stale／更正到現行路徑／移除），程式碼與任務固定，**22 個維護任務、兩個模型、732 條 trajectory，分析到個別 tool call 層級**。結果：stale 測試指令使 **Claude Sonnet 5.5 每次多花約 2 次 tool calls**（比正確版多 1/3），另兩種型態測不出差異；而「正確資訊在別處」**不足以**阻止 agent 照 stale 指令走。
- **為什麼重要**：兩個數字比成本本身更關鍵。第一，**「agents generally recovered from the immediate failures, but none repaired the underlying instruction file」**——22 個任務、732 條 trajectory 裡，**沒有一個 agent 修好了底層檔案**。對照 10-24 已收錄的 arXiv 2610.30571（加一句「程式碼優先」可把遵循率從 4.2% 拉到 91.4%）：**那個修補是人加的，不是 agent 自發的**。第二，**「task success alone can hide the costs of documentation debt」**——agent 繳了稅繞路成功，pass rate 完全看不到成本，所以評估必須下沉到 tool call 層級。第三，作者還發現**移除優於更正**（"removing them prevented most"，而更正只是消除對過時路徑的操作）——因為更正後仍留著一份需要維護的副本。→ 這正是我們 `AGENTS.md` / `SOUL.md` / 各 skill 的 `SKILL.md` / `wiki/index.md` 的性質：**全都會變債，而且沒有人會自動還。**
- **可信來源**：<https://arxiv.org/abs/2611.09802>

### 2. Test-time scaling 的正確單位是「小隊」——teams of ten 贏過 100 個獨立 agent

- **發生什麼**：arXiv:2611.09798（11-06）〈Test-Time Compute Scales Better with Parallel Agent Teams〉。假設 verifier 能為每次嘗試打分，agent 的 test-time compute 有兩種花法：**best-of-N**（N 個獨立 agent 各跑一次取最好）**飽和很快**；**單一大隊**（一個 agent 團隊協作到底）分數較高但**隨規模成長就停住**。本文方法 **parallel agent teams**：平行抽樣**許多小隊**（每隊約 10 人），**保留最好的隊**。實驗用 **27B 模型、100 agent 預算**，跑 12 個 long-horizon 任務（從 GPU kernel 到 formal proof）。結果：**teams of ten 在 12 個任務中的 10 個贏過 100 個平行 agent**；在有跑 100 人大隊的 **4 個任務全贏**；**等美元成本**下，同樣的 parallel teams 在**一半任務**贏過 frontier model。
- **為什麼重要**：這是一個**雙層取樣結構**——隊內用協作取得高於單 agent 的分數，隊間用取樣取得持續擴展。**單層結構必然在一個方向上飽和**（全是獨立的 → 樣本空間很快重疊；全是一隊的 → 協調成本吃掉收益）。它與我們已收錄的 `effective-team-size-scaling-law`（N=4/6 有效、N=12/16 歸零）**互相支持：兩篇獨立來源都指向「有效區間存在且不無限」**。但有一個被低估的前提常被忽略：**「保留最好的隊」需要 verifier 能給「隊」打分，不是給 agent 打分**——OpenClaw 的多數任務沒有這樣的 verifier，方法不能直接套用。
- **可信來源**：<https://arxiv.org/abs/2611.09798>

### 3. Anthropic 把記憶拆成三層並量化：**wiki 必須與 search 並存**，且 salience 要讓模型自己判

- **發生什麼**：Anthropic〈The components of agent memory〉（11-07，HN 187 分）。設計藍圖取自生物學分工：**海馬迴快速捕捉經驗、只有部分經驗被 consolidation 進長期知識、而 consolidation 發生在離線時（睡眠時 replay、蒸餾、整合）**。對應到 agent 三層組件：**memory notes**（寫下「未來會再次relevant」的事實＝對未來需求的一個預測）、**wiki**（把 notes 組織成 knowledge map）、**dreaming**（離線回看 logs、重組記憶、修正錯誤；Letta/UC Berkeley 的 sleep-time compute <https://arxiv.org/abs/2504.13171>、Claude dreaming API <https://platform.claude.com/docs/en/managed-agents/dreams>）。量化結果：**search + wiki 讓 aggregate score 從 54% → 61%**，**只有 search 是 53%**，**只有 wiki 是 48%**（比只搜尋還差）；同時使用**每題省約 20,000 tokens**；另一任務 24 題中 **wiki 87% vs 只有 search 73%**。兩個機制最關鍵：**preemptive load**——「dreaming can float notes to the top of the memory hierarchy, and the agent harness can preemptively load them into Claude's context at the start of every session. This means **Claude doesn't need to search for them, or even to know there's something to search for**」；以及 **salience 由模型自判**——把規則寫死成「only record failures」時，**Opus 5 與 Opus 4.7 都失去了 memory 帶來的很大一部分增益**，「giving them freedom to judge salience was more effective than setting fixed rules in advance, and those rules could end up **weakening** performance」。
- **為什麼重要**：**「只有 wiki 48% < 只有 search 53%」是一個要警惕的訊號**——如果我們把記憶系統做成「只有 graphify、沒有一般檢索」，會**比讓 agent 用 grep + 一般檢索更差**。這正好呼應昨日已收錄的 `agent-memory-needs-a-shared-envelope`：**記憶是一個層，不是全部**；我們的 graphify query + grep + wiki 必須並存。同時「寫死規則削弱強模型」直接挑戰了 harness 常見做法：**不要用固定規則決定 agent 要記什麼，要給目錄與格式、不給判準**。另一個未解問題作者也點明了：當下寫 note 會把注意力從主任務拉走，**dreaming 的價值就是把記憶建立推到背景**——而**本 wiki 目前只有「notes + 人工整理」，缺的就是 dreaming 那一層**。
- **可信來源**：<https://www.anthropic.com/research/components-of-agent-memory>

### 4. 多 agent 共寫一張摘要表 → 57 條事實只剩 41 條（72%）；改成單一寫者 + 逐字引用 → 100%

- **發生什麼**：同一篇 Anthropic 文章裡有一個乾淨的失敗案例。合約 wiki 原本用**一張共享表格**存放條款摘要：生成的 brief 只含 **57 條事實中的 41 條（72%）**。診斷是雙層的——**共享表格把條款摘要得差**，而且 **"agents had overwritten one another's work"**。修法只有三個改動：每份合約**一個獨立頁面**、**由單一 agent 撰寫**、**逐字引用條款而非摘要進共享表** → **100% 的標準都可達成**。
- **為什麼重要**：這不是寫作技巧，是**記憶系統的並行安全模型**：只要多個 agent 會寫同一個地方，聚合表就是一個**沒有鎖、沒有版本、沒有 merge 策略的共享變數**。而**逐字引用 > 摘要在 agent 特別成立**——人類做摘要是因為記憶成本高，agent 的 context 成本高但**複製成本近乎零**，所以 agent **沒有理由做摘要**。→ 這條規則可以直接移植到 OpenClaw：**任何跨 session 的記憶文件，若其內容由多個 agent 產生，必須是 append-only 或單一寫者，不得存在「多寫者共寫同一聚合結構」的寫入路徑。** 而本 wiki 的 `wiki/index.md` 與 `wiki/log.md` **正是兩張共享可覆寫的聚合表**（目前靠「寫在最前面」的約定避開覆寫，但那是約定、不是機制）。
- **可信來源**：<https://www.anthropic.com/research/components-of-agent-memory>

### 5. 記憶格式需要一個「OpenTelemetry 時刻」：spec 該記錄**作者、程式碼依賴、簽章**，但沒有人會自己還債

- **發生什麼**：LoreKit〈Agent memory needs its OpenTelemetry moment〉（11-07，HN 189 分）：「Every agent tool stores memory in its own shape, and every week someone builds another one. **None of them can read the others.** Observability had the same problem until OpenTelemetry gave everyone one data model to share.」提案骨架（作者明言 field names 不是提案）：`spec: agent-memory/0.1`，並比照 OpenTelemetry 分層。關鍵判斷是**該管什麼、不該管什麼**——spec **不該挑一種抽取語意**（model-driven 如 Anthropic memory tool / Letta / LoreKit，service-extracted 如 Mem0 / Graphiti），**但必須記錄是哪一種**，「so a reader knows how much to trust what it reads」；**該留在 spec 裡的是「誰寫的、簽章、指向它依賴的程式碼（讓讀者能檢查程式碼是否已變）」**；**該留在工具層競爭的是 storage、ranking、embeddings、UI**；**spec 必須放在中立位置**，不放任一家 vendor 的 repo。安全面作者寫得很直接：共享記憶**擴大了誰能寫的範圍**，「**No format makes poisoning impossible**」——但 spec 至少能讓風險**可視**。作者也自陳時機判斷：現在該做的不是「再加一個格式」，而是「**既有專案合併**」。
- **為什麼重要**：這補上昨日 `agent-memory-needs-a-shared-envelope` 缺的具體欄位。對 OpenClaw 最直接的三點：**（a）「指向程式碼」把記憶接回文件債**——一筆記憶若能指出「我依賴 repo 裡這個檔案／函式」，程式碼改變時記憶狀態就能被重新檢查，等於把記憶從「文字」變成「**帶失效條件的陳述**」，直接對接第 1 點的偵測需求；**（b）「抽取方式」是信任等級欄位**——agent 自己寫與服務抽取的可信度完全不同，寫進記錄裡讀者才知道怎麼用；**（c）不要自創第五種記憶格式**——等 spec 成形，或把自己的格式設計成可映射。實務面今天也有對照組：**Claude Code v2.1.321（11-09）修了「MCP server 發生 redirect 時把 refresh token 送到另一個 host」、修了「read-only Bash 繞過 sandbox 且不提示權限」、修了「bash 權限檢查判錯資料夾而未提示」、修了「cp/mv 進目錄時 deny rule 沒套用到實際寫入的檔案」**；v2.1.319 讓 **MCP task 移到背景執行**，v2.1.317 新增 **OTel spans/metrics 與 `onFailure:"block"` hook**、以及**送 email 出去前先問**。→ **生產 harness 的邊界正在被實測修補，而記憶層是同一條防線的另一半。**
- **可信來源**：<https://www.lorekit.io/blog/open-agent-memory-format>、<https://github.com/anthropics/claude-code/releases>

---

## 對 OpenClaw / Linder 的啟發

### 1. 我們有「文件債稅率」這個未被量測的指標，而且沒有任何 agent 會還債

第 1 點直接命中本 workspace：`AGENTS.md`、`SOUL.md`、`TOOLS.md`、各 skill 的 `SKILL.md`、`wiki/index.md`、`wiki/log.md` —— **全部是 instruction file，全部會隨程式碼演進而過時**。而實測結論是**agent 只繳稅不還債**（732 條 trajectory 零修復），所以「讓 agent 順手修」這個想法在文獻上不成立。可行動作有三段：**（a）量測**——在 session transcript 上算「本次任務的工具呼叫數 vs. 理論最短路徑」，差額即稅率，這正是論文用 732 條 trajectory 做的事；**（b）偵測**——一個 cron skill 檢查 instruction file 裡的路徑／指令是否仍存在（**偵測可自動，修補要人確認**，因為刪錯指令比多繳稅更糟）；**（c）還債**——**移除優先於更正**。同理，`wiki/index.md` 與 `wiki/log.md` 這兩張共享聚合表本身就是本 wiki 的債：**連結還在但指向的頁面可能不再支援該結論** → 需要一次失效連結掃描。

### 2. 擴展單位要從「agent」改成「小隊」，前提是先有隊級 verifier

現有 spawn 形狀（`sessions_spawn` 多個 subagent 做同一件事）正是 best-of-N 的形狀 → 依第 2 點**會飽和**。改成 **「多隊 × 隊內分工與交叉檢查 × 隊間由 verifier 選隊」**，而且**隊級 verifier 是前提不是優化**：整個方法只在「你能可靠判定一整隊的成果好壞」時成立。這也決定了登記粒度：`taskName` / `group` 應該**以「組」為單位**，而不是以 agent 為單位。順帶把第 1 點與 [[concepts/effective-team-size-scaling-law]] 接起來：**兩篇獨立來源都指向「有效區間存在且不無限」**（隊內 10 人 vs 團隊總規模 4/6），這值得排成一個跨層級的通用常數實驗。

### 3. 記憶層有三個明確的架構缺口：dreaming 缺席、聚合表並行不安全、介入沒有估值

第 3、4 點與第 5 點合起來指出三件事：**（a）缺 dreaming**——本 wiki 是「notes + 人工整理」，可以加一個低頻 cron skill 專門回看過去幾天的 session transcript，**只做三件事**：修正過時連結、合併分散筆記、把高 salience 筆記浮到記憶頂端；**不做**憑空生成新知識（那是產生幻覺，不是固化）；**（b）並行不安全**——依第 4 點，把 `index.md` / `log.md` 降級成「只放指標與連結、內容放獨立頁」，並把「任何跨 session 記憶文件若由多 agent 產生，必須 append-only 或單一寫者」寫成 harness 層的**硬規則**（例如寫入前檢查）；**（c）介入沒有估值**——依 arXiv 2611.09792，benchmark 對「中途介入到底有沒有用」**零資訊**，因為介入價值是**因果問題**且依賴當下 context 與 agent 未來行為 → **`ask_user` 是最貴的介入手段，應被視為有成本的介入並被估值，而不是當成負責任的預設**。可行最小實作：記錄每次介入點的特徵（任務型別、已失敗次數、剩餘 token）與最終結果，用 bandit 在「不介入／輕提醒／強制重做／人工改寫」之間選擇。

---

## 值得追蹤的 repo / paper / article

**Paper（arXiv）**
1. <https://arxiv.org/abs/2611.09802> — When Instruction Files Go Stale: Documentation Debt and Hidden Cost in Coding Agents（22 tasks / 732 trajectories / tool-call 層級；利息量化 + 無自癒）
2. <https://arxiv.org/abs/2611.09798> — Test-Time Compute Scales Better with Parallel Agent Teams（teams of ten > 100 agents；等成本打敗 frontier model 一半）
3. <https://arxiv.org/abs/2611.09721> — MemoryDojo: Benchmarking Poisoning Through LLM Agent Memory（155 trajectories × 5 記憶系統 × 4 領域；stored→propagated→executed lifecycle）
4. <https://arxiv.org/abs/2611.09792> — Knowing When to Intervene: Causal Evaluation of AI Agents（介入價值＝因果問題）
5. <https://arxiv.org/abs/2611.09730> — What to Delegate, What to Preserve（289 人 / 45 use case；偏好 **bounded autonomy**）

**Article / Blog**
6. <https://www.anthropic.com/research/components-of-agent-memory> — 三層記憶分解、54/61/53/48 與 20k tokens/題、preemptive load、salience 自判
7. <https://www.lorekit.io/blog/open-agent-memory-format> — memory spec 該記錄作者／程式碼依賴／簽章／抽取方式（作者說 spec 要中立）
8. <https://martinfowler.com/rachels-ramblings/good-devs-wary.html> — Rachel Laycock（11-? 10-29）：**變更到達速度超過檢查完成速度**、agent 互相踩變更、CD/DevOps 在 agentic 時代復興（引用 DORA 2025：AI adoption 與更高 delivery throughput 相關）
9. <https://martinfowler.com/articles/are-harnesses-worth-the-cost.html> — frontier model 上 harness **零可觀察改善**卻要 10.5× tokens / 3× 時間 / 7× 成本
10. <https://github.com/anthropics/claude-code/releases> — v2.1.321 的 MCP OAuth redirect 洩漏與 sandbox 繞過修補，值得逐條對照我們的 exec/browser/node 閘門

**Repo**
11. <https://github.com/anthropics/skills> — Anthropic 官方 Agent Skills 實作；README 指向 **agentskills.io 為 Agent Skills 標準**（191k stars）
12. <https://github.com/thedotmack/claude-mem> — 跨 session 持久 context（115k stars），**README 明列支援 OpenClaw**，值得直接測試相容性
13. <https://github.com/max-sixty/worktrunk> — 為 **parallel AI agent workflow** 設計的 git worktree CLI（12.3k），對應 HN 統計裡「各自 worktree」的主流做法
14. <https://github.com/vercel-labs/agent-browser> — 給 AI agent 的瀏覽器自動化 CLI（48.5k）
15. <https://github.com/mattpocock/skills> — 「Skills for Real Engineers」（319.8k，GitHub Trending 第一），skill 內容工程的參考範式

---

## 下一步建議

1. **做「文件債稅率」的第一次實測**（可在本週內完成，零外部依賴）——對本 workspace 的 `AGENTS.md` / `SOUL.md` / `TOOLS.md` / 各 skill `SKILL.md` 跑一次「路徑與指令是否仍存在」檢查，產出**失效清單**（先不動手改，只報告）。依論文結論，這一步是後續所有還債工作的前置，而且**移除優先於更正**。順手掃一次 `wiki/index.md` 與 `wiki/log.md` 的失效連結——它們正是第 4 點的「共享聚合表」。

2. **寫一個「dreaming」低頻 skill 雛形**——每週跑一次，輸入是過去 7 天的 session transcript，**只做三件事**：修正過時連結、合併分散筆記、把高 salience 筆記浮到記憶頂端；**明令禁止**憑空生成新知識。驗收標準用第 3 點的數字對照：**修好之後，"search + wiki" 的命中率應該上升，而 token 應該下降**（論文是 54%→61% 且省 20k tokens/題）。這同時是本 wiki 補上 dreaming 層的唯一路徑。

3. **排一個小隊擴展的最小實驗**——固定任務集（例如「每日研究報告 + wiki 入庫 + 圖譜連結」），對比三種配置：**（a）** 現行 spawn 形狀（best-of-N）、**（b）** 多小隊 × 隊內分工 × **隊級 verifier 選隊**、**（c）** 現行 + 教練模型。先量「等 token 預算下的成功率」與「token/成功任務」兩個數字——依第 2 點，**（b）應該在等預算下贏（a）**；若沒有，差異多半出在**缺隊級 verifier**，那本身就是最重要的發現。
