# 每日 Agent × 軟體開發情報 — 2026-11-06

> 來源：22 個公開來源。arXiv 四篇（2611.01386 / 2611.02361 / 2611.05636 / 2611.05313）皆 **abstract 級**；MCP servers v2.3.0 機制經 Forkast 二手整理；OpenClaw 2026.11.1 為官方 changelog 全文；Thoughtworks 為意見性文章。
> Raw：`/home/amr/llm-wiki/raw/documents/daily-research-2026-11-06-skill-evidence-memory-internalization-and-server-side-capability-narrowing.md`
> Wiki：已入庫 1 source + 4 concepts（graphify 已同步，5 頁全部 non-orphan；最終圖譜 **10,483 nodes / 18,691 edges / 1,191 communities**）

**一句話總結：今天最重要的不是又多了幾個 skill 工具，而是 skill 與記憶同時在「離開 text artifact」——skill 變成有證據溯源與 admission gate 的版本化生產物件，記憶則分成「下沉到顯式 state」與「下沉到權重」兩條路徑；而同一週 OpenClaw 自己修掉了「Doctor 回報成功但實際失敗」，說明 verifier 誠實性是 harness 的第一順位屬性。**

---

## 今日 5 個重點

### 1. Zep Agent Skills：skill 變成「有證據溯源、有 admission gate、有版本治理」的生產 artifact

- **發生什麼**：arXiv:2611.01386（11-01 提交）描述 **Zep Agent Skills**——把「從 agent run 學習程序」從研究系統（Trace2Skill / WikiSkill / SkillRevise）做成**生產服務**。機制逐條：**只用已驗證的 attempt 當證據**；**每個 Skill 的每個欄位都引用支撐它的 supporting events**；每個 attempt 記成帶 ordered events / outcome / **verification strength** 的 Trace；compiler 分成 **Reflector 與 Curator** 兩個角色；**scans 與 admission gates 控制哪些候選可以 active**；**verified use outcomes 會回饋調整每個 Skill 的搜尋排名**；並治理每個 Skill version 的 admission 與 distribution。取得途徑是 lexical search + progressive disclosure，透過 API 或 MCP。Agent Skills format 是 Anthropic 發起、捐給 **Agentic AI Foundation** 的開放標準 → 任何該 format 的 host 都能載入編譯出來的 Skill。
- **數字**：以 **teacher model 的 Traces** 編譯出的 Skill，讓**三個較弱的 executor model** 在 **τ³-bench banking / AppWorld / EnterpriseOps-Gym** 上的 pass rate，**在每個 reasoning effort 都提升 4.5 – 18.8 個百分點**，且**大部分增益集中在 teacher 本身解出的任務**。在 **ALFWorld** 上，**以小模型 run 編譯出的 Skill 帶來的增益與（或大於）continuous fine-tuning，且完全不需要訓練**。
- **為什麼重要**：這是 skill 第一次有「**證據鏈 + admission gate + 版本生命周期 + 使用結果回饋**」四件套。與既有的 `[[aaif-agent-skills-governance]]` 互補——基金會解決**格式與中立性**，本文解決**證據與生命周期**。兩者缺一不可：有格式沒有 admission gate，就會重演 11-04 記錄的 Cursor 市集投毒鏈（**取得發布權 → 改寫開機行為 → 自我授權**）。而「大部分增益集中在 teacher 解出的任務」是**警告**：skill 傳遞的是特定解法，不是泛化能力。
- **可信來源**：<https://arxiv.org/abs/2611.01386>

### 2. 「記憶不是檢索問題，是寫入時的過濾問題」——顯式狀態勝過長上下文，且臨界點隨讀者能力移動

