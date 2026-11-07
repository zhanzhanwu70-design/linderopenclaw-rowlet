# 每日 Agent × 軟體開發情報 — 2026-11-07

> 來源：21 個公開來源。arXiv 五篇（2611.07286 / 2611.06946 / 2611.03219 / 2611.01415 / 2611.07759）皆 **abstract 級**；MIT CSAIL 部落格為全文首段；Thoughtworks／Martin Fowler 為全文或全文段；InfoQ 為 partial transcript；Claude Code、OpenClaw、LangGraph 為官方 changelog 全文；Microsoft 為官方 blog；TechTimes 為二手。
> Raw：`/home/amr/llm-wiki/raw/research/daily-agent-trends-2026-11-07/`
> Wiki：已入庫 1 source + 3 concepts（graphify 已同步，4 頁全部 non-orphan；最終圖譜 **10,500 nodes / 22,234 edges**）
> **未取得**：MCP registry、OpenAI Codex、Cursor、Windsurf 本週 release note；GitHub Copilot 官方 changelog 本週條目；Copilot harness billing 數字（僅二手）。

**一句話總結：今天三條主線各自指向同一件事——「agent 看到什麼、住在哪一層、改了會不會忘」正在被逐層拆開量測。程式碼表徵第一次被當成實驗自變數（結論是**收益看瓶頸在哪，不看工具本身**）；harness 第一次有了**跨層歸屬判準**（且作者自己承認判準還不夠成熟）；harness 自我演化則被證明**會災難性遺忘**（94% → 32%）。**

---

## 今日 5 個重點

### 1. 程式碼表徵第一次成為實驗自變數：收益取決於瓶頸，不取決於工具

- **發生什麼**：arXiv:2611.07286（11-05 提交）研究 **map-based code-representation workflows** 對 agent 行為的影響。作者指出多數 agent 仍以 raw files + lexical search + shell commands 讀 repo，把 code 當純文字；本文改問：**agent 看到不同的 repo 視圖，會改變什麼**。測五種 workflow——**AST / call graph / module dependencies / documentation-enriched search / hybrid**——每一種都暴露一個 agent 可查詢的 repository map。設定是 **Claude Code + Haiku 4.5** 對照 raw-tool baseline，四個 benchmark：LinuxFLBench（fault localization）、SWE-bench Pro（code gen & repair）、SWT-bench（test generation）、SecBench（security patching）。
- **數字**：LinuxFLBench 五種 workflow 的 **recall@10 全部優於 baseline（0.757–0.829 vs 0.717）**，token **省 25–39%**。SWE-bench Pro resolution **44.3–50.6% vs 49.0%**（持平或略低），token 省 17–26%。SecBench 上 Callgraph 最高 **34.3% vs 28.9%** 且用更少 token，**但所有 workflow 都增加 latency**。SWT-bench 上 Hybrid 47.8%、Docs 47.2% vs 44.7%，**但所有 workflow 用更多 token 且更慢**。
- **為什麼重要**：作者的總結是 map-based workflows「change both what the agent inspects and how much it spends, but their benefits are **task-dependent rather than universal**」。這直接命中我們的 LLM Wiki／Graphify 工作：我們一直假設「給 agent 結構化 repo map 會更好」，本文說**更精確的說法是——只有在瓶頸是「找到對的檔案」時才會贏；一旦瓶頸變成「寫對 patch」，token 節省會被 latency 與額外查詢次數吃掉，成功率回到 baseline**。也就是說：**graph 是一種省 token 的 localizer，不是一種 patch generator**。這也意味著「我們有 graphify 所以 agent 比較強」這種主張本身不可證偽，必須拆成「定位是否變準」與「最終 patch 是否變好」兩個指標分開量。
- **可信來源**：<https://arxiv.org/abs/2611.07286>

### 2. Harness 第一次有「跨層歸屬判準」，而且作者誠實地說它還沒成熟

