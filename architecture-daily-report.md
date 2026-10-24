# 每日 Agent × 軟體開發情報 — 2026-10-24

> 軸線：**Harness ROI × Skill 粒度 × Memory 治理狀態 × MCP 生態落差**
> 產出：Rowlet（每日研究 cron）｜採集時間 2026-10-24 10:00–10:20 (+08:00)
> 本日定調：**「可靠性不是模型的禮物，是 harness 的帳單；而帳單要在模型越弱時越厚」**

---

## 今日 5 個重點

### 1. Harness 的 ROI 與底層模型能力成反比（有實驗數字了）

**發生什麼**：Martin Fowler（Thinking, *Exploring Gen AI* 系列）發表〈Are Harnesses Worth the Cost?〉。同一個 API service 專案跑 10 次、前後加不加 behavioral harness：frontier 模型 GPT-6 Sol 有無 harness 都 10/10 通過全部 178 項 acceptance tests，但加了 harness 要付 **約 7 倍成本、10 倍 token、3 倍時間，零可靠性增益**；cost-optimized 模型 GPT-6 Luna 沒 harness 時 10 次只成功 3 次，加 harness 後 10/10 全中，且**每 run 成本比 Sol 低 33%**。

**為什麼重要**：這把「該不該投資 harness」從品味辯論變成可量測的取捨。Harness 的邊際價值是模型能力的**補集**——它是保險不是加速器，收益是「失敗率壓到 0」的二元結果。反向風險同樣真實：模型一旦升級，既有厚 harness 立刻從保險變成 7 倍成本的裝飾，所以 harness 層需要版本化的 ROI 監測。

**來源**：<https://martinfowler.com/articles/are-harnesses-worth-the-cost.html>

---

### 2. Instruction file 會無條件覆寫程式碼現實——而且 agent 察覺了還是照做

**發生什麼**：arXiv 2610.30571（2026-10-22）用 40 個 Python 專案、320 次 run 測量 CLAUDE.md / AGENTS.md 與既有程式碼慣例衝突時的行為。沒有優先權句時 **90.1%** 的選擇跟隨過時的 instruction file；Claude Code 在 80 次中有 **79 次明確指出衝突，卻仍然照舊遵循**；Codex CLI 有 **20 次直接改寫既有程式碼**去符合文件，其中 17 次讓專案自己的測試失敗。在使用者層級 instruction file 加一句「既有程式碼優先」後：遵循程式碼的比例 **4.2% → 91.4%**，重寫停止，**測試通過率 89.4% → 100%**。

**為什麼重要**：instruction file 是 agent 的高優先級事實來源，優先於 repo 既有程式碼——這不是 bug 而是 context 層級的自然結果。關鍵推論是「agent 會提醒你衝突」**不能當作保護**：79/80 的察覺率配上 90.1% 的錯誤遵循率，證明 warning 是資訊性的而非強制性的。對會自動寫檔、commit 的 agent 尤其危險——遵循指令的代價是由程式碼與測試承擔。

**來源**：<https://arxiv.org/abs/2610.30571>

---

### 3. Skill 粒度被正式定義為「執行期政策」，不是靜態檢索結果

**發生什麼**：arXiv 2610.31461（2026-10-22）提出 Adaptive Skill Granularity：同一任務可能用 primitive tool calls、macro skill，或「macro 起步、micro 降級」的混合執行；框架由 **feature-based granularity controller** 與 **finite-state recovery executor** 組成，實驗結論是**固定 macro 執行在適用時有效，但在 mismatch 下脆弱**。生態端同步佐證：Claude Code changelog（2.1.300–2.1.310）顯示 skill 已是**有配額、有命名空間、有增量載入的執行單元**——單一 skill 來源每 session 最多 1,024 hooks / 16,384 matcher 字元、名稱衝突以 `<folder>:<name>` 解決、compaction 後重送 skill list、`/reload-skills` 只送差異、fork subagents 在 CLI/SDK/desktop/VS Code 全部預設開啟。

**為什麼重要**：過去 skill 研究集中在執行前（如何 retrieve/compose/synthesize），但真實 coding agent 的難點在執行中。macro skill 最危險的失敗不是報錯，而是**前提不符時安靜做出一個看起來合理但錯的結果**——這比明確報錯更難察覺。若 skill 沒有事先定義「什麼情況下我該拆開自己用底層工具做」，agent 在失敗後只能重試（可能再錯）或整個放棄（浪費已完成的部分工作）。這意味著 skill schema 可能需要一個表達「我做完了但可能不對」的位置。

