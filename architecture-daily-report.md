# 每日 Agent × 軟體開發情報 — 2026-11-23

> **來源**：三類皆有，共 27 個公開來源。
> **Agent / AI engineering research**：arXiv API（`cat:cs.AI AND abs:"agent"`，60 筆，全部 2026-11-19 提交——11-22 為週日，最新批次仍是週五）＋ 7 個 abs 頁。
> **軟體開發潮流**：InfoQ RSS（15 items，11-19～11-22）＋ InfoQ 全文 ×2（Claude Code 憑證外洩、Google Agent Compute Engine）＋ HN Algolia（868 筆符合門檻，取 11-17 後）＋ Signal blog（11-20）＋ Frostbite 架構長文（HN 676 分）＋ HN〈If you stop writing code〉（396 分）＋ GitHub Trending daily（16 repos）。
> **實務工具與框架**：Claude Code releases（v2.1.330 起 10 版）＋ Codex releases（rust-v0.171.0 起 8 版）＋ OpenClaw releases（v2026.11.10-beta.1 起 8 版）＋ LangGraph（1.2.24）＋ MCP spec。
> **Raw**：`/home/amr/llm-wiki/raw/research/architecture-daily-2026-11-23/`（15 檔，約 1.2 MB）
> **Wiki**：新增 1 source ＋ 6 concepts；更新 2 個既有 concepts（既有頁補 delta，未重複立頁）；已用 `tools/add-wiki-pages-to-graphify.py` 建立圖譜連結（7 頁全部 non-orphan，edge 數 7–33）
> **未取得／降級**：`npx graphifyy link` 子指令仍不存在（第四次確認）→ 改用 repo 內 linker｜GitGuardian 數字為 InfoQ 轉述，**未直接查其原始報告**｜MCP spec 自 2026-07-28 無新 revision（事實）｜arXiv 7 篇**僅讀 abstract**，未讀 PDF 正文、未交叉核對表格數字｜OpenClaw 自 v2026.11.10-beta.1（11-19）起無新 release

**一句話總結：今天有兩條互相獨立的軸線同時推進，而且它們指向同一個工程結論——
①「agent 可以有系統地演化自己的 harness，但不能在沒有 oracle 的情況下自由改寫自己的 skill」：前者是增益（GEPA 用小部分算力 recover 大部分權重更新的專化收益），後者是淨侵蝕（無回饋改寫 30 輪後 −15 分）。
②「允許清單不是安全邊界」：Claude Code 的憑證外洩規模升級到 31,088 個 secret、5,343 個仍有效、連 Docker Hub images 都有，而 Google 把「harness 在 sandbox 外、憑證由外部 Gateway 注入」變成基礎設施層保證。
而把兩條線接起來的那個洞是同一個：**缺 oracle**——skill 改寫、harness 選版、記憶漂移，三件事目前都靠「分數」當回饋，而今天的四篇論文分別指出：instruction-level coverage、counterfactual 歸因、trace replay、可證明安全保證，才是能撐起這些迴圈的東西。**

---

## 今日 5 個重點

### 1. ★★★ 無回饋的 skill 自我改寫是**淨侵蝕**：30 輪 −15 分，而且先丟掉最該留的東西

- **發生什麼**：arXiv:2611.25534（11-19）。實驗設計乾淨：讓模型**反覆改寫專家寫的 skill，全程沒有任何 task、run、judgment**，再用改寫後的 skill 建 agent 跑 benchmark。結果是**每個模型、每個 benchmark 都變差**，SkillsBench **30 輪後平均掉 15 分**。機制用對照組抓到了：只給 topic 讓模型自產 prior，改寫會**把 skill 拉向模型自己的 prior**，**最先捨棄的是 prior 之外的知識**。
- **為什麼重要**：★ 這把「agent 自我繁殖 skill」從中性設計變成**有方向的風險**——不是「不變好」，而是**系統性移除專家才知道、模型自己想不到的東西**，而那通常正是最罕見、最難從模型 prior 重建的部分（環境特有約定、反例、歷史陷阱）。好消息是作者說那些被丟掉的知識**可以放回去**，代表損失是**可定位的**，不是隨機退化。★ **與既有 wiki 的關係是層級不同而非衝突**：`continual-harness-evolution-forgets`（2611.03219）量的是「有評估訊號但跨任務不保留」，本篇量的是「**連評估訊號都沒有**」——後者更常見也更危險，因為我們多數 skill 繁殖路徑沒有 golden case 對照。
- **可信來源**：<https://arxiv.org/abs/2611.25534>

