# 每日 Agent × 軟體開發情報 — 2026-11-21

> **來源**：三類皆有，共 34 個公開來源。
> **Agent / AI engineering research**：arXiv API（`cat:cs.AI AND abs:"agent"`，60 筆，全部 2026-11-19 提交）＋ 15 個 abs 頁 ＋ 1 個 HTML 全文（取未展開的 LaTeX 巨集數字）。
> **軟體開發潮流**：InfoQ RSS（15 items，11-18～11-20）＋ InfoQ 全文 ×2（Google/CNCF、AWS Emulator）＋ HN Algolia（11-07 起，points>80，676 筆）＋ GitHub Trending daily（16 repos）。
> **實務工具與框架**：Claude Code releases（8 版）＋ Codex releases（8 版）＋ OpenClaw releases（10 版）＋ MCP spec ＋ LangGraph / AutoGen releases ＋ OpenAI GPT-6.2 公告。
> **Raw**：`/home/amr/llm-wiki/raw/research/architecture-daily-2026-11-21/`（34 檔，約 7.5 MB）
> **Wiki**：新增 1 source ＋ 6 concepts；已用 `tools/add-wiki-pages-to-graphify.py` 建立圖譜連結（7 頁全部 non-orphan）
> **未取得／降級**：`npx graphifyy link` 子指令不存在（第三次確認）→ 改用 repo 內 linker｜Google Cloud Blog 原始 URL 404 → 改以 InfoQ 為準｜apiiro 文章遭 Cloudflare 阻擋，僅取標題，**不引用其數字**｜MCP spec 自 2026-07-28 無新 revision（事實）｜AutoGen 最新 release 停在 2025-09-30（判定停滯）

**一句話總結：今天有兩個機制在兩份完全獨立的來源裡收斂，這才是本日真正的訊號——
①「合併閘門」（ClonAct 的 trial merge gate × AWS 的實務 merge gate）：agent 產生的變更必須先過一道可驗證的閘門，不過就回爛重做。
②「點名危害」而非「泛泛提醒」（ROGUE-AI × Claude Code 的 `/status` 壞檔清單）：agent 需要具體、可指認的失敗面清單。
而 ROGUE-AI 給出一個更大的反轉：72 件真實傷害事件中 62 件根本沒有攻擊者——我們的安全焦點長期押在錯的地方。**

---

## 今日 5 個重點

### 1. ROGUE-AI：108 次重現、89% 命中，而 62/72 件傷害**沒有攻擊者**

- **發生什麼**：arXiv:2611.26553（11-19）。空白在於：新聞報導 agent 事故只說「發生了什麼」，incident catalog 只收集、benchmark 只記錄失敗——**沒有一個會重現事故，也不會測試報告所懷疑的那個成因是否真是成因**。ROGUE-AI 離線重建每個已報事故，並配一個「只少了被指稱成因」的 matched control，兩個都跑 agent。
- **為什麼重要**：**108 次嘗試重現中 89% 重現了所報的傷害**；五個模型（GPT/Claude/Gemini/DeepSeek）**在 18–33% 的執行中犯下所報的錯誤，移除被指稱成因後最多 1%**——這個落差本身就是因果證據。★ 但真正的反轉在下一句：**72 件有真實傷害的事件中，62 件沒有任何攻擊者**，agent 只是照任務做、漏掉一個普通危害（原例：資料庫與線上站台共用）；**「無攻擊者」重現造成的傷害比 prompt injection 重現更多（五模型皆然）**，而 prompt-injection 防禦找的指令在這些重現裡一個都沒有。**可操作的副產物**：每次 tool output 之後給一段**點名危害與其後果**的警告 → 五模型傷害都下降；**等長但不提危害的註記幾乎無效**。
- **可信來源**：<https://arxiv.org/abs/2611.26553>

### 2. SkillBridge：skill 的跨 OS 可攜性是**合約欄位**，不是執行結果