- **發生什麼**：arXiv:2611.02361（11-02 提交）用可執行 benchmark（grants / withdrawals / reinstatements / expiries / groups / change windows，policy 已知，評分用只差在**決定事件順序或單一欄位**的成對歷史）問：**一個讀完整份 access log 歷史的模型，能不能說出服務「現在」是否被允許行動？** 結果：**open models 7B–32B** 從 8–16 事件時的 **72–86%** 掉到 **256 事件時的 48–55%**；**reasoning-trained 32B 讀當前狀態達 96% / 98%**；**120B reasoning model 讀歷史在 256 / 512 / 1,024 事件時分別落後狀態 4 / 7 / 約 10 個百分點** → **「顯式狀態勝過長上下文」的臨界長度會隨讀者能力增長**。作者把記憶視為**遞迴過濾**：決策只透過一個 state 依賴歷史，**state 大小由被追蹤的 key 數量決定**；儲存體若持有的 component record 少於 state，就會**以容量決定的時間尺度遺忘**。**不考慮時間順序地保留 log 行 → 錯誤機率趨近二分之一且此上界可達**。**filter（模型解析每行 + 顯式規則套用更新）在 256 事件時答對 80–89%，勝過 relevance retrieval、model-kept ledgers、StateMem 重作、以及 Mem0 library**。而在查詢時挑出「被查詢 state 所依賴的行」的 retriever 在 256 事件上打平 → **起作用的是「依 state 的依賴關係做選擇」，而這個選擇 filter 是在寫入時完成的，不需要查詢**。反證：**若把 parsed updates 直接套用而不做選擇 → 掉到 58% / 59%**。
- **為什麼重要**：這直接挑戰我們的架構偏好——我們的 `memory_search` 是**corpus 級語意檢索（查詢時）**，本文說**同樣的事在寫入時做更好**，而且勝過 Mem0 這個產業級基線。它同時給出一個**反直覺的量測結論**：不是「context 越長越好」，而是「**context 會被 reader 的能力吃掉**」——所以顯式狀態的價值會**隨模型升級而上升**，不會被 context window 擴容稀釋。與 `[[memory-policy-evidence-over-heuristics]]`、`[[memory-needs-a-repair-and-boundary-loop]]` 同屬「記憶先修選擇、再修內容」這條線，但本文把選擇從**查詢時**推到**寫入時**。
- **可信來源**：<https://arxiv.org/abs/2611.02361>

### 3. 記憶內化的第二條路：把知識蒸餾進權重，query 時完全不需要 context

- **發生什麼**：同日（11-03）兩篇。**Route to Remember**（arXiv:2611.05636）指出生產 agent 記憶**幾乎完全由 text 建構**（從超出的 context 抽 key points、查詢時檢索回來）→ **每次新查詢都增加一筆隨累積歷史成長的成本**；**weight memory** 是互補替代：**把知識內化進參數，回答時完全不需要 context**。方法 **OPSD（on-policy self-distillation）**：從 teacher（**同一個模型，但以使用者記憶為條件**）訓練出 **context-free student**，再加 **verify-then-regenerate router** 讓 weight memory 與 text memory **各處理自己擅長的查詢**。**在 HaluMem 上 OPSD 追平或超越強 text-memory baselines（含 full-context prompting 與檢索系統），而且每次查詢讀的 token 數更少。** 作者結論：**「隨 agent harness 走向持久化、多 session 部署，weight memory 是 agent memory 中一個實用、低成本的元件」**。**MDSKILL**（arXiv:2611.05313）則處理 skill memory 的內化障礙：**自產生的記憶含噪聲監督，且知識在功能上纠缠、冗餘、或衝突**，在有限訓練預算下直接蒸餾會**降低效能**。方法是把 skill memory 組織成**三個互補功能視圖——state grounding / action planning / execution control**，用動態指標挑出高品質 skill，構造 view-specific 與 integrated reasoning branches，再由 OPSD 跨分支整合進同一個 policy。**在不增加額外運算開銷下，比 SOTA 提升最多 7.1%（ALFWorld）與 8.1%（WebShop）**，baseline 包含 RL、skill-augmented、以及**不依賴更強外部 teacher model** 的 self-distillation。
- **為什麼重要**：**本週出現兩條互相獨立的證據鏈，都指向同一個方向：記憶與 skill 正在離開「text artifact」這個載體。** 一條下沉到**顯式 state**（#2），一條下沉到**權重**（本點）。這代表我們目前「記憶 = 一堆 markdown 檔案」的實際做法**在架構上是過渡形態，不是終態**。對我們的 skill_workshop 與 memory 架構，這是一個明確訊號：**skill 的下一個形態可能是「可執行、可驗證、可蒸餾」的程式化 artifact，而不是文字教學**。與 `[[harness-as-trained-artifact]]`、`[[Agent Skill Evaluation and Evolution]]` 直接接軌。
- **可信來源**：<https://arxiv.org/abs/2611.05636> ・ <https://arxiv.org/abs/2611.05313>