### 2. ★★★ 領域專化的主要增益**可以不要權重更新**：GEPA 只演化 harness，小部分算力 recovery 大部分收益

- **發生什麼**：arXiv:2611.25380（11-19）。把 domain specialization 從「收集軌跡 → RL/SFT → 部署新 checkpoint」換軸成 **harness 演化**：演化 **system prompt、tool schemas、skill library、planning scaffolding**，**policy 凍結**。方法是把 harness evolution cast 成 **RL-style outer loop**，用 **GEPA**（reflective evolutionary optimizer）實作。產出的 harness adapter **不需要 GPU 訓練、可按垂直領域載入、與 weight-based RL 可組合**。實驗對象是 **Codev（Claude Code-style coding agent）× SWE-bench Verified / OfficeBench / Terminal-Bench**。
- **為什麼重要**：結果型態非常清楚：**weight updates 給出最強的單一路徑增益；harness evolution 以一小部分算力 recover 大部分那些增益；兩者可組合**。★ 實務意義直接——**我們沒有能力為多個領域各訓一個 checkpoint，但我們有能力為多個領域各準備一個 harness adapter**：前者要 GPU 與資料管線，後者只要版本控制，**成本低一到兩個數量級**。★ 另一個不顯眼的推論：既然 harness 演化能 recovery 大部分權重增益，「模型選型」就不再是專化能力的唯一瓶頸——**在 MiniMax-M3 這種非 frontier 模型上，專化的槓桿在 harness 層可能比在模型層更大**。
- **可信來源**：<https://arxiv.org/abs/2611.25380>

### 3. ★★ skill 失敗有兩種成因，必須分開：**未覆蓋的指令是缺口，不是改寫對象**

- **發生什麼**：arXiv:2611.25429（SkillPlumber，11-19）。既有自演化方法**以整個 run 為單位**判斷失敗（看結果、看它錯在哪），**分不出**失敗是「指令寫錯」還是「指令沒被遵守」。解法是借鑑 **instruction-level coverage**：把每個 run 中**每條指令**標成 **follow / not-follow / not covered**——這一步就把兩種成因分開。SkillPlumber 再用一個 persistent root cause analysis agent 把每個標籤轉成修訂問題，**並用下一次 run 檢查每次修訂**，最後由 maintainer 蒸餾。
- **為什麼重要**：★ 這補上了 harness 演化領域缺的那塊 **oracle**——「哪個變體可以留下」的判定，需要比「分數高」更細的訊號；`harness-evolution-needs-requirement-verification`（2611.24924）早就說「合入條件必須是已驗證需求」，但**一直沒說誰來產生需求 oracle**。★ 更重要的是**成本結構**：**not-followed** 是執行面問題（agent 沒遵守、注意力被稀釋），**改寫指令沒有用甚至有害**；**not-covered** 是覆蓋面問題（該補覆蓋或刪指令）；**follow 但結果錯** 才是真正的「指令寫錯」，也是唯一該改寫的少數情形。→ **self-evolution 的正確單位不是整個 skill，是「沒被遵守的那條指令」**。
- **可信來源**：<https://arxiv.org/abs/2611.25429>

### 4. ★★ 「允許清單不是安全邊界」：憑證外洩升級到 31,088 個 secret，連 Docker Hub images 都有