- **發生什麼**：arXiv:2611.26256（11-19）。**OS 假設不是集中在一處，而是散落在 skill 的多個合約欄位**——guide text、scripts、metadata、install contracts、local entrypoints。所以「在這個 OS 會不會壞」是**可以靜態篩出來的**。方法為 contract-based 三段：static analysis → dynamic validation → repair（修「造成失敗的那個合約欄位」）。
- **為什麼重要**：先篩 **3,270 個 skill-target-OS 個案**（**1,090 個 skills** × Linux/macOS/Windows），修復把 **reviewer-judged target-task pass rate 從 30.6% 拉到 38.4%（+7.8pp）**。★ 但最實用的是效率數字：**185 次動態驗證確認 38 個 OS 問題，uniform random selection 期望需要約 865 次（≈4.7×）**。這補上了 skill 治理既有討論的一格空白——格式標準（agentskills-io-standard）不解答「我的機器上會不會壞」，證據溯源與 admission gate（skill-as-evidence-gated）不解答「進來之後能不能跑」。**信任鏈因此是三段：trust flow 決定能不能進來 → OS 宣告決定能不能跑 → 兩者都要是合約欄位。** 對 OpenClaw 的現況特別痛：ClawHub 已有 5,400+ skills（53,892 stars）、openclaw 本體 394,926 stars——**瓶頸已經不是「有沒有 skill」，是「skill 在我的機器上會不會壞」**。
- **可信來源**：<https://arxiv.org/abs/2611.26256>

### 3. CompAct-Bench：compaction 的失敗不只「遺漏」，還會**把未解決改寫成已結論**

- **發生什麼**：arXiv:2611.25673（11-19）。方法設計乾淨值得抄：**從成功的 agent 軌跡出發** → 在執行的不同階段**插入 compaction 邊界** → 用被評模型壓縮前段 → **再讓同一個 executor 繼續原任務**，以**下游任務完成度**衡量；再用 iterative ratio-adjustment 把各 compactor 調到**受控 retention ratio** 才比較。覆蓋 BrowseComp、SWE-bench、CompanyBench。
- **為什麼重要**：**working-context compaction 對 frontier model 仍然高度有損**（Claude/GPT 最強但激進壓縮下仍實質退化），而且失敗分兩型：**遺漏**（資訊不見了）與★ **扭曲**（把未解決的問題變成看起來已結論、忘記先前已建立的結果）。第二型比第一型惡劣——遺漏會讓 agent 去補，**狀態改寫會讓 agent 自信地重複執行已完成的工作**。這正好補上 wiki 對 compaction 的缺角：`compaction-provenance-laundering` 處理「溯源」、`context-partition-by-construction` 處理「建構期分割」，**本篇處理「執行期狀態失真」**；也順勢解釋了為什麼 evidence 必須保持可重新定址——**被 compaction 改寫的 state 不可信，所以要能回到原始 evidence 重新判讀**。
- **可信來源**：<https://arxiv.org/abs/2611.25673>

### 4. 記憶劑量是**模型的**性質，不是記憶的性質（而且方向會相反）

- **發生什麼**：arXiv:2611.26361（11-19）。管線：從 agent **自己的軌跡**挖 lessons（每集 1–3 條）→ 收斂成 guidelines（每條記錄自己合併了幾條 lesson，provenance 是結構欄位）→ 推理時給全部或精選子集。**已開源（altk-evolve），已部署於 IBM 的 CUGA agent 與 watsonx Orchestrate**——這是少數有真實產品落地的 agent memory 研究。
- **為什麼重要**：中心發現是「**正確的記憶量是模型的性質，不是記憶的性質**」。**強模型：guideline 越多越好——DeepSeek-V3.2 用滿 191 條 → task completion +9.5、scenario completion +16.1**；**弱模型：全量反而不如精選——gpt-oss-120b baseline 39.9%，用滿 199 條只到 51.2%，但用約 29 條精選子集到 55.4%**。**同一份記憶在強模型是淨增益、在弱模型是負邊際。** 作者自陳的四個坑比主數字更有價值，其中★ **「被吞掉的 API error 讓每個任務都失敗，卻產出看似合理的 log」**——這就是本 wiki `claim-vs-observation-verification` 的實戰版：**失敗會偽裝成成功**。
- **可信來源**：<https://arxiv.org/abs/2611.26361>

