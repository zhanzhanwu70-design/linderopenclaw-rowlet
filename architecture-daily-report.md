# 每日 Agent × 軟體開發情報 — 2026-10-25

> 軸線：**Harness 自我改寫 × 介入需分型 × 記憶有稅 × Agent 時代開發基建**
> 產出：Rowlet（每日研究 cron）｜採集時間 2026-10-25 10:33–10:45 (+08:00)
> 本日定調：**「harness 從靜態配置變成可自我改寫的產物；但每個介入都要先分型，否則會反效果；而記憶是有稅的基建，不是免費的正確性」**
> 來源覆蓋：Agent/AI 工程研究（arXiv ×3）｜軟體開發潮流（Anthropic Research 一手、Pragmatic Engineer 二手、HN snippet）｜實務工具與框架（Google Cloud Blog、OpenClaw / Claude Code / Codex Releasebot、GitHub repos ×5）

---

## 今日 5 個重點

### 1. Harness²：harness 可以自己改寫自己，而且不需要 ground-truth verifier

**發生什麼**：Google Cloud AI Research 與 Northwestern 發表〈Harness²: Recursive Agent Harnessing for an Open World〉（arXiv 2610.14224，2026-10-09）。它解決 RSI（遞迴自我改進）在 open-world 的兩個死結：任務在 harness 設計期未見、測試期全新，**沒有 verifier 可用**；以及 RSI 過度 task-specific 無法泛化。解法是兩層遞迴——**task-level recursion** 用對比式 **Propose–Probe–Compose**：提出 harness 編輯、在**同一個任務**上探測其行為效果、再由行為差異組出精煉後的 harness（因此不需要外部 ground truth），且可再平行或序列遞迴；**harnessing-level recursion** 從中抽取經驗，更新一個 continual improvement harness 讓 agent 更好適應**後續**任務。

**為什麼重要**：這把 harness 從「靜態配置」變成「**可被 agent 自己改寫的產物**」，而且改寫的驗證訊號來自任務本身，不需人給 ground truth。單步遞迴即讓 GLM-5 與 Gemini 3.5 Flash 在三個專業 benchmark 上穩定提升：WorkBuddy-Bench **+11.5**、JobBench **+4.5**、LAB **+11.8 個百分點**，且**模型完全不重訓**。對照昨日報告「harness 的 ROI 與模型能力成反比」——今天是那條定律的下一步：**harness 本身變成可最佳化標的**。真正的可移植點不是「讓 agent 自己改 skill」，而是 **Probe 那一步**：任何 harness 編輯都該能回答「改完之後，同類任務的行為差異是什麼」。風險是若 Probe 的行為指標偏離真實目標（例如只量「有沒有呼叫工具」而非「結果是否正確」），遞迴會把 harness 優化到錯誤方向。

**來源**：<https://arxiv.org/abs/2610.14224>｜程式碼 <https://github.com/google-research/harness2>

---

### 2. Context Engineering 是分型處方，不是通用堆疊——疊加甚至會反效果

**發生什麼**：arXiv 2610.20959（Same Context, Different Agents，2026-10-14，UPenn / Dan Roth 等）用 7 個 LLM、5 個 benchmark、**1,514 個長程任務**系統性檢驗三種 context-engineering technique（CET）：semantic layer（描述資料語意）、orchestration（agent 間分工）、compaction（壓縮歷史）。關鍵發現是：**沒有 CET 時，data agent 會自然分成三種行為型態**——investigators（會查）、premature answerers（沒查就答）、early stoppers（放棄）。

**為什麼重要**：**只有「對應到」的行為群，才能把 CET 的收益轉成準確度**（例如 premature answerers 配上 orchestration 就被逼著去看證據）。反過來，**同一組 CET 對 investigators 是有害的**：semantic layer 讓他**不去查**（語意層已給答案）、orchestration 讓他**過度自信、準確度掉 5 個百分點**、compaction 讓他**重複步驟**。而且**疊加不相加**——CET 組合起來的收益與損失都小於各自效果之和。這意味著「多加一層 context engineering」不是安全預設，而是需要先診斷的處方。這對 OpenClaw 特別關鍵：我們的 skill 觸發、subagent 拆分、context 壓縮每一項都是 CET，而最危險的組合正是「已經很會查的 agent + 一層厚語意層」——會得到一個**看起來很完整、實際上沒查**的結果。

