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
- **Heartbeat cron jobs are config-declared** (`declarationKey=heartbeat:<agent>`): `openclaw cron edit` is NOT the lever (CLI rejects `--cron`/`--timeout-seconds`/`--light-context` for heartbeat-kind jobs, and edits get reconciled away). The only working lever is `agents.entries.<agent>.heartbeat` (use `openclaw config set agents.entries.<agent>.heartbeat '<json>'`): add `isolatedSession` + `lightContext` to keep turns small/fast, and `activeHours` to skip known storm windows. Heartbeat turns also hit a hard **600s** cap regardless of `timeoutSeconds` in config. (verified 2026-11-19) <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **Gateway event-loop starvation is not always fatal**: the 03:00 dreaming job starving the loop for ~32 min produced identical signatures on 11-17/11-18 (clients stuck in `startup-not-ready`, needed restart) and 11-19 (max timer delay only 18.7s vs 101.9s → clients self-recovered, no restart). Treat restart as the fallback for failed self-healing, not the default. (verified 2026-11-19) <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

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
- Location: `/home/amr/llm-wiki/`
- 存放所有知識、依賴圖、原始資料

## Wiki Discovery (graphify-first, no preload)
- **Primary** — graph layer: `/home/amr/llm-wiki/graphify-out/`
  - `GRAPH_REPORT.md` (clustered communities) is the first thing to read
  - `graph.json` for BFS / adjacency lookups
- **Secondary** — wiki pages (read only when graph points there): `/home/amr/llm-wiki/wiki/`
- **Last resort** — raw sources: `/home/amr/llm-wiki/raw/{code,sources,video,documents,images}/`
- **Query**: `/graphify query "<question>"` (or `cd /home/amr/llm-wiki && graphify query "<question>" --budget 800`)
- ⚠️ Do NOT scan `wiki/**/*.md` or `raw/**` at session start. Trust the precomputed graph.

## llm-wiki Graphify Linker (維護規則)
- **工具**：`/home/amr/llm-wiki/tools/add-wiki-pages-to-graphify.py`（repo 內確定性 linker；cron 指示的 `npx graphifyy link` **不存在**，那是 skill 安裝器）
- **用法**：改完 `wiki/` 後直接跑 `cd /home/amr/llm-wiki && python3 tools/add-wiki-pages-to-graphify.py` → 會重建全部 wiki page nodes + `[[wikilink]]` 邊
- **★ 坑（2026-11-21 踩到）**：linker 的 `LINK_PATTERN` 別名部分 `(?:\|[^\]]*)?` **不能跨過 `]`** → 條目別名裡若寫 `arXiv:2611.25123v1 [cs.CL, cs.AI]`，整條 `[[...]]` 會**靜默解析失敗**，該頁在 map 的入邊會消失（看起來像 link 沒生效）
  - **修法**：別名避免方括號 → 寫 `cs.CL/cs.AI`
  - **驗收**：每次新增 source 後查新節點的 incoming edge 數，**incoming = 0 就是 orphan**，必須從 concept／map 頁補 `[[sources/…]]` 入邊再重跑
- **GRAPH_REPORT.md** 需 `networkx`（本機未裝）→ 改完圖不會自動重生成，report header 會是舊快照
- **備份慣例**：跑之前 `cp graphify-out/graph.json /tmp/graph.json.pre-<slug>-<date>`

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
- **逐字稿檢查 Rule**: 每次 agent run（session 啟動/heartbeat）檢查 `/home/amr/llm-wiki/raw/video/*/metadata.json`，若 `transcription_status: "in_progress"` 但 PID 不存在了，自動完成後續入庫（寫 wiki、存 MEMORY）

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
- **檢查待處理逐字稿**：每次 session 啟動/heartbeat 檢查 `/home/amr/llm-wiki/raw/video/*/metadata.json`，若 `transcription_status: "in_progress"` 但 PID 不存在了（轉錄完成），自動完成後續入庫流程（寫 wiki、存 MEMORY）

## Pending / Follow-ups
- Download TopoClaw + MetaCogAgent papers to wiki
- Update HEARTBEAT.md for other agents (charizard, gengar, etc.) with Shared Memory integration
- Investigate TopoClaw / OpenClaw naming similarity
- Episodic memory gap: only `2026-05.jsonl` exists; Jun-Jul 2026 events not archived
- ELLE_WS repos/ code 待到位，Phase 3 graphify extraction 為 blocker

