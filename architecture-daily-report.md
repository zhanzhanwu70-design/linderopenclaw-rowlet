# 每日 Agent × 軟體開發情報 — 2026-11-11

> 來源：19 個公開來源（arXiv 3 篇皆 **abstract 級**；VulnCheck〈After 7-months, Glasswing Overwelms Maintainers with Underwhelming Findings〉11-09；InfoQ〈LLM Reliability Layers Under Test〉11-10、〈GitLab 19.5 Makes Agentic Development a Governed Part of the DevOps Platform〉11-06、〈Google Finds that Technical Debt Can Derail Coding Agents Through "Agent Distraction"〉11-10（已於 11-08 收錄，僅複核）；OpenClaw v2026.11.3 release notes；Claude Code v2.1.318／319／322 release notes；GitHub API + Trending；HN Algolia 近 4 日 30 條逐條掃過；InfoQ AI/ML RSS；OpenAI News RSS）。
> Raw：`/home/amr/llm-wiki/raw/research/architecture-daily-2026-11-11/`
> Wiki：已入庫 1 source + 5 concepts，並擴充 4 個既有頁（graphify 已同步；6 頁全部 non-orphan，incoming link 皆 ≥1）
> **未取得**：Martin Fowler `martinfowler.com/articles/` → **403**；LangChain Blog RSS → 只回 feed 標題（無條目）；Papers with Code → 未直接抓取（站點改版重導向），以 arXiv abs 頁為準。
> **複核為無更新**：MCP spec 最新穩定版仍是 **2026-07-28**（本週無新版本）；OpenAI Codex 近期僅 `rust-v0.167.1` 與多個 `alpha` tag，**body 無實質 release-note 內容**。
> **Graphify linking 備註**：任務指示的 `npx graphifyy link --source … --target …` 在本機 graphify **不存在**（實測 `error: unknown command 'link'`）；已改用本 repo 既有的 `tools/add-wiki-pages-to-graphify.py`（以頁內 `[[wikilink]]` 建立 `wiki_link` 邊）＋ `cluster-only` 達成等效連結，並**實測 6 頁 incoming link 皆 ≥1**（第一次跑時 `tool-surface-as-least-privilege-boundary` 為 orphan，已補 `agentic-trust-boundaries` 的 inbound link 後重跑確認）。

**一句話總結：今天有五條來自四個不同領域的獨立訊號，全部指向同一個瓶頸位置的移動——瓶頸不再是「能不能生成」，而是「誰來驗、來得及驗嗎，以及驗的東西是不是真的被抽取出來了」。** Anthropic Project Glasswing 七個月後的帳單最刺眼：**回報 37,966 個 findings，只有 217 個被標記修好，9 月以來新增 12,000 個卻只多了 15 個修補**；curl 拒絕 34 份已發布報告中的 19 份為漏洞。InfoQ 的可靠性層實驗給出另一個角度：**沒有任何驗證層能救回 extractor 漏掉的 mention**，最大的增益來自對齊標註慣例而不是換模型。與此同時，MIRIX-2.0 把記憶整併搬到**寫入路徑之外**（AutoDream 關掉反而在五個計時基準都更快），MaxIM 把「摘要要 grounded」寫成**互資訊的目標項**而不是 prompt 裡的一句話，而 OpenClaw / GitLab / Claude Code 在同一天各自把**工具面、憑證隔離、失敗可見性、fail-closed** 拉到平台層。**harness 的下一個瓶頸是「驗證產能 + 抽取召回 + 最小權限」，不是「再多一層 agent」。**

---

## 今日 5 個重點

### 1. Agent 生成的安全發現快到維護者驗不過來——「驗證洪水」的第一份大規模量測

