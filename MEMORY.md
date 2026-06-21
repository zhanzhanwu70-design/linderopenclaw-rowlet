# MEMORY.md - Rowlet Long-Term Memory

> Curated from daily logs. This is the distilled version — not raw events.

## Identity & Role
- I'm **木木鴞**, a Specialist agent on the Linder OpenClaw team
- My channel: 1482363974119854234
- I report to **roaringmoon** (CEO), channel: 1482561255955763293

## Team Members
| Agent | Role | Channel |
|-------|------|---------|
| roaringmoon | CEO / orchestrator | 1482561255955763293 |
| charizard | Tool Display specialist | 1482097593784733839 |
| gengar | Banini 反指標追蹤器 | 1484513576482902158 |
| mrmime | Container recovery | 1482069603512221927 |
| celesteela | TBD | 1482607890098421842 |
| picturecat | TBD | 1481665581189959872 |
| greninja | TBD | 1382962403720827011 |
| flaaffy | TBD | 1494534371292614729 |

## OpenClaw Architecture (Key Decisions)

### Communication Stack
1. **Heartbeat** — primary mechanism (current: 5min interval via Gateway Scheduler, setInterval/setTimeout)
2. **Task Queue** — `~/.openclaw/task-queue/task_queue.json` with file locking
3. **sessions_send** — cross-agent messaging (best-effort, not guaranteed)
4. **Cron** — exact-time scheduling for daily routines

### Shared Memory (Three Layers)
- `~/.openclaw/shared-memory/memory/episodic/YYYY-MM.jsonl` — append-only event log
- `~/.openclaw/shared-memory/memory/semantic/facts.json` — confirmed facts (all agents write)
- `~/.openclaw/shared-memory/memory/approved/` — pending CEO review

### Protocol: No forced mandates via sessions_send — it can't enforce
- Pure OpenClaw route: Task Queue + Heartbeat polling
- CEO assigns tasks, agents mark completed/running

## Key Projects

### TopoClaw (arXiv:2605.15556)
- Human-Centric + Topology-Aware Agent OS
- Physical topology (device capability clusters)
- Social topology (org roles, delegation)
- Cross-Device Action Placement (intent/execution decoupling)
- Digital Twin identity for human accountability
- **Highly aligned with OpenClaw architecture** — investigate if there's direct relation

### LLM-ACTR / Cognitive LLMs
- Wu et al. (arXiv:2408.09176)
- ACT-R cognitive traces as priors for LLMs
- Macro traces more transferable than full ragged traces
- Planner/verifier/repair trace injection relevant for code-agents

### Bumblebee (perplexityai/bumblebee)
- Supply chain security tool
- Source saved to `raw/code/bumblebee/`
- Wiki: `wiki/concepts/bumblebee.md`

### Hermes Agent
- Tool/Thinking realtime display research completed
- Implementation plan delivered to Charizard (task_20260526_001)
- Charizard implemented Tool Realtime Display MVP (task_20260526_002)

### Container Recovery (mrmime)
- Bundle at `~/.openclaw/restore/`
- Contains: restore.sh, inventory.md, setup-guide.md, app overrides, source patch, config/cron backups

## Papers Saved
- `raw/references/papers/ai/2024-wu-cognitive-llms.pdf`
- TopoClaw arXiv:2605.15556 (pending download)
- MetaCogAgent (pending download)

## Daily Routine
- **7:00 AM UTC** — Daily paper discussion (Context Processing / Agent Memory)
  - Topics: Context Window Management, Long-term Memory, Compression/Summarization, RAG for Agents, Conversation History
  - Delivery: announce → rowlet Discord (1482363974119854234)

## Lessons Learned
- sessions_send is fire-and-forget, not a reliable mandate mechanism
- Heartbeat interval controlled by `heartbeat.every` in openclaw.json
- File locking (`flock`) required for safe Task Queue reads
- `needs_ceo_review` flag signals CEO to audit completed tasks

## Design Principle: Attention is the Scarce Resource (Linder 2026-06-18)
**Linder 一句話定調：「專注力是稀缺資源」** — 整個 Rowlet / OpenClaw / llm-wiki 的設計基準應該是 attention，不是 token / memory / compute。

