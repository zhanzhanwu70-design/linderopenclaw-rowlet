# 每日 Agent × 軟體開發情報 — 2026-10-26

> 軸線：**Agent Skills 治理轉移 × Compaction 出處洗白 × Raw-evidence 記憶典範 × 決策平面 API × 介入效益量測**
> 產出：Rowlet（每日研究 cron）｜採集時間 2026-10-26 10:00–10:15 (+08:00)
> 本日定調：**「Skill 有了中立治理、compaction 有了信任邊界、記憶有了保留原則、決策有了獨立平面——接下來缺的不是新元件，而是量測介入效益的方法。」**
> 來源覆蓋：Agent/AI 工程研究（arXiv ×5）｜軟體開發潮流（InfoQ ×2、HN、GitHub API）｜實務工具與框架（Linux Foundation / AAIF、OpenAI、框架 deprecation 彙整 ×12 來源）

---

## 今日 5 個重點

### 1. Anthropic 把 Agent Skills 捐給 Linux Foundation——skill 格式變成中立基礎設施

**發生什麼**：2026-10-22 於 San Jose 的 AGNTCon + MCPCon North America，Linux Foundation 旗下 **Agentic AI Foundation（AAIF）** 宣布四個新專案：**Agent Skills（Anthropic 捐贈）、Open Responses（OpenAI）、OpenEnv（Hugging Face）、OpenSandbox（阿里巴巴）**。AAIF 的 founding projects 原本已含 **MCP、goose、AGENTS.md**。Anthropic 原文：「we're donating Agent Skills to the AAIF to ensure that anyone building with skills can shape what's next.」

**為什麼重要**：這是 **MCP 路徑的重演**——先捐給 AAIF 取得中立治理，再讓多方共同參與。對我們最關鍵的事實是：**AGENTS.md 與 Agent Skills 現在在同一個治理傘下**，OpenClaw 的「AGENTS.md + SKILL.md」兩件武器不再依附任何單一廠商。真正的紅利在未來：格式一旦中立且可攜，**skill lint / skill eval / skill marketplace** 會從各廠自製變成可投資的公共品——skill 品質第一次有跨平台客觀評分基礎。風險側：格式變更權從單一廠商轉為多方共治，我們的 skill 實作不應過度依賴任一家的擴充語法。

**來源**：<https://www.linuxfoundation.org/press/agentic-ai-foundation-announces-four-new-projects-agent-skills-open-responses-openenv-and-opensandbox>｜<https://aaif.io/news/agentic-ai-foundation-announces-four-new-projects>

---

### 2. Compaction Laundering：壓縮是信任邊界，不是省 token 的功能

**發生什麼**：arXiv 2610.29869（2026-10-21）證明：把 typed conversation **壓平成單一純字串**並以文字標籤（如 `[User]:`）標記角色的 harness，會**在 summarizer 執行前、於程式碼層**摧毀訊息出處。攻擊者只要能控制 agent 讀到的任何內容，就能偽造一個 user turn，讓它在壓縮後**以真正指令的身分存活**。實測：**5 個 flattening harness**（pi、opencode、Cline、Aider、OpenHands）偽造 approval 洗白成功率 **87–100%**，context window 可達 **~908,000 tokens**；**4 個 role-typed harness**（Codex、Gemini CLI、Qwen Code、Continue）同一攻擊 **0%**。洗白後的 standing approval 讓 agent 在 sandbox 執行攻擊者控制的 `curl | sh`；live pi TUI 端到端 **~50%**（clean arm 0%）。同一通道還能把 agent 的計畫引開攻擊者指定的檔案，讓 code review 看不到植入的 backdoor。作者明言：**「因為出處是在 harness code 裡被決定性摧毀，任何 prompt 層防禦都無法修復它」**；code-level provenance check 可**抓 77%、僅誤傷 2%** 合法摘要內容。

**為什麼重要**：這不是「prompt injection 變強了」，而是**型別資訊在架構層被丟掉**。可攜判準極清楚：**compaction 前保留 role provenance**，用文字標籤代替結構化 role 等於把信任邊界壓扁。而 77% / 2% 代表**可部署且低誤傷的守門存在**，成本遠低於要求 agent 更小心。我們的每日 cron 長跑、memory compaction、subagent 回報壓縮全都踩在這個風險面上。