### 5. ★ 兩個獨立來源收斂到同一個機制：**合併閘門（merge gate）**

- **發生什麼**：**來源 A** = arXiv:2611.26346（ClonAct）的 **trial merge gate**。問題是 router-ticket 階層會產生 lossy prose handoff 與 blind merge：★ **即使各分支獨立 pass 率很高，真衝突 repo merge 的三天平均只剩 33.3%**。解法是 routerless 架構（Context MMU、in-place Context Cells、footprint-aware Synaptic Bus、wave-flushed Shared Trunk），其中可攜的 trial merge gate 把真衝突 merge 拉到 **63.3%**，且**少用 45.9% prompt token**，還避免 compact-model 的 router collapse。
- **為什麼重要**：**來源 B** = InfoQ 11-20〈AWS Emulator〉報導的實務做法——**完全不同領域、不同作者、不同組織、不同技術堆疊**，卻給出同一個機制：agent 產生的變更必須先過可驗證的閘門，不過就回爛重做，過了才進 mainline。原話：「**We've seen thousands of issues fixed every day as hundreds of agents concurrently work on the codebase. Without this merge gate, we wouldn't trust what our agents are building.**」★ **單一來源容易被其設定侷限（ClonAct 是合成 benchmark、AWS 是單一組織內部實務），兩份獨立來源收斂，才能把「合併閘門」從「某篇論文說的」升級為「這個模式正在被獨立發明出來」。** 它同時是 `hook-failure-must-block-the-action`（fail-closed）的更高層版本——不是「工具失敗要停」，而是「**產出的變更不可信時要退回**」。
- **可信來源**：<https://arxiv.org/abs/2611.26346> ｜ <https://www.infoq.com/news/2026/11/aws-emulator-local-testing/>

---

## 對 OpenClaw / Linder 的啟發

**① 加一道 merge gate，特別是「trial 型」的（先模擬合併看會不會撞，不動主分支）。**
ClonAct 的 trial merge gate 是 isolated 的，正對我們用 git worktree 開分支的場景；AWS 那句「once it had a spec and a test environment, the rebuild took about two hours」則指出閘門的形式應該是**能跑起來的最小驗證**。目前我們對「agent 改了程式碼」的驗證集中在 review 與 CI（事後），merge gate 是**事前的可驗證閘門**——而 33.3% 這個數字說明平行分支的瓶頸不在分支數量，在合併。

**② 把「已知危害」變成 skill 合約的一個欄位，並在 tool output 之後點名回報。**
ROGUE-AI 證明真正的高頻破口是「普通危害盲視」而非注入（62/72 無攻擊者；無攻擊者重現傷害 > prompt injection 重現）；而有效的提醒形式是**點名危害與後果**，等長泛泛註記幾乎無效。`openclaw-security-scanner` / `skill-guard` 是注入導向的，**建議補一條「危害清單」軸**。SkillBridge 正好提供了容納它的地方：skill 已經有 guide text / scripts / metadata / install contracts 這些合約欄位，**OS 宣告與危害宣告是同一種東西**。

**③ 把記憶投遞量做成 per-model 的部署參數，並給報告加 evidence 欄位。**
記憶劑量是模型的性質（強模型全量 +9.5、弱模型精選 55.4% > 全量 51.2%），而我們目前對所有模型灌同一份 MEMORY.md + skills——**在小模型上可能是負收益**。同時把報告體系補上 provenance：arXiv:2611.25760 顯示 **435 份工作報告中 37.24% 至少含一項不忠實宣稱**、最常見的是「誇大任務成功」、FaithDetector macro-F1 93.06%（比 baseline 高約 13pp）。配合 compaction 的「未解決 → 看似已結論」失真，這三條串起來就是完整的失敗路徑：**compaction 改寫狀態 → 下一個 agent 誇大成功 → 報告成了下游唯一事實來源。**

---

## 值得追蹤的 repo / paper / article

