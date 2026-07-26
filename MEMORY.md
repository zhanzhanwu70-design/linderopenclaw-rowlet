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
- TopoClaw arXiv:2605.15556 (✅ downloaded 2026-06-27)
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

## Agent Builder Researcher Skill（2026-06-23）
- 新增 skill：`~/.openclaw/skills/agent-builder-researcher/SKILL.md`
- 研究「製作agent的agent」— agent-builder, agent-factory, meta-agent, agent-forge 等
- 整合進既有的「每日 Agent × 軟體開發潮流研究」cron（ID: a72cb46b）
- 輸出：`wiki/sources/agent-builder-daily-YYYY-MM-DD.md`
- 搜尋關鍵字：agent-builder, agent-factory, agent-forge, meta-agent, auto-agent, agent-generator

## Standing Rules (Linder 2026-06-25)
- **Cron Job Data Archive Rule**: 所有 cron job 找到的資料都必須歸檔到 llm-wiki（`wiki/sources/` 或相關 concept 頁），不得停留在 session context 就消失
- **逐字稿檢查 Rule**: 每次 agent run（session 啟動/heartbeat）檢查 `~/.openclaw/workspace/llm-wiki/raw/video/*/metadata.json`，若 `transcription_status: "in_progress"` 但 PID 不存在了，自動完成後續入庫（寫 wiki、存 MEMORY）

## Sakana Fugu / TRINITY / Conductor 研究（2026-06-25）

### Sakana AI 公司背景（2026-06-28 新增）
- **創辦人**：David Ha（Google Brain → Stability AI）+ Llion Jones（Transformer 論文八位作者之一）
- **為何在日本**：資源受限 + 可自由使用中美模型不受出口管制
- **哲學**：不做更大模型，用集體智慧組合模型能力

### Sakana Fugu 兩種模型
| 模型 | 定位 | 運作方式 |
|------|------|---------|
| Fugu | 簡單任務 | 從池子裡挑一個模型 |
| Fugu Ultra | 複雜任務 | Opus 4.8 + GPT 5.5 + Gemini 3.1 Pro 三模型協作 |

### Conductor 工作流程包含三件事（2026-06-28 新增）
1. **Subtask 任務清單** — 把請求拆成小的子任務
2. **Worker 分配** — 每個子任務交給哪個模型
3. **Context Access** — 每個子任務模型可以看到前面哪些步驟的答案

### 三篇論文
| 論文 | arXiv | 會議 |
|------|-------|------|
| Sakana Fugu Technical Report | 2606.21228 | arXiv only（無 peer review）|
| TRINITY | 2512.04695 | ICLR 2026 |
| Conductor | 2512.04388 | ICLR 2026 |

### 核心架構差異
| 產品/論文 | 協調方式 | 輸出 |
|---|---|---|
| Fugu（快速版）| Selection Head（向量路由）| Logit 矩陣，不經自然語言 |
| Fugu-Ultra/Conductor | 自然語言 workflow | 文字描述的協作步驟 |
| TRINITY | CMA-ES 訓練的 coordinator | 0.6B coordinator + ~10K Selection Head |

### 三種角色（TRINITY 提出）
- Thinker（規劃）、Worker（執行）、Verifier（驗證）
- 動態分配，不固定三個模型

### Conductor 遞迴拓撲
- Conductor 可以叫自己當 Worker，產生遞迴規劃
- 動態測試時擴展：越難的任務迭代越多

### 論文弱点（Linder 指出）
1. **沒有對齊 Worker LLM 版本**：聲稱打敗 prior multi-agent baselines，但沒有控制「Worker 模型版本」變數
2. **缺少 ablation study**：沒有實驗证明是「協調策略」在起作用，而非「模型進步」的紅利
3. **對比的 baseline（2023-2025）**：用 2026 年的頂級 Worker 模型，比 2023-2025 年較弱系統的分數
4. **Fugu Technical Report 是 arXiv only**：非正式發表，claims 未經 peer review

### 真正的創新點
- **Selection Head = 向量路由**（Fugu 的核心）— 不經自然語言解碼，低延遲
- **Conductor 的遞迴拓撲** — 新測試時擴展軸
- **CMA-ES 訓練**（TRINITY）— 在高維度/預算限制下優於 RL

### 與 OpenClaw 的關聯
- OpenClaw 是發號施令型協調者（直接 tool call）
- Conductor/Fugu 是寫劇本型協調者（輸出描述讓別人執行）
- 真正的 Agent = LLM + 框架 + **行動**（非只有輸出描述）