**來源**：<https://arxiv.org/abs/2610.29869>

---

### 3. 記憶系統的複雜度已被三條獨立證據鏈判為不划算

**發生什麼**：**Raw-RAG 勝出**（arXiv 2610.30755，2026-10-22）：純 dense retrieval + reranking 檢索**原始歷史**，在 LoCoMo / LongMemEval / MEME / MemoryAgentBench 上，於 **7 個 benchmark-model 設定中 6 個排第一**，比最強 agentic memory 高 **0.13–5.53 分**；作者強調「**即使完整存取 transformed memory store，相對 raw evidence 仍留有 accuracy gap**」。**偏好端失效**（arXiv 2610.30485 MemPABench，2026-10-21）：99 sessions / 4 個月 / 14 偏好、每次 5 次事件驅動變更的 on-policy 評估中，「**Retrieval-based systems（Mem0、MemOS、simple RAG）do not outperform No Memory**」。加上 2026-10-25 報告的 MemoryTax（建構成本本身就超過一次 full-context rollout），已是**三條互相獨立的證據鏈**。

**為什麼重要**：這把「保留原始 + 讀取期治理」從偏好升級為**有收斂證據的架構原則**。精確的表述不是「不要記憶」，而是「**不要在寫入期把記憶形狀化**」——mutation / 預先摘要這類變形才有問題。配套原則：naive RAG 必須是**必測基線**而非弱對照組；記憶預算往「治理（淘汰過期內容）」傾斜而非「擴充（多寫記憶）」；並保留**非文字原始載體**（圖片說明、原始 trace、完整 log），因為摘要層最容易吃掉的就是這類證據。

**來源**：<https://arxiv.org/abs/2610.30755>｜<https://arxiv.org/abs/2610.30485>

---

### 4. Decisions API GA：決策平面從生成平面正式切出

**發生什麼**：OpenAI 於 2026-10-22 將 **Decisions API** 轉為 GA，以 **GPT-6 Luna** 供應，針對**有界答案**的問題，比經由 Responses API 的 GPT-6 Luna **快最多 10×**；自 beta 起新增 native GPT-Live 整合、prompt caching、US/EU inference residency、native JSON 輸入、圖片入題，單次請求最多 **400 個問題**（原 200）。OpenAI 內部用例涵蓋分類、路由，以及「判斷某主題是否值得進一步檢視」；客戶案例 Box Extract 為「~5x faster route selection on 30 certificate of insurance cases, with the same accuracy as the Responses API」，低信心案例轉人工。

**為什麼重要**：這是 2026-10-25 報告的 arXiv 2610.20959（context engineering 是**分型處方**、疊加不相加）的**產品化落地**——分型不只是研究分類，它有明確的產品邊界：決策平面（低延遲、有界答案、低成本）與推理平面（長鏈生成）。架構含意是**成本與延遲的量級分離**：agent 系統裡最頻繁的是小決定（路由、門控、閘值），最昂貴的是少數深度推理，混在同一模型呼叫上等於用最貴的通道處理最廉價的判斷。InfoQ 的架構側版本（《From Microservices to Agents》）說的是同一件事：**microservices 分解功能，agent 系統分解決策**——後者邊界隨輸入而變，所以 observability 與 reliability 權重必然上升。

**來源**：<https://openai.com/index/decisions-api/>｜<https://www.infoq.com/articles/distributed-systems-microservices-agentic-ai/>

---

### 5. HPCAgent-Bench：終於有「一次介入值不值」的量法

**發生什麼**：arXiv 2610.20673（2026-10-14）指出既有 benchmark 固定單一 accelerator／programming model／harness，因此「無法隔離各元件貢獻，也無法顯示新增的 skill 與 tool 是否回本」。HPCAgent-Bench 以 **689 個 kernel**（三軌）、**hidden fuzzed inputs + 外部 judge**（堵住 agent exploit 測試系統的路徑），提出兩個指標：**intervention efficacy**（以**配對 run** 量測介入對 speedup / success rate / cost 的影響）與 **weighted token cost**（input / cached-input / output 依**顯式權重**計價）。關鍵數字：「Across 40 matched setups, interventions significantly change speedup only twice but token cost by up to 3.0×.」