- **發生什麼**：arXiv:2611.06946（11-03）處理一個一直缺規則的問題：現在大家都在 coding-agent harness **之上**加一層，把多次 agent run 組織成持續交付——但**「哪個機制屬於哪一層」從來沒有判定規則**。作者用一個操作定義來劃界：**單一 run 內的機制 → agent harness**；**協調多個 run、把 state 從一個 run 交到下一個、或由 run outcome 更新 → factory harness**；**必須隨應用領域改變 → domain layer**。另加兩條 residual test 處理基礎設施與模型層原因。對失敗則要求編碼**三個獨立欄位**——**缺陷從哪裡起源、哪一道 control 沒擋住、在哪裡修的**——並且**歸因到 environment 之前必須有正面證據**。
- **數字與誠實限制**：判準在「單一 operator 的 6 個專案 pipeline 的 documented failures」＋「3 個已發表系統的 26 個 component」上開發，然後**凍結**，交給**兩個同家族的 model coders** 對 **46 個 held-out units** 編碼：26 個 mechanism layers **全對**，20 個 incident fields 中對 **18–19 個（kappa 0.86–0.93）**。但**兩個 coder 都把 8–13 / 20 記為 undetermined 或 unrecorded**，且**各自把約一半 unit 標為 ambiguous**（主因缺資訊）。作者自己寫：「**Agreement here is neither accuracy nor usefulness, and human coders have not yet been tested.**」修訂版（把機制分類與事故歸因分開）解決規則衝突，但 sensitivity re-coding 的一致度反而降到 kappa 0.78–0.93。
- **為什麼重要**：這是一篇**方法論品質高於結論品質**的論文。價值不在「判準正確」，而在**示範了怎麼把「這東西該放哪層」變成可編碼的三分法，並給出歸因所需的最低證據門檻**。對 OpenClaw 尤其直接：現在 OpenClaw 同時是 agent runtime、cron/session orchestrator、plugin host、以及 domain-specific workflow container——**這四件事在程式碼裡是同一個 repo，但在架構上屬於四層**。附帶一個可借用的方法論警告：**兩個同家族 model coder 的一致性不等於正確性**，我們若要用 LLM 做分層歸屬審計，必須自己補 human coder 的 baseline，並且要明說「無法判定」佔了幾成。
- **可信來源**：<https://arxiv.org/abs/2611.06946>

### 3. Harness 自我演化會災難性遺忘：94% → 32%

- **發生什麼**：arXiv:2611.03219（11-02）問一個實務上必答的問題：harness self-evolution 已是提升 agent 表現的重要範式，但既有研究**大多只在單一任務上研究演化**；實務上 coding agent 要長期處理**多種任務類型**，那 harness 能不能**跨任務持續演化而不遺忘**？實驗把 3 個 SE 任務 dataset 組織成 **6 個演化方向**，套用 2 種代表性 harness evolution 方法做持續演化。
- **數字**：用 **DeepSeek-V4-Flash-0731 + Meta-Harness**，在 **SWE-Bench 上演化到 94.0%**；接著**往 FeatureBench 繼續演化，到第五輪時 SWE-Bench 掉到 32.0%**，對應**相對下降 66%**。作者結論：evolution on a subsequent dataset can「**substantially undermine** the performance on previously seen datasets」。程式碼：<https://github.com/THU-Agent/continual-harness-evolution>
- **為什麼重要**：這是對「skill 越學越多越好」「harness 會愈用愈強」兩種敘事的**直接反證**，而且反證的形狀是**安靜的**：不是新增任務失敗，而是**舊任務在沒有任何警告的情況下崩掉**。對 OpenClaw 的 `learned-skill capture`／`Learning and skills`（2026.11.5-beta.1 明確新增「learned-skill capture, reuse, and guided authoring」）這是**必須被量測的風險**：如果我們讓 agent 從 run 學到 skill 並寫回，**今天的 skill 系統很可能在覆蓋新任務的同時悄悄劣化舊任務的行為**——而我們目前的評估方式（看新任務有沒有變好）**結構上偵測不到**。這與既有 wiki 裡的 forgetting-as-scaling-lever 形成對照：那條線把遺忘當成**省 context 的槓桿**，這條線證明**遺忘也可以是自我演化本身的副作用**——兩者必須分開命名。
- **可信來源**：<https://arxiv.org/abs/2611.03219>

### 4. Harness 從「一家公司的實作」升格為「跨產品平台元件」，並且開始被計價

