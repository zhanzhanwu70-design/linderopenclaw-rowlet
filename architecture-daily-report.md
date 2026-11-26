# 每日 Agent × 軟體開發情報 — 2026-11-26

> **資料窗口**：2026-11-19 ~ 2026-11-25（以 11-24 ~ 11-25 為主）
> **取得時間**：2026-11-26 06:10 ~ 06:25 (Asia/Taipei)
> **來源類別**：arXiv（cs.AI / cs.DC）｜官方 blog（MCP / Anthropic / Google / Microsoft）｜InfoQ｜HuggingFace research release｜GitHub Trending + search API｜Hacker News (Algolia)
> **Wiki-first**：先跑 `graphifyy query`（已建立圖譜共 2398 個 wiki 節點、18184 條 wikilink）；新增 1 source + 4 concepts，更新 1 既有頁
> **Raw**：`/home/amr/llm-wiki/raw/research/architecture-daily-2026-11-26/`（13 檔，約 524 KB）
> **圖譜**：以 repo 內 `tools/add-wiki-pages-to-graphify.py` 建立連結（★ `npx graphifyy link` 仍不存在，沿用上次做法）
> **未取得／降級**：見文末

**一句話總結：今天最紮實的一條是——「監督不該是一句話，該是一段程式」。**
同一週內，**46% 的多 agent 監督規則只存在於自然語言 prompt**；靠壓縮筆記的 supervisor **核准了 71% 刻意有缺陷的計畫**；
而把同樣的規則寫成 **requirement ledger + host 端 acceptance test**，跨 handoff 守住正式化需求的成本**只有 input token 的 1/6**。
換句話說：**形式化不是昂貴的，昂貴的是不形式化。**

這與另外四條同向：
- **政策**從宣告搬到 tool call 的執行點（Google：AgentDojo 攻擊成功率 48.7% → 0.9%，只損 2.6pp 良性效用）
- **狀態**從機器裡分離出來（Google 捐 Agent Substrate + gVisor 給 CNCF：**actor ≠ worker**）
- **記憶**從摘要改成可各自存取的紀錄，而且**要會丟棄**（context folding 全 6 個 setting 勝出、最多 +19.2%）
- **MCP** 現在直接承載 playbook（Skills over MCP public beta、Tasks/Elicitation GA、File Uploads 不經 context window）

---

## 今日 5 個重點

### 1. ★★★ **可執行監督勝過 prompt 監督——46% 的監督規則只活在自然語言裡**

- **發生什麼**：研究釋出 *Formalize or Lose It*（2026-11-23，HuggingFace research release，附 preprint + 實作 + 資料集）。稽核 **84 條 oversight rules，其中 39 條（46%）只存在於自然語言 prompt 指令**；23 條從 Root 傳給 Workers 的 requirements 中，**19 條沒有可執行檢查**。故障注入 19 個 × 29 次執行：既有 FBS 實作擋下全部 10 個 plan/delivery 故障，但**另有 6 個故障穿過既有 125 案例測試套件（2,599 assertions）並被接受**，Host-level checks 抓到其中 5 個且無誤報。
- **為什麼重要**：受控 relay 實驗（約 1,150 次 model call）給出兩個要合讀的數字——**依賴壓縮筆記的 supervisor 核准了 71% 刻意有缺陷的計畫**；**程式化檢查的 requirement ledger 以約 1/6 的 input token 成本維持正式化需求跨 handoff 不失真**。這直接打在我們身上：我們的 CEO→agent 分派目前仍是 prompt + task queue 文字。★ **「照做了嗎」prompt 答得，「做對了嗎」只有可執行檢查答得。**
- **可信來源**：<https://discuss.huggingface.co/t/research-release-formalize-or-lose-it-experimental-results-on-executable-oversight-in-agent-swarms/192381>（★ 僅讀貼文，preprint 全文未讀、數字未獨立驗證）
- **Wiki**：`concepts/executable-oversight-beats-prompt-supervision.md`（新增）

### 2. ★★★ **Context folding 勝過 rolling summary——記憶要可各自存取，而且要會丟棄**