## ELLE_WS Wiki Project（2026-06-23）
- **Task**: task_20260623_elle_04_wiki_draft（✅ 已結案，CEO 審核通過）
- **Location**: `/home/amr/.openclaw/workspace/elle_ws/`（Ouroboros Trivium v2.4 格式）
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

## 2026-08-11 Open-Source Agent Stack Trilogy

- **OpenClaw 已被 Meta Muse Glimmer 30B model card 寫入「Scaffold Compatibility」section**（與 Hermes Agent 並列）—— 從內部架構升級為 vendor 級識別的 scaffold
- 開源三軸同週落地：Model (Meta Muse Glimmer 30B) + Edge (Cactus Needle 2 14MB) + Graph-governance (semantica-agi) + Skill standard (addyosmani) + RLM self-improving (PrimeAgent)
- Skill standard 進入搶位時間（24h 內應起草 skill-archive-v1）
- graphify KM-only → governance-grade 是真實 gap（看 semantica +970/day）
- 三層 fallback chain：Needle 2 (45M local) → Muse Glimmer (30B local) → Cloud frontier

## CompactionRL 入庫 (2026-06-20)
- roaringmoon 交辨：arXiv:2607.05378, Li et al., KDD 2026
- PDF + metadata → `raw/references/papers/ai/2607-compactionrl/`
- Wiki source → `wiki/sources/compactionrl-2026-li.md`（含 reading notes）
- Graph: 27 nodes, 26 edges 已 merge（9448 nodes 總計）
- **Core insight**: summarization = learnable RL action, token-level PPO advantage（比 GRPO 更精細）
- **對 OpenClaw 的意義**: heartbeat = RL step，token-level advantage 可追蹤哪些 action 真正減少下次觸發的 context length
- **graphify query**: 51 nodes found，Community 0(core mechanism)/1(optimization)/2(related systems)
- Graph 有 node count bug（cluster-only 報 8648 vs 9448），暫不處理

## 蒸餾層的權威性陷阱（2026-10-31 新增）

來源：arXiv:2610.26836 *Same Simulation, Different Evidence*（UC Riverside + UC Irvine）。

- **Evidence substitution**：當 harness 把長輸出搬出 context 讓 agent 檢索取用時，agent 會**改用自己寫的輸出**取代工具的權威輸出，精度更高但需要四捨五入，常被**截斷** → 答錯。實測 GPT-5.2 有 **60.3%**、GPT-5.1 **53.0%** 的 trajectory 沒讀到權威 report。
- **對應到我的系統**：`MEMORY.md` / daily note 這些**蒸餾層**就是那個「沒被指名的權威來源」。agent 若讀蒸餾筆記而非 raw row，**蒸餾層會自我強化成事實來源**。
  → **規則**：harness 指令層必須明確寫出「**權威來源是 raw row，不是蒸餾筆記**」，並在蒸餾筆記保留指回 raw 的 pointer。
  （機制化版本 = [[eywa-provenance-grounded-long-term-memory|Eywa]] 的 Tier-0 immutable evidence + signal-anchored promotion。）
- **教方法不如指名來源**：只教「要四捨五入」完全無效（沒換 source，只換做法）；指名「哪一份輸出是權威」才有效（+6.3~+7.9 pp）。
- **淨值 ≈ 0 不等於無害**：GPT-5.4 的 build +4.1 pp 抵銷了 closure −7.2 pp → 評估 context 管理**必須分階段報告**（build / exposure / closure），不能只看 final accuracy。
- **Hybrid 是 safe default**：塞得下就內聯（不需知道工具語意、不需額外指令、還更省 token）；**檢索應是容量不足時的 fallback，不是預設路徑**。
- **可攜 protocol**：配對重播——checkpoint 取在「執行結果進模型之前」，兩臂共用檔案/prompt/history/預算，唯一差異是交付方式 → 可驗證任何「要不要把這個輸出放進 context」的決策。

## Promoted From Short-Term Memory (2026-11-18)