- **發生什麼**：VulnCheck 追蹤 Anthropic Project Glasswing 七個月（11-09）：**442 個** CVE 可歸因 Anthropic（約佔今年所有 CVE 的 0.5%），但**僅 2 個**被確認在野利用；Anthropic 回報的 **37,966** 個 findings 中**只有 7,349（19.4%）已公開、只有 217 個標記為已修**；9 月以來新增近 **12,000** 個 findings 卻只記錄 **15** 個額外修補；**1,654（4.4%）** 被標為 duplicate（≈已修數的 **8 倍**），另有 419 個 withdrawn。Anthropic 宣稱的 true positive rate 從 90.8% 升到 94.2%，引發其如何計算 duplicate／withdrawn 的疑問。**Anthropic 的 OSS Scanner 把驗證工作轉移給維護者**：curl **拒絕 34 份已發布報告中的 19 份**為漏洞，只確認 6 份為低嚴重度，9 份待評估。
- **為什麼重要**：這是「驗證吞吐是新的瓶頸」在**安全領域**的實測版本，而且比 coding 領域更嚴苛——coding 領域的瓶頸是「agent 產生的變更驗不過」，安全領域是「agent 產生的**指控**驗不過，而且每一份指控都要消耗一個真實維護者的信任」。**19/34 的維護者拒絕率**意味著 scanner 產出若未經維護者確認就外流，會直接侵蝕報告的可信度基準。更關鍵的是結構：**Anthropic 的真陽性率是自報的，唯一的外部檢定手段就是維護者的接受／拒絕**。
- **可信來源**：<https://www.vulncheck.com/blog/anthropic-glasswing-november-update>

### 2. MIRIX-2.0：記憶的整併應該在寫入路徑之外，而且可以是選配的

- **發生什麼**：arXiv:2611.12068（11-09 提交）MIRIX-2.0。六個 typed memory agents **保留完整紀錄作為 system of record**；**provenance hypergraph** 以 n-ary frames **引用其 rows** 來索引 episodic 與 semantic 紀錄；**retrieval 在明確預算下執行**，所以「一個問題所檢視的證據量不隨歷史增長」。**AutoDream merges duplicate anchors outside the write path without rewriting any record, and it distills task sessions into skills.** 成效：LoCoMo **91.4%**、LongMemEval-S **72.6%**（領先最強 baseline **14.3 點**）；**AutoDream 關閉時**在 single-hop／multi-hop document QA 上仍比 HyperMem 高 **31.0／22.0 點**，且「**AutoDream 關閉時，MIRIX-2.0 在五個計時基準全都比 HyperMem 快**」。程序性記憶在 MetaClaw-Bench **49.2%**，高於 MetaClaw 自家 skill library 的 **44.0%**。不需 fine-tuning，code public。
- **為什麼重要**：最有結構性意義的不是分數，是**「關掉整併層反而更快」**——它證明 consolidation 是一個**可選、非同步、且要付延遲成本**的層，而不是每次寫入的同步步驟。加上「不改寫任何紀錄」與「provenance hypergraph 引用 rows」，整併後**仍可追溯回原始 row**。另外「蒸餾 task sessions 成 skills」與「單一寫者記憶頁」互補：**技能是從會話蒸餾出來的產物，不該散落在會話裡**。
- **可信來源**：<https://arxiv.org/abs/2611.12068>｜<https://github.com/Mirix-AI/MIRIX>

### 3. InfoQ 可靠性層實驗：驗證層的上限是抽取器，不是模型

- **發生什麼**：InfoQ（11-10，Pushpdeep Mishra／Wejdan Bagais，reviewed by Hien Luu）〈LLM Reliability Layers Under Test〉。五條結論：(a) **reliability layers 依可信度排序答案，但幾乎沒有修正任何一個**；**yield**（正確答案數 ÷ 全部紀錄數）揭露 accuracy 隱藏的東西；(b) **deterministic code 可以證明答案錯，永遠不能證明答案對**——它抓得到不存在的 code 與缺漏的 span，但貌似合理的答案仍需模型或人；(c) **recognition beats generation**——從記憶回想 SNOMED code，模型**捏造 13–18% 不存在的碼**；改成從選單挑選，分數高十倍；(d) temperature 0 下**五個模型家族有四個完全重現輸出**，第五個三次執行有 70% 的 mention 一致；(e) **detection 設下硬上限**：**沒有任何一層能救回 extractor 漏掉的 mention**，因此**最大的增益來自對齊 corpus 的標註慣例**，而非 domain-adapted 模型。
- **為什麼重要**：這把「驗證」從**模型能力問題**重新定位成**召回問題**。我們先前得到的「agent 不會自修 instruction file」是同一個形狀：兩個層級的失敗都是**上游缺口不會被下游修復**。所以投資順序是 **extractor recall → 標註慣例對齊 → 才是 verifier**；倒著做只會得到「排序變好了但沒幾個被修正」的假進步。Recognition ≫ generation 則直接命中我們的 skill 與 wiki：讓 agent **從受控選單挑**永遠比让它**憑記憶生成**可靠。
- **可信來源**：<https://www.infoq.com/articles/llm-reliability-layers-limits-accuracy/>