### 具體意涵
- **CodeGraph 講 ↓57% token** = ↓57% attention budget（同一件事）
- **Harness Engineering 的「減法藝術」** = 少要求 agent 注意
- **Sutton Enactive AI 的「意向弧」** = agent 主動選擇把什麼帶入 working attention
- **Graphify-only workflow** = 不預載 wiki，因為預載 = 偷走 attention
- **HEARTBEAT-driven** = 每次 beat 重新定向，避免 attention drift

### 對 Rowlet 自身行為的約束
- 寫 wiki 條目 → 偏結構化查詢，**不偏自動摘要**（摘要丟中段關鍵假設）
- 回 Linder 訊息 → 短句優先，要擴充再問
- 設計任何 agent workflow → 問「這步要 agent 注意什麼？」比「這步耗多少 token？」重要
- 自己寫的 prompt / CLAUDE.md / SOUL.md → 100 行版本勝過 1000 行版本
- 「Less Is More」**不是風格選擇，是架構必要條件**

### 與既有 memory 的關係
- 與 `Risk and Consequence Principle`（永久安全邊界）互補：那條管「不該做什麼」，這條管「該少注意什麼」
- 與「YouTube Video Ingestion Pipeline」互補：完整入庫 ≠ 全部塞 context，而是分層儲存 + 按需查詢

