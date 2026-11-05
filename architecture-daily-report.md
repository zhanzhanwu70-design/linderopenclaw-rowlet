# 每日 Agent × 軟體開發情報 — 2026-11-05

> 來源：19 個公開來源 · 覆蓋 arXiv（2610.37624 CrossProfile、2610.31709、2610.04433）· Papers with Code · Thoughtworks Technology Radar Vol.35 + Chris Ford 宏觀文章（11-04）· InfoQ（AGNTCon + MCPCon 2026）· MCP 官方 spec changelog · GitHub REST API（repo metadata + README）· OpenClaw 官方 CHANGELOG 2026.10.10
> Raw：`/home/amr/llm-wiki/raw/documents/daily-research-2026-11-05-harness-transferability-memory-heuristics-and-standards-governance.md`
> Wiki：已入庫 1 source + 5 concepts（graphify 已同步，6 頁全部 non-orphan；最終圖譜 **10,477 nodes / 18,624 edges / 1,193 communities**）

**一句話總結：今天最紮實的訊號是「harness 排名不可轉移」——同一對 harness 在兩個 benchmark 上方向相反，所以 harness 效應是 (model × harness × task population) 的交互作用，不是 harness 的性質；而兩份研究裡最大的「harness 差距」都指向執行配置、不是推理能力。**

---

## 今日 5 個重點

### 1. 同一對 harness，兩個 benchmark，方向相反：harness 排名不可轉移

