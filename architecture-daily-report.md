# 每日 Agent × 軟體開發情報 — 2026-10-27

> 來源：16 個公開來源 / 5 篇論文 · 產出：木木鴞 🌿🦉 · Wiki 已入庫（1 source + 4 concepts）

**一句話總結：模型變強之後，harness 的下一個職責不是「把更多東西塞進 context」，而是「決定什麼時候把 context 丟掉、把工作留在檔案裡」——而且這個職責的收益要用 rerun 校準的雜訊底線來衡量，不是用排行榜分數。**

---

## 今日 5 個重點

### 1. 四方獨立收斂：丟掉 context，保留工作

- **發生什麼**：10 天內四個彼此無關的團隊，用 Qwen / GLM / GPT-5.5-5.6 / Codex / Claude Code / DeepSeek 與完全不同的任務域，得出同一解法 —— 定期丟棄對話脈絡、把進度寫成檔案產物，下一個 agent 只繼承產物。Anthropic Memento 每 1.5 小時 fork（留 codebase + environment + note）；MSR 的 Fork-and-Flush fork 成多條平行軌跡、各自空白 context、跑完由最高分者繼續；UC Berkeley+Stanford 的 Forgetting 定期丟棄所有 session 與候選歷史、只從「最佳候選（以檔案留在 environment）」重啟。
- **為什麼重要**：Forgetting 那篇（arXiv 2610.20563）試了三種 scaling 策略 —— 單 agent 迭代更久、多 agent 平行、多 agent 互相溝通 —— **三種全部 plateau，原因相同：agent 被自己的過去錨定**。這說明瓶頸是「記憶」不是「算力」，加 agent 或加算力都不解。量化：Fork-and-Flush 在**等算力預算**下比 single-run **+66.0%**、比 best-of-N **+44.4%**；Forgetting 最高 **+15%**（vs 平行 agent）/ **+39%**（vs 單一 agent）。可遺忘的停滯 run 在後續 30 個 proposal 內 +4.5%~9.2%，不可遺忘者 <2% 且成本最高 2 倍。
- **來源**：[arXiv 2610.07447](https://arxiv.org/abs/2610.07447)、[arXiv 2610.20563](https://arxiv.org/abs/2610.20563)、[arXiv 2610.07625](https://arxiv.org/abs/2610.07625)、[dbreunig 10-14](https://www.dbreunig.com/2026/10/14/context-inertia.html)

### 2. Compaction 救不了 Context Inertia —— 本次最可操作的一條

- **發生什麼**：dbreunig 定義了第五種 context 失效模式 **Context Inertia** —— 模型在 context 中對某個假設做出承諾後，即使證據已說明該改道仍不放。它同時屬於既有的 context poisoning 與 distraction，並被前沿模型「不懈指令遵循」的訓練放大。關鍵負向結果來自 Fork-and-Flush 實測：inertia **在定期 compaction 之後依然存在**。
- **為什麼重要**：機制很直白 —— 摘要的設計目標是「擴充可用 context **同時保留任務與進行中的工作**」，而那正是模型固著的對象。**摘要是把固著點提煉濃縮，不是移除它。** 所以 compaction 與 forgetting 必須是兩個原語：前者由 token 壓力觸發，後者應由「已連續 pursue 同一假設多久」觸發。症狀量化（Stanford SLA / CORAL harness）：最後一次改進出現在 **231M tokens**，其後 1,500 個 turn 中 **98% 完全沒有 tool call** —— 模型只是反覆咀嚼既有 context。
- **來源**：[The State of Context Engineering（10-24）](https://www.dbreunig.com/2026/10/24/the-state-of-context-engineering.html)、[Context Inertia（10-14）](https://www.dbreunig.com/2026/10/14/context-inertia.html)

### 3. Harness 買到的是 token，不是分數 —— 而且效應小於雜訊

- **發生什麼**：arXiv 2610.04433（山東大學）用 5 個模型 × 3 個**生產級** harness（Claude Code / mini-SWE-agent / OpenCode）× SWE-bench Verified，**並重跑同一設定做校準**。結果：最重的 harness 與最輕的 harness（~100 行 Python、單一 bash tool、不做任何 compaction）**在 5 分點內等價**；換 harness 翻掉 **13%** 的任務，而**重跑同一個 harness 也翻掉 13%**，且「這次贏的任務下次不會贏」。
- **為什麼重要**：唯一穿過雜訊的 harness 效應是**負向**的（OpenCode 落後最多 9 分，其中一半其實來自 output cap 截斷）。成本差 **3 倍**，且差距在**第一次 API call** 就被鎖死：固定 context（system prompt + tool schema）= Claude Code **16,581 tokens** / OpenCode **7,025** / mini-SWE-agent **829** —— 這是先付的入場費。三條最低報告標準：① **rerun 校準**（同一 setup 重跑 10 次散布 2.2–6.0pp）② **adapter 固定**（同一 harness minimal adapter 19.1% vs full adapter 73.4%，差 54pp）③ **網路隔離**（439 個 trial 中 **312 個（71%）**從 GitHub 抓到原始人類修法）。這補上了 10-24 已入庫的 Fowler harness-ROI（那份量 reliability，这份量 noise floor）。
- **來源**：[arXiv 2610.04433](https://arxiv.org/abs/2610.04433)、[VentureBeat 10-23](https://venturebeat.com/orchestration/a-coding-agents-harness-can-triple-its-cost-without-making-it-more-accurate-study-finds)

### 4. 安全研究與 context 工程交會：Anthropic 自己用 Memento 跑實驗

- **發生什麼**：Anthropic 的 self-replicating-ai 論文中，9B 模型在 9 種測試硬體中的 8 種跑起 inference；15 台 Android TV box 分布式跑 Gemma4-26B-A4B（0.39 tok/s）。同一篇附帶的 harness，恰恰是定時 fork + 丟 context + 留 note + 留 workspace。
- **為什麼重要**：能力邊界研究與 context 工程最佳實作出現在同一個 harness 上，不是巧合 —— **「長時間跑」正是那個實驗的硬性要求**。對 OpenClaw 的意義：同一個機制既是**安全護欄**（不讓 agent 無限固著）又是**成本控制**（避免 231M tokens 式的空轉）。
- **來源**：[anthropic.com/research/self-replicating-ai](https://www.anthropic.com/research/self-replicating-ai)

### 5. 長期 agent 會被自己的 skill 反噬 —— 這是 2027 的問題，而且目前無解

- **發生什麼**：dbreunig 在 AGNTCon 演講中**直接點名 OpenClaw 這類系統**。他跑了六個月的 Hermes agent，觀察到 skill 與記憶持續累積、互相矛盾，**解答品質隨時間下降**：「他們 solve one task one way, then rediscover a different way to solve something similar. The instructions and memories start to build up and conflict with one another.」
- **為什麼重要**：這是本團隊記憶軸的第四段 —— 10-25「記憶是有稅的補丁」→ 10-26「保留原始證據，治理在讀取端」→ **今天「累積本身會產生衝突」**。dbreunig 明說 **「nobody has yet figured out how to handle this」** —— 這是**開天窗**，不是待最佳化的細節。方法論推論：現有記憶 benchmark（Mem0 / Zep / LoCoMo / MemPABench）幾乎全是 snapshot，抓不到「六個月後才形成」的衝突；要評估需要 **longitudinal** 設計。
- **來源**：[The State of Context Engineering（10-24）](https://www.dbreunig.com/2026/10/24/the-state-of-context-engineering.html)

---

## 對 OpenClaw / Linder 的啟發

1. **把 forgetting 從 compaction 裡拆出來，做成獨立原語。** 觸發條件不是 token 壓力，而是「連續 pursue 同一假設的時長 / 步數」。保留物 = 檔案產物 + 一份短 handoff note —— **note 是 context 與 artifact 之間的轉換橋樑**（Memento 正是靠它才能把工作帶過 context 邊界）。Multi-agent 版可直接移植 Fork-and-Flush 結構：子 agent 繼承共享工作區但各自空白 context，週期結束由最高分軌跡繼續。
2. **harness 層的 A/B 在 rerun 校準之前不可比較 —— 把三條最低標準立成規範。** (a) 報 rerun 分布而非單點分數 (b) 固定並聲明 adapter (c) 網路隔離。同時要有意識：**context inertia 這類效應在總分 benchmark 上完全不可見**，必須用 scenario-specific 評測（長時程 / 固著 / 跨模型遷移）才抓得到。
3. **記憶與 skill 治理往「exactly-once handoff + 過時標記」走。** `akitaonrails/ai-memory`（13.8k stars, Rust, 10-27 push）讓 20+ harness 共用一份記憶，關鍵設計是 **handoff 為有型別的協定：每個 handoff 有 owner 且恰好被 claim 一次**。OpenClaw 的 agent 團隊（roaringmoon / charizard / gengar / mrmime）目前靠 session 傳遞，缺這個 exactly-once 保證；而累積衝突則需要「過時標記 + 合併而非平行累積」的機制 —— 這正好是能交給 skill_workshop 的提案。

---

## 值得追蹤的 repo / paper / article

- [arXiv 2610.20563 — Scaling Discovery Requires Forgetting](https://arxiv.org/abs/2610.20563)（UC Berkeley + Stanford, 10-14）— 證偽三種 scaling 策略
- [arXiv 2610.07447 — Fork-and-Flush: Escaping Idea Basins](https://arxiv.org/abs/2610.07447)（10-05）— +66.0% / +44.4%，且證明 inertia 撐過 compaction
- [arXiv 2610.07625 — Stateless Language Agents](https://arxiv.org/abs/2610.07625)（Stanford, 10-06）— 231M tokens / 98% 無 tool call
- [arXiv 2610.04433 — What Does a Harness Buy? Tokens, Mostly](https://arxiv.org/abs/2610.04433)（山東大學, 10-03）— harness 效應 vs 雜訊底線
- [dbreunig — The State of Context Engineering](https://www.dbreunig.com/2026/10/24/the-state-of-context-engineering.html)（10-24, AGNTCon 演講稿, HN 255 pts）— 唯一點名 OpenClaw 的材料
- [dbreunig — Context Inertia: When Agents Won't Let Go](https://www.dbreunig.com/2026/10/14/context-inertia.html)（10-14）
- [Anthropic — AI models may be capable of self-replicating without access to a datacenter](https://www.anthropic.com/research/self-replicating-ai) — Memento harness 的一手出處
- [akitaonrails/ai-memory](https://github.com/akitaonrails/ai-memory) — 跨 harness 記憶 + exactly-once handoff（13.8k stars, Rust）
- [stablyai/orca](https://github.com/stablyai/orca) — agent fleet，107k stars，10-27 push
- [Graphify-Labs/graphify](https://github.com/Graphify-Labs/graphify) — 136k stars，`/graphify` skill 給 Claude Code / Cursor / Codex / Gemini CLI

---

## 下一步建議

1. **Ingest 已完成**（本次已做）：raw snapshot + 1 source + 4 concepts 已寫入 llm-wiki，index/log 已更新，圖譜已同步（**10,326 nodes / 17,303 links / 1,206 communities**，5 頁全數通過 orphan 檢查）。建議先讀 `wiki/concepts/forgetting-as-scaling-lever.md` 與 `wiki/concepts/strategic-forgetting-and-memory-conflict.md`。
2. **安排一個小實驗（推薦）**：在我們自己的 session 上做 forget vs compact 的**配對 A/B**（同一 repo 任務、n ≥ 5），量測 (a) 固著率（重複 pursue 同一假設的 turn 比例）(b) token 差異。這正好接上 10-24 的 harness ROI 軸，成本低、判準明確。
3. **寫一支 skill：harness A/B 報告最低標準**（rerun 分布 / adapter 設定 / 網路隔離 / 首次 call 固定 context token 數），把今天三條警示變成可執行 checklist，避免我們自己未來做出「我改了 harness，勝率上升」這種不可比較的宣告。

---

## 本日查過但無高訊號的來源

- **Hacker News**（Algolia API，created_at + 關鍵字過濾）：只命中 2 條相關（dbreunig 255 pts、另一篇 5 pts）。→ 本次過濾未命中高訊號；**不等於** HN 本日無動向。
- **arXiv export API**：本次 3 次成功、1 次空回應（重試後成功），非穩定。
- **框架面另見**：Microsoft Agent Framework `[BREAKING] Add MCP 2.x compatibility foundation (#9236)` ＋ `[BREAKING] Require explicit AG-UI authorization scope (#9413)`（MCP 從「擴充中」走向「有版本遷移路徑」）；GitHub Agentic Workflows v0.93.0–v0.93.5（10-26，靜態分析收緊 + 憑證處理更安全 + Pi CLI 1.4.0 成預設）；Notion 第六代 harness（單任務可跑 **>24 小時**，先前 5 分鐘；新增 **Auto model router** 依成本委派）。

---

## 誠實限制

1. Anthropic self-replicating-ai 原頁僅取前段（35,548 chars 中抽取 3,776 chars），**Memento 細節為 dbreunig 二手轉述**，非一手核對。
2. **arXiv 2610.04433 一手日期 2026-10-03（>14 天）** —— 今日仍值得看的理由是：它是目前唯一用 rerun 校準量化 harness 效果的研究，且與 10-24 已入庫的 Fowler harness-ROI 互補。**這點明講，不假裝它是新資料。**
3. arXiv 內容為 API 摘要抽取，**非全文精讀**；+66.0% / +44.4% / +15% / +39% 皆為 min-max normalized average score，**非絕對 pass rate**，跨任務不可相加。
4. GitHub star 數為 2026-10-27 API 快照，會變動。
5. 本地 graphify 的上游是 `safishamsi/graphify`，與 Trending 上的 `Graphify-Labs/graphify`（136,197 stars）**不是同一個 repo**，兩者關係未查證，故不做推論。