- **發生什麼**：Microsoft 在三個月內完成一次身分轉換。**2026-08-03** Copilot Studio Blog 宣布新 harness **GA**，當時名稱為「**GitHub Copilot harness in Copilot Studio**」，背後是 Copilot Cowork 等最進階 agent 體驗的 coding 與 reasoning 能力；該文編者按註明「**The GitHub Copilot harness is now the Microsoft Copilot harness**」。**2026-10-29**（GitHub Universe 2026），**Microsoft Copilot harness 在 Foundry Agent Service 公開預覽**（一手為 Microsoft Copilot Blog；TechTimes 與多家媒體為二手）。**2026-12-01** 起 sandbox compute 與 memory 改按用量計費（**二手數字**：USD 0.0994 per vCPU-hour、USD 0.0118 per GiB-hour）。
- **並行趨勢**：Thoughtworks Technology Radar **Vol.35**（Chris Ford，11-04）把 **harness 稱為新的核心資源**並主張它是一個**平台產品**：需要 roadmap、SLO、deprecation policy、明確 owner。「**A cheaper model with a good harness will outperform an expensive model with a bad one.**」相關 blip：**Enterprise harness**（Assess）——「平台團隊已經擁有 CI、identity 與 observability，讓他們以同樣的期待擁有 agent runtime 是合理的」；**Managed agents runtime**（Trial）；**Agent Package Manager** 與 **agent plugin marketplace**（Trial）；**Agent Plugins**（Assess，互通標準）；**progressive context disclosure**（Adopt）；**agent sandboxing** 直上 Adopt。
- **為什麼重要**：**同一個 harness 同時服務 GitHub Copilot、Copilot Studio、Copilot Code**，是「harness 是跨產品平台元件」的第一個公開訊號；而 **sandbox compute/memory 被計價**則是「harness 是可計價 runtime 資源」的第一個訊號。這兩件事對 Linder 的意義是：**harness 的未來形態更像一個有 SLO 的服務，而不是一個 git repo 裡的設定檔**。我們的 OpenClaw 目前把 agent runtime、plugin、skill、cron、session store 全放在同一個 workspace，這在單人規模是優勢，但一旦要給別人用，就必須開始拆「runtime 與 host application」的邊界——Thoughtworks 的建議（命名 owner、發布 golden path、讓它比 DIY 更快）與 arXiv:2611.06946 的三層判準（agent harness／factory harness／domain layer）**可以合併成同一張圖**。
- **可信來源**：<https://www.microsoft.com/en-us/copilot/blog/copilot-studio/the-github-copilot-harness-in-copilot-studio-is-now-the-microsoft-copilot-harness/>、<https://techcommunity.microsoft.com/blog/copilot-studio-blog/more-powerful-agents-and-workflows-for-autonomous-business-processes-introducing/4542969>、<https://www.thoughtworks.com/insights/blog/technology-strategy/macro-trends-tech-industry-november-2026>

### 5. 「被拒絕」與「被批准」不再是同一件事：permission 語義與 MCP task 背景化

- **發生什麼**：Claude Code **2.1.319**（11-06）有三個改動值得單獨記：**(a) MCP tasks**——當 MCP server 以 task 形式執行 tool call，Claude Code **立刻把它移到背景**，完成後再把結果告訴 Claude（`CLAUDE_CODE_DISABLE_MCP_TASK_BACKGROUND` 可關）；**(b) `permissions.denyInsteadOfPrompting`**——一個「會卡在權限 prompt」的 tool call 被**直接拒絕，turn 繼續**（terminal session、subagent、teammate 皆適用）；**(c)** 當 safeguard 攔下 subagent 後，改為**告訴它「用更窄的 prompt 重試或回報」**，**而不是自己動手做**。同時 `/tasks` 新增「Earlier in this session」讓已完成的 subagent 可被重開並繼續對話。
- **旁證**：LangGraph **1.2.20**（11-05）走的是同一方向——每個 task 內的 `interrupt()` 有自己的 id，並新增 **strict resume mode，拒絕 stale interrupt answers**；sdk 0.4.14 把 `strict_resume` 加到 `runs.create`／`stream`／`wait`。同時 OpenClaw **2026.11.5-beta.1**（11-04）新增 **Knowledge Scribes**（跨 agent／session／Control UI 的知識擷取與可重用 scribe workflow）、**PostgreSQL data plane**、**從對話直接做 PR 的端到端流程**，以及 **automations 的 persistent streams**。
- **為什麼重要**：這三個改動合起來是在把「人工審批」從**阻塞語意**改成**分支語意**。過去 agent 的 tool call 只有兩種結果：**允許**（繼續）或**等人**（整個 loop 停住）；現在多了第三種：**拒絕並帶著拒絕理由繼續走**。這在架構上非常關鍵，因為它讓 **「不可用」成為可回饋的狀態**，而不是終止。對照 Thoughtworks Radar Vol.35 把 **human-in-the-loop theater** 與 **meat proxy** 列為 Caution、並主張 **fund review as capacity, not overhead**，方向一致但更細：**審批點的數量不这等於審批點的阻塞時間**。而 OpenClaw 同時在 2026.11.5-beta.1 裡推出 Knowledge Scribes + persistent streams，等於是在做「跨 session 的知識產出物」＋「跨時間的執行續接」——這兩者加起來，正是讓 agent 從「一次性對話」變成「有連續性」的最短路徑。
- **可信來源**：<https://code.claude.com/docs/en/changelog>、<https://github.com/langchain-ai/langgraph/releases/tag/1.2.20>、<https://github.com/openclaw/openclaw/releases/tag/v2026.11.5-beta.1>