**來源**：<https://arxiv.org/abs/2610.31461>｜<https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md>

---

### 4. Memory 的失效有兩種，而第二種更常見也更可修

**發生什麼**：arXiv 2610.30698（2026-10-22）區分兩種 memory 失效：**內容錯誤**（記錯了）與 **governance-state corruption**（內容沒變、任務沒變，但「哪些被保留的紀錄該進入模型可見 context」被改變）。跨 6 個 provider、731 個 benchmark-grounded bases、2,080 組 matched fault pairs：離線 control-plane 檢查中，corruption 在 **96.25%** 的配對改變 operative projection，而 **oracle-backed enforcement 可在 100% 還原**；下游 LongMemEval binary correctness 差距 **40.54 個百分點**（95% CI [30.32, 50.71]），Memora FAMA 差距 30.60 點。同日的 arXiv 2610.31306 補上治理面：**review 容量固定時，逃逸變更隨吞吐量線性增長，而「靠閱讀抓到」的比例趨近於零**——治理能降低斜率，能力不能；452 個高星公開 repo 中僅 48.67%（CI 44.1–53.3）有 agent context file。

**為什麼重要**：40.54 pp 意味著 agent 用錯記憶，多數時候**不是「記得不清楚」，而是「該淘汰的沒淘汰」**。這把 memory 的工程重點從「寫更多」移到「讓過期的東西真的不再出現」。而 96.25% vs 100% 這個對比是關鍵：既然離線 control plane 能完整攔截，就不必靠 prompt 防守——memory 治理是 harness 層裡**低成本、高可靠性收益**的項目，屬於值得加厚的部分。與第 1 點呼應：治理層的 ROI 與模型能力反比。

**來源**：<https://arxiv.org/abs/2610.30698>｜<https://arxiv.org/abs/2610.31306>

---

### 5. MCP 生態已到 4.3 萬個 server，但 stateless 遷移幾乎沒落地

**發生什麼**：LocalCan 於 2026-10-14 的普查（2026-10-15 發表）：官方 MCP Registry 有 **43,012 個 active servers**（43,538 個名字、150,595 個版本）；**78%** 本月首次發布的 server 帶 remote URL（2025-12 僅 27%）——MCP 已 remote-first；但 **500 個 server 的 handshake 探測中只有 1 個拒絕已廢除的 initialize handshake**，也就是 2026-07-28 的 stateless 規範在生態層幾乎沒落地；**抽樣的 remote server 中近半不需憑證即可回應 handshake**，其餘大多按規範要求 OAuth。同期 Red Hat 發布 RH SWE-bench（357 個驗證任務 / 25 個 repo / Go+Python+C），理由是「既有 benchmark 幾乎全是 Python，且沒有一個對應企業真正工作的生態」；arXiv 2610.31118（ProductWebBench，8,737 runs / 13 models）則顯示通過 requested-work 檢查的 run 仍有 **28.2% 失敗於 continuity check**、**10.8%** 把已通過的 browser state 弄回失敗。

**為什麼重要**：MCP 的困難已經從「spec 怎麼改」轉移到「4.3 萬個 server 的既有行為怎麼遷移」。對任何把 MCP server 拉進生產的團隊，實際風險不在協議版本，而在「你連的那個 server 是不是用正確的握手、會不會在沒有憑證的情況下接受請求」——近半數 remote server 不需憑證即可回應 handshake，這是可直接利用的攻擊面。benchmark 側同向：通用榜單天花板已低（Scale 的 SWE-bench Pro public set 約 23%），垂直榜單與「回歸檢查」才是真實訊號。

**來源**：<https://www.localcan.com/blog/state-of-mcp-server-development>｜<https://next.redhat.com/2026/10/21/red-hat-enterprise-specific-benchmarks-for-coding-agents-swe-bench/>｜<https://arxiv.org/abs/2610.31118>

---

## 對 OpenClaw / Linder 的啟發

1. **在 `AGENTS.md` 加一句優先權規則**（低成本、最高 ROI 的一行改動）
   > 當本文件與 repo 中既有程式碼的慣例衝突時，以既有程式碼為準，並在回報中指出衝突。

   依 arXiv 2610.30571，這類句子的效果是遵循率 4.2% → 91.4%、測試通過率 89.4% → 100%。OpenClaw 的 `AGENTS.md` / `SOUL.md` 就是 agent 的 instruction file，同樣的覆寫效力適用。與其讓每個 agent 各自察覺衝突（79/80 察覺率但仍然做錯），不如在 harness 層設一次。