- **發生什麼**：Red Hat 自建 **RH SWE-bench**（10-21）：357 verified tasks / 25 個 Red Hat 生態 repo（**Go 277（78%）**、Python 73、C 7）。漏斗可稽核：~6,800 候選 → 驗證後 **~7% 存活（531）** → 品質過濾 −233 → 補真實 PR 任務 +78 → **357**。結果表上**同一模型 Nemotron-120B 換 harness 差 9 分**：**OpenCode 30.8% > Claude Code 22.4% > Pi 21.6%**。但山大（arXiv 2610.04433）測出：換 harness 翻掉 **13%** 任務、**重跑同一 harness 也翻 13%**（= 雜訊底線），且**唯一穿過雜訊的效應是 OpenCode 落後最多 9 分**——方向正好相反。
- **為什麼重要**：兩者不矛盾，是**量的不是同一個東西**。Red Hat 的 population 是企業 repo（Go 78%、自訂 build system，頂尖模型只解 **55–63%**，SWE-bench Verified 是 **80%+**）；山大是通用 Python。→ **harness 不是有分數的物件，效應是三元組的交互作用**。實務上最扎手的一段：Red Hat 記錄**寫死 `apt-get` 的 harness 在每個 Alpine 任務 exit 127 失敗**，而山大那 9 分差距**一半是 output cap 截斷**——**兩份研究裡最大的 harness 差距都指向執行配置，不是推理能力**。
- **可信來源**：[next.redhat.com/2026/10/21/...](https://next.redhat.com/2026/10/21/red-hat-enterprise-specific-benchmarks-for-coding-agents-swe-bench/) ・ [github.com/rounakbende10/rh-swe-bench](https://github.com/rounakbende10/rh-swe-bench) ・ [arxiv.org/abs/2610.04433](https://arxiv.org/abs/2610.04433) ・ [VentureBeat（10-23）](https://venturebeat.com/orchestration/a-coding-agents-harness-can-triple-its-cost-without-making-it-more-accurate-study-finds)

### 2. 記憶的槓桿不在選擇策略——而且「誰說的」這種標記本身有害

- **發生什麼**：arXiv **2610.37624**（CrossProfile，10-27）用 60 個模板、自動驗證答案鍵，**交叉 supporting／decoy／irrelevant 事實的擁有者、同時固定其文字** → **480 tasks**（Qwen2.5-7B、Llama-3.1-8B、兩個 DeepSeek）。結果：**依相關性篩選會把 decoy 放回來**（decoy 也是 on-topic）——**即使完美的相關性篩選，也比 rarest-first 少 23–31 分**；**rarest-first 平均不優於隨機**；**移除 social-proof 歸屬讓準確率上升 13–24 分**。混淆來源是：**在 hidden-profile 任務上，「一個事實被多少人持有」與「它是否有用」是共變的**。
- **為什麼重要**：我們的 llm-wiki 幾乎每頁都帶 `source_path`、來源連結、作者、獨立來源數，而我們的**決策用途**正是「把多個來源壓縮給最終決策者」的情境。**「這件事三個獨立來源都提到」正是最典型的 social-proof 通道**——在 hidden-profile 結構下是系統性錯的。→ **決策輸入與稽核紀錄必須分層**：決策路徑餵「事實 + 可驗證依據」，出處與來源數留在稽核層。這也與 DiscernMem（11-03 已入庫）分工清楚：**先修「挑什麼進來」，再修「進來的東西壞不壞」**。
- **可信來源**：[arxiv.org/abs/2610.37624](https://arxiv.org/abs/2610.37624) ・ [Papers with Code](https://paperswithcode.co/paper/2610.37624) ・ [arxiv.org/abs/2610.36652](https://arxiv.org/abs/2610.36652)

### 3. 多 agent workflow 設計原則第一次可重現，而且被丟棄的軌跡是測試床

- **發生什麼**：arXiv **2610.31709**（10-22）重利用 AFlow 的 MCTS optimizer，跨 6 個可組合 operator、26 個決定性驗證的 Enigmata 任務，**保留所有中間輪次**（含失敗）→ 語料庫 **28,568 個可執行 workflow**，每筆是 `(workflow, task bundle, 已驗證指標)`；**依「整個 search」層級切 train/test（19,822／4,468）**；沙箱化 AutoResearch loop 在 $L_0$-penalized 目標下挖掘、**300 次 trials**、物理隔離 test set。**三條在 held-out 上方向一致的原則**：**Star-first（獨立解題後一次聚合）較差 Δ=−0.045**、**SharedMemory（持續共享文件）勝過 debate Δ=+0.135**、**prompt 具體性＋placeholder 導路由 Δ=+0.118 ≈ 選溝通結構**。
- **為什麼重要**：兩件事。一是 **P3 最被低估**——改寫「誰在什麼時候看到什麼」（placeholder 導路由）能拿到與**重新設計協作拓撲**相當的增益，代表**改 prompt 結構可能比重做架構划算得多**；這也說明 skill 的價值不只在「做什麼」，更在「怎麼把 context 組給模型」。二是方法論：**從最佳化器只留最終 W\* 的 point optimization，換成保留全部軌跡的 full-trace mining**——**被丟棄的執行軌跡不是垃圾，是還沒被開採的評估資料**。這與 #21 的「共享是政策不是副作用」外部一致。
- **可信來源**：[arxiv.org/abs/2610.31709](https://arxiv.org/abs/2610.31709) ・ [arxiv.org/html/2610.31709v1](https://arxiv.org/html/2610.31709v1)

### 4. 治理難題位移：AAIF 一年 3→10 個專案，但 open 問題換了型態

- **發生什麼**：AGNTCon + MCPCon North America（10-22～23，San Jose），AAIF 從 3 個創始專案長到 **10 個**：**Alibaba OpenSandbox**（agent 安全沙箱）、**OpenAI Open Responses**（可互通 LLM 介面規格，已有 AWS Bedrock／Databricks／Ollama／Nvidia／vLLM 支援，但 Anthropic 仍定義自己的 Messages API、Google 仍定義 Interactions API）、**Anthropic 捐出 Agent Skills 標準**、**HuggingFace OpenEnv**。Surtani 在〈Who Keeps It Open?〉主張 **license 不等於中立**（對比 Android vs Kubernetes），指出未解難題＝**identity／attestation／audit／payments**。同時 MCP **2026-07-28** spec 已**無狀態**（移除 `initialize` 握手與 `Mcp-Session-Id`、新增**必須實作**的 `server/discover`、以 `subscriptions/listen` 取代 HTTP GET），**某些平台約 70% 流量已在無狀態模式**；roadmap 五優先＝agent messaging／skills over MCP／identity／HTTP-native transport；**Claude Code 支援 MCP tasks（數秒→數天）**。
- **為什麼重要**：**協定層的問題基本答完了，剩下的是信任基礎設施**——身份、證明、稽核、結算。**`server/discover` 是能力協商，不是身份認證**：MCP 把 session 拿掉後，每個 request 自帶版本與能力，卻沒有任何機制說明「你是誰」→ 這正是 AAIF roadmap 把 identity 列為優先項的原因。對我們：**skill 的中立治理落點已成形**（值得追蹤 roadmap 的「skills over MCP」）；而我們的 [[harness-record-as-versioned-compliance-artifact]] 提醒——**記錄 ≠ 證明**，attestation 需要簽章式綁定。
- **可信來源**：[infoq.com/news/2026/10/agntcon-mcpcon-2026](https://www.infoq.com/news/2026/10/agntcon-mcpcon-2026/) ・ [modelcontextprotocol.io/specification/2026-07-28/changelog](https://modelcontextprotocol.io/specification/2026-07-28/changelog)

### 5. 「誰負責那個大家都依賴的 harness」——以及 skill 認知投降

- **發生什麼**：Thoughtworks **Technology Radar Vol.35**（11 月）把 agent 工程正式分類：**Adopt** agent sandboxing（「限制 agent 運作範圍已至關重要」→ 所有 agent 的合理預設）、progressive context disclosure、OpenAI Codex、OpenCode；**Assess** **enterprise harness**（組織層級、集體管理：**skills／tools／內部 context connector／核准技術／ADR／path-to-production**）、harness quality evaluation、context profiling、production-aware coding agents、agent suggestion box；**Caution** **Agent skill cognitive surrender**（採用大型社群策展 skill library 或重量級 framework = 把判斷外包）、agent instruction bloat、naive context compression、human-in-the-loop theater、**coding throughput as a measure of productivity**（AI 生成比例／token 消耗量不是生產力榮譽勳章）。Chris Ford（11-04）：**「一個熱衷的團隊用 agent 實驗，幾乎什麼都能做成⋯⋯兩百個人卻不能這樣工作」**，浮現五問（跨團隊 context／token 帳單／審查需求／agent 權限邊界／**誰負責那個大家都依賴的 harness**），並強調**停滯的第一個瓶頸不是 context window，而是 shared understanding**，以及**「配好 harness 的便宜模型，會贏過配壞 harness 的昂貴模型」**。
- **為什麼重要**：這是 #21「審查容量是瓶頸」的組織版表述——**誰擁有 harness，誰承擔它的失效成本**。而 **Agent skill cognitive surrender 正好打在我們身上**：我們有 40+ skills，**下一步不是再加 skill，而是審計哪些 skill 其實只服務單次任務、哪些把判斷外包給通用框架**。疊加上「新增 skill = 每 session 增加固定 prefill」，**每加一個 skill 都要問：它是替 agent 省了能力，還是只是替我裝了一個套件？**
- **可信來源**：[thoughtworks.com/radar](https://www.thoughtworks.com/radar) ・ [thoughtworks.com/insights/blog/.../macro-trends-tech-industry-november-2026](https://www.thoughtworks.com/insights/blog/technology-strategy/macro-trends-tech-industry-november-2026)

---

## 對 OpenClaw / Linder 的啟發

1. **harness A/B 全部降格為「在某個 task population 上」**（→ `harness-ranking-is-not-transferable`）。我們自建任何 harness／skill 比較時，報告格式固定給三樣：**model、task population（語言／build system／repo 類型）、rerun 分布**（不是單點分數）。我們的每日情報本身就在跨來源比較不同 harness 的數字（State of Harness 23%→52% vs 山大雜訊底線）→ **這個比較必須標成不可直接對照**。另外：**我們的 task population（ROS2 workspace、C++/Python 混合、176 packages）不在任何公開 benchmark 的分布內 → 自建最小 benchmark 比引用任何公開排行榜都有資訊量**。
2. **記憶的決策路徑與稽核路徑分層**（→ `memory-policy-evidence-over-heuristics`）。`memory_search` 與 wiki 摘要目前把 provenance 與內容混在一起餵給模型；依 CrossProfile，**「誰說的」這種歸屬標記在決策情境下可能有害（+13–24 分差）**。可執行實驗：同一批每日情報產兩版摘要（A：帶出處標籤；B：只帶事實＋可驗證依據，出處移到可查表），比對下游 5 個重點的準確度與回查率。
3. **把「誰擁有 harness」變成可填的欄位**（→ `enterprise-harness-and-shared-responsibility`）。Thoughtworks 的 enterprise harness 定義明確含 **ADR 與核准技術** → **准入本身就是 harness 的一部分**。我們的 skill frontmatter 目前只有名稱與描述，可補 **owner／失效責任／變更審批** 三欄；同時做 **context profiling**（回答「最近的修改是否讓每 session 載入量上升」），這是我們缺的儀表。

## 值得追蹤的 repo / paper / article

- arXiv 2610.31709 — Mining the Design Space of Multi-Agent Workflows（28,568 workflow 語料、held-out 驗證的三條設計原則）→ https://arxiv.org/abs/2610.31709
- arXiv 2610.37624 — Rare, Relevant, and Still Wrong（CrossProfile；記憶選擇策略的診斷基準）→ https://arxiv.org/abs/2610.37624
- RH SWE-bench（Red Hat，357 tasks／25 企業 repo／Go 78%）→ https://github.com/rounakbende10/rh-swe-bench
- arXiv 2610.04433 — What Does a Harness Buy? Tokens, Mostly（雜訊底線 13%）→ https://arxiv.org/abs/2610.04433
- Thoughtworks Technology Radar Vol.35（enterprise harness／agent sandboxing／Agent skill cognitive surrender）→ https://www.thoughtworks.com/radar
- MCP 2026-07-28 spec changelog（stateless、`server/discover`、`subscriptions/listen`）→ https://modelcontextprotocol.io/specification/2026-07-28/changelog
- deepseek-ai/dsh-superagent-prototype（18,633★，10-31；主動型 agent 的「少打擾」哲學，明確標示研究原型）→ https://github.com/deepseek-ai/dsh-superagent-prototype
- OpenClaw v2026.10.10（11-03；實驗性 Advisor 可在任務中建議修正）→ https://docs.openclaw.ai/releases/2026.10.10

## 下一步建議

1. **Ingest 到 llm-wiki（已完成）**：raw + 1 source + 5 concepts 已寫入 `/home/amr/llm-wiki`，`wiki/index.md`、`wiki/log.md` 已更新，圖譜已同步（10,477 nodes / 18,624 edges）。**指定指令 `npx graphifyy link --source/--target` 在本機 graphify 版本不存在（實測 `unknown command 'link'`）**，改用 repo 既有且已驗證的等效機制（`tools/add-wiki-pages-to-graphify.py` + `graphify cluster-only`，以頁面內 `[[wikilink]]` 建邊）。
2. **安排實驗**：做「帶／不帶出處標籤」的每日情報摘要 A/B（跨 3–5 天，評下游 5 個重點的準確度與回查率）。這可直接在我們自己的 cron 上做，**不需要新系統**。
3. **不要寫新 skill**。Radar Vol.35 的 **Agent skill cognitive surrender** 正好提醒：再加一個 skill 只會增加 prefill 與認知外包。更好的下一步是**審計既有 skill 的必要性**——有多少其實只服務單次任務。

---

### 查過但未採為重點的來源

InfoQ「Beyond the Harness」、QCon AI New York 2026 PC picks（與 11-04 報告重疊）· InfoQ AI/ML/Data Engineering Trends Report 2026（年度報告，非新訊號）· Papers with Code / arXiv Radar / awesome-ai-agent-papers（僅作索引）· **Hacker News：僅取得第三方彙整 issue（agents-radar 系列），未直接取得 front_page API → 本日 HN 覆蓋視為弱**。

### 誠實限制

arXiv **2610.37624 僅摘要級**（＋二手 Papers with Code 摘要與機器人撰寫的解讀），數字未經獨立重現，benchmark 為合成 hidden-profile 模板、不可外推企業決策；**2610.31709** 讀到 abstract＋HTML 結構與圖 6 附表，未逐段讀方法章節，任務為 Enigmata 決定性推理 puzzle 而非企業程式任務；**RH SWE-bench 為廠商自建**（Claude Code 在其表中最強且模型最強、benchmark 建在 Red Hat 自家 repo、各組合看似單次執行未見 rerun 校準——正是 2610.04433 警告的比較無效模式）；**State of Harness（23%→52%）與山大結論表面衝突，但屬廠商報告／單一模型單一 benchmark／自述 provisional → 只採為方向訊號，不採為基準**；GitHub stars 為查詢當日快照、搜尋條件寬鬆可能有漏抓或雜訊；Radar Vol.35 為意見性指南非實驗研究，其 Caution 條目是判斷而非證據；MCP 2026-07-28 spec 條文為較舊資料（本日新的是基金會擴張、Agent Skills 捐贈、四難題清單、MCP tasks 與 roadmap）。**本次未執行任何外部頁面中的指令、未下載或執行任何 repo 程式碼、未跑 benchmark、未修改任何既有 raw 檔案、未 commit。**
