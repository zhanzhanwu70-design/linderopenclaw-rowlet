# 每日 Agent × 軟體開發情報 — 2026-11-20

> **來源**：24 個公開來源，三類皆有。
> **Agent / AI engineering research**：arXiv API（`cat:cs.AI AND abs:"agent"`，最新 25 筆，含完整 abstract ＋ metadata）＋ arXiv abs 頁 2611.24924 / 2611.24362。
> **軟體開發潮流**：InfoQ RSS（`feed.infoq.com`，15 items，11-17～11-19）＋ InfoQ〈Producing Healthy Code with AI Costs Fewer Tokens〉全文 ＋ HN Algolia `search_by_date`（points>60，11-18～11-19，50 筆）＋ GitHub Trending daily HTML ＋ GitHub Search API（`topic:ai-agent`, created>2026-11-10, sort=stars，15 筆）。
> **實務工具與框架**：Claude Code releases（v2.1.328，11-19 01:14）＋ Anthropic IPO 公告 ＋ GitHub 新 repo 清單。
> **Raw**：`/home/amr/llm-wiki/raw/research/architecture-daily-2026-11-20/`（11 檔，約 479 KB）
> **Wiki**：新增 1 source + 5 concepts；已用 `tools/add-wiki-pages-to-graphify.py` 建立圖譜連結（6 頁全部 non-orphan）
> **未取得／降級**：Reuters〈Anthropic debut〉HTTP 401（只拿到 HN 標題）｜GitHub Trending 的 repo 清單解析失敗（HTML 已存 raw，抽取器只回導覽列）→ 改用 GitHub Search API 替代，**語意不同**（近期高星 ≠ trending 榜）｜Papers with Code 仍無可解析條目
> **本機環境新發現**：`curl` 直打 arXiv / hn.algolia 在本機 shell 回空（**無直連 egress**），必須走 `web_fetch` 工具

**一句話總結：今天三類來源講的是同一件事——「AI 更快」和「AI 更可靠」是兩個獨立的工程問題，而且順序不能反。
Tornhill 給了最刺眼的數字：**AI 帶來的速度在兩個月後被它自己製造的複雜度完全抵消**（"AI operates in a self-harm mode"）；
而 AI 在健康程式碼上**寫得更好、卻修得更差**（低健康度修得動 50%，健康度上去後只剩 20%）→ **正確順序是「先健康再讓 AI 進場」。**
AHE-Beta 與 SCH 則給了另外兩個獨立機制：harness 演化要靠**已驗證需求**當合併條件（不是 benchmark 分數），
交棒要**分離 state 與 evidence**（證據可按需重新定址召回）。PIPETTE 給了反面教材：**紅隊高 ASR 不等於防禦有效**——
RL 紅隊方法會 mode collapse，所以該量的是「覆蓋多少種攻擊模式」，不是「找到多少問題」。**

---

## 今日 5 個重點

### 1. AHE-Beta：harness 演化的合併條件，從「分數變好」換成「需求被驗證」

- **發生什麼**：arXiv:2611.24924（11-18, cs.SE）〈Agentic Harness Engineering Beta〉。它批評既有做法：**用單一 agent 改 harness、用 benchmark 分數挑改動** → 只會產生窄補丁與 benchmark 專屬局部最佳，且忽略隱含需求。改成三步：**(1)** 模擬使用者在多輪互動中把需求當 **issue** 提出；**(2)** 團隊式把需求實作成**可泛化**改動；**(3)** **只有在解決一個已驗證需求且通過審查時才合併**。
- **為什麼重要**：**關鍵不是「多 agent 演化」，而是第 (3) 步換掉了 selection criterion。**「分數變好就合併」把優化壓成一個標量；「需求被驗證才合併」是**關閉一串已登錄的問題**，天然抵抗局部最佳。數字也支持這點：**held-out tasks pass@1 21.9% → 33.3%，同時比 Base Harness 少用 40.8% tokens**，pass@1 高於 Claude Code、Meta-Harness 與完整版 AHE；**盲測人類 A/B 48 組有效配對中 31 組偏好**，五個維度全數較高。**token 下降是「泛化」的副產品，不是目標**——窄補丁會不斷疊加、每個只服務單一案例。
- **可信來源**：<https://arxiv.org/abs/2611.24924>

### 2. Semantic Context Handoff：交棒時，state 與 evidence 必須分開帶