### 4. MCP servers v2.3.0：能力收窄下沉到伺服器端——而且有版本地雷

- **發生什麼**：官方 MCP servers 於 **11-04 發布 v2.3.0**。**A. filesystem `--read-only`**：啟用後 server **只註冊標註 `readOnlyHint: true` 的 tool**，**寫入型 tool 完全不會出現在 `tools/list`**，對被省略的 tool 呼叫會**失敗為 unknown**；是 **server-wide toggle**（尚不支援 per-directory）；設計意圖是**讓 server 而不是 client 端的顯示偏好決定哪些工具可用**。**B. fetch `--allowed-hosts`**：可重複指定，**包含 redirect 與 robots.txt 的 request**；可為 exact hostname / wildcard subdomain / IP literal，**scheme、port、path 一律拒收**；**wildcard 不含 base domain**；**與既有 private-address guard 並存**（把內部 host 加進 allowlist **不會**關掉那個 guard）。**C. fetch timeout 三層優先序**：**per-call `timeout_ms` > `--timeout-ms` > `FETCH_TIMEOUT_MS`**，最具體者勝出，範圍 100–600,000 ms，預設 30 秒；語意是**分別限制連線階段、每次讀取、每次寫入**，**不是限制整個傳輸的總時長**（robots.txt 另有 5 秒預設，Readability extraction subprocess 另有獨立 timeout）。**D. git 新增 `git_merge`**（作用於當前 checkout 的 branch，**預設 fast-forward only**，需乾淨 working tree，衝突時中止）與 **`git_remote`**（列出 remotes 與 fetch/push URL，**回傳前遮蔽 URL 的 userinfo credentials**）。**版本地雷**：repo tag 是 v2.3.0，但 **npm 的 `@modelcontextprotocol/server-filesystem` 是 2.2.0、PyPI 的 `mcp-server-fetch` / `mcp-server-git` 是 2026.11.4**。
- **為什麼重要**：**方向與我們 11-03 的判斷一致——「工具治理是 gateway 問題不是工具數量問題」——但這次官方 reference server 自己把治理做進去了。** 最有結構性意義的是 **A**：用「**根本不註冊**」而不是「註冊但期望模型自律」來做唯讀，**把限制從提示層移到註冊層**。這與我們既有的 `[[tool-surface-as-a-gateway-problem]]`、`[[minimal-tool-surface-codes-leverage]]`、`[[no-sandbox-max-permission-by-design]]` 完全同構，且 `git_remote` 的 **credential redaction** 與 Uber 的 **PII redaction** 是同一個方向：**敏感資料的遮蔽要發生在 server 端，不能寄望於 agent 不去讀**。**版本地雷則是實務提醒：不要用 repo tag 去判斷你實際安裝的套件行為。**
- **可信來源**：<https://github.com/modelcontextprotocol/servers/releases/tag/v2.3.0> ・ <https://forkast.news/understanding-the-v2-3-0-mcp-server-release-and-its-granular-controls/>

### 5. 「Exit code 0 is not proof」——verifier 誠實性與 harness 產品化在同一週對撞