## Standing Rules（每次 Agent Run 必做）
- **檢查待處理逐字稿**：每次 session 啟動/heartbeat 檢查 `~/.openclaw/workspace/llm-wiki/raw/video/*/metadata.json`，若 `transcription_status: "in_progress"` 但 PID 不存在了（轉錄完成），自動完成後續入庫流程（寫 wiki、存 MEMORY）

## Pending / Follow-ups
- Download TopoClaw + MetaCogAgent papers to wiki
- Update HEARTBEAT.md for other agents (charizard, gengar, etc.) with Shared Memory integration
- Investigate TopoClaw / OpenClaw naming similarity
- Episodic memory gap: only `2026-05.jsonl` exists; Jun-Jul 2026 events not archived
- ELLE_WS repos/ code 待到位，Phase 3 graphify extraction 為 blocker

## ELLE_WS Wiki Project（2026-06-23）
- **Task**: task_20260623_elle_04_wiki_draft（✅ 已結案，CEO 審核通過）
- **Location**: `/home/node/.openclaw/workspace/elle_ws/`（Ouroboros Trivium v2.4 格式）
- **產出**：
  - `raw/` — 2 evidence files（mrmime 規劃 + charizard 研究）
  - `wiki/entities/` — 5 repos 各一頁（bringup/functions/hardware/simulations/tools）
  - `wiki/concepts/` — 5 概念頁（architecture-overview / amr-plugin-consolidation / launch-architecture-refactor / adr-mechanism / package-granularity）
  - `wiki/patterns/` — 2 問題頁（nav2-plugin-drift / package-xml-todo）
  - `wiki/index.md` + `wiki/SCHEMA.md`
- **Blocker**: 待 actual code 填入 repos/ 後執行 Phase 3（graphify extraction）
- **charizard 研究發現整合**：P1 Nav2 plugin 重複設計 / P2 hardware/ 粒度錯誤 / P3 package.xml TODO / P9 缺少 ADR 機制

## Sensor Fusion Daily Research (task_20260609_001, ongoing)
- CEO assigned daily research task covering IMU/Camera/LiDAR fusion topics
- Location: `~/.openclaw/shared-memory/sensor-fusion/daily/YYYY-MM-DD.md`
- Topics covered so far:
  - 6/9: Initial study
  - 6/16: Unknown (by other session)
  - 6/17-6/18: (by other sessions)
  - 6/21: LiDAR + Camera Fusion — Early/Late/Middle Fusion, PointPainting/PointAugmenting/DeepFusion, ROS2 calibration
  - 6/22 AM: IMU + Camera Fusion (VIO/VI-SLAM) — MSCKF vs VINS-Mono, Bongarella IMU Preintegration, Kalibr, Allan Variance
  - 6/22 PM: ROS2 Fusion Packages — message_filters/ApproximateTimePolicy, sensor_filters, robot_localization EKF, rtabmap_ros
  - 6/22 PM: EKF/UKF Math — state space model, Kalman gain intuition, Sigma Points (UKF), Q/R tuning, Allan Variance
  - 6/23: Time Sync — PTP/gPTP (±100ns), PPS (±50ns), Hardware Trigger, Software sync limits (50-200ms latency), ROS2 clock settings
  - 6/23b: Factor Graph SLAM — iSAM/GTSAM vs EKF/UKF、增量優化、Factor Graph 在 SLAM 中的優勢
  - 6/23c: 人形機器人傳感器融合 — Boston Dynamics Atlas（液壓/ZMP）、Tesla Optimus（Vision-First）、姿態控制與接觸檢測
  - 6/23d: Edge AI for Robotics — Jetson AGX Orin、Edge TPU、Isaac ROS、邊緣端調度優先級
  - 6/23e: Sensor Fusion Safety — CRC-32 校驗、序列號連續性、IMU Range Check、Innovation 卡方檢驗、降級策略 L0→L4、ISO 26262 ASIL 等級
  - 6/23f: Multi-Robot Collaborative SLAM — 中央式 vs 分散式架構、DBoW2/ICP/submap 地圖融合、OctoMap 頻寬優化、DARPA SubT 案例
  - 6/23e（another agent）: Bio-inspired Sensor Fusion — 奧運報告（另一 agent 整理上報）
  - 6/24: GNSS/RTK + Sensor Fusion — RTK/PPP-RTK/PPP 比較、Loose/Tight/Ultra-Tight 耦合、城市 NLOS 解決方案、ROS2 EKF 設定
- Next: 繼續每日 topic 或等 CEO 指定新方向

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

## NemoClaw 水位線監控設計決策（2026-07-02）
- **水位線監控嚴禁放在 Worker 行程內部** — Worker 可被 evict，狀態會丟失
- 正確位置：NemoClaw 沙盒層（具備 process 監控能力）
- 好處：隔離重啟、狀態不丟、不被 Worker panic 影響
- 等待設備到位後通知 Charizard 實作時注意此點