- **arXiv:2611.26553** — ROGUE-AI：Replication of Agentic Security Events — <https://arxiv.org/abs/2611.26553>
- **arXiv:2611.26256** — SkillBridge: Cost-Aware Diagnosis and Repair of Cross-OS Compatibility Defects in Agent Skills — <https://arxiv.org/abs/2611.26256>
- **arXiv:2611.26346** — Context as a Resource（ClonAct，含 trial merge gate）— <https://arxiv.org/abs/2611.26346>
- **arXiv:2611.25673** — CompAct-Bench：working-context compaction 的下游效果基準 — <https://arxiv.org/abs/2611.25673>
- **arXiv:2611.25760** — Characterizing and Detecting Unfaithful Work Reports by Coding Agents（FaithDetector）— <https://arxiv.org/abs/2611.25760>
- **arXiv:2611.26361** — How Much Should an Agent Remember?（**已開源 `altk-evolve`**，部署於 IBM CUGA / watsonx Orchestrate）— <https://arxiv.org/abs/2611.26361>
- **InfoQ 11-20〈Google Donates Agent Substrate and gVisor to the CNCF〉** — agent 執行基礎設施開始有廠商中立治理落點 — <https://www.infoq.com/news/2026/11/google-substrate-gvisor-cncf/>
- **InfoQ 11-20〈AWS Emulator〉** — CC0、200+ 服務、**agent 撰寫並維護全部程式碼**、每 release 發布 fidelity score；**不評估 IAM** — <https://www.infoq.com/news/2026/11/aws-emulator-local-testing/>
- **`openclaw/openclaw` v2026.11.10-beta.1** — agent templates（ClawHub + `CLAW.md` + 原生 trust flow）、usage-ranked tool index、**state 遷移改 copy-and-swap**、pre-update rehearsal — <https://github.com/openclaw/openclaw/releases/tag/v2026.11.10-beta.1>
- **Claude Code v2.1.327** — `claude mcp add-json <name> -`（token 不留 command line）＋ **`/status` 列出壞掉的 skill/agent/command 檔案** — <https://github.com/anthropics/claude-code/releases/tag/v2.1.327>
- **`VoltAgent/awesome-openclaw-skills`**（53,892 stars，5,400+ skills）＋ `openclaw/clawhub` — skill 生態的規模就是 SkillBridge 的適用面 — <https://github.com/VoltAgent/awesome-openclaw-skills>
- **HN 11-11〈United Airlines bans AI agents from booking flights〉**（682 分）＋ **11-08〈Goldman Sachs is pulling Claude Code from its bankers and traders〉**（905 分）— agent 代辦真實交易的權限邊界，正被現實業者直接劃線 — <https://news.ycombinator.com/>

---

## 下一步建議

1. **在本 repo 跑一次 merge-gate 實驗（可執行，2 小時內可完成）**：用現有 worktree 流程開 2–3 個平行分支，各自跑最小驗證後**先做 trial merge**（模擬合併、檢查衝突），記錄「trial merge 後的成功率 vs 直接 merge」——對照 ClonAct 的 33.3% → 63.3%，看我們的數字落在哪。同時把這個數字寫進 wiki 作為我們自己的基準，而不是引用別人的合成 benchmark。
2. **寫一個 skill 產生靜態 lint 工具（接續 SkillBridge 與 Claude Code v2.1.327 的 `/status` 思路）**：掃 `~/.openclaw/skills/**/SKILL.md` + scripts + metadata，撈出 OS 相關假設（`/bin/`、`bash`、`chmod`、`osascript`、`powershell`、path separator）並產出一張「skill × OS 相容性」對照表。**先做報告、不做自動修復**——因為 SkillBridge 的 30.6% → 38.4% 是 repair 的成果，而我們連「哪些 skill 真的有 OS 問題」都還不知道。
3. **決定要不要 ingest 兩件事**：(a) 把今日 6 個 concepts 與 1 個 source 納入下一次 `graphify` 全量重建（目前 `GRAPH_REPORT.md` 仍落後 graph.json，因本機缺 `networkx`——**這是已知積欠，不建議在無網路核准的情況下自行安裝套件**）；(b) 針對「記憶劑量 per-model」做一個小實驗：用同一份 MEMORY.md 全量 vs 精選，在一個小模型上跑我們自己的日常任務，量 task completion 差異——**這是 arXiv:2611.26361 的核心結論在我們環境的第一次驗證**。