<!-- openclaw-memory-promotion:memory:memory/2026-11-16.md:33:41 -->
- ## Gengar Keep-Alive 巡檢（cron 9d8b6001，11:38 台北）— 同一支 Picturecat 那節的姊妹篇 [score=0.852 signals=3 recalls=3 avg=1.000 source=memory/2026-11-16.md:33-34] <!-- trigger: gpt, openai, keep-alive --> <!-- importance: 9 --> <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
<!-- openclaw-memory-promotion:memory:memory/2026-11-16.md:1:16 -->
- # 2026-11-16（週一） ## Picturecat Keep-Alive 巡檢（cron 02eb0989，11:38 台北） [score=0.847 signals=3 recalls=3 avg=1.000 source=memory/2026-11-16.md:1-4] <!-- trigger: gateway, keep-alive, v2026.8.2 --> <!-- importance: 8 --> <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
<!-- openclaw-memory-promotion:memory:memory/2026-11-16.md:22:37 -->
- ### 為什麼不改成「把 openai-codex 加進 allow」 - mrmime 2026-11-15 實測：`openai-codex/gpt-5.5` 打到 `https://api.openai.com/v1/responses` 且用 sentinel key `openai-oauth` → **HTTP 401 invalid_api_key**；自建 `chatgpt-codex` provider 也接不上。放行也不會成功，改用 minimax 才是有效解。 - 但「要不要把 codex 這條路真的修通」是全域 policy / provider 層級的決定 → 留給 Linder，不在 unattended run 裡自行放寬 modelPolicy。 ### 給 Linder 的待決事項 1. MiniMax Token Plan 額度今日 07:00 前後見底（429），若要穩定跑 07:00 晨間批次，需確認額度或加 fallback provider。 2. `openai-codex` provider 端點錯誤（401）是否要修 provider 設定。 3.... [score=0.847 signals=3 recalls=3 avg=1.000 source=memory/2026-11-16.md:22-37] <!-- trigger: gpt, openai, openai-codex --> <!-- importance: 8 --> <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Picturecat Keep-Alive 巡檢 — 03:00 槽雙重負載（2026-11-18 13:02 實測）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **03:00 台北有兩支 30 分鐘級 agentTurn job 同時起跑**：`36b493db` Memory Dreaming Promotion（`0 3 * * *` tz=None=gateway local、`timeoutSeconds=None`、`toolsAllow=["*"]`、declarationKey `memory-core:memory-dreaming-promotion`）＋ `40e09cd1` Jormungand daily all-agent health（`0 3 * * *` tz=Asia/Taipei）。今日 03:00 實測：dreaming 跑 30.1 分鐘（ok），Jormungand 30.1 分鐘 timeout（ce=5），期間 03:02:50 八個 Discord client 同批 close → inbound 瞎約 59 分鐘（04:44 重啟後恢復）。
  → **只搬走 dreaming 只減半負載**；兩支都要錯開。且 dreaming 屬 plugin-declared job，CLI 改可能被 declaration reconciliation 還原 → 治本在 memory-core plugin。