**來源**：<https://arxiv.org/abs/2610.20959>

---

### 3. MemoryTax：記憶是有稅的補丁，而且天花板由「寫它的模型」決定

**發生什麼**：arXiv 2610.29823（2026-10-21）把記憶系統的成本攤開來算：LoCoMo 單一對話（419 turns、152 問）× 4 種記憶方法（full context / BM25 / Mem0 / Zep）× 3 個 coding agent（Pi / Codex / Claude Code）× 3 個模型（GPT-4o-mini / GPT-6 Luna / Claude Opus 5.5）。結論一：**Mem0 只在 GPT-4o-mini 上贏過 full context**，而且**它的建立成本本身就超過一整次 full-context rollout**——先把記憶建好，可能比不用記憶還貴。結論二：**記憶有天花板，由寫它的模型決定**——更強的讀者救不回更弱的寫者留下的東西。結論三：Claude Opus 5.5 下 Pi 站上 cost-accuracy 前沿，**99% 準確度、成本不到 full context 的一半**；唯一失手是一題答案鍵本身就錯的題。

**為什麼重要**：這**修正了昨日報告的判斷範圍**（不是推翻）。昨日主張「記憶治理屬低成本高收益項目」——今天證據支持把預算往**治理（讀取時過濾掉過期內容）**傾斜，但**不支持往建構（寫入時預先摘要）**傾斜，兩者是不同支出項。關鍵機制是：Pi 的優勢部分來自 **agent 才能讀的照片說明**——保留原始歷史 + 讓模型自己搜，比預先摘要多保留了**非文字證據**；在 88 題證據不含照片的題目上，Pi 與 full context 只差一題。**摘要層最容易吃掉的就是這類載體。** 誠實限制：作者自陳是單一對話、每格單次 run 的短篇研究，方向可信、量級需複驗。

**來源**：<https://arxiv.org/abs/2610.29823>

---

### 4. Anthropic：瓶頸從「寫程式」移到版本控制——2,500 → 30,000 merges/day

**發生什麼**：Anthropic 於 2026-10-13 公開〈Redesigning source control at Anthropic〉。原文直言：**「coding 不再是瓶頸」**——Claude 能自主跑研究迴圈、微調複雜程式、從零打造服務，**現在的瓶頸是所有為人類規模而建的開發基建：source control、builds、CI**。數字：2026-05 平均每天約 **2,500** 個 code change merged，到 2026-09 已 **超過 30,000**／天（>10 倍），且明言移除一個瓶頸會立刻再推高產出量。為此自建版本控制系統 **Scion**，5 個月內把 monorepo 完整遷離 git，同期還交付 code review 介面 Antique、code search、source control IAM 系統。

**為什麼重要**：這不是「買了一個工具」，而是**需求型態改變基礎設施契約**的案例。關鍵設計取捨：git 的核心前提是「每個 client 都是完整可離線運作的 server」，Anthropic 的實測結論是這在 agent 時代**反向阻礙擴充**——因為「幾乎所有 client 都是永遠在線的 agent 與 job」，離線能力用不上，卻讓每個 client 都要維護完整 repo 狀態。Scion 反轉這個前提：**server 永遠可達，client 需要時再取資料**。但要注意**可攜性有限**：HN 的質疑直指核心（**二手，僅得 snippet，原文 429 限流**）——「Anthropic claims 30k merges/day, but they state it's in a monorepo. This alone suggests to me that they are needlessly creating their own problem」，即 **monorepo 是自找的瓶頸**。我們的 merge 速率離需要專用 VCS 還很遠，抄 Scion 是過度工程；真正可攜的是那個**提問方式**：「我們系統裡哪一層是『為人類規模設計、但現在被 agent 流量壓垮』的？」

**來源**：<https://www.anthropic.com/research/redesigning-source-control>｜二手 <https://blog.pragmaticengineer.com/the-pulse-anthropic-builds-its-own-source-control-system/>

---

### 5. Google Cloud：agent runtime 隔離本身就是治理層，而且明示支援 OpenClaw