- **發生什麼**：InfoQ 11-22 報導 Claude Code 的「Don't Ask Again」憑證外洩（既有 wiki 已於 11-08 收錄，本次是**規模 delta**）。★ **GitGuardian 補充的新數字**：公開 GitHub 上 `.claude/settings.local.json` 內有 **31,088** 個 secrets，其中 **5,343 個在偵測當下仍有效**，另有 **613 個在 Docker Hub images** 內。★ **新的失效機制事實**：泛用 secret scanner（**gitleaks、TruffleHog**）**漏掉大部分**，因為秘密以 **shell command 字串**形式存在——同一模式也出現在 **transcripts、memory files、handoff notes**。Claude Code 只把該檔加入**全域** gitignore，**不寫進 repo 自己的 `.gitignore`**，所以不隨專案走。
- **為什麼重要**：★ **「命令字串」是秘密的第二個存放位置**，key-format 型掃描器對它無效——這意味著任何「我們有 gitleaks 所以安全」的斷言都是不完整的。★ Apiiro 自己的定性更狠：Claude Code 管理秘密的方式本身就是安全缺口——「它是一份開發者可觸及系統與其密碼的清單，一個檔案搜尋之內」，而且**每個專案都在同一個路徑**。★ 對 OpenClaw 的直接含意：**持久化的允許清單同時是弱點的儲存處與弱點的傳播路徑**。
- **可信來源**：<https://www.infoq.com/news/2026/11/claude-code-leaking-secrets/>

### 5. ★★ 強制點要落在 **syscall 層**：命令層擋不住巢狀副作用，Google 把「可稽核軌跡」變成基礎設施

- **發生什麼**：兩個來源收斂。**arXiv:2611.25599（Tether）**：現有防禦兩類都不夠——**LLM monitor 沒有可證安全保證**（它自己就是被攻擊的同一類元件）、**stateless policy 漏掉多步資料流與未建模副作用**（原文舉例：**Python script 內發起的網路呼叫**）；Tether 的做法是**每個動作在短暫隔離沙箱中實際執行，從觀察到的 system call 反推抽象動作語意，再在推得的語意上強制「狀態化」policy**（policy 能記住「剛才發生過什麼」）。**InfoQ 11-22〈Google Agent Compute Engine〉**：★ harness（brain）**完全在 sandbox（hands）之外**，guest 只執行 harness 明確派發的指令，**每次 tool call 對應 sandbox 內的預期 compute activity** → 形成可稽核軌跡；**憑證由外部 Agent Gateway 注入、永不進 sandbox**；內部用於 Gemini、Antigravity、model eval。
- **為什麼重要**：★ 這是 `hook-failure-must-block-the-action` 的**系統層版本**，而且補上了它的盲區：command / HTTP / `mcp_tool` hook 檢查的是**指令字串**，`python -c 'urllib.request.urlopen(...)'` 在指令層看只是「執行 python」。★ 實務推論：**允許清單是便利性機制，不是安全邊界**；短期最便宜的缺口修法是**巢狀執行器展開式檢查**（`python -c` / `sh -c` / `node -e`），中期可用 seccomp / eBPF **觀察模式**先收集真實副作用基線。
- **可信來源**：<https://arxiv.org/abs/2611.25599> ｜ <https://www.infoq.com/news/2026/11/google-agent-compute-engine/>

---

## 對 OpenClaw / Linder 的啟發

**① 把「skill 自我改寫」和「harness 演化」在架構上拆成兩條路，前者預設關閉、必須掛 oracle。**
今天的兩篇論文剛好構成一個完整的操作準則：**無回饋改寫 = 侵蝕（30 輪 −15 分）**，**GEPA 式演化 = 增益（小部分算力 recovery 大部分專化收益）**。差別不在改什麼，而在**有沒有 oracle**。所以：skill 內容的自改寫預設關閉；要讓 agent 改自己的東西，就改 **harness adapter**（system prompt / tool schema / skill library / planning scaffolding），而且改完**必須用下一次 run 驗證**（SkillPlumber 的做法）。我們的 harness 應該做成**可按 agent × 領域獨立載入與回滾**的版本化資產——這也是多 agent 部署下成本最低的專化路徑。