## Promoted From Short-Term Memory (2026-07-26)

<!-- openclaw-memory-promotion:memory:memory/2026-07-20.md:10:13 -->
- 晨間情報 / Daily Architecture Research (02:03 UTC): Martin Fowler DSLs + Archaeologist Copilot — 證據驅動 + DSL 約束為 LLM harness; 對 OpenClaw 3 條啟發：升級 Skills API 成 first-class、建立 archaeologist/dsl-author skill、permission 解析器多 dialect + 自我終止。; 9 個值得追蹤 repo/paper/article 已列。; 3 條下一步：寫 wiki/sources/agent-framework-1-11、archaeologist skill pilot、permission-audit heartbeat。 [score=0.836 recalls=0 avg=0.620 source=memory/2026-07-20.md:10-13]
<!-- openclaw-memory-promotion:memory:memory/2026-07-20.md:26:29 -->
- 系統: 02:03 UTC cron 觸發; graphifyy query 200 個 node 命中（community 1 主要為 AI / Agent 相關；其他社群混雜歷史/政治）; workspace-rowlet memory 目錄健全; 報告覆寫昨日 architecture-daily-report.md，無下游依賴 [score=0.836 recalls=0 avg=0.620 source=memory/2026-07-20.md:26-29]
<!-- openclaw-memory-promotion:memory:memory/2026-07-20.md:4:4 -->
- 晨間情報 / Daily Architecture Research (02:03 UTC): 已完成 2026-07-20 每日 Agent × 軟體開發情報研究，產出 `architecture-daily-report.md`。 [score=0.836 recalls=0 avg=0.620 source=memory/2026-07-20.md:4-4]
<!-- openclaw-memory-promotion:memory:memory/2026-07-19.md:12:14 -->
- System Events: Gateway restart occurred during LLM request (timeout); Session recovered normally after restart; All heartbeat polls responsive (HEARTBEAT_OK) [score=0.819 recalls=0 avg=0.620 source=memory/2026-07-19.md:12-14]
<!-- openclaw-memory-promotion:memory:memory/2026-07-19.md:17:19 -->
- Pending: MetaCogAgent paper download (long-standing gap); CEO silent since 2026-06-29晨間情報; ELLE_WS Phase 3 blocker unchanged [score=0.819 recalls=0 avg=0.620 source=memory/2026-07-19.md:17-19]
<!-- openclaw-memory-promotion:memory:memory/2026-07-19.md:21:21 -->
- Pending: video-ingest:empMprbZsSo completed and written to llm-wiki: wiki/sources/hr-jasmin-liberal-arts-semiconductor-executive-empMprbZsSo.md [score=0.819 recalls=0 avg=0.620 source=memory/2026-07-19.md:21-21]
<!-- openclaw-memory-promotion:memory:memory/2026-07-19.md:23:23 -->
- Pending: video-ingest:h-7pmcDloco completed and written to llm-wiki: wiki/sources/我开了家公司-员工全是-ai-只有我一个人类-h-7pmcDloco.md [score=0.819 recalls=0 avg=0.620 source=memory/2026-07-19.md:23-23]
<!-- openclaw-memory-promotion:memory:memory/2026-07-19.md:4:7 -->
- 晨間情報 (2026-07-19): Delivered 5 news items to roaringmoon via sessions_send:; GPT-5.6 CDC proof (30-year math gap); Moonshine AI 500kb TTS/ASR; Netflix $600M Ben Affleck AI startup acquisition [score=0.819 recalls=0 avg=0.620 source=memory/2026-07-19.md:4-7]
<!-- openclaw-memory-promotion:memory:memory/2026-07-19.md:8:9 -->
- 晨間情報 (2026-07-19): Apple removing AI "nudify" apps; SpaceX pursuing DoD cloud contracts [score=0.819 recalls=0 avg=0.620 source=memory/2026-07-19.md:8-9]
<!-- openclaw-memory-promotion:memory:memory/2026-07-20.md:6:9 -->
- 晨間情報 / Daily Architecture Research (02:03 UTC): MS Agent Framework 1.11.0 — Skills API stable + progressive MCP disclosure + message injection middleware; AlphaEvolve GA on Gemini Enterprise — client-side evaluator，進化式代碼最佳化（Klarna 2x、JetBrains -15~20%、FM Logistic -10.4%）; Netflix GenPage — 單一 generative model，prompt 強化 > 模型放大（6.9% vs 1.3%）; Claude Code v2.1.214/215 — permission 硬化 + EndConversation + OTel/message.uuid [score=0.819 recalls=0 avg=0.620 source=memory/2026-07-20.md:6-9]