- **發生什麼**：arXiv:2611.28244（2026-11-20 提交，*Demystifying the Autoresearch Harness*，HKUST／NVIDIA／U. Tokyo）在 MLE-Bench + KernelBench、3 個模型、**6 個 setting** 下逐項隔離 harness 設計選擇（以 recency-truncation 為 baseline、同 framework 內比較）：**保留每個過去嘗試「可各自存取的紀錄」比維持 rolling summary 更有效**；**context folding 在全部 6 個 setting 都最好，比 baseline 最多高 19.2%**；skill 端**選擇性丟棄持續未被使用的教訓平均上優於 consolidate**。姊妹作 arXiv:2604.25850（v5，11-22）把增益**定位在 tools／middleware／long-term memory，而非 system prompt**。
- **為什麼重要**：★ **「harness 厚度不等於分數」這條（2026-11-24）在本輪補上了方向**——厚度該加在**工具／中介／長期記憶**，不是加在 prompt。對我們三層記憶的直接含義：我們的 daily memory 檔案**本來就可指名引用**（接近 context folding），但 **MEMORY.md 的摘要層仍是 rolling summary**；而且**我們的 skill 只增不減，未被使用的教訓是負債不是資產**。★ **與其加更多記憶機制，不如先加淘汰。**
- **可信來源**：<https://arxiv.org/abs/2611.28244>、<https://arxiv.org/abs/2604.25850>、<https://arxiv.org/abs/2611.24924>（★ 三篇**僅讀 abstract**）
- **Wiki**：`concepts/context-folding-beats-rolling-summary.md`（新增）

### 3. ★★★ **每次 tool call 的身分與政策就是控制平面——agent 需要自己的 ID**

- **發生什麼**：四家廠商在同一週補同一層磚：① **LangSmith Tool Gateway** public beta（11-19）集中處理**憑證、caller identity、存取政策、審批流程、稽核軌跡**，可搭 MCP 相容 client；② **Microsoft Foundry**（11-19）可把 agent provision 成**具名 M365 成員**，擁有**自己的 Entra (agent) 身分**、email、calendar、OneDrive 與**可問責的 manager**；③ **Azure Monitor** 統一 agent observability preview，採 **OTel trace context + OTel GenAI semantic conventions**，跨多 agent／平台／模型／工具追蹤；④ **Google Gemini「Semantic governance policies」**（11-24 preview）把**每個建議的 tool call** 對照**自然語言政策與使用者原始請求**檢查。
- **為什麼重要**：★ 治理不再是「哪個模型比較安全」，而是「**每一次動作有沒有可歸屬的身分與可執行的政策**」。Google 報告的數字 **AgentDojo 攻擊成功率 48.7% → 0.9%，代價只有 2.6pp 良性效用**——這個交換比遠優於用 prompt 擋（prompt 擋不住時的失敗率是 46%，見重點 1）。★ **有 agent 身分才談得上只撤權限不撤人**；★ 我們的 `ask_user` 目前是**模型自己決定要不要問**，依這條證據，「需不需要簽核」應是 policy 層判定。
- **可信來源**：<https://aiagentstore.ai/ai-agent-news/this-week>（二手彙整）、<https://www.infoq.com/news/2026/11/google-substrate-gvisor-cncf/>（同週基礎設施面）
- **Wiki**：`concepts/per-call-agent-identity-is-the-control-plane.md`（新增）

### 4. ★★ **Agent 執行需要自己的基礎設施層——actor 與 worker 必須分開**

- **發生什麼**：Google 把 **Agent Substrate 與 gVisor 捐給 CNCF**（InfoQ，2026-11），置於廠商中立治理。★ **Substrate 的核心切分是把 agent state（actors）與執行它的 compute resources（workers）分開**：agent 閒置時 **state 可保存、底層 compute 可釋放**，之後可指派給另一個 Worker 並還原。**隔離邊界可分級**：gVisor 以 user-space application kernel 攔截 syscall（不碰 host kernel），Substrate 另支援 **Cloud Hypervisor microVM** 做硬體級隔離，而 agent lifecycle 模型不變。InfoQ 的原話：agent 需要的不只是 orchestration framework 與工具存取，而是**自己的、安全的、有狀態的執行基礎設施**。
- **為什麼重要**：★ **如果 agent 的存在綁在機器上，「很多 agent」就等於「很多機器」**；分開之後**狀態才是稀缺的、機器是可租的**。對我們：多 agent 的問題多半**不是缺 agent，是缺可釋放的 worker**——分派出去的工作佔著 session 不放，等於沒有排程。同時 Gartner（二手轉述）預測 **2030 年 70% 企業會把 agentic 開發流程放進 sandbox（2026 為 10%）**。
- **可信來源**：<https://www.infoq.com/news/2026/11/google-substrate-gvisor-cncf/>、<https://github.com/agent-substrate/substrate>
- **Wiki**：`concepts/agent-execution-needs-its-own-foundation-layer.md`（新增）