- **發生什麼**：**OpenClaw 2026.11.1**（**11-05 09:48 UTC** 發布，83 PR / 91 direct commits / 67 contributors，patch release 不加功能）的三個修復之一就是 **「失敗的 Doctor inspection 被回報為成功」**：當 **inspection 被阻擋、final configuration 無效、或必要 migration 被延後** 時，**Doctor 現在回傳 nonzero exit code**；**`doctor --json` 的腳本必須處理新的 exit status**；**無人值守的 Doctor 只回報缺少的 plugin、不再自動安裝**，除非給 `--fix` / `--repair` / `--yes`。同版另有 **skill 發佈與回滾都失敗時保留前一份副本**、**Codex 第一個回覆不再被「檢查哪些 MCP apps 可用」卡住**、**跨並行 MCP request 重用同一個 shared OAuth token**、**in-process browser 不再在啟動時寫入 Gateway auth settings**、**Gateway 遇暫時 SQLite lock 改為有界重試**。同一週社群出現 **`Balanov/verdict`**——**197 KB 的本地語意驗證器**，README 第一句就是「**Exit code 0 is not proof.**」（11-02 建立，11-05 已 236★）；另有 **`gauge-sh/gauge-cli`**——**「hillclimbing Agent Experience」**的開源 CLI，**把真實 agent 跑在你的產品上、記錄它們卡在哪裡，再讓你自己的 coding agent 在發佈前測試修正**，全迴路本地 Docker 跑、**不需帳號**、支援 Claude Code / Codex / Pi / OpenCode；其 README 列出的發現類型極精準：*互動式指令卡住 agent*、*agent 去用已被棄用的指令*、***「某個 Skill 明明該幫上忙卻完全沒被用到」***、*agent 自信地宣稱一個不存在的限制*。另一側，**Thoughtworks 的 Cecilia Geraldo（11-04）〈The harness is a product〉** 定義 harness＝model 與工作之間的八件事（instructions/skills、tools、permissions/sandboxes、context policy、跨步 state、orchestration、evaluation、telemetry），並指出在 agentic system 裡它們**塌縮成一個小團隊一個下午就能改、卻可能沒有人負責的單一 artifact**；產品化要件是 **users / versions / dependencies / roadmap / quality gates / owner**，否則**「你以為的 harness 其實只是帶著 system prompt 的 configuration debt」**。
- **為什麼重要**：**OpenClaw 自己修了「Doctor 回報成功但實際失敗」，而同一週出現一個 README 第一句就寫「Exit code 0 is not proof」的小工具——兩者是同一個命題。** 這把「harness 品質」從模糊的工程判斷，壓成一個**可否證的命題**：*你的 verifier 會不會在失敗時說失敗？* 而 Geraldo 的清單補上另一半：**沒有 owner 的 harness 不會有人去修它**。這與既有的 `[[harness-record-as-versioned-compliance-artifact]]`、`[[enterprise-harness-and-shared-responsibility]]`、`[[harness-is-also-the-meter]]`、`[[Agent Harness as First-Class Citizen]]` 構成完整鏈——記錄 ≠ 證明 ≠ 誠實回報 ≠ 有人負責。
- **可信來源**：<https://raw.githubusercontent.com/openclaw/openclaw/main/CHANGELOG/2026.11.1.md> ・ <https://github.com/Balanov/verdict> ・ <https://github.com/gauge-sh/gauge-cli> ・ <https://www.thoughtworks.com/insights/blog/generative-ai/harness-is-a-product>

---

## 對 OpenClaw / Linder 的啟發

### 1. 把 skill 從「文字教學」升級成「有證據溯源 + admission gate 的版本化 artifact」

今天最可落地的一條。Zep 的四件套可以直接映射到我們的 `skill_workshop` 與 skill 生命週期：**（a）只用已驗證的 attempt 當證據** → skill 提案必須附「我實際跑過並通過」的紀錄，不是「我讀過文件所以應該對」；**（b）每個欄位引用支撐事件** → skill 內容要能追回具體的 session / commit / log 行；**（c）admission gate** → 進入 active 目錄需要一道明確的審核，且**未通過的候選不影響其他 skill 的排序**；**（d）使用結果回饋排序** → 被驗證使用過的 skill 排前面，長期沒被用到或用後失敗的降權——這一條正好對應 Gauge CLI 發現的那類問題（「某個 Skill 明明該幫上忙卻完全沒被用到」）。**最小可行實驗**：挑我們最常用的 5 個 skill，加一個 `provenance` frontmatter 欄位（來源 session / commit / 日期）＋一個 `last_verified` 欄位，再加一個簡單的「用過幾次／被 agent 引用幾次」計數，觀察一個月後這 5 個 skill 的實際命中率是否上升。

### 2. 記憶架構：把「依賴關係選擇」從查詢時搬到寫入時，並把顯式狀態與權重記憶當成兩個不同容器