### 4. 工具面、憑證與失敗可見性——三個平台在同一天各自把它們拉到產品層

- **發生什麼**：(a) **OpenClaw v2026.11.3**（11-10）：**Visible tool failures**——**回報無回應的 tool failure，而不是靜默結束一個 user-addressed turn 當成成功**；**Private task results**；**Reliable child-task handoffs**（取消 child 後可交接，不被已取消 child 的 receipt 堵住）；**Bounded authentication**；**Sandboxed image access**；**Verified workspace connections**；另有一整組 **credential isolation** 修正——plugin 結果綁其連線憑證、Firecrawl key 綁其 endpoint、embedding 憑證綁其目的地、config 讀取遮蔽 inline env 憑證、managed Signal daemon 與 bundled language server **不再繼承無關的 Gateway secrets**。(b) **GitLab 19.5**（InfoQ 11-06 報導；版本 10-15 發布）：GitLab MCP server **GA**、Claude Code／Cursor 可存取更廣工具目錄並啟動或監控 Duo agents／flows、**管理員可選擇暴露哪些 MCP toolsets**（「giving an agent every available tool increases both context consumption and the number of actions」→ toolset selection 是一種 **least-privilege agent design**）、**MCP rate limits**（Free 60／Premium・Ultimate 600 req/min，reconnect 與 retry 計入）、**Externally Connected Agents** 納入 AI Governance Dashboard（可見哪個 agent、由誰、對哪個 project）。(c) **Claude Code v2.1.319／v2.1.318／v2.1.322**（11-09～11-10）：auto mode 在 telemetry 或 feature flags 關閉時（含 LLM gateway 後方），**伺服器無法檢查的呼叫改為「詢問或拒絕」，不再 fallback 到內建 classifier**（fail-closed）；terminal 支援 **MCP tasks**；mod 的 `$.model.fork` 可設 **`effort`**，讓側邊小任務用低 effort；v2.1.322 為 Vertex fast mode。
- **為什麼重要**：三件事看似獨立，實則是同一條主線的三個切面——**「agent 碰得到什麼、碰壞了會不會被看見、碰不到的會不會被擋下」**。OpenClaw 的 visible tool failures 直接對應我們每週遇到的「靜默成功」；GitLab 把工具集選擇做成管理員開關，等於**把 least privilege 從設計建議變成平台預設**；Claude Code 在無法檢查時選擇詢問或拒絕，是同一個 fail-closed 判斷。對 OpenClaw 最直接可攜式的一條是 **effort 分層**：側邊小任務不該繼承主 session 的高 effort 與全工具面。
- **可信來源**：<https://github.com/openclaw/openclaw/releases/tag/v2026.11.3>｜<https://www.infoq.com/news/2026/11/gitlab-19-5-agentic-platform/>｜<https://github.com/anthropics/claude-code/releases>

### 5. MaxIM：把「摘要要 grounded」從 prompt 要求變成可最佳化的目標項