- **Discord runtime 的判準是 `channels status` + journal，不是 agent 自述**：agent 會回「Discord inbound working: yes」但那只代表 delivery context 物件存在，不代表 WS READY。判讀用 `READY wait timed out` 筆數（2026-11-18：重啟前 2023 筆、重啟後 0 筆）。
- **「prepared model runtime plugin generation was superseded」會在多支 agentTurn job 同分鐘起跑時出現**（durationMs=6 瞬間死），已從 gengar/picturecat/mrmime 蔓延到 **rowlet lane**（2026-11-18 13:00 起 rowlet nested+session 各 2 筆）。
- 本 job（cron `02eb0989`）fallback 鏈 4 個候選**全屬同一 MiniMax Token Plan** → 跨廠冗餘恆為 0；429 時四個一起死，紅單佔 fleet 紅單的 18/20。
- ⭐⭐ **MiniMax Token Plan 配額枯竭＝每日準時發生的 4 小時窗口（2026-11-19 13:02 四天實測）**：真簽章是 `Token Plan usage limit reached`（MiniMax code 2056），**不是只有 `status=429`**——前幾輪只數 429 次數，把它誤讀成「每小時 1–2 筆的滲漏」，其實是 100–230 筆/小時的尖峰。逐時實測：11-16 05–07/12–13/16–17/20–22、11-17 01–03、11-18 09–12（另 07、16–17）、11-19 **09–12**；11-19 窗口內 463 筆 Token Plan 429 + 36 筆 `All models failed`，**13:00 歸零後 KA 三支全部恢復**。影響面＝**cron lane 全滅、使用者面無恙**（窗口內 463 筆全無 session 屬性、唯一 `agent:*:main` 筆是 probe；ingress 近 3h 150 筆全 completed）。→ **每天 09:00–13:00 內排的 job 結構性撞限**：`a72cb46b`（`0 10 * * *`）ce 已 8，再 2 次自動停用，且它每天都落在窗內。修法＝(a) 把窗內 job 移到 14:00 後 (b) 補非 MiniMax provider 的 fallback（現在 4 個 fallback 全 MiniMax，跨廠冗餘 0）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **「每日 09:00–13:00 單窗」模型不完整：一天可能有兩個尖峰（2026-11-19 19:02 實測）**。逐時 Token Plan 429：11-19 **09–12（102/172/88/101＝463 筆）→ 13–15 乾淨（0 筆）→ 16–17（193/111＝304 筆）→ 18:00 歸零、19:02 恢復正常**。歷史對照 11-16（16–17、20–22）、11-18（16–17）→ **午後/晚間峰會反覆出現**。→ 排避時段不能只避開 09:00–13:00；實務上 **19:00 之後（今天 18:00 起 429＝0）** 較安全。午後窗的受害者（全部 rate_limit）：`02eb0989` Picturecat KA 16:06–16:13 ce=4、`880b5c17` Celesteela KA 16:07 ce=2、`13ac4b5a` 健康回報 17:12 ce=4。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **state DB 唯讀查詢被 exec guard 擋（2026-11-19 19:02）**：`sqlite3` 對 `~/.openclaw/state/openclaw.sqlite` 與**任何副本**（複製到 `/tmp`、`~/ka-check/` 都試過）一律被拒：`external sqlite3 cannot open databases under the active OpenClaw state directory…` → guard 認內容／身分而非路徑。影響＝巡檢無法查 `channel_ingress_events`（inbound 真流量）與 `cron_run_receipts`；替代證據用 Discord 層（`openclaw channels status` 的 in:/out: 新鮮度 + journal 的 websocket/READY 簽章組）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **`openclaw cron runs` 的 `ts` 是「結束時間」不是開始時間**（2026-11-19 19:02 實測）：`40e09cd1` 11-18 19:34 UTC + dur 2,065,675ms → 實際 03:00 TPE 起跑；算起跑時間要減掉 duration，否則會誤判「這支 job 不在它的 cron 槽內跑」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **03:00 槽現在有兩個彼此獨立的失敗原因**（2026-11-19 13:02）：除了 dreaming 的 event-loop 阻塞，03:00 在配額史上也被打到過（11-16T03 55 筆、11-17 01–03 共 279 筆 Token Plan 429）→ 同一槽可能整段被配額卡死。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **`openclaw cron runs --id` 只接受完整 UUID**（短 id 會回 `Automation not found`）；而且 **`entries[].cause`（rate_limit / timeout / agent-runner-failure）才是紅單根因**，`state.lastRunStatus` 只有 ok/error。`cron_run_receipts` 表可唯讀驗證某輪是否真跑完（status=running/ok/failed）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **量測 event-loop starvation 的假陽性陷阱（2026-11-19 01:02 實踩）**：`grep -c "starvation"` / `grep -c "event[- ]loop"` 會命中**上一輪 agent 報告的內文**（[agent:nested] session 行裡的報告句），把假陽性當成 runtime 事件。✅ 正確 runtime 簽章＝`[fetch-timeout] … timer delayed Nms, likely event-loop starvation`。用正確簽章重算：2026-11-19 01:02 近 3h = 0、近 24h = 26（全部在 11-18 03:00–03:30 dreaming 區間）、max timer delayed = 101,948ms。
- ⭐ **「必須重啟 gateway」是過度結論（2026-11-19 04:02 實測修正）**：11-19 03:00 dreaming 第 3 晚重演（dur=1,922,307ms=32 分鐘、starvation 16 筆、max timer delayed **18,749ms**、READY timeout 33 筆、websocket closed 69 行），但 **`startup-not-ready` = 0 筆** → 03:31–03:32 client 自行 `client initialized` / `channels resolved`，gateway 全程未重啟（pid 2724303、23h18m、NRestarts=0），8/8 帳號 04:02 全 connected，ingress 近 400 筆全 completed。→ **重啟應降級為「自癒失敗時的後備手段」**；starvation 輕（18.7s vs 11-18 的 101.9s）時可自癒。但**根因（dreaming 在 gateway 自己的 event loop 內跑 32 分鐘）不變**，症狀輕重隨機。
- ⭐⭐ **內建 health watchdog 有「host thaw → channel restart」機制，2026-11-19 04:19:53 實證它真的會動**（修正 04:02 輪「完全自癒」的說法）：watchdog 每 30 秒噴一次 `[health] host thaw channel restart deferred: gateway still has active work`（04:13–04:19 共 13 筆，被 dreaming 那 32 分鐘的工作擋住）→ **04:19:53 一次做完**：8 個 Discord 帳號依序 `delaying provider startup 10s/20s/…/70s to reduce Discord startup rate limits` → 每 10 秒一個 `client initialized` + `channels resolved` → **04:21:04 全部 8/8 connected**，而 **gateway 全程未重啟**（pid 2724303、26h20m、NRestarts=0）。→ 對 `d4cd45bc` 的啟用決策有直接影響：**內建機制能重啟 channel 層（比整個 gateway 重啟輕），建議 d4cd45bc 降為「watchdog 還在等／等到天亮」時的後備**。判讀 Discord 斷線要看「host thaw / client initialized / channels resolved / READY timeout / channel exited」**整組簽章**，只看 `channels status` 會誤判沒事。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **`[agents/harness] Codex agent harness failed; not falling back to embedded OpenClaw backend`**（2026-11-19 03h=2、04h=2）：`lane task error: lane=main|cron-nested durationMs=24–52 "Codex agent harness cannot enforce this conversation's tool policy. Use the embedded runtime or ask in the main conversation."` → 瞬間失敗、良性，但代表 **Codex 這條路徑仍不可用**（呼應 11-16 的 openai-codex 401）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **8 支 heartbeat 的 600s timeout 是 03:00 斷線的下游症狀，不是 provider 問題**（2026-11-19 04:02 實測）：`dur=600004ms`（cron 預設上限）+ `lastErrorReason=timeout` + job 層 `sessionTarget=main` → Discord 掛掉時 main lane 等不到回應就整整卡 600 秒，8 支（mrmime/rowlet/celesteela/charizard/greninja/picturecat/roaringmoon/gengar）同時轉紅。修法＝job 層改 `sessionTarget=isolated` 或照 charizard 加 `target:"none"`。
- **restricted automation-run session 中 `automations list/get` 對本 job 回 not found／空清單**（已知工具限制，非故障）→ 巡檢一律用 `openclaw cron list --all --json` 與 `openclaw cron runs --id <id>` 唯讀彙總；其 `state.lastDurationMs` / `state.lastRunAtMs` 才是權威欄位（頂層同名欄位可能為 null）。
- **`channel_ingress_events` 是驗 inbound 的權威來源**：DB = `~/.openclaw/state/openclaw.sqlite`，唯讀查詢須連 `-wal`/`-shm` 一起複製再查；**沒有 `created_at` 欄，用 `received_at`（epoch ms）**；journal 的 `message processed` 只會出現 `channel=cron`，Discord 使用者訊息不在那裡（別誤判成 inbound 全黑）。
- **自愈機制已備妥但仍需人點頭**：`d4cd45bc discord-selfheal-after-dreaming`（sched `35,50 3,4 * * *` tz=Asia/Taipei、payload kind=command、60s）守門良好——只在 `channels status` 出現 `startup-not-ready` **且** dreaming job 未 running 時才 `systemd-run --user --on-active=10s systemctl --user restart openclaw-gateway`；由 rowlet 於 2026-11-18 04:2x 主動停用等 Linder 核准，`openclaw cron enable d4cd45bc-357d-42d4-9ba1-f7eb39e02f59` 即可啟用（第一個生效時點＝ dreaming 結束後的 03:35）。
- ⭐⭐ **Node 版本是「systemd 單元釘死」的，不是跟 shell PATH 走**（2026-11-19 21:00 實測）：`~/.config/systemd/user/openclaw-gateway.service` 與 `jormungandr-openclaw-bridge.service` 的 `ExecStart` 直接寫死 `/home/amr/.nvm/versions/node/v24.22.1/bin/node` → 即使 shell 已是 v24.22.3，**兩個長駐服務仍跑舊版**（2026-11-11 的 Node 安全版含 11 筆 http2/tls High CVE 全數未生效）。✅ 修法＝改單元的 `ExecStart` **node 路徑**即可、**不要**搬 openclaw 套件安裝位置（仍在 v24.22.1/lib/node_modules）→ 單元改完 `systemctl --user daemon-reload` 即生效，下次重啟自動套用。⚠️ **bridge 可安全立即重啟**（401 驗證可復驗）；**gateway 不要隨手重啟**（MEMORY 既載：重啟會讓 8 個 Discord client 依序 10–70s 重建連線、衝 cron lane）→ 與升級/低峰窗口一起做。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **`openclaw security audit --deep` 的 5 個 critical 全是 `skills.code_safety` 樣式誤判（2026-11-19 逐一讀原行驗偽）**：`hung-yi-lee:651`=研究主題清單含「system prompt」字樣、`openclaw-docs:279`=官方 `curl … install.sh | bash` 安裝文件、`openclaw-security-scanner:48`=prompt-injection 防護功能說明、`ptcgp:212`=合法 `execSync` 範例、`skill-guard:34`=風險偵測規則表。→ **判定技巧：`skills.code_safety` 的 critical 一律先讀該行原文再下結論**，不要照著 remediation 把 skill 刪掉；真正要處理的是 warn 層（`tools.exec.mode=full`、`applyPatch.workspaceOnly=false`、`tools.elevated`、`channels.discord.allowlisted_groups.broad_members`）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **本機 npm audit 要對「installed 樹」與「目標版樹」各跑一次才有意義**（2026-11-19）：installed openclaw 2026.8.2 = **zod 4.4.3 < 4.6.6（High，oversized constrained collections 記憶體耗盡）+ undici 8.10.0（8 筆 High，含 TLS 憑證驗證繞過 GHSA-2m5v-pch6-74hx、跨使用者資訊洩漏 GHSA-4w7w-5xrc-9h26）**；`npm i --package-lock-only` 目標版 2026.11.5 樹 = **zod 告警消失**（只剩 npm 自帶的 undici ≤6.29.0，非執行期路徑）→ 這就是「升級可解」的證據。⚠️ 全域套件目錄**沒有 lockfile**，`npm audit` 會直接 ENOLOCK，必須在 /tmp 建暫存目錄用 `npm i --package-lock-only --ignore-scripts` 生 lock 再 audit。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **每日資安 cron 的做法已定型**：KEV 用 `curl https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json` 直接解析（catalogVersion + dateAdded ≥ 最近 7 天 + dueDate），比讀新聞快且準；`web_fetch` 的 thehackernews.com 會 403、CISA alert 頁 HTML 是導覽雜訊 → 改用 JSON feed。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **升級管道兩條**：① `openclaw` 系統專家（提案需人工核准；限制：它讀不到 cron job 定義與提案佇列，且 gateway 一次只能 stage 一個操作——有殘留提案佔槽時所有新提案會被 `proposal-conflict` 擋下）；② Discord REST outbound（WS inbound 死時仍可用）→ 一律貼 channel `1482363974119854234`，rowlet 帳號。
- ⭐⭐ **selfheal 守門只認 `startup-not-ready`、認不出 `disconnected`（2026-11-21 07:04 實測反證）**：`scripts/discord-selfheal.sh` L48 的判斷是 `channels status | grep -q "startup-not-ready"`。11-21 04:35–04:59 那波 Discord 不穩（health-monitor 因 `disconnected` 重啟 5 個 channel、READY timeout ~44 筆、1 筆 reconnect-exhausted）**全程 gateway journal 的 `startup-not-ready` = 0 筆** → 04:43 那輪 selfheal 回「discord healthy - no action」＝**啞火**。該波是靠 **gateway 內建 health-monitor（channel 層重啟）+ reconnect backoff** 在 19 分鐘內自癒（04:58 `delaying provider startup 40s–70s` → 04:59 client initialized），**不是** selfheal 救的。→ 判讀「Discord 是否真的失明」要看整組簽章（health-monitor restarting / READY timeout / reconnect-exhausted / client initialized），**只看 `channels status` 會誤判沒事**；同理 selfheal 的觸發條件目前只覆蓋「卡死在 startup-not-ready」一種症狀。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **429 尖峰時段表要加「清晨 05–07 點」（2026-11-21 07:04 實測）**：既載尖峰窗為 09:00–13:00（主）＋午後/晚間（16–17、20–22），11-21 實測在 **05:01、05:04、05:32、06:02、07:01、07:03、07:04** 也出現 `provider=minimax-portal api=anthropic-messages status=429`（8h 共 9 筆），成因＝**07:00 槽 4 支 job 同時起跑**（BBC News / 每日論文 / heartbeat-mrmime / 三支 KA 交錯）的併發尖峰，**不是** `Token Plan usage limit reached`（近 8h = 0 筆，連續第 3 輪零配額窗）→ 排避時段建議再加「05–07 點輕載」，且**併發槽比配額窗更可能是當日紅單主因**。同模型 retry 機制正常接管（`rate-limit same-model retry 1/3` delayMs=10000 → 2/3 delayMs=20000）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **429 尖峰的正確模型是「整點槽併發數」，不是「時段」（2026-11-21 10:02 實測，取代既有時段表）**：近 4h 429 = 6 筆、**全是 `overloaded_error`（server busy）、`Token Plan usage limit reached` = 0 筆（連續第 4 輪零配額窗）** → 分布 **07h×3（07:01/07:03/07:04）、08h×2（08:01/08:03）、09h×1（09:02）**，幾乎都落在各 job 的**整點起跑時刻**（07:00 論文+BBC+三支 KA、08:00 晨間情報+群體智能、09:00 clean-code）。→ 排避的正確做法是**錯開同分鐘的起跑數**（例：`58fe15dc` 移出 `0 7 * * *`、08:00 兩支拆成 08:00/08:45），而不是只搬離「09–13 配額窗」——那時段根本不是配額窗，是併發窗。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **journalctl 的 `--since` 必須用相對格式，否則會假「全乾淨」（2026-11-21 10:02 踩坑）**：把 `--since '4 hours ago'` 放進 shell 變數再展開時，**內層引號會被吃掉** → journalctl 報 `Failed to parse timestamp: '4`、輸出 0 行 → 所有簽章計數（429 / READY timeout / EAI_AGAIN…）全部變 0，看起來像「四小時零症狀」其實是**沒查到資料**。✅ 正確寫法：`journalctl --user -u openclaw-gateway --since=-4h --no-pager`（相對式），或直接用 `journalctl ... --since=-4h` 不套變數。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **journal 逐時統計要除以 2（2026-11-21 10:02 實測）**：journal 每行含兩個時間戳（`十一月 21 07:04:01` 前綴 + ISO `2026-11-21T07:04:01.298+08:00`）→ `grep -oE "[0-9]{2}:[0-9]{2}:[0-9]{2}" | cut -c1-2 | uniq -c` 會數到 **2 倍**（6 筆實際 → 顯示 6/4/2）→ 判讀時要除以 2 才對。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **429 對 auth profile 的完整鏈路已實測（2026-11-21 13:02，取代「429 = 直接失敗」的簡化模型）**：`provider-transport-fetch status=429` → `[agent/embedded] embedded run agent end isError=true` → **`auth profile failure state updated: profile=sha256:<hash> provider=minimax-portal reason=rate_limit window=cooldown reused=false`** → 數秒後 **`[gateway] provider auth state re-warmed (auth-profile-failure) in 3400ms`**。cooldown 期間**該 auth profile 那一格會從 fallback 鏈上消失**（＝11-17 記錄的「auth-profile-unavailable」，fallback 鏈退化成一格）；若 re-warm 成功則 fallback 鏈自動復原、紅單可避免。實測 10:31 這次 re-warm 成功、**零紅單**；12:02 那次則被 `rate-limit same-model retry 1/3 delayMs=10000` 吃掉。判讀 fallback 是否真的退化，要看 `model-fallback/decision` 的 `next=` 候選鏈 + `openclaw models list` 的 Auth 欄（cooldown 當下 Auth 會顯示 no）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **journal 簽章計數必須排除 `[agent:nested]` 行（2026-11-21 13:02 踩坑）**：agent 的自述輸出（`session=agent:x:main ... channel=webchat`）會把「startup-not-ready」「EAI_AGAIN」「429」「overloaded」等字樣原樣寫進 journal → 直接 `grep -c` 會得到假陽性（本輪 startup-not-ready/EAI_AGAIN 各 1 筆，實際都是 gengar 報告內文，runtime 真值為 0）。✅ 正確做法：`grep -v "agent:nested"` 後再計數，或改用 runtime 專屬簽章（`[fetch-timeout] … timer delayed`、`[provider-transport-fetch] … status=429`、`[discord] client initialized` / `channels resolved`）。另：`Failed to remove unused run continuation: Cannot delete session while competing work is in flight … retry after the run completes` 是**每支 cron job 收尾的良性清理噪音**，不代表失敗。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