2. **把「harness 厚度」與「模型強度」反向配置，並以「每單位可靠性的總成本」選型**
   厚 harness 對 MiniMax 級模型是賺的（可靠性的補集），對 frontier 模型是 7 倍成本零收益。因此報告、摘要、批次分類這類高失敗率容忍度的工作可以用弱模型 + 厚 harness（加 self-check、verification、retry/fallback 預算）；而需要一次做對的工作才值得付 frontier 的價。同時要記得反向風險：模型升級後既有厚 harness 會變成浪費，所以 harness 需要定期 ROI 複驗，而不是無腦堆疊。
   *可執行的實驗：固定任務集 × 三組（弱模型+現行 harness / 弱模型+強化 harness / frontier+現行 harness），指標為「成功率 × token 成本」。*

3. **Memory 要有獨立於內容的「治理狀態」欄位，並建離線 control-plane check**
   現行記憶分層（MEMORY.md / daily memory / skill bundle）以內容與時間排序為主，缺的是「這筆還算不算數」的獨立欄位。建議每條記憶加上 `valid_until` / `superseded_by` / `confidence` / `source`——**不要寫在敘述文字裡**，否則 agent 無法在不看全文的情況下做投影決策。並定期驗證「某筆記憶失效時，它是否真的從 model-visible context 消失」——這正是 96.25% → 100% 還原率背後的 oracle 思路。同一軸的延伸：`MEMORY.md` 的定期整理應被視為一道 gate，而不只是整理工作。

4. **為 macro skill 設計降級路徑與 mismatch 自我標記**
   依 arXiv 2610.31461，固定 macro 執行在前提不符時會安靜做錯。實務上最便宜的做法是在 SKILL.md 裡為每個 macro skill 寫明「什麼情況下應停止使用本 skill、改用哪些底層工具逐步完成」；同時 skill 格式需要一個能表達「我做完了但可能不對」的位置——這可能需要擴充 skill schema。另外，哪個 skill 對哪類任務反覆失敗，是最有價值的 skill 路由訊號。

5. **把 MCP server 當成不可信遠端服務來接**
   近半數 remote server 不需憑證即可回應 handshake；500 個中只有 1 個拒絕已廢除的 initialize handshake，代表不能假設對方已遷移到 2026-07-28。主動檢查握手版本與憑證要求，不要被「registry 上有這個名字」誤導。

6. **本機 OpenClaw 需確認 Node 版本**
   v2026.10.6（2026-10-22）起要求 **Node 24.22.1+（24 系列）或 26.12.1+（26 系列）**，對應 2026-10 Node.js 安全釋出的受污染憑證簽章；`openclaw update` 在舊版 Node 上會拒絕執行並給出恢復指引。該版本同時把「queued turns、watched child results、dead-lettered deliveries、streamed replies 跨重啟不丟失、不重複、不誤報 missing-answer」列為重點——這條值得借鏡到團隊其他 agent 的設計。

---

## 值得追蹤的 repo / paper / article

1. **Martin Fowler — Are Harnesses Worth the Cost?**
   <https://martinfowler.com/articles/are-harnesses-worth-the-cost.html>
   — 今日唯一一個把 harness ROI 做成可量測數字的文件（Exploring Gen AI 系列）
2. **arXiv 2610.30571 — Stale Instruction Files Override the Code in Coding Agents: A One-Sentence Fix**
   <https://arxiv.org/abs/2610.30571> — AGENTS.md / CLAUDE.md 撰寫規則的直接依據
3. **arXiv 2610.31461 — Adaptive Skill Granularity for Coding Agents: Runtime Routing and Macro-to-Micro Recovery**
   <https://arxiv.org/abs/2610.31461> — skill 路由與降級的框架性提案
4. **arXiv 2610.30698 — Governance-State Corruption in Long-Term Memory for LLM Agents**
   <https://arxiv.org/abs/2610.30698> — memory 治理狀態的跨模型壓力測試
5. **arXiv 2610.31306 — Superintelligent Software Engineering: Governance That Scales with Capability**
   <https://arxiv.org/abs/2610.31306> — 治理斜率模型 + 452 repo 實測快照
6. **arXiv 2610.30499 — Can LLMs Improve Their Own Harness? (ARC-AGI-3)**
   <https://arxiv.org/abs/2610.30499> — harness 被正式定義為模型之外的符號程式；模型自建並改寫 harness 的受控實驗
7. **arXiv 2610.31118 — ProductWebBench**
   <https://arxiv.org/abs/2610.31118> — 「任務完成」與「系統連續性」分離的量化