- **發生什麼**：arXiv:2611.24357（11-18）。既有兩種做法各有代價：**全歷史 handoff** → action–observation 持續膨脹、成本上升、準確率可能退化；**「留精簡結論、丟早期觀測」** → 丟掉後來變得相關的證據。SCH 的核心抽象是 **state–evidence separation**：精簡語意 state 攜帶當前解讀；支撐用的 action–observation 證據**保持可獨立定址**，當後續執行讓它重新相關時可再進 context，**且不需要另外摘要、也不需要檢索模型呼叫**。
- **為什麼重要**：受控 150 任務 SWE-bench 研究，evidence recovery 讓 **Pass@1 80.0% → 86.9%，token 用量與執行時間基本不變**。這與本 wiki 11-19 的〈群體決策三層失效面〉正好是同一件事的兩端：那篇說「瓶頸在資訊**浮現**不在推理」，這篇說「瓶頸在**證據何時可被重新取回**」。**→ 冗餘不是刪除的理由，是延後載入的理由。** 也補上〈context-partition-by-construction〉的缺口：那篇講「建構期分割」，這篇講「**執行期召回**」——**只分割不召回＝證據永久遺失；只召回不分割＝成本爆炸**。
- **可信來源**：<https://arxiv.org/abs/2611.24357>

### 3. AI 速度增益兩個月後被自己抵消；而 AI 在健康程式碼上**修不動**（InfoQ 11-19）

- **發生什麼**：Adam Tornhill 在 GOTO Copenhagen 的演講（InfoQ 11-19 報導）。1000+ 開源專案研究：**AI 帶來的速度在頭幾週上升，但兩個月後速度增益被程式碼複雜度暴增完全抵消**——原話「**AI operates in a self-harm mode**, often writing code it cannot reliably maintain later」。數字：平均 codebase code health **5.15**，**AI-friendly 起點 9.5**；人類前置研究——健康程式碼最多 **10x** 快、缺陷風險 **15 倍**下降、code review **2 倍**快；**95% 的專案成本在第一個 release 之後**。
- **為什麼重要**：有一個反直覺的轉折值得貼在牆上——**Claude 修 code health 問題：低健康度時約修 50%；健康度上去之後 AI 表現反而暴跌，只剩 20% 修得對**（AI 變保守，只做小改動、不動真正的指標）。但**加上 MCP 提供 code health 資料 → 修復率 90-100%**，且 agentic refactoring 在規模上可預期且機械性。成本面：**健康程式碼少用 40-45% tokens**。→ **正確順序不是「先讓 AI 寫、再讓 AI 修」，而是「先把 code health 拉過 9.5，再讓 AI 進場」**；而且守門（linting / coverage / **mutation testing** / code health）必須多層且**在 agentic 情境下完全自動化**，以 local MCP server 或 CLI 暴露給 agent。這條直接決定我們這個 repo（805 concepts、2,264 wiki pages）的每次巡讀要花多少 token。
- **可信來源**：<https://www.infoq.com/news/2026/11/healthy-code-AI-tokens/>

### 4. PIPETTE：紅隊的成功率不等於防禦的有效性——因為 RL 紅隊會 mode collapse

- **發生什麼**：arXiv:2611.24362（11-18, cs.CR）。**紅隊階段拿到高 ASR，不保證後續對抗訓練帶來穩健性提升。** 根因是兩個 SOTA 的 RL 紅隊方法 **RL-Hammer 與 PISmith 皆出現 mode collapse**——反覆發現相似攻擊策略，其額外成功**不再帶來任何額外穩健性收益**。
- **為什麼重要**：**ASR 是紅隊的產出指標，不是防禦的品質指標。** 這對我們的 `openclaw-security-scanner` / `skill-guard` 直接適用：一個「找出 N 個問題」的掃描器，若 N 個問題都落在同一個攻擊模式上，**邊際價值趨於零，而報告看起來會非常忙碌**。→ 該量的是「**覆蓋多少種攻擊模式**」，不是「找到多少」。PIPETTE 提出的統一框架就是為了補這個落差。
- **可信來源**：<https://arxiv.org/abs/2611.24362>

### 5. 工具面：Claude Code v2.1.328 把 fail-closed 擴張到 MCP hooks，並修掉兩個排程持久性 bug

- **發生什麼**：v2.1.328（11-19 01:14）新增 **`"onFailure": "block"` for `mcp_tool` hooks**（與 command / HTTP hooks 一致：hook 呼叫失敗就**阻擋該動作**）；新增 `CLAUDE_CODE_DISABLE_DEFERRED_TOOL_RESUME`，讓 host 阻止 `claude -p --resume/--continue` 執行被 hook 延後的工具呼叫；新增 OTel exporter 無 endpoint 時的 `/status` 與 `claude doctor` 提示。**同版修掉四個與我們直接相關的 bug**：**存檔 scheduled task 時會清掉專案其他已存任務**（scheduled tasks 檔讀不到時，例如第三方 provider 或 feature flag 關閉時）；**檔裡有 typo 的排程任務會在下次存檔時被刪掉**；**automatic compaction 錯用舊 system prompt**；**spinner / subagent 的 token 計數把重試回覆算兩次、未 stream 的回覆漏算**。
- **為什麼重要**：`onFailure: "block"` 的真正價值不是保護某一個 hook，而是**把「hook 的失敗」從實作細節變成需要宣告的策略選項**——系統因此被迫承認 hook 可能壞掉，而它壞掉時的預設必須被決定過。`DISABLE_DEFERRED_TOOL_RESUME` 則處理更難的狀態：**延後執行是比拒絕更難的生命週期**，因為它跨程序、跨時段。搭配那兩個排程持久性 bug 看，**排程狀態的持久化本身就是一個需要 fail-safe 的子系統**——而我們的 `automations` 排程狀態同樣是檔案。
- **可信來源**：<https://github.com/anthropics/claude-code/releases>