### 5. ★★ **MCP 現在直接承載 playbook——server 可以自己發 skill、跑背景任務、暫停等人簽核**

- **發生什麼**：Anthropic 官方（2026-11-24）發布 **MCP 四擴張**：**Skills over MCP**（public beta，server 可在工具之外**發佈 skill**，Claude **只在需要時載入**，且 **skill 隨 server 更新、使用者不需另外安裝**）、**Tasks**（GA，server 可跑耗時操作**甚至完整 agent loop**，Claude 續作、結果備妥再取回）、**Elicitation**（GA，server 可**暫停以表單或連結向使用者要輸入**再從原處繼續）、**File Uploads**（即將推出，**PDF／試算表／圖片不經 context window**）。次級來源稱 MCP SDK **月下載 700M**（去年 11 月約 90M，近 8 倍）、**10,000+ connectors**。
- **為什麼重要**：★ 這**改變了 skill 的風險模型**：skill 從「本機檔案」變成「**可被遠端替換的執行契約**」——我們 wiki 在 2026-08-12 曾判定「OpenClaw 的 SKILL.md bundle 角色不受直接衝擊」，**這個判斷今天要修正**。★ 同時 File Uploads 不經 context window，對我們的成本結構是實質機會（附件走檔案+路徑而非貼進 context）。★ Tasks + Elicitation 的組合意味著**「背景執行 + 人工簽核」第一次變成協定層能力**，不必每個 app 自己寫 loop。
- **可信來源**：<https://claude.com/resources/articles/skills-over-mcp-tasks-and-more>、<https://modelcontextprotocol.io/extensions/skills/overview>、<https://modelcontextprotocol.io/extensions/tasks/overview>
- **Wiki**：`concepts/Skills Over MCP.md`（補 2026-11-26 delta，並修正舊判斷）

---

## 對 OpenClaw / Linder 的啟發

### ★ 1. 把 handoff 的 acceptance 從「agent 自述」改成「host 端可執行檢查」

依重點 1：我們的 CEO→agent 分派、背景任務、跨 session 接手，**驗收目前是文字**（agent 回報「已完成」）。
**可執行方向**：每個 handoff 附一條 host 端會跑的檢查（產物存在、schema 通過、關鍵數字在範圍、報告含指定欄位），
回傳 **verdict（pass/fail + 證據）** 而非自述。★ 依那個 1/6 token 成本比，這是本週**效益比最高的單一改動**。

### ★ 2. 記憶層補「淘汰」與「可指名」，而不只是補「更多」

依重點 2：我們的 daily memory 檔案已經可指名（接近 context folding），但 **MEMORY.md 是 rolling summary**，
且**我們的 skill 只增不減**。
**可執行方向**：① MEMORY.md 的 curation 加入明確規則——「N 天沒被引用就降級或移除」；
② skill 目錄加**淘汰檢查**（有誰在用？多久沒用？）；③ **刪之前先量一次使用率**，不要憑感覺刪。

### ★ 3. 對外動作加「身分 + 意圖比對」這一層，別只靠 prompt 說明

依重點 3 + 5：我們的 skill 允許 agent 在預設情況下直接對外行動（Discord 寫入、外部 API 呼叫）。
**可執行方向**：★ 在對外動作前，比對 **(a) 這次呼叫的身分／權限、(b) 使用者原始請求、(c) 當前政策**——
形狀抄 Google 的 semantic governance policies（動作前檢查，不是事後稽核）。
★ 另外，**MCP server 端 skill 可遠端更新**這件事，意味著我們對外部 skill 的信任不能只看「安裝時的內容」。

---

## 值得追蹤的 repo / paper / article