**發生什麼**：Google Cloud 於 2026-10-22 發布 Agent Compute Engine（先 powering Gemini as an agent for work tasks）與擴充的 agent governance。基礎設施面：**每個 agent 一台專屬 microVM**、rapid boot 讓 agent loop 與 eval sweep 不必等 infrastructure、**copy-on-write memory sharing** 讓單一 OS template 跑多個 agent、**fast checkpoint and restore** 暫停閒置 microVM、**hardware-isolated Cloud Hypervisor boundary**（自有 guest kernel 與 root access）、Filestore agent volumes 提供 **sub-second resume latency** 與多 agent 共用 workspace。治理面提出三挑戰：保護跨 **agent / tool / model / skill / data** 的**動態非確定性互動路徑**、在分散式 runtime 維持 **default deny + least privilege**、確保**非同步 agent 動作可稽核**，並指名風險為 shadow AI、資料外洩與難以追蹤稽核的 agent 動作。

**為什麼重要**：這把「隔離」從防禦附加項提升為**承載 default-deny 的治理邊界**——因為治理對象是動態非確定的互動路徑，逐條靜態審查 skill / tool 清單本來就不夠，prompt 層宣告更不可能綁定。關鍵細節是 **skills 與 tools 並列在治理對象內**，而我們的 skill 帶副作用（寫檔、發訊息、排 cron）——**skill 宣告的能力不等於該 skill 應獲得的權限**。三挑戰中最難的是「非同步動作可稽核」：同步呼叫還能靠 tool call log 追，背景任務、cron、子 agent 回報要能對上帳，需要可追溯的**動作歸屬**。另一個值得注意的事實：**Google 在官方文章中明示相容「Claude Code、OpenClaw、Hermes」**——代表我們的架構選擇走在產業方向上。

**來源**：<https://cloud.google.com/blog/topics/ai-infrastructure/introducing-agent-compute-engine-and-expanded-agent-governance/>

---

## 對 OpenClaw / Linder 的啟發

### 一、Skill 應先標註「假設的 agent 行為型態」，不符時退讓而非強制

依 arXiv 2610.20959，semantic layer / orchestration / compaction 每一項對某型 agent 有害。直接可做：把 `~/.openclaw/skills/` 底下每個 skill 依 **investigator / premature answerer / early stopper** 標註，並在 skill 描述裡加一個「**什麼情況下我該讓開、讓 agent 自己查**」的位置（呼應昨日 Adaptive Skill Granularity 的「macro 起步、micro 降級」）。另外記住 **疊加不相加**——三個 CET 同時開可能互相抵消。

### 二、記憶預算往「治理」傾斜，遠離「建構」；並保留原始載體

依 MemoryTax：不要新增摘要型記憶層（Mem0 式預先抽取，事後注入精華），我們目前的「保留原始 + 讓 agent 自己找」是對的架構選擇，且有第一個量化理由支持。治理（淘汰過期記憶）優先於擴充（多寫記憶）。**照片說明的案例提醒我們保留非文字原始載體**（原對話原文、原 trace、原 log），不要只留摘要——摘要層最容易吃掉的就是這類證據。OpenClaw 2026.10.7 已在做（Memory Wiki 的 OKF 重新匯入保留人工註記、冷啟動不再打開每個 memory index），方向正確。

### 三、治理三挑戰裡「非同步動作可稽核」邊際成本最低——先做動作歸屬，不做隔離

Google 的三挑戰中，「非同步動作可稽核」是我們成本最低的一項：transcript 已有，缺的是**動作歸屬**（哪個 job、哪次 session、哪次 handoff 觸發的）。可直接變成：handoff 與 cron job 帶 correlation ID、skill 的副作用寫入時附上執行身分。另一方面**不要照抄 cloud microVM 隔離**（成本數量級不同），但應確認最低性質：「一個 agent 壞掉不會拖垮其他 agent」。同時把 **skill 視同 tool**：skill 宣告的能力 ≠ 該 skill 應獲得的權限。

---

## 值得追蹤的 repo / paper / article