arXiv:2611.02361 的核心是**「依 state 的依賴關係做選擇」這個動作本身最有價值，而它可以在寫入時完成，不需要查詢**。我們目前的 `memory_search` 是 corpus 級語意檢索（查詢時）。可行的下一步**不是重寫記憶系統**，而是加一層**寫入時的結構化索引**：每次寫入 memory 時，順手記錄「這個事實被哪些 key／哪些主題依賴」，之後查詢先查依賴關係（精準、快），再退回語意檢索（模糊、慢）。同時要分清楚三個容器：**（i）顯式 state**（少量、高價值、常常更新——例如「目前有哪些未完成的 skill 提案」）、**（ii）text corpus**（不可數的 raw 歷史與快照）、**（iii）權重**（目前不適合我們，但應記住這條路存在）。另外值得做一個**小型量測**：在我們自己的 daily memory 上跑一次「依賴關係選擇 vs 純語意檢索」的對照，N 小到 30 題就夠，目的是取得**我們自己的**數字，而不是引用別人的 benchmark。

### 3. 驗證器的誠實性要能被獨立驗證——而且要有 owner

今天 OpenClaw 修的 Doctor bug 讓我們得到一個具體、可立即套用的自我檢查清單：**任何我們用來判定「工作已完成」的訊號，都必須能區分「通過」「失敗」「無法判定」三態，而不只是回傳 0/1。** 這包括：doctor / doctor --json 的 exit status、cron 的完成判定、taskflow 的 finish 條件、skill 發佈的回滾路徑（11-05 這版已修好「發佈與回滾都失敗時保留前一份副本」）。配套兩件事：**（a）一個不依賴被測系統本身的外部 verifier**——`verdict`（197 KB 本地語意驗證器）與 `gauge-cli`（用真實 agent 跑真實產品並記錄卡點）示範了兩種可行做法，尤其 **gauge-cli 的「在你的產品上跑真實 agent」** 幾乎可以直接套到 OpenClaw 自身：我們可以用它來量測「OpenClaw 的 skill 與 CLI 對 agent 到底好不好用」，而不只是「agent 有沒有把任務做完」。**（b）一個 named owner**——依 Geraldo 的清單，harness 需要 users / versions / dependencies / roadmap / quality gates / owner；在我們的規模下，最小版本是：**每個 cron 與每個 skill 有一個明確負責人與「壞了多久算故障」的 SLO**。

---

## 值得追蹤的 repo / paper / article

1. **Zep Agent Skills**（arXiv:2611.01386）— skill 的證據溯源 + admission gate + 版本治理 + 使用結果回饋排序的完整生產設計。 <https://arxiv.org/abs/2611.01386>
2. **Agent Memory as Rate-Limited Filtering**（arXiv:2611.02361）— 顯式 state 勝過長上下文；寫入時過濾勝過查詢時檢索；勝過 Mem0。 <https://arxiv.org/abs/2611.02361>
3. **Route to Remember / OPSD**（arXiv:2611.05636）— weight memory 與 text memory 的 router；HaluMem 上追平或超越檢索基線且讀更少 token。 <https://arxiv.org/abs/2611.05636>
4. **MDSKILL**（arXiv:2611.05313）— skill memory 的三視圖蒸餾（state grounding / action planning / execution control）。 <https://arxiv.org/abs/2611.05313>
5. **MCP servers v2.3.0** — filesystem `--read-only`（不註冊即不存在）、fetch allowlist 與三層 timeout、git merge / remote（credential redaction）。 **注意 package 版本不一致。** <https://github.com/modelcontextprotocol/servers/releases/tag/v2.3.0>
6. **Thoughtworks — The harness is a product**（Cecilia Geraldo，11-04）— harness 的八項定義與產品化要件（users / versions / roadmap / quality gates / owner）。 <https://www.thoughtworks.com/insights/blog/generative-ai/harness-is-a-product>
7. **`Balanov/verdict`** — 197 KB 本地語意驗證器；「Exit code 0 is not proof.」 <https://github.com/Balanov/verdict>
8. **`gauge-sh/gauge-cli`** — 用真實 agent 跑你的產品、記錄卡點、讓自己的 coding agent 發佈前測試修正；本地 Docker、免帳號。 <https://github.com/gauge-sh/gauge-cli>

---

## 下一步建議