- **arXiv:2611.28244** — *Demystifying the Autoresearch Harness: How Context and Skills Shape Self-Evolving Agents*（context folding +19.2%）<https://arxiv.org/abs/2611.28244>
- **arXiv:2604.25850** — *Agentic Harness Engineering*（v5，2026-11-22；消融定位在 tools/middleware/long-term memory）<https://arxiv.org/abs/2604.25850>
- **arXiv:2611.24924** — *Agentic Harness Engineering Beta: Requirement-Centered Evolution of Agent Harnesses*（2026-11-18）<https://arxiv.org/abs/2611.24924>
- **arXiv:2611.26980** — *Contexture: Runtime Context Eviction for High-Throughput Agent Serving*（點名 Hermes／OpenClaw／Codex；64% 最終歷史 token 為撤除候選）<https://arxiv.org/abs/2611.26980>
- **arXiv:2611.26346** — *Context as a Resource*（ClonAct：routerless context virtualization，避免跨題 constraint bleed 與 head-of-line stalling）<https://arxiv.org/abs/2611.26346>
- **Formalize or Lose It** — 可執行監督的實驗釋出（附 preprint／實作／資料集）<https://discuss.huggingface.co/t/research-release-formalize-or-lose-it-experimental-results-on-executable-oversight-in-agent-swarms/192381>
- **Anthropic：MCP servers can now ship skills, run tasks, and more**（四擴張官方說明）<https://claude.com/resources/articles/skills-over-mcp-tasks-and-more>
- **InfoQ：Google Donates Agent Substrate and gVisor to the CNCF** <https://www.infoq.com/news/2026/11/google-substrate-gvisor-cncf/>
- **InfoQ：QCon SF 2026 — The Harness Is the New Operating System**（「instructions guide. boundaries enforce.」「give the model a pointer, not the whole thing」）<https://infoq.com/news/2026/11/harness-new-operating-system/>
- **github.com/agent-substrate/substrate**｜**gvisor.dev**（agent 執行基礎設施層）
- **repo 觀察**：GitHub `topic:agent-skills` 近 7 日有 push 者 **177 個**，頭部是**單一垂直領域的 skill 庫**（design / taste / diagram / research / media），另有 `addyosmani/agent-skills`（production-grade engineering skills）、`paperclipai/paperclip`（管理 agent 的開源 app）

---

## 下一步建議

1. **把 handoff acceptance 從文字改成 host 端可執行檢查**（先做一條：cron 任務的產物驗收）——
   量一次「agent 自述完成」與「程式判定 pass」的不一致率，這就是我們自己的 71%／49% 基線。
   ★ **未量之前不要引用那個 71% 當作我們的數字。**
2. **量我們的記憶使用率，再刪**（MEMORY.md 條目 + skill 各自的「多久沒被引用」）——
   依 arXiv:2611.28244，未被使用的教訓是負債；★ 刪之前先量一次引用率。
3. **Ingest 到 llm-wiki**（本輪已完成：1 source + 4 concepts + 1 既有頁 delta，圖譜連結已建）→
   下一輪可補：讀 **Formalize or Lose It 的 preprint 全文**、讀 **arXiv:2611.28244 全文**驗證 19.2% 與「選擇性丟棄」的具體幅度、
   並核對 **MCP SDK 700M／10,000+ connectors** 的一手來源。

---

## 未取得／降級（誠實標註）

- **arXiv 三篇（2611.28244 / 2611.24924 / 2604.25850）僅讀 abstract**，未讀全文、未重現任何數字。
- **Formalize or Lose It 的 preprint 全文未讀**，僅讀 research release 貼文；**其數字未經獨立驗證**。
- **arXiv:2611.26980（Contexture）** 主體已於 2026-11-24 建頁，本輪**未另立重點**。
- **QCon SF keynote** 僅讀文字報導（投影片與錄影未看）；且該條已於 2026-11-24 建頁，**本輪僅視為既有覆蓋**。
- **MCP SDK 月下載 700M / 10,000+ connectors 來自次級部落格**，官方頁面未核對。
- **Google semantic governance 的 48.7% → 0.9% 與 2.6pp** 來自二手彙整，**未讀 Google 技術報告原文**。
- **GitHub star 數未逐一核對**（search API 回傳數量級可疑），本輪只當排序參考、不引用數字。
- **LangSmith Tool Gateway／Microsoft Foundry／Azure Monitor 三條**僅讀二手彙整，官方文件未讀。
- **未跑任何實驗、未量我們自己任何基線。**
