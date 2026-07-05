# 每日 Agent × 軟體開發情報 — 2026-07-05

> Cron `a72cb46b` 執行時間：02:04 UTC（10:04 台灣）
> 涵蓋範圍：最近 7-14 天，重點放在昨日（2026-07-04）至今日的訊號

---

## 今日 5 個重點

### 1. OpenAI Codex 內部資料顯示 GPT-5.5 reasoning tokens 群聚在固定邊界（516 / 1034 / 1552）

**發生什麼**：使用者 `dkundel-openai` 在 `openai/codex` repo 開 issue #30364（2026-06-27 開立、至 7-04 已 58 則留言），統計 2 月至 6 月共 390,195 筆回應紀錄後發現：`reasoning_output_tokens = 516` 的事件中有 82% 屬於 GPT-5.5，其它模型僅 1.3% 比例。模式暗示存在「thresholded reasoning budget」或隱藏 chain-of-thought 截斷。

**為什麼重要**：這是「reasoning 模型在 production 中實際 reasoning effort」的罕見量化證據。若屬實，模型在複雜任務下被 budget cap，主觀感受會是「越來越笨」。對所有依賴 reasoning model 的 agent 與程式助理都直接影響品質。

**來源**：[openai/codex#30364](https://github.com/openai/codex/issues/30364)｜[HN 48789428 (149 分)](https://news.ycombinator.com/item?id=48789428)

---

### 2. Armin Ronacher：「Better Models: Worse Tools」 — 新版 Claude 工具呼叫 schema 紀律退化

**發生什麼**：`lucumr.pocoo.org`（Flask 作者、Pi 維護者）2026-07-04 發文：Pi editor 用戶回報 Opus 4.8、Sonnet 5 對 nested `edits[]` 物件加料（發明不存在的 key），導致 schema validation fail。文章深入解釋工具呼叫是「in-band signal」、「ANTML 標記不是真的 XML」、並指出 constrained decoding 對 JSON-in-XML 混合格式可能失效。

**為什麼重要**：當 SOTA 模型在基本 tool schema 不如前代，這是個結構性警訊。能力提升 ≠ structured output 紀律提升。所有依賴 tool-use 的 harness（OpenClaw、Claude Code、Codex）都要重新評估 retry / schema guard 預設。

**來源**：[lucumr.pocoo.org/2026/7/4/better-models-worse-tools/](https://lucumr.pocoo.org/2026/7/4/better-models-worse-tools/)｜[Pi issue #6278](https://github.com/earendil-works/pi/issues/6278)｜[HN 48788599 (92 分)](https://news.ycombinator.com/item?id=48788599)

---

### 3. Claude Code 出現 Enterprise ZDR workspace session 洩漏回報

**發生什麼**：2026-07-04 開 issue #74066，使用者在 Enterprise Zero-Data-Retention workspace 中，agent 突然宣稱「在幫你蓋 Minecraft 神廟」。懷疑 consumer 帳號 session 與 Enterprise ZDR 之間存在 cross-tenant cache 污染。截圖、14 則討論，官方尚無明確回應。

**為什麼重要**：對企業用戶極敏感。ZDR 是 Anthropic 對企業客戶的隱私承諾，若快取層共用則承諾失效。也提醒所有 multi-tenant agent 產品（含 OpenClaw self-host 部署）：session isolation 不能只靠 workspace 標籤，仍需在 retrieval / cache key 上獨立 namespace。

**來源**：[anthropics/claude-code#74066](https://github.com/anthropics/claude-code/issues/74066)｜[HN 48785485 (273 分)](https://news.ycombinator.com/item?id=48785485)

---

### 4. OpenAI 推出 `codex-plugin-cc` — Codex 跑在 Claude Code 內做 delegation

**發生什麼**：2026-07-05 trending #1 on GitHub (`openai/codex-plugin-cc`)。設計目標是「從 Claude Code 內呼叫 Codex 來 review code 或委派任務」。718 stars today，作者 `dkundel-openai`。

**為什麼重要**：交叉 harness delegation 已成為產品類別。代表廠商都承認「單一 coding agent 不夠，需要 orchestrator + specialist」分工。對 OpenClaw 意義：未來 specialist agent（如 Rowlet）不一定要全部跑在 OpenClaw，可在 OpenClaw orchestrator 內委派給外部 coding agent 做嚴格 review。

**來源**：[github.com/openai/codex-plugin-cc](https://github.com/openai/codex-plugin-cc)

---

### 5. `alibaba/page-agent` 與 `usestrix/strix`：GUI agent 與 security agent 兩個新興開源熱點

**發生什麼**：
- `alibaba/page-agent`（TypeScript）：JavaScript in-page GUI agent，用自然語言控制 Web UI。742 stars today。
- `usestrix/strix`（Python）：open-source AI 滲透測試工具，自動找漏洞。**1,904 stars today**（今日 trending 第一）。

**為什麼重要**：兩者皆為「specialized agent」產品化：「GUI 操控」與「security testing」不再是 framework demo，而是獨立可部署的工具。對 OpenClaw skill 設計啟示：未來可思考「page-agent skill」（網頁自動化）與「strix skill」（安全稽核），把外部明星 agent 整入 OpenClaw 生態。

**來源**：[github.com/alibaba/page-agent](https://github.com/alibaba/page-agent)｜[github.com/usestrix/strix](https://github.com/usestrix/strix)

---

## 對 OpenClaw / Linder 的啟發

1. **Tool schema guard 是必做而非可選**。Ronacher 文章顯示 SOTA 模型會發明欄位。建議在 `~/.openclaw/skills/` 新建一個 `tool-schema-guard` skill：對 `read / edit / write / exec` 的 argv 做 JSON-Schema 驗證，失敗就 hard fail、不丟回模型重試；同時把 schema 文件加入 system prompt，從 prompt 端降低犯錯率。

2. **部署 session isolation 設計檢查**。Claude Code ZDR 洩漏事件提醒我們，OpenClaw multi-agent（rowlet / charizard / gengar / mrmime）目前用 `sessions_send` 跨 session 通訊，需要審查：
   - workspace-id 是否真的出現在 cache key
   - Heartbeat poll 共用 channel 是否有 unintentional state leak
   - 若未來上 multi-tenant，必須做到 per-tenant namespace + cache eviction on logout

3. **跨 harness delegation 是新 workflow 模式**。`openai/codex-plugin-cc` 把「Claude Code orchestrator + Codex specialist」當 1-click plugin 賣。OpenClaw 可反過來定位為 specialist（wiki / knowledge）暴露 MCP 或 HTTP endpoint，被 Claude Code / Cursor / Codex orchestrator 呼叫。具體路徑：寫一個 MCP server wrapper，把 `archaeology_wal skill` 與 `wiki_query skill` 公開。

---

## 值得追蹤的 Repo / Paper / Article

1. [openai/codex#30364](https://github.com/openai/codex/issues/30364) — GPT-5.5 reasoning-token cluster 統計問題
2. [lucumr.pocoo.org/2026/7/4/better-models-worse-tools](https://lucumr.pocoo.org/2026/7/4/better-models-worse-tools/) — Anthropic Opus 4.8 / Sonnet 5 tool schema 退化
3. [anthropics/claude-code#74066](https://github.com/anthropics/claude-code/issues/74066) — Enterprise ZDR session 洩漏回報
4. [openai/codex-plugin-cc](https://github.com/openai/codex-plugin-cc) — Claude Code 內呼叫 Codex 的 delegation plugin
5. [alibaba/page-agent](https://github.com/alibaba/page-agent) — 純 JS in-page GUI agent
6. [usestrix/strix](https://github.com/usestrix/strix) — open-source AI pentesting agent
7. [anthropic.com/research/economic-index-june-2026-report](https://www.anthropic.com/research/economic-index-june-2026-report) — Cadences：每小時抽樣人們何時用 Claude、做什麼
8. [ziglang.org/devlog/2026](https://ziglang.org/devlog/2026/#2026-06-30) — Zig 把 package 管理從 compiler 搬到 build system（語言生態演進訊號）

---

## 下一步建議

1. **寫 `tool-schema-guard` skill**：基於 Ronacher 文章的 observation，定義 OpenClaw 自己的 argv schema + validator。預估 30 分鐘可完成、降低 tool-call retry loop 至少 30%。

2. **Ingest Ronacher 文章到 llm-wiki**：高密度結構性觀察（tool-call 是 in-band signal、ANTML、constrained decoding 限制），寫一篇 `wiki/sources/2026-07-04-better-models-worse-tools.md` 並 `wiki link` 到 `wiki/concepts/tool-calling-internals.md`。

3. **監控 issue #74066 進展**：Claude Code 官方應在下週內回應。設 cron 每日早上檢查最新回覆；若官方確認是真 bug，立即套同樣 isolation pattern 自審 OpenClaw。

---

## 資料來源覆蓋狀態

- ✅ **LLM Wiki graphify query**：成功取得 Architecture / OpenClaw / TDD skill 等既有主題的 node 與 edge
- ✅ **Hacker News top stories**：40+ stories 掃描，篩出 5 則高訊號
- ✅ **GitHub Trending daily**：抓取前 10 repo，識別 4 個高相關
- ✅ **Anthropic research blog**：抓到 June 26 Cadences report
- ✅ **OpenAI Codex issue**：API 直接取得 issue body 與 metadata
- ⚠️ **arXiv cs.AI / cs.SE 2026-07**：索引頁成功但摘要未逐篇讀，前線尚未發現暴增的 agent 論文（與昨日觀察一致）
- ❌ **Papers with Code**：未抓取（昨日已 fail）
- ❌ **Pragmatic Engineer / InfoQ**：未取得內容（昨日至今未修）

---

_註：`graphify link` 指令不存在（已用 `graphify --help` 確認）；wiki-source 頁面以 `[[wiki-link]]` 標記目標 concept，下次 `graphify extract` 自動建立節點與 edge。今日已寫入 `wiki/sources/2026-07-04-better-models-worse-tools.md` 並加入 `wiki/log.md` 的 2026-07-05 區段。_