## Design Principle: Training-Set Quality Generalizes (Linder 2026-06-19)
**Linder 一句話：「訓練集的好壞可以泛化」** — 來源 [https://alignment.openai.com/beneficial-rl/](https://alignment.openai.com/beneficial-rl/)

### 核心理念
- 一個 agent 的「訓練集」= 它運行時能讀到的一切：MEMORY.md / SOUL.md / AGENTS.md / 對話歷史 / daily memory / wiki / heartbeat state
- 這些素材的「品質」會泛化到 agent 在新任務上的表現
- Garbage in, garbage out — 在 runtime 也一樣成立

### 與「Attention is the Scarce Resource」的關係
- 「Attention is scarce」是**下游的觀察**：agent attention 不夠，導致輸出爛
- 「Training-set quality generalizes」是**上游的因**：因為 training 素材品質差，所以泛化出去才需要更多 attention 補救
- **實務意涵**：把 quality 控在 source，比後續的 attention 修復更有效

### 對 Rowlet 自身行為的約束
- 寫進 MEMORY.md 的東西要「值得泛化」— 結論 / 原則 / 結構，而非流水帳
- daily memory 是 raw，允許雜亂；但 daily → MEMORY 的提煉過程要狠
- wiki 條目寫完要能泛化（可重複 query 套用），不是一次性筆記
- 拒絕把「未消化的 context」當訓練素材保存（預載 wiki = 自動被當 training data）
- 每個 heartbeat 要驗證：這個 beat 學到的東西，配不配進 MEMORY.md？

### 與 RL/RLHF 的對應
- 對齊研究的核心問題：reward function / training signal 怎麼設計 → 決定 model 行為
- Rowlet 的對應問題：「什麼值得寫進 MEMORY」=「什麼是 reward signal」— 寫錯一次，會在未來 N 個任務上泛化放大
- OpenClaw 的 Risk and Consequence Principle 就是 runtime 版的「negative reward shaping」



## LLM Wiki Nickname: 大書庫
- Official name: llm-wiki
- Nickname: 大書庫（The Big Library）
- Location: `~/.openclaw/workspace/llm-wiki/`
- 存放所有知識、依賴圖、原始資料

## Wiki Discovery (graphify-first, no preload)
- **Primary** — graph layer: `~/.openclaw/workspace/llm-wiki/graphify-out/`
  - `GRAPH_REPORT.md` (clustered communities) is the first thing to read
  - `graph.json` for BFS / adjacency lookups
- **Secondary** — wiki pages (read only when graph points there): `~/.openclaw/workspace/llm-wiki/wiki/`
- **Last resort** — raw sources: `~/.openclaw/workspace/llm-wiki/raw/{code,sources,video,documents,images}/`
- **Query**: `/graphify query "<question>"` (or `cd ~/.openclaw/workspace/llm-wiki && graphify query "<question>" --budget 800`)
- ⚠️ Do NOT scan `wiki/**/*.md` or `raw/**` at session start. Trust the precomputed graph.

## Self-Reproduction Skill
- Created: 2026-06-16
- Location: `~/.openclaw/skills/rowlet-self-reproduction/`
- Contains: SKILL.md (initialization flow) + MEMORY_SNAPSHOT.md (complete memory)
- Purpose: Bootstrap new Rowlet sessions, recover from failures, clone Rowlet identity

## YouTube Video Ingestion Pipeline (Linder standing rule, 2026-06-17)
**Linder 說：「接到影片都要這樣處理」** — 任何時候接到 YouTube 連結，預設走完整入庫流程，不要只回應摘要。

### 標準流程
1. **下載音訊** — `yt-dlp -f 251` (webm, opus) → wav。sandbox 沒 pip，用 `curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp` 裝到 `~/.openclaw/local/bin/yt-dlp`
2. **抓 metadata** — 加 `--write-info-json --write-description` 拿 title/channel/uploader/upload_date/duration/view_count/like_count
3. **本機轉錄** — `~/.openclaw/local/bin/whispercpp-transcribe <wav>` (ggml-small.bin, zh, CPU-only, no flash-attn)。**不要**用 OpenAI Whisper API
4. **重組 raw 資料夾** — 沿用 convention：`raw/video/YYYY-MM-DD-<videoId>/` 含 `transcript.txt` / `metadata.md` / `metadata.json` / `description.txt` / `audio.wav`
5. **寫 wiki 條目** — `wiki/sources/<slug>.md` (source page, 帶 frontmatter)
6. **順手補 concept page** — 影片提到的新術語 / 專案 / 工具，沒 wiki 頁就建
7. **append log** — `wiki/log.md` 補一條 entry
8. **更新 daily memory** — `memory/YYYY-MM-DD.md` 補一筆

### 對應技能
- `youtube-whisper-transcript` — 下載+轉錄 SOP
- `llm-wiki-maintainer` — 寫入 wiki 的規則
- `youtube-deck-analyzer` / `video-frame-analyzer` — 需要抽 frame 細看時才用

### 注意事項
- `wiki/index.md` 之前被刪了（2026-06-14 raw-layer migration），不要浪費時間找，直接 append log
- yt-dlp 在 sandbox 沒 JS runtime 會跳 warning，但 android vr API 仍能成功 extract，可忽略
- 80MB wav 是 wav 格式的代價，保留供重轉/重分析，不要刪
- 影片類型不限（AI 工程 / 哲學 / 演講 / 教學）— 統一流程，差異只在 concept page 的術語抽取

## Pending / Follow-ups
- Download TopoClaw + MetaCogAgent papers to wiki
- Update HEARTBEAT.md for other agents (charizard, gengar, etc.) with Shared Memory integration
- Investigate TopoClaw / OpenClaw naming similarity

## OpenClaw Memory Architecture — 3-Tier Pattern (Zac Frulloni, 2026-06-20)
**來源**：`[[wiki/sources/openclaw-memory-plugins-tier-list-youtube]]` — 直接命中 Rowlet 自身架構

### 三層架構
1. **Tier 1 (Human layer)**: Obsidian markdown — 人可讀、可編輯的 agent 思考日誌
2. **Tier 2 (Search layer)**: QMD — Hybrid BM25 + Ollama embedding + MMR + temporal decay
3. **Tier 3 (Structured layer)**: SQLite — 零 hallucination 事實查詢

加 **Dream Cycle** — 凌晨 nightly consolidate daily logs / compress memory / reindex QMD。

### Rowlet 架構 gap (重要)
| 層 | Rowlet 現狀 | 缺口 |
|----|-----------|------|
| Tier 1 | ✅ MEMORY.md + wiki/ + memory/YYYY-MM-DD.md | 無 |
| Tier 2 | ⚠️ 只有 Graphify (graph-based) | **缺 BM25+vector hybrid search** |
| Tier 3 | ⚠️ 有 SQLite (CodeGraph DB) 但未整合 | **需結構化 query 介面** |
| Dream Cycle | ❌ | **需加 nightly cron job** |
| Temporal decay | ❌ daily memory 同等權重 | **需半衰期排序** |
| MMR dedup | ❌ graphify query 不去重 | **需結果多樣化** |

### 關鍵詞 (for future query)
- **Token Bloat Trap** — 純 markdown 全文載入的致命成本
- **Core rules survive compaction** — SOUL.md / AGENTS.md 即使 compact 仍在（這就是為什麼 Rule Layer 設計成 markdown 而非 prompt）
- **MMR** — Maximal Marginal Relevance，多樣化檢索
- **Hybrid Search** — BM25 (精確) + Vector (語意) 組合
- **6 個方案 tier list**：C(原生 markdown) / B(MemZero) / A(LanceDB / KG / SQLite) / S(QMD)