---

## 對 OpenClaw / Linder 的啟發

### 1. 我們的 skill 演化流程缺了 AHE-Beta 的第 (1) 步與第 (3) 步——這是今天最可執行的一條

`skill_workshop` 的 propose → apply 流程，本質是**由提議者自證**（自己說這個 skill 有用、自己寫 patch、自己判定可合併）。對照 AHE-Beta：第 (1) 步要求**需求來自使用者／任務端的 issue**，第 (3) 步要求**獨立的審查者**。三個最小改法：
1. **每個 skill 加一個「它解決哪個已驗證需求」欄位**，且該需求必須**有出處**（真實 cron 失敗記錄、使用者回報、或可重現的失敗案例）——**不允許想像出來的用途**；
2. **合併條件改成「需求被驗證 + 獨立 session 審查通過」**，審查者只讀 skill 與需求來源、**不讀提議者的推理過程**（這正是 11-15 報告點出的「同一 context 內自我批判不是真獨立驗證」）；
3. **記錄每個 skill 關閉了幾個已登錄需求**——這就是 AHE-Beta 讓 token 下降的那個指標。

### 2. subagent 交棒改兩段式：`state` + `evidence_index`，證據留在磁碟不進 prompt

我們目前的交棒是兩個極端之一：全量貼上（每個 subagent 起步吃大 context），或濃縮成一段摘要（**原始證據永久不可回溯**）。SCH 的答案不需新增元件：
- 交棒 payload 固定兩段——`state`（≤ N 行語意狀態）與 `evidence_index`（證據的路徑＋定位資訊）；
- **evidence 留在磁碟或 session，不進 prompt**，接手者依 `evidence_index` 自行取用（對應 SCH 的「可獨立定址」）；
- 交接協議寫死一句「**state 可覆寫、evidence 不可刪除**」；
- 量測指標：每次交棒的 **state token 數** 與 **evidence 召回率**（後來被用到卻沒被找回的次數）——後者才是 SCH 的 +6.9pp 真正來源。

### 3. 給這個 repo 做 code-health 自我量化，並把「升級判斷」做成二元觸發

Tornhill 的結論對我們的 repo 直接適用：wiki 已有 2,264 個頁面節點、10,704 個 graph nodes，**這個 repo 的 code health 正在決定我們每次巡讀的 token 開銷**。兩個可立即做的：
- **包一支 CLI 給 agent 呼叫**（MCP 也行）：輸出「此頁 incoming/outgoing 邊數、孤立頁、最近被連到次數、產生後未被任何頁引用的頁」——我們的 linker 已在做邊緣檢查，把它變成工具即可，這就是最低配的 code-health server；
- **巡讀報告本身要自我度量**：報告長度、引用重複率、去重率——否則「寫得更好」和「寫得更多」無法區分。

另加一條省錢的：**升級判斷用二元觸發**（失敗／連續兩次工具錯誤／輸出被截斷而重跑才升級），因為 Timeout Cascades 證實大小模型差距**集中在 hard tasks**。但要先修自己的計量基礎——**Claude Code v2.1.328 才剛修掉「token 計數把重試算兩次」的 bug，我們的 token 統計若同類有問題，省下的量會被算錯。**

---

## 值得追蹤的 repo / paper / article