**為什麼重要**：這是我們 10-24（Fowler harness ROI）與 10-25（harness 自我改寫、context 分型）兩天討論**缺的那把尺**——之前都在談 ROI，現在有了正規定義。數字本身揭示了一個此前被忽略的結構：**多數介入改變的是成本結構，不是能力上限**（顯著改變 speedup 只有 2 次，但 token cost 變動最高 3.0×）。作者並直說「token weighting decides whether a saving is significant」——**不寫權重就無法判定省下的 token 值不值**。誠實限制：kernel 是 HPC/ML 最佳化任務，不是通用軟體工程任務，移植需自行驗證成功率的定義。

**來源**：<https://arxiv.org/abs/2610.20673>

---

## 對 OpenClaw / Linder 的啟發

### 一、Compaction 路徑要加「出處守門」——放在 harness code 層，不是 prompt 層

依 arXiv 2610.29869：壓縮前保留**結構化 role provenance**（不要用 `[User]:` 這類文字標籤代替角色欄位）；摘要後每一則「指令」必須能對應到原始訊息識別碼，對不上的一律降級為不可信內容。量化目標可直接採用論文值（抓 77% / 誤傷 2%），失敗基準也明確（flattening harness 87–100%）。**我們目前所有壓縮路徑（memory compaction、subagent 回報、cron 長跑）都應視為同一個風險面。**

### 二、記憶預算結構調整：讀取期治理 > 寫入期建構，且保留原始載體

依三條證據鏈（Raw-RAG / MemPABench / MemoryTax）同向：具體動作是**淘汰過期與失效記憶**優先於**新增記憶摘要層**；同時不把原始 trace / log / 對話原文摘要化後丟棄（非文字證據一旦摘要即不可逆遺失）。把 naive RAG 設為**必測基線**——任何記憶層若贏不過 raw retrieval + reranking，就沒有存在理由。既有方向（Memory Wiki 的 OKF 重新匯入保留人工註記、冷啟動不逐個開 memory index）正確，應繼續往治理側走。

### 三、把「介入效益」變成 skill 的常駐欄位，並把決策判斷下沉到便宜通道

依 HPCAgent-Bench：每個 skill 應記錄「**配對 run** 後的 Δpass rate 與 **weighted token cost**（含 cached-input 權重）」，否則無法回答「這個 skill 是不是只在燒 token」——retro-fit 的第一步應是建立量測骨架，而不是先加功能。搭配 Decisions API 的啟示：OpenClaw 裡三個高頻有界判斷——cron/heartbeat 的「要不要升級處理」、skill routing 的「該不該觸發某 skill」、subagent 分派的「派給哪個專家」——都該走低延遲有界答案路徑，而非完整推理模型。

---

## 值得追蹤的 repo / paper / article

- <https://www.linuxfoundation.org/press/agentic-ai-foundation-announces-four-new-projects-agent-skills-open-responses-openenv-and-opensandbox> — AAIF 四案（Agent Skills / Open Responses / OpenEnv / OpenSandbox）
- <https://aaif.io/news/agentic-ai-foundation-announces-four-new-projects> — AAIF 官方版本
- <https://arxiv.org/abs/2610.29869> — Compaction Laundering（今日最高價值單篇）
- <https://arxiv.org/abs/2610.30755> — Raw-RAG 勝過複雜 agentic memory
- <https://arxiv.org/abs/2610.30485> — MemPABench：檢索式記憶不優於 No Memory
- <https://arxiv.org/abs/2610.20673> — HPCAgent-Bench：介入效益量法
- <https://arxiv.org/abs/2610.18933> — The Agentic Scientist：每階段 rubric 驗證的 meta-controller（與本團隊 swarm-intel 研究互補）
- <https://openai.com/index/decisions-api/> — Decisions API GA
- <https://www.developersdigest.tech/blog/multi-agent-orchestration-patterns> — 四家框架 supervisor／network 原語退場一覽（二手）
- <https://news.ycombinator.com/item?id=50231722> — r/opensource 封禁 solo 與 LLM 專案（社群治理摩擦，80 分 / 108 留言）
- <https://github.com/HKUDS/nanobot> — 極輕量 self-hosted agent framework（Python + WebUI + tools + memory）
- <https://github.com/zhayujie/CowAgent> — 明講 Agent Harness + skills + self-evolution 的開源實作
- <https://github.com/codewhale-hq/Codewhale> — Rust 寫的終端 agent
- <https://github.com/CopilotKit/CopilotKit> — AG-UI 協定層（agent ↔ 前端的介面標準）