**② 允許清單持久化要「存意圖不存含值」，同時補一個「命令字串內秘密」的掃描軸。**
今天最實用的一條硬事實：**gitleaks / TruffleHog 對「秘密嵌在 shell command 裡」是盲的**，而這正是 agent 記錄「它跑了什麼」時的天然格式——transcripts、memory files、handoff notes 全都一樣。所以：(a) 允許規則應該存**正規化後的意圖 / pattern**，不是含值指令字串；(b) 讓 repo 自己的 `.gitignore` 生效，而不是只靠全域 gitignore；(c) 對既有設定檔補一次**自訂的「命令字串內秘密」掃描**（不是 gitleaks）。這三件事一起做，成本很低但直接切斷今天的失效鏈。

**③ 記憶治理從「相關性」轉向「因果」，而且先做最便宜的那一步。**
DriftGuard 的兩個障礙很誠實：**perplexity / relevance 不足以判定「中和掉這條記憶會不會改行為」**，**counterfactual 重放又太貴**。可執行的版本是：**對一批可疑記憶做離線中和重放，建立我們自己的因果貢獻基線**——★ 這正好可以當作第 1 點裡「skill 改寫所需 oracle」的候選實作（同一套機制同時服務兩個問題）。中期用「top-k vs 隨機基線」的表現差異當 drift 的粗代理。另外把記憶投遞量做成 **per-model 參數**（強模型全量、弱模型精選，見 11-21 的 arXiv:2611.26361），並且**所有負載量測改用 trace replay**（replay 1.18x vs live re-run 4.98x，arXiv:2611.25905）。

---

## 值得追蹤的 repo / paper / article

- **arXiv:2611.25534** — How Feedback-Free Self-Evolution Reshapes Agent Skills（無回饋改寫 = 侵蝕，30 輪 −15 分）— <https://arxiv.org/abs/2611.25534>
- **arXiv:2611.25380** — Beyond Weight Updates: Evolving Agent Harnesses for Domain Specialization（GEPA 路線；實驗對象 Codev）— <https://arxiv.org/abs/2611.25380>
- **arXiv:2611.25429** — Evolve Where It Matters（SkillPlumber；instruction-level coverage：follow / not-follow / not-covered）— <https://arxiv.org/abs/2611.25429>
- **arXiv:2611.25599** — Tether: Verified Stateful Policy Engine for System-Level Monitoring of Agents（syscall 層狀態化強制）— <https://arxiv.org/abs/2611.25599>
- **arXiv:2611.25583** — DriftGuard: Online Memory-Drift Detection via Causal Attribution（記憶 drift 要因果、不是相關性）— <https://arxiv.org/abs/2611.25583>
- **arXiv:2611.25905** — Validation-driven Deployment of LLM Inference Platforms for Agentic Workloads（replay 1.18x vs live 4.98x；vLLM code-coverage 顯示 live/replay/synthetic 互補）— <https://arxiv.org/abs/2611.25905>
- **arXiv:2611.26601** — SoK: Assessing the Evolution of LLM Capability in Software Vulnerability Research（**autonomy scale** × correctness × availability × evidence strength；受限 frontier model 之前 agent 已能無人介入地 discover/validate/patch 漏洞，open-weight 模型後來達到相當 autonomy）— <https://arxiv.org/abs/2611.26601>
- **InfoQ 11-22〈Claude Code Has Been Leaking Secrets…〉** — 31,088 / 5,343 有效 / 613 在 Docker Hub；gitleaks 與 TruffleHog 的盲區 — <https://www.infoq.com/news/2026/11/claude-code-leaking-secrets/>
- **InfoQ 11-22〈Google Announces Agent Compute Engine〉** — harness 在 sandbox 外、可稽核軌跡、Agent Gateway 注入憑證 — <https://www.infoq.com/news/2026/11/google-agent-compute-engine/>
- **`elementalsouls/Claude-BugHunter`**（今日 +1,721 stars）— Claude Code skill bundle，**82 個 skill + 15 個 slash command**，做 bug hunting 與外部 red-team — <https://github.com/elementalsouls/Claude-BugHunter>
- **`obra/superpowers`**（今日 +785）— agentic skills framework & software development methodology — <https://github.com/obra/superpowers>
- **`HKUDS/CLI-Anything`**（今日 +687）—「Making ALL Software Agent-Native」；**`google-labs-code/stitch-skills`**（+516）— Agent Skills library — <https://github.com/HKUDS/CLI-Anything>
- **Frostbite（HN 676 分）** — Architect Labs 主張 CPU 從 ISA、microarchitecture、RTL 到驗證與 GDS **全由 AI 系統自主迭代**，25 個 workload（含 15 個留到最終評估）取得 **4.59x perf/W** — <https://architectlabs.com/blog/frostbite>
- **Signal（11-20，HN 577 分）** — 限制 iOS 27 與可偵測的 Android 版本上 OS 內建 AI assistant 讀取 Signal 螢幕；沿用當年擋 Microsoft Recall AI 的 screenshot blocking 手段 — <https://signal.org/blog/protecting-your-privacy/>
- **HN〈If you stop writing code, you also get worse at reviewing it〉**（396 分）— 只輸出不動手會讓審查能力退化，**閱讀（含閱讀 AI 生成內容）不等於練習** — <https://cekrem.github.io/posts/if-you-stop-writing-code-you-also-get-worse-at-reviewing-it/>
- **工具動態**：Claude Code v2.1.330（Enterprise organization sign-in、內建 `easel` mod）｜v2.1.329（**trust dialog 警告 hook 在哪宣告**、managed settings hook 載入失敗告警、`/tasks`、`/mcp` 顯示 JSON-RPC 錯誤）｜v2.1.328（**`"onFailure": "block"` 對 `mcp_tool` hook 生效**、Opus 4.6 / Sonnet 4.6 auto mode、OTel exporter 缺 endpoint 警告）｜Codex rust-v0.171.0（**GPT-6.2 Sol / Astra 進 model catalog**、TUI workspace 預設開啟含 subagent transcripts、`codex exec --remote`）｜LangGraph 1.2.24（11-20）｜**MCP spec 最新仍是 2026-07-28（無新 revision）**｜OpenClaw 自 v2026.11.10-beta.1 起無新版本