- **發生什麼**：arXiv:2611.12825（11-09 提交，**NeurIPS 2026**）MaxIM。將增量摘要表述為 **capacity-constrained, information-theoretic reward-shaping** 問題；從 value suboptimality bounds 出發，**限制序列資訊損失**會促使**最大化對未來、任務相關目標的預測 log-likelihood**（predictive sufficiency 的變分下界）；**遞迴一致性條件**透過**最大化與已觀察歷史的互資訊（MI）**來確保摘要 grounded；以**參數化非對稱 critic**計算 step-wise 變分 MI 下界做 dense reward shaping，緩解 credit assignment。實驗：長時程科學閱讀與多輪對話基準上勝過 RL、SFT、prompt-focused baselines，在**嚴格 token 預算**與**更長時程**下於 factual grounding、autorater 指標與下游任務效用皆優，且**不需昂貴的人類偏好標籤**。
- **為什麼重要**：過去我們對 compaction 的處理是「在 prompt 裡要求摘要要 grounded」——這是一個**不可驗證的期望**。MaxIM 把它變成一個**有下界的量**（摘要與已觀察歷史的互資訊），而且**不需要人類偏好標籤**就能訓練 → 這給了 compaction 一個**客觀回饋訊號**，讓 A/B 判準不再靠「看起來比較好」。與第 3 點合起來構成一條完整命題：**先確保抽取沒漏，再確保摘要有根據。**
- **可信來源**：<https://arxiv.org/abs/2611.12825>

---

## 對 OpenClaw / Linder 的啟發

1. **把「驗證洪水」當成容量問題排程，不要當成品質問題排程。** 今日四個領域同時顯示同一件事（安全 findings、文件債、agent distraction、抽取召回）：我們的瓶頸是**驗證產能**。可執行版本：(a) 對每個自動產出的主張（finding、wiki 命題、報告結論）標一個**驗證狀態欄**（`unverified` / `maintainer-rejected` / `confirmed`），並**明確記錄被維護者拒絕的數量**——那比自報真陽性率可信；(b) 每週跑一次**過期性稽核**（對 7 天前寫入的 wiki 命題重新抽證），把維護者接受率當成 cron 的健康指標，而不是只看有沒有跑完；(c) 報告要同時報 **yield**（正確紀錄數 ÷ 全部紀錄數），否則成功率會隱藏洪水。
2. **記憶整併改走「寫入路徑之外 + 不改寫紀錄 + 有 provenance」三條件。** 具體到 OpenClaw：daily memory 維持 append-only（現況已對），但**補上 provenance 欄位**——每個蒸餾條目帶一個 `sources:` 指向產生它的會話段落或檔案範圍；且**整併（dreaming／蒸餾成 skill）不得就地改寫來源檔**，只寫新頁並建立連結（這正是 Anthropic 案例中「共享表被互相覆寫 → 72% 覆蓋率」的教訓）。因為「關掉反而更快」是已量測的事實，整併還應該**做成可開關的背景層**。
3. **給子任務設「低 effort + 窄工具面」，並在 harness 層設 fail-closed。** 兩條外部證據指同一方向：Claude Code 的 `$.model.fork` `effort` 選項（側邊小任務用低 effort）與 GitLab 的 toolset 選擇（least privilege）。可執行版本：OpenClaw 的 `sessions_spawn` 在派**研究／查證型**子任務時明確指定 `toolsAllow` 白名單（`read`／`web_search`／`memory_search`／唯讀 `exec`）而非繼承全套工具；並且**當子任務的工具呼叫無回應時必須報成失敗、而不是回傳空成功**——這正是 OpenClaw v2026.11.3 的 visible tool failures 修的同一個 bug，我們要把它當成**回歸測試**而不是一條 release note。

---

## 值得追蹤的 repo / paper / article

- arXiv:2611.12068 — MIRIX-2.0: Multi-Agent Memory System（AutoDream、provenance hypergraph、budgeted retrieval）— <https://arxiv.org/abs/2611.12068>
- arXiv:2611.12825 — MaxIM: Maximally Informative Incremental Summarization via RL（NeurIPS 2026）— <https://arxiv.org/abs/2611.12825>
- VulnCheck — After 7-months, Glasswing Overwelms Maintainers with Underwhelming Findings — <https://www.vulncheck.com/blog/anthropic-glasswing-november-update>
- InfoQ — LLM Reliability Layers Under Test: Accuracy, Yield, and the Limits of Verification — <https://www.infoq.com/articles/llm-reliability-layers-limits-accuracy/>
- InfoQ — GitLab 19.5 Makes Agentic Development a Governed Part of the DevOps Platform — <https://www.infoq.com/news/2026/11/gitlab-19-5-agentic-platform/>
- OpenClaw v2026.11.3 release notes（visible tool failures／credential isolation／child-task handoff）— <https://github.com/openclaw/openclaw/releases/tag/v2026.11.3>
- GoogleChrome/modern-web-guidance（Chrome／Edge／Firefox／MDN 共同維護的 agent skills，CLI 有 `search`／`retrieve`／`legacy-scan`）— <https://github.com/GoogleChrome/modern-web-guidance>
- yetone/magpie（agent 的模型路由層做成桌面選單：Codex on DeepSeek、Claude Code on Kimi）— <https://github.com/yetone/magpie>