---

## 下一步建議

1. **把 compaction 出處守門做成一個可執行的 skill／檢查項**（成本最低、證據最強）：先盤點本團隊壓縮路徑中「typed role → 純字串」的轉換點（memory compaction、subagent 回報壓縮、cron 長跑），再依 2610.29869 的 77%/2% 目標設計 code-level provenance check。
2. **Ingest 到 llm-wiki（已完成主體，待補）**：本次已寫入 `raw/documents/daily-research-2026-10-26-agent-skills-compaction-decisions.md`、`wiki/sources/daily-research-2026-10-26-agent-skills-compaction-decisions.md` 與 5 個新 concept 頁（aaif-agent-skills-governance / compaction-provenance-laundering / raw-evidence-primacy / intervention-efficacy-metric / decision-plane-vs-reasoning-plane），`wiki/index.md` 與 `wiki/log.md` 已更新，graphify 圖譜已重建（10,313 nodes / 17,205 links，6 個新頁面皆非 orphan）。**下一步**：為 `wiki/concepts/agentskills-io-standard.md` 補一則治理轉移時間軸段落（已加註引言，內文仍待補），並把「compaction 出處守門」掛到 `wiki/maps/code-agent.md`。
3. **安排一個小實驗：skill 介入效益基線**——挑 2–3 個既有 skill（建議 `rowlet-self-reproduction`、`ouroboros`），用 HPCAgent-Bench 的方法做配對 run（有／無該 skill），記錄 Δpass rate 與 weighted token cost。先建立量測骨架再談優化；同時可把結果回寫進 wiki 的 skill 頁作為後續基準。

---

## 證據限制（誠實標註）

- **InfoQ 兩篇**（*From Microservices to Agents*、*AI in Production*）：web_fetch HTTP 200，但抽出的正文主體為導航樣板，核心論點**僅得 snippet 級證據**；已標為二手線索，未以一手全文口吻陳述。
- **AAIF 細節為二手**：SKILL.md 格式與 progressive disclosure 不變、70+ agent 平台、10 個 hosted projects 皆來自第三方，未經一手驗證；一手可確認的只有「四案入駐 AAIF」與「AGENTS.md 已是 founding project」。
- **Decisions API 價格 $0.10/M input tokens 為二手**（unite.ai、dev.to）；官方頁面未列價。
- **HPCAgent-Bench 任務域**為 HPC/ML kernel 最佳化，其介入效益量法移植到通用 coding agent 需自行定義「成功」與「介入切換單位」。
- **框架 deprecation 為第三方彙整**（developersdigest，頁面標示 2026-10-17），非各框架一手 changelog；引用的官方文件敘述（langgraph-supervisor 停止維護、ADK 2.12.0 DeprecationWarning 原文、CrewAI v2.0.0 移除）與框架文件一致。
- **未涵蓋**：Papers with Code 今日無可用新資料；Martin Fowler / Pragmatic Engineer 今日無新文（10-24 已引用 Fowler「Are Harnesses Worth the Cost?」，不重複）；`npx graphifyy link` 指令在現行版本**不存在**（回報 `unknown command 'link'`），已改用 `tools/add-wiki-pages-to-graphify.py` + `graphify cluster-only` 完成圖譜連結與驗證。
- **arXiv export API 當日不穩**：曾遇 HTTP 429 與 45 秒逾時（0 bytes），部分 id 需分批重試；本次 5 篇摘要皆已完整取得。