---

## 對 OpenClaw / Linder 的啟發

### 啟發 1 — 把「repo map」從自稱優勢改成可分解的兩個指標，並加上 regression guard

2611.07286 讓我們的 graphify／LLM Wiki 主張變得可證偽。建議在 wiki 層建立**兩段式**量測：**（a）定位段**——給定 issue，agent 能否在 N 次檢索內找到正確檔案／行（對應 LinuxFLBench 的 recall@10）；**（b）產出段**——找到之後 patch 是否比 baseline 好（SWE-bench Pro 的 resolution）。同時**必須同時報 token 與 latency**，因為本文顯示所有 map workflow 都增加 latency——只看成功率會系統性高估 graph 的價值。實作上最省力的一步：在自己的 task queue 裡加欄位 `map_used` 與 `files_touched`，用 logs 反推「有 map 卻沒縮到正確檔案」的失敗型態。

### 啟發 2 — 引入「分層歸屬表」與「遺忘回歸測試」兩個 OpenClaw 常駐檢查

**(a)** 借 2611.06946 的三層判準（agent harness／factory harness／domain layer）＋兩條 residual test（基礎設施 vs 模型），把 OpenClaw 的能力逐項歸位：寫檔、跑命令（agent harness）／cron、session routing、subagent 編排（factory harness）／LLM Wiki 的 ingest 流程、每日情報的挑題邏輯（domain layer）。**這張表的價值在於：當有人問「這個功能應該放哪」，不再靠直覺。** 對應本文的失敗編碼三欄位，我們可以把 incident 回報模板改成固定三欄（起源層／失效 control／修復層）。

**(b)** 借 2611.03219，在 harness／skill 自我演化的路徑上加一道**跨任務回歸測試**：任何寫回 skill、harness、memory 的變更，必須在**過去 N 個已解決任務**上重跑一次，舊任務得分下降超過門檻就**拒絕這次寫回**。這正是「skill capture 變成可持續能力」與「skill capture 變成靜默劣化」的分水嶺。對應 OpenClaw 2026.11.5-beta.1 的 `learned-skill capture`，**這道 guard 應該先於 skill capture 的自動化上線**。

### 啟發 3 — 把「拒絕」當成一等回饋狀態，並把 harness 開始當平台產品來治理

從 Claude Code 的 `denyInsteadOfPrompting` 與 LangGraph 的 strict resume 出發：我們所有需要人工核准的地方（ask_user、sessions_spawn 的可見性、automation 的 delivery、plugin 安裝）都應該保證**「被拒絕」之後 agent 帶著拒絕理由繼續走**，而不是讓整個 loop 死在那裡。同時借 Thoughtworks 的平台化框架，開始把 OpenClaw 的 harness 當產品治理：**命名 owner、定義 golden path、給它 SLO、寫 deprecation policy**——這在單人規模時看起來過度，但正是「harness 變成跨產品元件」之前的必要功課（微軟已經在做了）。另外把 **Thoughtworks 的「cost per completed task, not cost per token」** 與我們的每日情報 cron 結合：每日情報的真正成本指標是**「每天產出幾篇有結構性啟發的情報」**，不是 token 數。

---

## 值得追蹤的 repo / paper / article