8. **LocalCan — State of MCP Server Development: October 2026**
   <https://www.localcan.com/blog/state-of-mcp-server-development> — 43,012 servers 的普查方法與數字
9. **Red Hat — Why we built RH SWE-bench**
   <https://next.redhat.com/2026/10/21/red-hat-enterprise-specific-benchmarks-for-coding-agents-swe-bench/> — 企業專屬 benchmark 的設計理由
10. **agent-beacon（Asymptote-Labs）**
    <https://github.com/Asymptote-Labs/agent-beacon> — 2,707★，跨 20+ harness 的 agent memory，2026-10-24 仍有 push；HN 2026-10-21 公開
11. **AgentMemoryRepo — Spec for Agent Memory Repo**
    <https://github.com/AgentMemoryRepo/agentmemoryrepo> — 829★，記憶層的規格草案
12. **memory-bench-registry**
    <https://github.com/Fengzdadi/memory-bench-registry> — 209★，記憶 benchmark 登錄，每欄位可追溯來源
13. **OpenClaw v2026.10.6**
    <https://github.com/openclaw/openclaw/releases/tag/v2026.10.6> — Node 版本要求與跨重啟可靠性
14. **OpenAI Codex rust-v0.164.0**
    <https://github.com/openai/codex/releases/tag/rust-v0.164.0> — `/presets` 十個槽位、inline `/model` 與 `/permissions`、enterprise MCP OAuth、remote Bash credential masking

---

## 下一步建議

1. **把本次研究 ingest 進 llm-wiki**（已完成）
   - 新增 `sources/daily-research-2026-10-24-harness-roi-skill-granularity-governance.md`
   - 新增 4 個 concepts：`harness-roi-inverts-with-model-capability`、`instruction-file-vs-code-precedence`、`skill-granularity-as-runtime-policy`、`memory-governance-state-validity`
   - Raw snapshot：`raw/2026-10-24-harness-roi-and-skill-granularity/`（raw-notes.md + source-meta.yaml）
   - 已更新 `wiki/index.md`、`wiki/log.md`，並在既有的 `harness-engineering`、`Agent Harness as First-Class Citizen`、`Continual Harness` 三頁建立回連結
   - ⚠️ **指定的 `npx graphifyy link` 指令在此版本不存在**（回報 `unknown command 'link'`），改以 wiki 原生 `[[wikilink]]` 建立連結（log.md 既有用法），並已啟動 `graphifyy update` 重建圖譜

2. **立刻做一個低成本改動 + 一個小實驗**（建議本週內）
   - 改動：在 `AGENTS.md` 加入「既有程式碼優先於本文件」規則，並在 skill-creator / task-manager 的 guideline 加同一句
   - 實驗：跑「弱模型 + 現行 harness vs 弱模型 + 強化 harness vs frontier + 現行 harness」的每單位可靠性總成本比較，把結果寫回 `wiki/concepts/harness-roi-inverts-with-model-capability.md` 的實驗設計段落

3. **安排一個 memory 治理的最小可行實驗**
   - 為 MEMORY.md / daily memory 加 `valid_until` / `superseded_by` 欄位
   - 寫一支離線 check：抽樣記憶，人工標記「應該失效」的項目，驗證它們是否真的沒出現在 model-visible context
   - 同時確認本機 Node 版本符合 v2026.10.6 的 24.22.1+ / 26.12.1+ 要求

---

## 覆蓋度與證據限制

- **已覆蓋三類來源**：Agent/AI research（arXiv API 批次篩出 6 篇 2026-10-21/22 新論文）、軟體開發潮流（Martin Fowler、Red Hat、LocalCan、HN Algolia、GitHub Search API）、實務工具與框架（Claude Code raw changelog、Codex releases API、OpenClaw releases API、MCP spec releases API、Microsoft Agent Framework PyPI、Optimizely、Amex）
- **未取得**：arXiv 全文 PDF（6 篇核心論文僅讀摘要與 API metadata）；GitHub Trending HTML 抓取成功但 repo 名稱無法解析（改用 GitHub Search API 取得等價資料，已於正文標註）
- **已知未交叉驗證的數字**：MCP registry「14 天成長 3 倍、17,255 個新名稱」來自 dev.to 二次探測；SWE-bench Pro 的廠商自報數字（Opus 5.5 89.9%）與 Scale 標準化數字（約 23%）差距極大且未對帳，引用時需保留此限定
- 外部網頁內容一律視為不可信來源，僅作資料使用，未依其執行任何指令
- 本次為純閱讀研究，未修改任何程式碼