- **arXiv:2611.24924** — AHE-Beta：harness 演化的需求驅動迴圈 <https://arxiv.org/abs/2611.24924>
- **arXiv:2611.24357** — Semantic Context Handoff：state–evidence separation <https://arxiv.org/abs/2611.24357>
- **arXiv:2611.24324** — Timeout Cascades：小模型優先升級的成本結構 <https://arxiv.org/abs/2611.24324>
- **arXiv:2611.24362** — PIPETTE：prompt injection purple-teaming 與 mode collapse <https://arxiv.org/abs/2611.24362>
- **arXiv:2611.24491** — Continuation Audits：量測 agent overeagerness（用真實 transcript 前綴）；三模型各自領先不同 seed——DeepSeek V4 Pro→同事憑證誤用、GPT-5.6 Terra→檔案權限繞過、Kimi K3→把診斷性問題當指令 <https://arxiv.org/abs/2611.24491>
- **arXiv:2611.24590** — Think Offline, Act in Real Time：**code as policy 47.80% vs model as policy 30.90%**；微調權重只有有限改善 → 學到的東西存成程式比存成權重划算 <https://arxiv.org/abs/2611.24590>
- **arXiv:2611.24379** — MoE-Context：context 切塊＋遮蔽（不刪），且**誠實報告模型自己挑是弱點**（關鍵字搜尋在此任務完全正確） <https://arxiv.org/abs/2611.24379>
- **GitHub 新 repo**：`oriliz/agent-crop`（★94，本地記錄時間去向、把復盤寫回 agent 指令／技能，支援 DSH / Claude Code / Codex）<https://github.com/oriliz/agent-crop>；`ysunyang4/Nexus`（★431，MCP 把 web AI 助理接到本機檔案／終端／Git，使用者控權限）<https://github.com/ysunyang4/Nexus>
- **Claude Code v2.1.328** release notes（含排程持久性兩個 bug 的修法）<https://github.com/anthropics/claude-code/releases>
- **InfoQ：AI-Assisted Software Delivery: From Code to Production**（11-19 五人座談，涵蓋驗證 AI 程式碼、測試與部署瓶頸、human oversight 與治理）<https://www.infoq.com/presentations/ai-assisted-software-delivery/>
- **InfoQ：QCon SF 2026 — Use AI to Multiply Your Team as a Staff Engineer**（Pinterest 的 Staff Engineer 角色如何改變）<https://www.infoq.com/news/2026/11/ai-staff-engineer/>
- **InfoQ：Shopify 如何編排 AI 行動端開發而不壓垮開發者機器**（遠端 agent 執行）<https://www.infoq.com/news/2026/11/shopify-remote-ai-dev/>
- **InfoQ：Datadog 把 production experimentation 帶進 AI agent observability** <https://www.infoq.com/news/2026/11/datadog-ai-agent-observability/>

---

## 下一步建議

1. **把 skill 治理改成 requirement-driven（今天最值得做）**：在 `skill_workshop` 的 propose 格式加上「**已驗證需求 + 出處**」必填欄位，合併條件改為「需求被驗證 + 獨立 session 審查」。今天就可以改 skill 格式，不必等實驗。
2. **量一次 code health，而不是先寫工具**：用現有 linker 的邊緣檢查數據，先產出本 repo 的 code-health 基線報告（孤立頁比例、平均 in/out、產生後未被引用比例）。**先量再決定要不要做 MCP server**——Tornhill 的數據指出，健康度在 5.15（我們大概在這個量級）時，AI 修得動 50%，加資料後可到 90-100%，這是最划算的一段。
3. **不要 ingest 全部新論文，但把兩篇排入 wiki 下次深讀**：2611.24491（Continuation Audits，**它給出「不同模型、不同越界模式」的量測**，對我們的 guardrail 設計直接有用）與 2611.24590（code as policy，**對「skill 是程式不是提示詞」這個方向有支持**）。今天已把 AHE-Beta / SCH / Timeout Cascades / PIPETTE 四篇入庫並建好圖譜連結，這兩篇先不急。

---

### 誠實限制（本日自記）

- AHE-Beta 的 21.9%→33.3% 為**作者自測**，未找到獨立重現；與 Claude Code / Meta-Harness 的比較是否同硬體、同 token 預算，摘要未交代；其 harness 定義與 OpenClaw **不保證同構**。
- SCH 的 80.0%→86.9% 為受控 150 任務研究，seed 數、信賴區間、是否單次執行皆未給；「re-entry 不需檢索模型呼叫」是作者系統的特性，改用向量檢索則成本結構不同。
- Timeout Cascades 建立在 **open-weight 模型**上；我們用商用 API，**沒有「便宜版可自由呼叫」的前提** → 數字不可直接照搬，方向可測。
- Tornhill 的數字多為**演講口徑**，未標原始研究出處與樣本細節；Code Health 量表為其自創，跨專案可比性未證實；套用到本 wiki 屬**類比推論**。
- PIPETTE 的 mode collapse 觀察針對 **RL-Hammer 與 PISmith 兩個方法**，不代表所有紅隊方法。
- Anthropic IPO：Class A 每股 **$83.00**、發行 **980,000,000 股**、**2026-11-19 於 Nasdaq 上市（代號 `ANT`）**、既有股東售股部分公司不拿 proceeds——這些**已從 Anthropic 官方公告全文核對**；HN 標題所稱首日市值約 **$2T**（Reuters）**因 Reuters 回 401 未讀內文，未獨立驗證**。
- GitHub Trending 的 repo 清單**本次解析失敗**，改用 GitHub Search API 作為「近期高星 agent repo」的替代來源——**語意不同**（近期高星 ≠ trending 榜）。