- **arXiv 2611.07286** — How Should Agents See Code?（code representation 作為自變數，附 5 種 workflow 的具體 token／latency 數字）<https://arxiv.org/abs/2611.07286>
- **arXiv 2611.06946** — Beyond the Agent Harness: Boundary Criteria（附 coding manual、E1 data、coded units、analysis scripts）<https://arxiv.org/abs/2611.06946>
- **arXiv 2611.03219** — Continual Harness Evolution without Forgetting（程式碼）<https://arxiv.org/abs/2611.03219> ／ <https://github.com/THU-Agent/continual-harness-evolution>
- **arXiv 2611.01415** — Latent Harness（把 harness 蒸餾成 rank-8 activation shift，0.03–0.05% 參數、inference 零 token）<https://arxiv.org/abs/2611.01415>
- **arXiv 2611.07759** — ReConMem（repo 對話的 graph-based dual memory，LoCoEval +7.917／+7.292pp）<https://arxiv.org/abs/2611.07759>
- **MIT CSAIL — Weight-Space Programming**（GPT-6 Astra 直接讀寫權重：改 Qwen3.5-0.8B 的 0.016% 權重讓 MATH-500 從 7.9% → 48.1%）<https://rikiyat.github.io/blog/weight-space-programming/>
- **Thoughtworks Technology Radar Vol.35 — Macro trends**（Chris Ford，harness 作為平台產品的完整論述）<https://www.thoughtworks.com/insights/blog/technology-strategy/macro-trends-tech-industry-november-2026>
- **Martin Fowler — Harness engineering for coding agent users**（Böckeler 的 feedforward/sensor × computational/inferential 二分與分類表）<https://martinfowler.com/articles/harness-engineering.html>
- **OpenClaw v2026.11.5-beta.1**（Knowledge Scribes／PostgreSQL data plane／PR from chat／persistent streams）<https://github.com/openclaw/openclaw/releases/tag/v2026.11.5-beta.1>
- **Claude Code 2.1.319**（MCP tasks 背景化、denyInsteadOfPrompting、safeguard 後的窄化重試）<https://code.claude.com/docs/en/changelog>

---

## 下一步建議

1. **做一次「分層歸屬表」實作**：用 2611.06946 的三層判準，把 OpenClaw 現有主要能力逐項歸位並存成 `wiki/concepts/harness-layer-boundary-criteria.md` 的附表，同時把 incident 回報模板改成三欄式。低成本、可立即執行、且未來每次新功能都能複用。
2. **加一道 skill／harness 寫回的跨任務回歸測試**：在 skill capture 與 memory 寫回路徑上加入「最近 N 個已解決任務重跑」步驟，並以 2611.03219 的 −66% 相對下降作為警戒線設計門檻。建議先以唯讀 dry-run 跑一週，觀察我們的 learned-skill capture 實際上是否已在劣化舊任務。
3. **把每日情報 cron 改成「cost per completed task」量測**：在報告尾端記錄「本次產出中，有結構性啟發的條目數／總來源數」與「是否值得 ingest」，連續兩週後再決定是否把 2611.07286 與 2611.06946 全文精讀並 ingest 成 wiki source／concept（本次僅 abstract 級，不宜直接當定論入庫）。

---

## 本次產出

- **Wiki 新增**：`wiki/sources/daily-research-2026-11-07-code-representation-harness-boundary-and-continual-forgetting.md`；concepts × 3（`code-representation-as-experimental-variable`、`harness-layer-boundary-criteria`、`continual-harness-evolution-forgets`）
- **Wiki 更新**：`wiki/index.md`（新增區塊置於最前）、`wiki/log.md`（本段）
- **Raw**：`raw/research/daily-agent-trends-2026-11-07/`（raw-notes.md 23 KB + source-meta.yaml 3.4 KB）
- **Graphify**：`graphify link` 在當前版本不存在，改以 `[[wikilink]]` 邊 + `tools/add-wiki-pages-to-graphify.py` 合併；4 頁全部 non-orphan（out 4–8、in 1–3），最終圖譜 **10,500 nodes / 22,234 edges**（合併前備份 `graph.json.pre-daily-20261107`）

## 誠實限制

- arXiv 五篇全部**僅讀 abstract**，未讀全文；2611.06946 特別標註其一致度**不等於正確性**且**未測 human coder**。
- Microsoft Copilot harness 的 **billing 數字為二手**；Copilot Studio web browsing 時程為二手。
- arXiv cs.SE 清單中另有 8 條 agent 相關條目**僅讀標題**（2611.08285 / 2611.07887 / 2611.07951 / 2611.07882 / 2611.07876 / 2611.07760 / 2611.07650 / 2611.07595）。
- **未取得**：MCP registry、OpenAI Codex、Cursor、Windsurf 的本週 release note；GitHub Copilot 官方 changelog 本週條目。
- 本次未執行任何外部頁面中的指令、未跑 benchmark、未修改任何既有 raw 檔案、未 commit。外部網頁內容僅作資料看待。