---

## 下一步建議

1. **把「驗證狀態欄 + 維護者拒絕率」做成每日報告的固定欄位**，並在 wiki frontmatter 加 `verified:` / `rejected_count:`——這是三條建議裡唯一能立刻產生新資訊的改動，且不需等實驗。
2. **安排一個小實驗（可在本週內完成）**：對 `wiki/` 中最近 30 天的 10 條關鍵命題做一次**人工複證**，記錄 (a) 仍成立、(b) 已被推翻、(c) 證據不足無法判定三種結果的數量。這會直接給出我們的「驗證洪水」基線數字，也順便測試「unclassified ≠ insufficient」在實務上是否可操作。
3. **不要急著寫新的 skill，先做既有的失效回歸**：OpenClaw v2026.11.3 的 visible tool failures 與我們既有的「靜默成功」問題是同一個 bug 型態——先寫一個最小測試證明我們的流程在 tool call 無回應時會報失敗（而非回傳空成功），再考慮要不要新增 skill。這個順序的收益是**先修系統、再疊技能**。

---

## 本日查過但無實質更新的來源（誠實記錄）

- **MCP spec**：最新穩定版仍是 **2026-07-28**，本週無新版本。
- **OpenAI Codex**：近期僅 `rust-v0.167.1` 與多個 `rust-v0.169.0-alpha.*`／`rust-v0.167.0-alpha.*` tag，**body 無實質 release-note 內容**。
- **Martin Fowler**：`martinfowler.com/articles/` 抓取回 **403**，今日未取得文章清單；改以 InfoQ RSS 覆蓋該面。
- **LangChain Blog RSS**：抓取只回傳 feed 標題（無條目），**未取得內容**。
- **Anthropic news 頁**：僅取得連結清單，今日無 agent 架構／方法論條目。
- **OpenAI News RSS**：近 5 筆全為產品／公司公告，非架構或方法論更新。
- **Multi-step SWE**（arXiv:2611.07166）、**Harness²**（google-research/harness2）、**dsh-superagent** 已於先前日期收錄，本次僅複核不重複入庫。

---

## Wiki 入庫紀錄

- **Raw**：`/home/amr/llm-wiki/raw/research/architecture-daily-2026-11-11/`（raw-notes.md 17.7 KB + source-meta.yaml 0.8 KB）
- **Wiki 新增 6 頁**：
  - `wiki/sources/daily-research-2026-11-11-verification-flood-write-path-consolidation-and-tool-surface-governance.md`
  - `wiki/concepts/verification-flood-generation-outpaces-triage.md`
  - `wiki/concepts/consolidation-outside-the-write-path.md`
  - `wiki/concepts/extraction-recall-is-the-verification-ceiling.md`
  - `wiki/concepts/tool-surface-as-least-privilege-boundary.md`
  - `wiki/concepts/grounding-as-an-optimization-target.md`
- **擴充既有頁 4 個**：`verification-throughput-is-the-new-bottleneck`、`dreaming-as-offline-memory-consolidation`、`compaction-provenance-laundering`、`agentic-trust-boundaries`
- **Index / Log**：已更新 `wiki/index.md`、`wiki/log.md`
- **Graphify**：`tools/add-wiki-pages-to-graphify.py` → **PASS: Added 2130 wiki page nodes and 14796 wiki links**；`cluster-only` → 完成；**實測 6 頁 incoming link 皆 ≥1（全部 non-orphan）**。