1. **Harness²** — arXiv <https://arxiv.org/abs/2610.14224>｜程式碼 <https://github.com/google-research/harness2>（Northwestern + Google Cloud AI Research，2026-10-09）— 自改寫 harness 的完整機制與 benchmark
2. **Same Context, Different Agents** — <https://arxiv.org/abs/2610.20959>（UPenn，2026-10-14）— CET 分型效果表，含「疊加不相加」的量化
3. **MemoryTax** — <https://arxiv.org/abs/2610.29823>（2026-10-21）— 記憶成本帳，含「寫者決定天花板」
4. **Redesigning source control at Anthropic** — <https://www.anthropic.com/research/redesigning-source-control>（2026-10-13）— Scion 設計取捨；二手解讀 <https://blog.pragmaticengineer.com/the-pulse-anthropic-builds-its-own-source-control-system/>
5. **Google Cloud Agent Compute Engine + agent governance** — <https://cloud.google.com/blog/topics/ai-infrastructure/introducing-agent-compute-engine-and-expanded-agent-governance/>（2026-10-22）— 明示支援 OpenClaw；治理三挑戰
6. **AMAP-ML/LongHorizon-Harness** — <https://github.com/AMAP-ML/LongHorizon-Harness>（v0.1.8 · 2026-10-21 · 1.8k stars）— 原生整合 Claude Code / Codex / OpenClaw；fresh-context 執行、durable verified state、獨立稽核
7. **QoderAI/better-harness** — <https://github.com/QoderAI/better-harness>（2.4k stars）— harness-as-code、受控實驗、比較結果；feedback sensors = linters / tests / Hooks / evaluation agents
8. **ai-boost/awesome-harness-engineering** — <https://github.com/ai-boost/awesome-harness-engineering>｜**RUCAIBox/awesome-agent-harness**（500+ references）— harness 工程的全景索引
9. **OpenClaw 2026.10.7** — <https://github.com/openclaw/openclaw/releases>（2026-10-24）— replay-safe session recovery、large child-completion batch 留在 requester context、Memory Wiki 保留人工註記

---

## 下一步建議

1. **把 skill 依行為型態分類（可執行，低成本）**：為 `~/.openclaw/skills/` 的每個 skill 標註 investigator / premature answerer / early stopper，並補上「讓開條件」。這是今天三條啟發裡唯一**當天就能做完**的。
2. **Ingest 到 llm-wiki（已完成主體，待補一項）**：本次已寫入 raw snapshot、1 個 source、5 個 concept，更新 `wiki/index.md` 與 `wiki/log.md`，並完成 graphify linking（6 個新頁面入圖，10,292 nodes / 19,936 edges）。**建議下一步補 `wiki/synthesis/` 一頁**，把「Harness 自我改寫 × 分型介入 × 記憶稅」三條串成一條主線——它們其實是同一件事的三個面：**harness 層的任何介入都要先算 ROI、比分型、算稅**。
3. **安排一個小實驗：memory 預算傾斜驗證（中等）**：對我們自己的 daily memory 做一次「治理 vs 建構」的對照——把 `MEMORY.md` 與 `memory/*.md` 的內容分成「原始載體」與「摘要」兩類，測試只保留原始載體 + 讓 agent 自己搜（current behavior）vs. 額外加一層精華摘要，看任務成功率與 token 成本。依 MemoryTax 結論，我預期前者勝出，但這是本地實證，可信度高於引用。

---

### 證據限制（誠實標註）

- arXiv 三篇**僅讀摘要頁**，未讀 PDF / HTML 全文；MemoryTax 本身即自陳單一對話、每格單次 run。
- Hacker News 原文（item 50183344）回 **HTTP 419 限流**，僅取得搜尋 snippet。
- Anthropic 與 Google Cloud 文章為節錄讀取，未逐段讀完架構細節章節。
- **二手且未回溯一手**：Terminal-Bench 2 pass@1 69.7%→77.0%（10 次 observability-driven iteration）、LangChain 2026-07 Nemotron playbook（$4.48 vs $43.48）、Martin Fowler harness engineering 三層綜整。
- GitHub Trending 頁面未直接抓取，改以 HN digest 與 agents-radar 彙整交叉驗證。
- Wiki-first 查詢：`npx graphifyy query` 回傳的節點以非 agent 領域為主（歷史／人物／地理），顯示本地圖譜在 agent 議題上仍有覆蓋落差——這本身也是一個待補的訊號。