---

## 下一步建議

1. **做一次「skill × oracle」實驗（今天就能啟動，2 小時內有第一個數字）**：挑 3 個我們最常用的 skill，把每條指令拆成清單，對最近 10 次真實 transcript 標 **follow / not-follow / not-covered**。產出兩份東西：(a) **哪些 skill 從未被觸發**（比「看最後修改時間」精確得多，直接接上 `stale-skill-is-worse-than-no-skill`）；(b) 我們自己的 coverage 基線——這就是「skill 自我改寫所需的 oracle」的實作。若結論是 not-followed 為主（我猜是），那麼「讓 agent 改寫 skill」這條路就先關掉，改走 harness adapter 路線。
2. **改允許清單的持久化格式 + 補掃描（低成本、直接切斷今天的失效鏈）**：(a) 允許規則改存**意圖 / 正規化 pattern**（含值指令字串不入庫）；(b) 讓 repo 自己的 `.gitignore` 生效而非只靠全域；(c) 對 `~/.openclaw/**` 與本 repo 跑一次**自訂的「命令字串內秘密」檢查**（gitleaks/TruffleHog 對這個位置是盲的，要自己寫規則）。★ 順帶把 `secrets` 的使用時機與 `settings.local.json` 的寫入路徑一起檢查。
3. **決定要不要 ingest 兩件事**：(a) 把今日 1 source + 6 concepts 納入下一次 `graphify` 全量重建（目前 `GRAPH_REPORT.md` 仍落後 `graph.json`，因本機缺 `networkx`——**這是已知積欠，不建議在無網路核准的情況下自行安裝套件**）；(b) 針對「記憶 drift 的因果基線」做一個小實驗：取一批可疑記憶做**中和重放**（移除該條後重跑任務，比較執行路徑差異）——**這同時是 skill oracle 的候選實作**，一石二鳥。