1. **入庫（建議執行）**：本日的 raw snapshot 已存於 `raw/documents/daily-research-2026-11-06-*.md`。已建立 1 source + 4 concepts，並以 `[[wikilink]]` 接到既有的 `[[aaif-agent-skills-governance]]`、`[[Agent Skill Evaluation and Evolution]]`、`[[memory-policy-evidence-over-heuristics]]`、`[[tool-surface-as-a-gateway-problem]]`、`[[harness-record-as-versioned-compliance-artifact]]` 等；圖譜已同步（10,483 nodes / 18,691 edges / 1,191 communities，5 頁全部 non-orphan）。**本機 `npx graphifyy link` 子指令不存在**（實測回 `unknown command 'link'`），改用既有且已驗證的 `tools/add-wiki-pages-to-graphify.py` + `graphify cluster-only .`。
2. **小型實驗（建議排入本週）**：在我們自己的 daily memory 上做「依賴關係選擇 vs 純語意檢索」的對照，約 30 題即可，目標是取得**自己的**數字。同時把 5 個常用 skill 加 `provenance` / `last_verified` frontmatter + 使用次數計數，一個月後回頭看命中率。
3. **工具導入（低成本高價值）**：評估在本地引入 `verdict` 作為 skill 與 cron 完成判定的**外部** verifier；並跑一次 `gauge-cli` 對 OpenClaw 自身做一輪「agent 好不好用」的實測——這是目前最便宜的真實使用者回饋來源。

---

## 已查過但未列入重點（誠實記錄）

- arXiv：**2611.00314（ParallACT）**與 **2610.04433** 已於 11-04／11-05 入庫；**2610.29695（MicroPerf-Bench）、2610.40293（MAServeBench）、2610.37434（FeatureArc）、2610.35138（Co-Design Bench）** 本日未讀全文。
- Thoughtworks Radar Vol.35 與 Chris Ford 〈Macro trends〉：11-05 已入庫；本日僅補入 Cecilia Geraldo 新文（wiki grep `Geraldo|harness is a product` **零命中**）。
- **Uber MCP Gateway**（InfoQ 11-02）：已於 **11-03** 入庫，本日僅補讀先前未記錄的 AutoCrawler 細節（IDL 自動發現 + **owning team 審閱後才 enable** + 設定變更免重啟傳到 data plane）。
- InfoQ RSS 其餘條目（GCP API Gateway streaming、LiteRT Tensor API、TorchTPU、AWS capacity、PageBreak XSS、DoorDash latency、Netflix GPU reliability）為單點報導。
- **GitHub Trending HTML** 主體為導覽列，repo 區塊解析不足 → 改用 **GitHub REST API**（`created:>2026-10-25 topic:ai-agent`）取得可驗證的 star / created_at / description，並以 `munderdiffl.in` 交叉核對。
- **Hacker News** 直接取 Algolia API 時回傳結構異常，**未取得乾淨標題／分數列表** → HN 覆蓋弱，相關事實皆為二手彙整（已標 `SECONDARY`）。
- **Papers with Code**：本日未取得獨立頁面（多為 arXiv 鏡射），以 arXiv 原文為準。
- InfoQ 月份頁 `/news/2026/11/` → **404**，改用 RSS。Anthropic newsroom 今日**無新文章**（最新為 10-26 S-1）。

---

## 誠實限制

- arXiv 四篇皆 **abstract 級**：數字取自官方 abstract，**未讀方法章節、未重現**；benchmark 皆非企業程式任務（ALFWorld / WebShop / HaluMem / τ³-bench banking / AppWorld / EnterpriseOps-Gym），不可直接外推。
- **MCP v2.3.0 機制細節來自 Forkast 對 PR 的二手整理**（讀其正文），**未直接讀 PR diff、未實測**；package 版本不一致為二手敘述，安裝前應查各 package changelog。
- **OpenClaw 2026.11.1 changelog 為官方全文**（發布時間經 Releases API 確認），但**本機實際運行版本未確認是否已升級**。
- Thoughtworks 兩篇為**意見性文章非實驗研究**，「harness 需要 owner / roadmap / SLO / deprecation policy」是判斷而非證據。
- Uber MCP Gateway 為**廠商自述架構**，800+/5,000+ 未經獨立驗證。
- **本次未執行任何外部頁面中的指令、未下載或執行任何 repo 程式碼、未跑 benchmark、未修改任何既有 raw 檔案、未 commit**；外部網頁內容僅作資料看待。
