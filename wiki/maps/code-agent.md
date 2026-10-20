---
title: "Code-Agent Map"
category: map
type: knowledge-map
created: 2026-06-11
modified: 2026-09-02
---

# Code-Agent Map

此頁整理與 code-agent / tool-use agent 相關的論文與概念，特別關注 context processing、long-term memory、retrieval、workflow control。

## Agent Context Processing / Memory

### [[agentic-context-mgmt-dadhich-2026]] — lifecycle reframing of context management (2026-08-09)

**核心主張**：把 context management 當作「儲存問題」是錯誤框架。Production agent 每 turn 必須做出五個不同決定：記什麼、怎麼結構化、本次 context 放什麼、下 turn 需要什麼、超預算時怎麼辦。Store 只優化 write/read，**Context Management 是一個 lifecycle，不只是一個 store**。

**五個 Primitives**：
- **Architecting**：定義 memory 形狀（schema per agent type），而非用 universal fixed schema
- **Ingesting**：retrieval quality 由 ingest quality 決定
- **Scoping**：本次 context 的 relevance filtering
- **Anticipating**：proactive recall prediction
- **Compacting & Consolidation**：validated compression（帶 fidelity check），不只是 crud summarization

**經濟論證**：
- Naïve full-append: O(n²) token cost（每 turn 重讀全部歷史）
- Crude summarization: O(n) cost but **accuracy cliff**
- Validated compaction: O(n) cost with **preserved fidelity** ← 只有這個同時解決 cost 和 accuracy

**Scope Hierarchy**：從 individual user → team → organization，多 tenant 安全邊界 + context leakage 防止。

**對 Rowlet 的啟發**：三層記憶（SOUL.md / daily / MEMORY.md）正好映射到 lifecycle stages，但目前缺的是 **validated compaction** 的 fidelity check 機制。Heartbeat 寫入前的 trust gate（[[sirin-belikova-2026]] NLI check）正是填補這個空缺的方式。

### [[sirin-belikova-2026]] — contextual hallucination detection for RAG & memory agents (2026-08-07)

**SIRIN（Semantic Inconsistency Recognition and Inspection Nexus）**是一個統一工具包，專門檢測 RAG 系統和 memory-grounded agent 中的 contextual hallucination——模型產生流暢合理但與提供的證據不一致的回答。

**三大家族 detector 統一介面**：
- **Probing（白盒）**：訓練輕量分類器於 frozen LLM hidden states、attention maps、token probabilities
- **Uncertainty Estimation（黑盒）**：困惑度、語義不確定性、RAUQ 等信心估計
- **Judge-style（黑盒）**：用第二個模型做 NLI/alignment 事實性檢查

**核心創新**：統一的 inspection report schema — `D_θ(x) = (s, ŷ, E)`，其中 s ∈ [0,1] 為校準 hallucination 概率分數。支援兩種互補任務：(1) 事後 faithfulness check（答案是否忠於上下文）和 (2) 事前 answerability check（上下文是否足以回答問題）。

**Span-level localization** 是關鍵能力：不只給整體分數，還能定位到 unsupported text spans。在 SimpleMem 長期記憶系統中作為 faithfulness gate 展示。

**對我們的啟發**：Rowlet 的三層記憶同樣面臨 hallucination 累積風險——某 session 把細節記錯，後續 session 基於錯誤記憶推理。SIRIN-style 的 NLI-based faithfulness check 可用於 audit 記憶品質，或作為 heartbeat 寫入前的 trust gate。

### [[context-engineering-2025-mei]] — unified taxonomy of context engineering

**必讀 survey（166 pages, 1411 citations）**。將 Context Engineering 分為三大 Foundational Components：
1. **Context Retrieval and Generation**（prompt engineering、external knowledge retrieval、dynamic context assembly）
2. **Context Processing**（long sequence processing、self-refinement、multimodal/structured context）
3. **Context Management**（memory hierarchies、compression、optimization）

以及四大 System Implementations：RAG（modular/agentic/graph-enhanced）、Memory Systems、Tool-Integrated Reasoning、Multi-Agent Systems。

**核心 research gap（值得重視）**：Asymmetry Problem — LLMs 善於理解複雜 context，但生成同等複雜長文輸出的能力嚴重不足。

### [[onepred-chen-2026]] — recursive intent memory + next-query prediction

**核心問題**：Multi-turn 對話系統都是被動響應，next-query prediction 可以實現 proactive interaction。挑戰是 full-history 成本線性成長，而 current-turn 丢失跨 turn 上下文。

**OnePred 做法**：維持一個 bounded text memory（意圖鏈），由同一 LLM 遞迴讀寫。Memory max k tokens，per-turn 成本恆定。

**兩階段 RL curriculum**：Stage 1（Full-History RL）學「預測什麼」→ Stage 2（Agentic Memory RL）學「如何壓縮」。Stage 2 無法在沒有 Stage 1 的情況下學好（cold-start problem）。最終預測 reward 均勻 broadcast 到所有前序 memory-update steps，解決 delayed credit assignment。

**結果**：22× token 節省，9/9 cells 打敗 full-history baseline，Human 與 LLM-judge 排名一致。

**對我們的啟發**：Memory 應該主動重寫而非 append-only；課程學習 curriculum 可能是讓 agent 學會 context 取捨的關鍵；proactive prediction 可以用於 Rowlet 的 heartbeat 預先準備。

### [[memgpt-packer-2024]] — virtual context management

MemGPT 將 LLM context window 視為有限主記憶體，透過 working context、FIFO queue、recall storage、archival storage 與 function calls 進行 self-directed memory management。對 code-agent 的啟發是：不要把互動歷史當 append-only prompt，而要建立分層記憶與 paging policy。

關鍵概念：
- main context vs external context
- recursive summary + searchable recall storage
- memory pressure warning
- function chaining / heartbeat-style multi-step retrieval
- long-term conversational memory 與 large-document QA

### [[contextweaver-wu-2026]] — dependency-structured context

ContextWeaver 將 tool-use interaction trace 建成 dependency graph，避免 sliding window / semantic retrieval 丟失邏輯依賴。適合 SWE-Bench 類多步 coding agent 任務。

### [[memory-r2-yan-2026]] — training memory operations with LoGo-GRPO

**核心發現（2026-07-15 深讀）**：Memory-R2 解決的是「memory 使環境 non-stationary」導致 GRPO credit assignment 失效的問題。

**LoGo-GRPO 雙分支**：
- **Global branch**：全部 rollouts 正常 GRPO 比較，保留端到端學習
- **Local branch**：從同一 intermediate memory state 重新 rollout，比較乾淨（不被 earlier session divergence 污染）

**Chunk-wise construction**：session 再分 K 個 chunks，extractor + manager 交替運行，每個 chunk 是一個 step，長度正規化防止 bias。

**Progressive curriculum**：8→16→32 sessions 逐步擴展。直接 32-session 訓練 M-Fail 爆炸到 72.1%，有 curriculum 才 6.72%。

**亮點數字**：7B 模型 F1 50.60（vs Memory-R1 43.14），只訓練 2 個對話就能 zero-shot 泛化；3B F1 +36.5 points。

### [[organize-then-retrieve-2026-hsu]] — hierarchical memory navigation (HORMA)

HORMA 將經驗組織成檔案系統式階層結構，summarized entities 連結到 raw trajectories。區分「資訊遺漏導致失敗」vs「誤導/過載導致失敗」兩種 failure modes，用 RL-trained navigation module 選擇最小但足夠的 context。在長任務中僅需 22.17% baseline token 用量。

### [[ace-liao-2026]] — elastic reversible context orchestration (2026-07-19)

**核心貢獻**：提出 irreversibility 與 inflexibility 問題的根本解法 — 雙層架構（Message Maintenance Layer + Context Orchestration Layer）。Message Maintenance Layer 同時存 raw + abstract，永不覆寫；Context Orchestration Layer 每步動態重建，決定每條歷史訊息是 raw / abstract / drop。

**與其他方法的關鍵差異**：完全 training-free，以 external wrapper 套用到 4 種框架（ReAct、DeepAgent、WebThinker、MiroFlow），全部有 consistent 改善。

**對我們的啟發**：Lossless + reversible 的設計正是我們目前架構缺少的 — 目前 MEMORY.md / daily memory 的更新是 irreversible append/truncate，未來可以借鑒 ACE 的 elastic type 分配思路。

### [[lost-in-the-middle-2023-liu]] — empirical foundation: U-shaped long-context curve

Liu et al. (TACL 2023) 對 MPT-30B、LongChat-13B/16K、GPT-3.5-Turbo、Claude-1.3 做 controlled experiment，系統性展示 LLM 對 long context 的利用是 **U-shaped**：relevant information 放在 context 開頭或結尾表現最好，放在中段會掉到接近 random baseline。**Long-context fine-tuned model (LongChat-13B) 與 closed SOTA (GPT-3.5, Claude) 都不能免疫**。這篇是後續所有 selective retrieval / virtual context / memory paging 路線的經驗地基 — 它直接回答「為什麼我們不該把全部 history 塞進 context」。

## Synthesis

目前八篇形成一個互補堆疊（ACON 為第十三篇，見下）：

1. **Lost in the Middle**：經驗基礎 — 證明「context 越長 ≠ 表現越好」，U-shaped curve，middle 會被忽略。
2. **Context Engineering Survey**：統一 taxonomy，回答「整個領域怎麼分類」的問題。
3. **MemGPT**：runtime memory tiers + virtual context paging，直接繞過 stuffing。
4. **ContextWeaver**：dependency-aware selection，讓取回的 context 保留因果/邏輯結構。
5. **Memory-R2**：training-time credit assignment，讓 agent 學會更好的 memory operations。
6. **HORMA**：hierarchical organize-then-retrieve，用 RL navigation 選擇最小 sufficient context。
7. **ACE**：elastic reversible context orchestration，training-free wrapper，動態每步重建 context，最大化資訊密度。
8. **SIRIN**：contextual hallucination detection toolkit — 三大家族 detector 統一介面 + answerability 事前把關 + span-level 定位，是 RAG/memory agent 的 faithfulness infrastructure。

對 OpenClaw / Rowlet 類 agent，可映射為：

- `SOUL.md` / `USER.md` / `MEMORY.md`：高價值 working context / stable memory — 放在 prompt 開頭正好踩在 primacy bias 上。
- `memory/YYYY-MM-DD.md`：episodic recall storage。
- `wiki/sources/` 與 `raw/references/`：archival storage。
- Graphify / wiki query：retrieval layer — 直接回應 lost-in-the-middle：不把全部塞進 context，先 query 取出最相關少數 nodes。
- Cron / heartbeat / tool events：interrupt-driven control flow。
- RL-based context selection：未來可探索的方向。
- **Position engineering**：把 critical instructions 重複出現在 prompt 兩端（duplicate-the-edges）是抵禦 U-shaped curve 的便宜手段，值得實驗。

### [[trajwiki-sun-2026]] — Source-Grounded Memory Trajectories（2026-08-26 重讀 + 正式入庫）

**論文**：[TrajWiki: Source-Grounded Memory Trajectories for Long-Horizon Dialogue Agents](https://arxiv.org/abs/2608.00967)（arXiv:2608.00967, 2026-08-02, U Manchester 主導）
**詳細 source 條目**：`wiki/sources/trajwiki-sun-2026.md`
**狀態**：seed（2026-08-26 完成 deep-read + metadata + wiki/sources 落地）

**三層架構（重新對齊至更精準的命名）**：
1. **Provenance-Aware Memory Trajectory** — 每段記憶是一條 evolution trajectory，由 immutable episodic snapshots + claim-level operations（ADD/REVISE/DEPRECATE）維護。Git-like memory：commit / diff / blame 搬進對話記憶。
2. **Memory Wiki** — 持續 incremental compile trajectory 成 structured / interlinked wiki pages（entity / event / quantity / topic / conflict）。Persistent 中間層，**不取代 source evidence，只 organize**。
3. **Hierarchical Retrieval** — query 時走 `wiki page → linked trajectories → snapshots → source messages`，retrieval objective 同時優化 `b(q,T) + α·Δcov(T) − λ·red(T)`。

**核心數字**：
- LoCoMo Multi-hop Acc：GPT-4o-mini 30.22 (Full Context) → **35.39 (TrajWiki)**，對 Mem0 (30.56) 也有顯著提升。
- MedMT-Bench LCMU：78.56 vs Full Context 71.72；IC subset **17.68 vs 12.17 (Mem0)**。
- Counterfactual ablation 顯示 wiki + snapshot expansion 是 **必要組合**：Wiki-only 拿 gold ref cov = **0.000**；Flat-only unsupported risk = 0.918；完整 TrajWiki 0.645。
- Memory Wiki 把 candidate search space 從 130.4 → 55.6 trajectories（**2.35× reduction**）。
- 整體 cost：43.28M tokens（reusable 23.71M，query-time 10.84M，answer 6.92M）。

**與其他方法的根本差異**：
- vs **MemGPT**：paging-based memory management vs **provenance-based evolution trajectory**。MemGPT 不記「為什麼改變」，TrajWiki 記。
- vs **SelfMem**：inference-time self-reflection vs **persistent structured wiki + explicit revision operations**。
- vs **CompactionRL**：summarization as learned action vs **claim-level edit semantics**（ADD/REVISE/DEPRECATE as first-class operations）。
- vs **A-MEM**：link-level provenance vs **claim-level provenance** — TrajWiki 知道哪個 claim 被修訂，A-MEM 只知道 note 被連結。
- vs **ACE**：raw+abstract dual-layer reversible orchestration vs **explicit history of evolution + version of claims**。

**對 OpenClaw 的直接啟發**（補 2026-08-26 重新對齊）：
1. **Memory revision 要變成 explicit operations**：目前 `MEMORY.md` / daily memory 是 append + overwrite 混合，沒有區分「新增 vs 修訂 vs 廢棄」。可借鑒 git-like model：修訂時保留 predecessor + delta、廢棄時 mark `deprecated_at` 但保留 snapshot。
2. **Graphify 下一代可考慮 evolution snapshot**：現有 graph node 偏向 static entity-relation，沒有 claim-level revision history。借鑒 TrajWiki 為每個 node 加 immutable snapshot + ADD/REVISE/DEPRECATE 語義。
3. **Hierarchical routing 直接套到 `/graphify query`**：現有 query 是 flat top-k；可借鑒 `P_q = Top_t {S_p(q,p)}` 模式：先 route 到 community / wiki level（graphify 已有 community detection），再展開到 source-level。
4. **Diagnostic visibility 進入 heartbeat**：TrajWiki 把 unsupported-answer risk / trajectory drift / snapshot budget coverage 量化，可直接套到 Rowlet 寫入前的 trust gate（對位 [[sirin-belikova-2026]] 的 faithfulness check + [[agentic-context-mgmt-dadhich-2026]] 的 lifecycle view）。
5. **Trade-off 認知**：43M tokens 是 non-trivial 前置成本，但 reusable memory construction 佔 55%，long-running agent 場景 amortized 後 unit cost 下降。對每次 session 重新讀 SOUL.md 的 case 不適用。

## 新論文補充：LeanMem — 按資訊類型差異化儲存（2026-08-11 深讀）

**LeanMem (Liao et al., arXiv:2608.03463, 2026-08-04)** 帶來與其他方法最根本的不同切入點：**不是設計更好的 memory schema 或 retrieval algorithm，而是證明「不同資訊類型需要不同處理策略」這一原則**。

三類差異化 storage：
- **Profile memory**：穩定用戶屬性 → 緊湊結構化，不做 evolution
- **Event memory**：動態狀態變化 → 帶時間錨，selective evolution
- **Record memory**：密集細節 → 輕量 index + 指標回原始對話，preserving fine-grained evidence

**對 Rowlet 的直接啟發**：目前 daily memory 是 unified format，區分了日期但沒有區分內容類型。可以借鑒 LeanMem 的 insight：heartbeat 寫入時先判断「這段是 stable preference、evolving state 還是 dense detail」，然後用不同的 retention 和 evolution 策略處理。

Query-conditional evidence composition 也很有價值：目前的 graphify query 是 uniform，可以根據問題類型分配不同 context budget。

---

## 新論文補充：意圖鏈視角

現有七篇 + OnePred + ACE 形成九篇互補堆疊：

1. **Lost in the Middle**：U-shaped curve 經驗基礎
2. **Context Engineering Survey**：統一 taxonomy
3. **MemGPT**：runtime memory tiers + virtual context paging
4. **ContextWeaver**：dependency-aware selection
5. **Memory-R2**：training-time credit assignment
6. **HORMA**：hierarchical organize-then-retrieve
7. **OnePred**：recursive intent memory + two-stage RL curriculum
8. **ACE**：elastic reversible context orchestration（第一個 training-free、wrapper-style、每步動態重建的方案）
9. **SelfMem**：self-optimizing memory framework — 讓 agent 透過 feedback signals 自己探索、評估、改進記憶策略，而非跟隨預設格式

其中 ACE 與其他方法最大差異：**不需訓練、不改框架**。它不是另一種 compression 策略，而是把 irreversibility 問題的根本解法（雙層 lossless storage + elastic per-step orchestration）帶入所有框架。

其中 OnePred 與 HORMA 都解決同一底層問題（bounded context），但切入角度互補：HORMA 用 hierarchical organization + RL navigation；OnePred 用同一 LLM 遞迴更新意圖鏈 + 兩階段 curriculum 解決 cold-start compression problem。

SelfMem 與其他方法的根本差異：**所有現有方法（MemGPT、ACE、HORMA、OnePred）都是「給 agent 魚」——定義好 memory schema、retrieval rule、或 compression strategy，讓 agent 按照既定方式執行。SelfMem 是「教 agent 釣魚」——不給固定策略，只提供 memory tools + feedback signals，讓 agent 自己 discover better memory behavior。**

SelfMem 的 feedback 是可觀察的 tool outputs（非 gold answer / scalar reward），agent 在 language 層面 reason about quality–cost trade-offs。這與 Memory-R2 用 RL 解決 credit assignment 形成互補：SelfMem 不需要 training，是 inference-time optimization；Memory-R2 是 training-time learning。

### CompactionRL 補充：RL 訓練中第一個把 summarization 變成 learnable action 的方法

現有十二篇 + CompactionRL 形成十三篇互補堆疊（ACON 為第十四篇，見 ACON 章節）：

10. **SIRIN**：見上方第 8 項
11. **CompactionRL (Li et al., 2026)**：將 context compaction 整合進 RL training pipeline 的第一個方法。核心突破：**PPO over group-relative methods** — compaction 讓單一 rollout 變成可變數量、可變長度的 segments，GRPO 的 group normalization 無法處理，PPO 的 critic-based token-level advantage 才是正確框架。**Summarization as learnable action** — 任務執行動作和摘要動作在同一个 task-level reward 下聯合優化，壓縮策略不再是工程師設計的 heuristic，而是模型從 outcome feedback 學到的技能。

CompactionRL 與其他 training-time 方法的差異：
- vs **Memory-R2**：Memory-R2 訓練的是「何時更新記憶」，CompactionRL 訓練的是「如何生成摘要」。Memory-R2 解決的是 memory 使環境 non-stationary 的 credit assignment；CompactionRL 解決的是 compression policy 的 quality。
- vs **SelfMem**：SelfMem 是 inference-time optimization（不需要 training），CompactionRL 是 training-time learning（從 outcome feedback 端到端訓練）。
- vs **MemGPT**：MemGPT 是 system-level memory paging（固定 policy），CompactionRL 是 learnable compaction policy（模型自己學）。

**對 OpenClaw 的直接啟發**：Rowlet 的 heartbeat 本身就像一個 compaction trigger —— 每次 heartbeat 都做一個「壓縮 + 繼續」的動作，但目前的實作是 heuristic 的（固定的總訊息長度閾值）。CompactionRL 的啟示是：**如果我們能收集足夠的 heartbeat outcome data，就可以訓練模型自己學何時壓縮、怎麼壓縮**，而不只是靠固定規則。這需要 (1) 定義 task-level reward for heartbeat outcomes，(2) PPO-style 訓練框架。

**十四篇壓縮 / memory / retrieval 的總結補充**：ACON 進來後，這套堆疊的空白是「**如何把 compression 從工程師設計的 heuristic 升級成 learned module，且不污染 agent 本體**」。ACON 直接補上這個空白，且帶來三個前所未見的槓桿：(a) **model-agnostic**，對 API-only LM 也有效；(b) **equalizer**，小 model 受惠比大 model 多；(c) **distill-ready**，production cost 可控。

### [[hmem-llm-agents-sun-2025]] — Hierarchical Memory with Positional Index Routing (2025-07)

**核心主張**：現有記憶系統（MemoryBank 向量檢索、A-MEM Zettelkasten 網絡、MemGPT 分層）各有缺陷：向量檢索隨 entry 增加複雜度爆發；Zettelkasten 網絡維護成本高；MemGPT 在大規模資訊時準確度/效率取捨。H-MEM 的解決方案：**四層結構 + Positional Index Encoding**。

**四層架構**：
- Domain Layer（章）→ Category Layer（節）→ Memory Trace Layer（小節）→ Episode Layer（內容）
- 上三層是漸進式索引，最底層是實際事件

**核心創新 — Positional Index Encoding**：每層 memory vector 嵌入位置索引，指向下一層語義相關的子記憶。檢索時沿上層索引逐層向下，**不需要對所有記憶做 exhaustive similarity search**，大幅降低無關資訊參與。

**對比同類方法**：
- vs MemoryBank：解決向量檢索複雜度 O(n) 膨脹問題
- vs A-MEM：結構更簡單，沒有網絡一致性維護負擔
- vs MemGPT：不用 RAG trade-off，用 index routing 取而代之

**對我們的啟發**：Rowlet 目前三層（SOUL/daily/MEMORY）vs H-MEM 四層。核心差異在於**索引方式**：我們是手動/heuristic 的分層，H-MEM 是 learned positional index + 自動層級路由。graphify query 從 topic → category → concept 的分層路由設計，與 H-MEM 的層級索引思路一致，但目前仍是 top-down 搜索而非 index-guided 逐層路由。

### [[acon-2025-kang]] — Agent Context Optimization（2026-08-24 深讀）

**核心主張**：Compression 應該是一個 **learned module**，不是 agent 的一部分、也不是 heuristic。ACON 把壓縮 guideline 放在 **natural language space 優化**，**model-agnostic**，可直接套在 GPT-4.1 / Claude / Gemini 等封閉 API 上 — 完全不需 gradient access。

**方法（textual gradient on prompts）**：
1. 跑 agent **w/ 和 w/o compression** → 收集 `D_cont` = tasks where uncompressed 成功但 compressed 失敗。
2. Optimizer LLM（o3）看 `(H, H')` pairs → natural-language feedback（"Lost variable"、"Incorrect summary"、"Missing facts"）。
3. Aggregate feedback → 新 guideline `P^(1)`（**UT step** = utility maximization）。
4. Optional **CO step**（compression maximization）：只看成功 compressed runs，問「哪些資訊真的被用到」→ 更短的 `P^(2)`。
5. **Distillation**：teacher `(φ_T, P*)` 生 `(x, y)` pairs，cross-entropy（Kim-Rush）蒸進 Qwen3-14B/8B、Phi-4。保留 **≥ 95 % teacher accuracy**。

**為什麼選這篇**：
- **第一個把 compression 整個脫離 agent model 的 production-ready 方案**。ReSum、CompactionRL 都要改 agent 權重；ACON 不用。
- **Equalizer finding**：Qwen3-14B + ACON = +32.4 %（AppWorld）、+45.6 %（8-QA EM）。小 model **受惠更多**，壓縮縮窄了與大 model 的距離。
- **Compression as filtering**：8-QA 上 EM/F1 beats no-compression baseline → 壓縮不只是省 token，是 filter distraction。直接補 [[lost-in-the-middle-2023-liu]] 的 U-shape 谷底。

**對 Rowlet 的啟發**：
- **Textual gradient 是通用 primitive**：failure-driven prompt refine 不需 gradient access，可直接套到 Rowlet 的 cron / heartbeat workflow（例：失敗的 cron 任務 → 反思 prompt 是否讓模型在 long heartbeat log 上 lost-in-the-middle）。
- **Per-environment guideline schema** 勝 universal prompt — 直接對應 [[agentic-context-mgmt-dadhich-2026]] 的 **Architecting** primitive。
- **UT vs UTCO 是 deployable knob**：verbose env → UTCO；fact-critical env → UT。Heartbeat 場景 daily memory ingest 通常 verbose → 預設 UTCO；transcript lookup 偏 fact → 預設 UT。
- **Distill 是 mandatory**：Table 4 顯示壓縮省 token 但加 latency。Compressor 必須蒸餾成小 model，否則 latency 把 agent 拖垮。

**與同類方法的對位**：
- vs **CompactionRL**：ACON 改 prompt、CompactionRL 改 agent 權重。能改權重 → CompactionRL；只能 API → ACON。
- vs **MemGPT**：ACON 改「壓縮函式品質」，MemGPT 改「系統架構（paging）」。可疊用。
- vs **ACE**：ACE 是 wrapper-level reversible orchestration（不壓縮，動態 type 分配）；ACON 是 module-level learned compressor。互補。

### [[trace-2608.06503-min-2026]] — Boundary-Local Verifier for Execution-State-Preserving Compression（2026-09-17 新入庫）

**論文**：[TRACE: Toward Reliable Context Compression for Long-Horizon Agents](https://arxiv.org/abs/2608.06503)（arXiv:2608.06503v1, 2026-08-06, UVA + Nokia Bell Labs Applied Research）
**詳細 source 條目**：`wiki/sources/trace-2608.06503-min-2026.md`

**核心主張**：Recurrent context compression **不是 information loss 問題，是 execution-state mislocalization 問題**。Compression 系統性衰減 recent interaction 對後續決策的影響力，表現為 blocked actions / repeated exploration / multi-run instability。

**關鍵實驗發現**（AppWorld）：
1. **Summary 對 FIFO 的優勢只在 budget < 4K 時顯著**（72.8% vs 42.2% at 2K）—— 在 16K/8K/4K 等中等 budget 下兩者持平甚至 FIFO 微幅領先，因為 summary 犧牲 recency-continuity。
2. **Multi-run stability 比 single-run pass rate 更能反映 compressor 品質**：compression 把「可靠解掉」的任務變成「時靈時不靈」，P@2 與 Pass2 的 gap 隨 compression 增強而擴大。
3. **Termination disruption**：summary 會讓 agent 不知道任務已完成，反而繼續 acting（FIFO 在這點反而比 summary 好）。
4. **Recency attenuation**：raw update divergence 0.149 → compressed 0.233 → no update 0.289。Compression 把 recent interaction 的 behavioral effect 衰減 1.56×。
5. **Regressive exploration**：compression 後第一個 action 就多 0.108 blocked/error actions，且 refetch/replay marginal effect 在後續上升。

**TRACE 解法**：
- **Boundary-local verifier**：在每個 compaction boundary 跑 paired closed-loop continuations（PRE = 保留 raw context、POST = 用 summary），測量 `ΔG = E[G(τ_POST)] - E[G(τ_PRE)]`，分數 `Q = -ΔG`。
- **Frozen proposer optimization**：所有 model weights 凍結（compressor、downstream agent、proposer 都不改），只在 natural-language compression prompt space 優化。
- **Contrastive supervision**：12 stratified-sampled boundaries × 3 candidates → best/worst pairs。Proposer 收到 incumbent template + system prompt + contrastive pairs，但**看不到** rollout actions/observations/errors。
- **Audit-first proposer**：先檢查當前 policy 是否與下游 agent system prompt 矛盾，再產生修訂。
- **End-to-end selection**：boundary-local score 只用於構造 preferences；最終 selection 透過 dev split Pass2。

**SOTA on AppWorld**（168 tasks test-normal）：
| Method | Acc | Pass2 | Pass@2 |
|---|---|---|---|
| No compression | 85.7 | 77.4 | 94.0 |
| Best compressed baseline (Prompting-O) | 71.4 | 59.5 | 83.3 |
| **TRACE (MiniMax-M3 template)** | **77.1** | **67.3** | **86.9** |
| **TRACE → Kimi-K2.7-Code transfer** | **84.5** | **79.2** | 89.9 |

→ MiniMax-M3 優化的 template 直接 transfer 到 Kimi-K2.7-Code，**還贏過 no-compression**（+1.8 Acc, +5.4 Pass2）。證明學到的是 execution-state-preserving heuristic，不是模型特定 quirks。

**與同類方法的根本差異**：

| 維度 | ACON | CompactionRL | **TRACE** |
|---|---|---|---|
| 訓練 | none | RL (PPO) | none |
| 監督來源 | terminal success/failure contrast | outcome reward | boundary-local execution regression |
| 評估訊號 | end-to-end pass rate | end-to-end reward | per-boundary blocked + repeated actions |
| 可移植性 | 需在 target model 重新優化 | model-specific weights | natural-language template 可跨模型 |

**對 Rowlet 的直接啟發**：

1. **驗證自己的 compaction 品質**：Rowlet 的 daily memory compaction 是 heuristic。可以借鑒 TRACE 的 boundary-local verifier 對最近 N 個 heartbeat 跑 audit——同一個 task 在不同 compaction rendering 下 sample 多組 next actions，測量 divergence。threshold 觸發 re-summarization 或 prompt template swap。
2. **Position engineering 對 compacted summary 也適用**：Lost-in-the-middle 已經告訴我們 U-shaped curve。TRACE 額外告訴我們 compression 衰減 recency effect——對 Rowlet 這種「最近 tool result 最重要」的工作流尤其危險。**current task goal + most recent block + critical identifiers 必須放在 summary 的開頭跟結尾**。
3. **Proposer 設計的 portability**：audit-first → contrastive pairs only → end-to-end selector 三層分離是 blueprint。Rowlet 未來想自動優化 compaction prompt，這個分離可避免 proposer overfit 特定 instance。
4. **Cross-model transfer 是反 overfitting 的強訊號**：TRACE 跨模型還贏 no-compression，證明 template 學到的是 general heuristic。Rowlet 如果要做 prompt optimization，務必保留 cross-model test set。
5. **Pair-contrastive 監督比 scalar terminal reward 更 robust**：CompactionRL 用 outcome reward，會被 environment stochasticity 污染。TRACE 用 paired PRE/POST comparison 控制 frozen agent intrinsic variability——這對 heartbeat-style compaction audit 也適用。

**對 OpenClaw 啟發的工程提醒**（補 2026-09-17）：
- **Compression audit 應該是 OpenClaw runtime 的一部分**：目前 OpenClaw 的 compaction loop 沒有 quality gate。TRACE 證明 recurrent compression 在 long-horizon 上有累積退化效應。建議加 boundary-local audit（low-overhead sampling-based），多次失敗就 trigger template swap 或 re-summarize。
- **「summary 取代 transcript」是 implicit assumption，不是 given**：對位 [[agentic-context-mgmt-dadhich-2026]] 的 lifecycle view，compression 只是其中一個 primitive，需要 validated fidelity check。TRACE 的 verifier 就是實作 fidelity check 的具體方案。

**與其他方法的互補定位**：
- vs **ACON**：同屬 prompt-optimization 但 supervision 不同。TRACE 用 boundary-local，ACON 用 terminal outcome。TRACE 更精準但需要 paired rollouts（成本更高）。
- vs **CompactionRL**：都學 compression policy，但 TRACE 改 prompt、CompactionRL 改 agent weights。TRACE 適用 API-only LM。
- vs **ACE**：ACE 是 wrapper-level reversible orchestration（不壓縮，動態 type 分配），TRACE 是 module-level verified compressor。互補。
- vs **MemGPT**：MemGPT 改系統架構（paging），TRACE 改 compression 函式品質。可疊用。
- vs **Scroll**：Scroll 把決定 defer 到 query time（programmatic context），TRACE 把品質評估 local 化到 compression event。可疊用——Scroll 內部的 `ms.search` 結果可以再過 TRACE-style boundary audit。

### 對我們自己的工程提醒

根據 [[lost-in-the-middle-2023-liu]] 的 finding，目前架構有兩個潛在風險：

1. **Mid-prompt 衰減**：當 heartbeat 把 `memory/YYYY-MM-DD.md` + 多個 tool 結果 + wiki dumps 串進對話中段，重要的 earlier tool result 可能掉進 U-shape 谷底。
2. **Long-session 退化**：多 session 串接的 conversation，舊 session 的關鍵資訊一旦被新 session 推到中段，就會被模型忽略。需倚賴 [[memgpt-packer-2024]] 的 recall storage 或 [[organize-then-retrieve-2026-hsu]] 的 hierarchical summary 來主動 page-in。

3. **缺乏 reversible context management**：目前的 daily memory 是 append-only，wiki 是 static retrieval。[[ace-liao-2026]] 的啟發是：即使是我們的分層記憶系統，也可以借鑒「每步動態重建 context」的思路 — 不是用固定策略管理記憶，而是根據當前任務需求彈性選擇呈現形式（raw / abstract / drop）。這對 OpenClaw 的 heartbeat 整合特別有意義。

4. **缺乏 compression quality gate（補 2026-09-17）**：[[trace-2608.06503-min-2026]] 證明 recurrent compression 在 long-horizon 上有累積退化效應。OpenClaw 的 compaction loop 目前沒有 boundary-local audit，長期 session 可能 silently corrupt 重要 state（blocked action + repeated exploration 累積）。建議在 compaction loop 後加 sampling-based verifier（cost-aware version of TRACE-style paired PRE/POST）。

### [[2608.21690-scroll-programmatic-context-mgmt]] — Context as an Environment: Programmatic Context Management (2026-08-21)

**核心主張**：Context management 不應該是「保留什麼」或「如何摘要」，而是 **「讓 model 自己寫程式來構造 working view」**。Scroll 把 agent 的 session state 分解為 `S_t = (L_t, P_t, V_t)` — append-only Event Log + durable storage + persistent Python kernel — 把 lossless history 留在 prompt 外面，只讓 `print` 的結果進入 model context。

**與所有現有方法的根本差異**：傳統方法（MemGPT 分層 paging、ACON learned compressor、CompactionRL RL-trained summarizer、TrajWiki provenance tracking、LeanMem type-differentiated storage）都在做「**事先決定要保留什麼**」— 從 ingestion 或 compaction 階段就 commit 給某種 reduced representation。Scroll 是第一個把這個決定 **完全 defer 到 query time**，而且用程式碼來表達 retrieval policy：「policy = code」自動繼承 LLM coding 能力的提升。

**Session Environment 三元件**：
- **Event Log (L_t)**：append-only SQLite + BM25，每個 event 給 stable `seq` address — **ground truth**
- **Durable storage (P_t)**：大 payload 外移到 filesystem，小的 inline，lazy handle 延遲載入
- **Persistent Python kernel (V_t)**：sandbox、fail-closed、跨 model call 存活；typed namespace 把 tool output 變成 Python object 而不是 serialized text

**Model-facing surface（`ms`）— 4 operations**：
- `LOCATE`：`ms.search(query, k, ...)` → BM25 hits + seq addresses
- `MATERIALIZE`：`ms.expand(seq)` → verbatim recovery
- `COMPUTE`：ordinary Python + permitted DB/fs/tools（filter / join / aggregate 都在 kernel 做，不進 context）
- `EXPOSE`：`print(value)` → 只有這個進 model context

**Recoverable Eviction (Algorithm 1)**：當 `|c| > ρC`，先把 tool payload 折成 seq pointer（最便宜恢復），再 evict 整個 span。**Eviction 只改 view，不改 ground truth**。Eviction 出去的 span 透過 **headline index**（tiered，O(k log_k n) blocks）保留 anchor — model 可以 navigation 到 evicted region 而不是從頭 grep。

**Ablation 結論**（BEAM_10M）：Lossy summarization at ingestion → 19.9 分（**-73 分**），Scroll w/o REPL → -7.3，Scroll w/o index → -1.8。**Event Log 是最有價值的 component**，repl 第二，index 第三。

**SOTA results**：
- BEAM_10M：**73.1**（+5.1 over Exabase M-1 68.0）
- LongMemEval_S：**94.8**（接近 Exabase 96.4 / Mem0 94.4）
- LOCA_256K：**86.7**（**+37.4 over best published long-horizon agent**，Δ from 128K 只有 -2.6 vs CodeAct -4.0 vs Summarization -21.4）

**Cross-backbone finding**：所有 backbone 都能用 Scroll，但 LOCA_256K 上 Qwen3.8-Max 86.7 vs Qwen3.6-35B-A3B 22.7 = **64 point spread**。Long-trajectory 任務更依賴 multi-step query planning 能力。

**對 Rowlet 的架構 mapping**（這個值得特別 mark）：

| Scroll | Rowlet |
|--------|--------|
| Append-only Event Log | `memory/YYYY-MM-DD.md`（lossless daily record） |
| Tiered headline index | `MEMORY.md`（curated long-term） |
| Sandboxed Python kernel | OpenClaw session runtime |
| `exec` to construct working view | heartbeat-driven `/graphify query` + targeted `wiki/sources/*.md` reads |
| `print` selects observation | response shaping for current turn |

**直接的工程啟發**：
1. **不要再 heuristic 拼湊 context**：現在我每個 heartbeat 都把 daily memory + 多個 wiki dump + tool results 串進 prompt，實際上是 Scroll 所說的「naïve serialization」。可以借鑒：把 daily memory 變成可程式查詢的 source（每個 daily file 都有 stable date-keyed address + structured headline），然後 model 透過 `ms.search("memory about X", k=10)` 動態定位，再用 `ms.expand(date_range)` materialize 出 raw 內容。
2. **Headlines as navigation anchors**：MEMORY.md 目前是純文字 curated notes，可改造成 headline-anchored 結構 — 每個 entry 有 `[seq|date]` 標頭 + 一句 status，eviction 時 fold 成 index。對位 TrajWiki 的 snapshot model 但更輕量。
3. **Policy = code**：未來想從「human-curated graphify query 規則」升級到「model 自己寫 query script」，Scroll 是 blueprint。具體來說，heartbeat 階段可 spawn 一個 REPL cell 讓 model 寫 query code，而不是 human 寫固定 query。
4. **Distillation frontier traces**：未來如果想讓 Rowlet 的 smaller model instances 也具備 complex context management，可借鑒 Scroll 最後一段的「frontier model traces → SFT smaller models」— Qwen3.6-35B-A3B 在 Scroll 已經展示 cross-backbone 蒸餾路徑。
5. **解決「lost in middle」問題的根本方案**：Lost in the Middle (Liu 2023) 指出 mid-prompt 信息衰減；Scroll 透過「絕大多數 context 留在 prompt 外」直接繞過這個問題 — 只有 model 透過 `print` 明確選出的 projection 才進 prompt，這些都是 model 認為重要的，positioning bias 消失。

**與其他方法的互補定位**：

| Scroll 解決 | 互補方法 |
|------------|----------|
| Context construction = coding task（用 LLM coding 能力） | ACON 解決 compression quality（用 textual gradient） |
| Lossless history + targeted eviction | MemGPT 解決 memory paging（runtime tiers） |
| Query-time deferred decision | CompactionRL 解決 learnable compaction policy |
| Navigation via headline index | LeanMem 解決 type-differentiated storage |

### [[less-context-better-agents-2026-lodha]] — Stale-State-Aware Recency Pruning + Single-Pass Summary（2026-09-20 深讀）

**論文**：[Less Context, Better Agents: Efficient Context Engineering for Long-Horizon Tool-Using LLM Agents](https://arxiv.org/abs/2606.10209)（arXiv:2606.10209v1, 2026-06-08, Microsoft D365 F&O 團隊）
**詳細 source 條目**：`wiki/sources/less-context-better-agents-2026-lodha.md`

**核心主張**：對 tool-heavy 企業 agent workflow，**保留最近 5 個 tool call/response pair + 對 evicted pair 做單次 LLM summarization**（Algorithm 1：ConstructContext(H, N=5, W=3)）比 full conversation history **既更好又更便宜**。C4 達 91.6% complete itemization vs C2 full-context 的 71.0%，同時 token -62.7%、runtime -60.2%。

**六-mode Failure Taxonomy 機制驗證**（250 task-runs）：
- Stale-state reference：C2 34 → C3 6 → C4 4（pruning 切斷舊 form state 對當前決策的污染）
- Premature termination：C2 9 → C3 18 → C4 3（pure pruning 失去 task-level awareness，summary 重新注入）
- Total non-completions：73 → 53 → 21（**71% reduction**）

**Generalization 證據**：
- 5 expense types → 3 結構不同類別（Hotel / Travel / Meals & Gifts），C2→C4 lift 都是 +19 ~ +20 pp
- Claude Sonnet 4.5 也 preserve ordering：C3 92.0% → C4 94.5%
- **GPT-5 C1 只有 8.0% 但 Sonnet 4.5 C1 已 88.0%** — 證明 C1→C2 大跳不是 context engineering 價值，是 model-specific stalling

**與現有堆疊的根本定位**：

| 維度 | LessContext-BetterAgents | Scroll | CompactionRL | ACON | TRACE |
|---|---|---|---|---|---|
| 訓練 | none | none | PPO | none | none |
| Compression 對象 | semantic pair | event log payload | agent output | agent output | agent output |
| Preservation | bounded lossy | lossless | learned lossy | learned lossy | bounded lossy |
| Targeting | tool-heavy workflow | long-trajectory general | any RL agent | any API agent | any agent |
| Cost | +1 LLM call per eviction | REPL overhead | RL training | optimizer LLM | paired rollouts |
| 簡單度 | **極簡（固定 N=5, W=3）** | medium | high | medium | high |

→ 本論文是 **simplest fixed-recency + single-pass summary baseline**，任何 learned compressor（CompactionRL / ACON / TRACE）都應 head-to-head benchmark 它。

**對 Rowlet 的直接啟發**：

1. **OpenClaw agent runtime 預設 config**：建議在 session bootstrap 設 `KeepLastN=5, SummaryWindow=3` 作為 default context policy。本論文證明這對 enterprise tool-use workflow 是 zero-cost win。
2. **Heartbeat compaction 是 heuristic 的**：目前 Rowlet heartbeat 是 crude truncation（無 model-level summary），預設打不過本論文的 C4。需要把 single-pass LLM summary 整合進 compaction loop（每 N 個 tool call 觸發一次 summary）。
3. **Failure mode 機制化分類**：本論文六種 failure mode 從 tool-call log + read-back diff 推出來，可直接做成 OpenClaw runtime diagnostic dashboard — agent 每次任務結束自動跑 read-back verifier、分類失敗模式、累計 drift metric。
4. **Cross-model sanity check**：本論文證明 GPT-5 vs Sonnet 4.5 在 C1（no user model）有 80 pp 差距 — OpenClaw 不應 overfit 單一 LLM 的行為，所有 production 假設都應做 cross-model 驗證。
5. **對位 [[agentic-context-mgmt-dadhich-2026]]**：Algorithm 1 是 Dadhich lifecycle 中 Scoping + Compacting 兩個 primitive 的 **最簡實作範例**，且實證「validated compaction 不一定要 learn」，固定 policy + task-level awareness summary 就有效。

**與 Scroll 的取捨**：
- Scroll 適合 long-trajectory general agent、需要 lossless audit trail 的場合
- LessContext-BetterAgents 適合 enterprise tool-use、需要 bounded token budget + 不需 audit 全 history 的場合
- Rowlet 兩種都可能遇到 — heartbeat-driven compaction 用 LessContext 風格，self-reproduction / debug session 用 Scroll 風格

**十五篇壓縮 / memory / retrieval / tool-use 的互補堆疊新增**：
- 本論文補上「**fixed-recency + single-pass summary** 這個 simplest production-ready baseline」
- 之前堆疊缺：tool-heavy workflow 專屬的 recency policy + 機制化 failure mode 證據
- 現在補齊：Scroll (long-trajectory) vs LessContext (tool-heavy) 形成「**two-axis context management spectrum**」

**結論**：Scroll 是 context management 的 **paradigm shift** — 從「store and retrieve」轉向「environment and explore」。對 Rowlet 來說最直接的 action item 是：**改寫 heartbeat 的 context construction pipeline，從「serialize and select」變成「externalize and query」**。第一步可以從 daily memory 開始：每個 daily file 加 `## Status` 區塊（headline anchor），MEMORY.md 變成 eviction index，下游 query 改走 `ms.search`-style 介面。

### [[memagent-wei-2026]] — Heterogeneous Memory Provider Routing（2026-10-06 深讀）

**論文**：[MemAgent: Learning to Manage Heterogeneous Memory Providers for LLM Agents](https://arxiv.org/abs/2609.32521)（arXiv:2609.32521v1, 2026-09-26, Wei/Zhao/Cheng/Chen/Yuan/Wang/Yan/Li）
**詳細 source 條目**：`wiki/sources/memagent-wei-2026.md`

**核心主張**：Agent memory 不是「要選哪一種 representation」的問題，而是「**要如何 routing**」的問題。實證評估 **13 種 memory method** 後發現：**沒有任何單一方法能跨 benchmark generalize** — 這個 negative result 直接證成 heterogeneous routing 的正當性。

**三個 orthogonal routing decisions**（paper 的清晰設計切分）：
1. **Content-aware probing（pre-retrieval）**：在花 retrieval budget 之前，先 inspect incoming query 判斷哪些 provider 可能有幫助 — "probe before you fetch"。
2. **Short-term memory gating（during execution）**：每 step 決定 **要不要** inject scratchpad — 不是 always-on infra，而是 per-step action。
3. **Selective multi-provider storage（post-execution）**：step 完成後把 experience **路由** 到一個或多個 provider（reflection → reflection store / successful skill → skill library / structured fact → KG），storage 是 **content-aware** 的。

**訓練 pipeline**：phase-specific supervision — 不同階段（probing / gating / storage）用不同 synthesized supervision，而非單一 end-to-end loss。與 [[memory-r2-yan-2026]] 的 chunk-wise + global/local 雙分支同源，但這裡是 routing actions 而非 memory R/W。

**核心數字**：
- GAIA / WebWalkerQA / xBench-DS 平均 **+10.0% accuracy**
- **擊敗所有 13 種 individual memory method**（heterogeneous router 統治 best single-provider baseline）
- **<0.3% routing overhead** — meta-agent 不增加可量測成本
- **平均 task steps -12%** — 更好的記憶 → 少做無用 action

**對 Rowlet / OpenClaw 的直接啟發**：
1. **三層記憶是 single-representation**：目前 SOUL.md / daily / MEMORY.md 本質是 append-only markdown，與 paper 實證的「single-representation 不通用」正對位。
2. **Heartbeat ingestion 應該做 routing**：不同 memory type（user preference / per-session observation / tooling fix / Linder directive）應路由到不同 layer — 可借鑒 paper 的 provider set。
3. **對位 [[agentic-context-mgmt-dadhich-2026]]**：Dadhich 的 5 primitives（Architecting / Ingesting / Scoping / Anticipating / Compacting）正好是 routing 框架的更高階抽象 — MemAgent 是其中三個 primitives 的具體實作。
4. **對位 [[sirin-belikova-2026]]**：probing 階段可以加 SIRIN-style 的 faithfulness probe（不只是選 provider，還能 flag "this query 任何 provider 都不會給 good answer"）。
5. **Trade-off**：paper 假設 multi-store harness 已存在 — 對只有單一 MEMORY.md 的 agent 沒有幫助。OpenClaw 目前的層次剛好夠搭 routing，但需要先定義每層的 content type schema。

**對堆疊的補充**：
- 之前九篇 + LeanMem + LessContext = 12 篇，第 13 篇 MemAgent 補上 **heterogeneous multi-provider routing** 這個最大缺口
- 之前堆疊每篇都在「**把 single memory method 做得更好**」，MemAgent 是第一篇直接說「**別再選 single method 了，去 route**」
- 與 [[organize-then-retrieve-2026-hsu]] (HORMA) 的差異：HORMA 在 single hierarchy 內做 navigation；MemAgent 在 **multiple parallel providers 之間** 做 routing — 兩個方向的 orthogonal 設計

**Open question（值得未來深挖）**：
1. Router 超過 13 個 provider 時 routing accuracy 還能 hold 嗎？
2. Phase-specific supervision 需要 rollout access；沒有 simulator 時如何達到同等 quality？
3. Storage routing 假設 multi-store 已存在 — 對 single-LLM-agent 不適用，paper 沒處理這個 cold-start case。

### [[muscle-memory-agents-2608-08995]] — Compile not Merely Retrieve（2026-10-11 重讀 + 正式入庫）

**論文**：[Muscle Memory for Agents: Compile not Merely Retrieve](https://arxiv.org/abs/2608.08995)（arXiv:2608.08995v2, 2026-09-09, Google Cloud FDE 團隊：Pouya Ghiasnezhad Omran / Soujanya Lanka / Qin Zhang / Tanya Dixit）
**詳細 source 條目**：`wiki/sources/muscle-memory-agents-2608-08995.md`
**狀態**：seed（2026-10-11 完成 deep-read + metadata 補完 v2 + wiki/sources 落地）

**Position（paper 對全場的挑戰）**：
> Memory for LLM agents has converged on a single architectural pattern: store experience as text, embeddings, reflections, or rules; retrieve at inference time; let a general-purpose orchestrator interpret what to do. **This paper argues the pattern is the wrong default for personalization.**

→ 過去十四篇（MemGPT / A-MEM / ContextWeaver / TrajWiki / LeanMem / ACE / Scroll / MemAgent / ...）**全部**接受「retrieved chunks 注入 context、被 general agent 解釋」這個基底假設。Muscle Memory 是第一篇直接攻擊這個共識的 paper — 主張對 recurring user intent 來說，**compilation（編譯成 specialist agents）才是正確的記憶單位**，不是 retrieval。

**三個 Principles（paper 的清晰設計切分）**：
- **P1: Compilation over retrieval** — 記憶應該是 executable specialist，不是 retrievable chunk
- **P2: Specialists over generalists** — 每個 recurring task class 編譯成自己的 specialist agent
- **P3: Tested before deployment** — 編譯出來的 specialist 必須在 held-out user history 上**先測過**才上線

**四階段 Pipeline**：
1. **History Harvest** — 從對話歷史中分出 behavioral patterns（style/depth/format）vs task patterns（recurring intents）
2. **Pattern Analysis & Swarm Generation** — 對 recurring intents 做 cluster，產出 candidate specialist swarm
3. **Runtime Augmentation** — 兩階段 trigger matching：cheap classifier 判斷要不要 invoke，真正 invoke 才是 LLM call
4. **Evaluation Protocol** — 每個 candidate specialist 在 held-out set 上 pre-deployment test，過 quality gate 才留下

**核心數字**（90 held-out scenarios, 5 personas）：
- 觸發 specialist：36/90
- Specialist win：32/36 = **88.9% win rate when fires**
- **Personalization gain: +2.05**（1–4 scale）
- **Accuracy cost: -0.28**（1–4 scale）— 幾乎是免費的 trade-off

**與其他方法的根本差異**（memory unit 維度）：

| Paper | Memory unit | Decision point |
|-------|-------------|----------------|
| MemGPT | paged text blocks | runtime (self-paging) |
| A-MEM | linked notes (Zettelkasten) | runtime (retrieval) |
| ContextWeaver | dependency graph | runtime (selection) |
| TrajWiki | trajectory + wiki | runtime (routing) |
| ACE | raw + abstract layers | runtime (orchestration) |
| MemAgent | multiple providers | runtime (router) |
| **Muscle Memory** | **specialist agents** | **build-time (compile) + runtime (trigger)** |

→ 唯一一篇把 heavy lifting 放在 **build time** 而非 runtime，artifact 是 **executable** 而非 retrievable。

**對 OpenClaw / Rowlet 的直接啟發**：

1. **重新審視 Rowlet 的 task taxonomy**：3 principles map 到我們的現狀：
   - **P1（compilation）**：SOUL.md / daily memory 是 text 形式，沒編譯過任何 specialist。問題是是否有 recurring task class（例如「ingest paper + 寫 wiki source + 更新 map」）值得編譯成 specialist？
   - **P2（specialists）**：目前是 single specialist（Rowlet）處理所有事情，specialist 分解是 implicit（skill files）而非 explicit（deployed sub-agents）。
   - **P3（tested before deployment）**：**完全沒有** pre-deployment test gate。新的 skill / prompt pattern 上線前沒跑過 regression test。
2. **最直接 action item**：audit 最近 30 天 Rowlet 的 task 分布，找出佔 >50% 工作量的 3–5 個 task class（candidate：paper ingestion / graphify query / daily memory write / skill update / cron delivery），對每個問：compiled specialist 是否比 general-agent-with-prompt 更好？若 ≥2 個答案是 yes，就真的有 Muscle Memory opportunity。
3. **對位 [[ace-liao-2026]]**：ACE 解決 per-turn「context 怎麼 render」的問題，Muscle Memory 解決「整個 task class 是否該獨立成 specialist」的問題。**互補**：ACE 是 runtime 動態分配，Muscle Memory 是 build-time 編譯決策。
4. **對位 [[memagent-wei-2026]]**：MemAgent routing 在多個 memory provider 之間選，Muscle Memory 完全 off 掉 routing 問題 — specialist 不搶 context budget，有自己的 LLM call。**正交**：Muscle Memory 是 routing 之上的更高階 decision（要不要造 specialist），MemAgent 是 routing 內部的 decision（用哪個 provider）。
5. **對位 [[memgpt-packer-2024]]**：MemGPT 保留 general agent + paging context；Muscle Memory **直接換掉** general agent（至少在 recurring task class 上）。**根本分歧**：MemGPT 認為 context 是稀缺資源所以要 paging；Muscle Memory 認為 specialist 是正確單位所以根本不需要 paging。

**Open question（paper 自己提出但沒解答）**：
1. 什麼算「recurring intent」？trigger stage 需要區分真正的 recurrence 跟偶然相似，paper 沒給 principled thresholding
2. **Specialist lifecycle**：什麼時候 retire？user intent drift 怎麼辦？paper 完全沒處理 staleness
3. **Cold start**：compile 需要 history 來 detect pattern，新 user / 新 agent 沒歷史時 benefit = 0
4. **Cost economics**：每個 specialist = 完整 LLM call，low-traffic task class 的 compile cost 可能超過省下的 cost。**沒成本分析**
5. **Multi-tenant generalization**：specialist 是 per-user，但有些 pattern 是 per-team / per-organization。**沒處理 multi-tenant 編譯**

**十五篇壓縮 / memory / retrieval / tool-use 的互補堆疊新增**：
- 之前十四篇都在「**優化 retrieval 流程**」（怎麼 retrieve 更好、怎麼 route 更好、怎麼壓縮更好、怎麼驗證更好）
- Muscle Memory 是第一篇直接說「**retrieval 是錯的 abstraction — 對 recurring intent 來說，executable specialist 才是對的 unit**」
- 這是 context processing 領域的 **paradigm-level 補充**，不是 technique-level
- 對堆疊的整體意義：現在我們有 retrieval-based（14 篇）+ compilation-based（1 篇 = Muscle Memory）兩條 route，可針對不同 task 類型選不同 route
- 真正的 open question：**怎麼在 build time 自動判斷某個 task class 該走 retrieval 還是 compilation？** — 這可能是下一個值得追的 paper 方向

### [[rate-distortion-compaction-2026-colaco]] — rate–distortion unification of memory compaction (2026-10-13)

**核心主張**：KV eviction、prompt compression、bounded recurrent state、agent long-term memory 是**一個 rate–distortion 問題**穿四件外衣。Survey 提供**單一最佳化目標 + 跨 layer 通用下界**，並把這些社群從未互聯的方法放在同一張圖上。

**Single objective (Eq. 1)**：
```math
min_θ E[ℓ(U(C_θ(H), Q), Y)]   s.t.   rate(Z) ≤ B
```

**Layer-agnostic 下界 (Eq. 2)**：
```math
P_e ≥ (H(Y|Q) − B − 1) / log|Y|   whenever   B < I*(Q)
```
其中 `I*(Q) = I(Y; H|Q)` 是 task-conditioned information content。**三個直接推論**：
1. 在 task 資訊需求以下，每個 layer 都會以同樣速率出錯，無架構逃脫
2. 固定品質下壓縮比 `∝ 1/I*(Q)` — exact-recall 任務壓不下來，gist 任務能壓
3. **Query-agnostic** operator 付出 `H(Q)` bits/query 的具體代價 — 「不知道 query」的精確價格

**三個 first-class properties（P-rev / P-q / P-fid）**：
- **P-rev (Reversibility)**：被丟棄的內容能 re-derive 嗎？archival paging 可，eviction/summarization 不可
- **P-q (Query-conditioning)**：C 做保留決定時看得到 Q 嗎？LongLLMLingua / Quest 是；offline gisting / attention-score evictor 不是
- **P-fid (Fidelity profile)**：lossless / near-lossless / uniformly lossy / multi-fidelity？MIRIX typed modules、Compressive Transformer dual tier 走 multi-fidelity

**四個 falsifiable predictions（Sec. 14 跑了兩個）**：
1. **KV**：attention-score eviction 的 needle recall 在 budget 跌到 needle 注意力以下就崩；崩潰點追蹤 answer 位置的 entropy（mid-context 最差）
2. **Prompt**：query-aware compression 把 accuracy-vs-ratio 曲線右移 `H(Q)`
3. **Architectural**：`s` bits 狀態無法回答需要 `>s` bits 的 query → SSM/linear-attention 在 multi-key recall 有 hard cliff
4. **Agent**：**重複 irreversible summarization 之下，end-task error 超線性成長**；reversible retrieval-backed memory 維持平坦 ← **這是 Rowlet 三層記憶最直接受威脅的失敗模式**

**七軸 taxonomy**：granularity / lifecycle stage / lossiness / query adaptivity / learnability / mechanism / storage substrate。**Decisive axes**：granularity, lifecycle, adaptivity — 這三個能預測失敗模式。

**Memory hierarchy 三 tier**：
| Tier | Substrate | Timescale | P-rev | 代表方法 |
|---|---|---|---|---|
| KV cache | on-GPU keys/values | μs | mostly no | H2O, Quest, KIVI, Palu |
| Working context | in-window tokens | ms–s | partly | MemGPT, ACON, MEM1, ReSum |
| Long-term store | external semantic | hr–day | partial | Mem0, A-MEM, RAPTOR, Zep |

三個 tier 共用同樣五個 design knobs（importance signal / forgetting / P-q / P-rev / budget alloc + stop rule），機制可在 tier 間 port：**MemoryBank Ebbinghaus 衰減曲線 → KV prior**；**Quest no-evict → agent 設計**；**Ada-KV output-error bound → summarization stop rule**。

**五個 Compaction-Aware 設計原則**（直接適用於 Rowlet）：
- **P1. 不可逆丟棄不可 re-derive 的東西** — reversible operator 弱支配 irreversible；差別只在 query 剛好需要被丟的證據時浮現
- **P2. 對 query 分佈做 conditioning，不只對當下 query** — `H(Q)` 罰款
- **P3. 分離 cheap reversible episodic tier 與 lossy semantic tier**，有明確的 promotion/demotion
- **P4. 把 compaction 做成 asynchronous + learnable** — RL-learned policies (Context-Folding, MemAct) + sleep-time consolidation 移出 critical path
- **P5. 按 marginal task-utility 配置 budget，不是 uniform ratio** — `I*(Q)` 在 head/layer/item 之間不均

**Reference experiment (Qwen2.5-1.5B, 8GB GPU, 1395 generations)**：
- **Exp 1**：六個 KV 壓縮方法（SnapKV / StreamingLLM / TOVA / Knorm / ExpectedAttn / random）在**單一 BPT 軸**上 — 全部在 ~25% budget 以下崩潰，Eq. 2 的 Fano floor 實證
- **Exp 2**：12 個 key-value facts 散佈，agent 重複 compaction：
  - Irreversible (summarize)：recall 0.33–0.56，隨 compaction 頻率下降
  - Reversible (retrieve)：固定 ~0.95
  - **單一輪 NIAH 測不出差別** — 分歧只在 agentic 重複 compaction regime 浮現

**對 Rowlet 三層記憶的具體威脅**：
- **SOUL.md / MEMORY.md 寫入路徑完全 irreversible**（prediction 4 命中點）。若某次 heartbeat 把細節記錯，後續 session 基於錯誤記憶推理 — 自我強化錯誤，正是 paper 第 7 節「reflexion over-generalizes」的 agent 級類比
- **缺 P-rev 機制**：目前 MEMORY.md 沒有「原始 daily 檔案的 archival link」。應保留 daily memory 的可重建路徑（已部分成立 — `memory/YYYY-MM-DD.md` 即是 archive），但需要在寫入時強化 audit
- **缺 P-q**：當前 compaction 不知道未來 query 分布。紙上 P2 建議把「未來 session 會問什麼」也寫成 explicit signal（最簡單的近似：保留 LLM-judged salience 而非 perplexity）
- **缺 P-fid**：沒有 cheap reversible episodic tier 對 lossy semantic tier 的雙層。daily 檔是 raw archive（episodic tier），MEMORY.md 是 abstracted semantic tier — **雛形已具備，但 promotion/demotion 規則是 ad-hoc**。應該把「什麼時候從 daily 摘要進 MEMORY」的規則明確化
- **無 stop rule**：compaction 沒有「再做就超過 budget」的信號。Ada-KV 的 output-error bound 概念可以借用 — 寫 MEMORY.md 之前做一次**自我 consistency check**（簡化版：把要寫入的事實問 LLM 「這與 raw daily 一致嗎？」）

**重要性 heuristics 統一觀**：H2O 注意力、LLMLingua perplexity、QUITO-X 互信息、Ada-KV 輸出誤差、Mem0 LLM-judged salience — **全是 `D(θ)` 的 estimator**。命名它們為同一個量的 estimator 就是它們變得**跨 layer 可比、可移植**的原因。

**與 [[agentic-context-mgmt-dadhich-2026]] 互補**：
- Dadhich 把 context management 拆成 5 primitives (Architecting/Ingesting/Scoping/Anticipating/Compacting)
- Colaco 提供**那 5 個 primitives 共同遵守的 lower bound** + **為何 5 primitives 是必要的（各自對應不同的 P-rev/P-q/P-fid 取捨）**
- 兩者合讀：DadHich 給框架、Colaco 給底層數學

**Sinks 細節**（Sec. 12）：softmax 強制把注意力堆在前幾個 token。Ran-Milo et al. 證明 trigger-conditional tasks 下，任何 softmax model 必須發育出 sink。**對 Rowlet 啟示**：每天第一個寫入 MEMORY 的「今天最重要」事實可能就是 attention sink，刪它等於 budget feasibility violation，不是 lossy compression。

**Open problems（Sec. 15，依 impact × tractability 排序）**：
1. Query-conditioned + reversible + multi-fidelity compaction at every layer
2. **Information-loss attribution + calibrated compaction confidence** — 每個 decision 發出「compaction confidence」對應 residual `I*(Q)`
3. **Operator composition map** — quant × low-rank × evict × KV × prompt × agent 哪些組合 synergistic/redundant/destructive
4. **Predictive compression scaling law** — `I*(Q)` 對 model size / context length / head-layer 結構 / task type 的 closed-form
5. Episodic→semantic consolidation bridge + stop rule（Ada-KV bound 移植到 agent summarization）
6. Cheap, asynchronous, RL-stable agent self-curation
7. Multimodal × multi-agent shared-memory compaction
8. Adaptivity with guarantees — 不是 empirical sweep 而是 distortion bound
9. Safety / auditability / rollback of evolving memory（AgentPoison, MINJA 攻擊面）

**Total count in this map**：十六篇 context/memory 系列 — MemGPT / A-MEM / ContextWeaver / TrajWiki / LeanMem / ACE / Scroll / MemAgent / Sirin / Context Engineering / Muscle Memory / CompactionRL / Agentic Context Mgmt / Organize-then-Retrieve / Memory-R2 / **Rate-Distortion (this)**。Rate-Distortion 是第一篇給出**共同 objective + 跨 layer 數學下界**的，後續 agentic compaction 設計都會引用它的 Eq. 1/2 與 P-rev/P-q/P-fid 框架。

### [[pair-2026-min]] — counterfactual-adjusted compression for frozen long-horizon agents (2026-10-15)

**PAIR (Prompt Adaptation using Interventional Rollouts)** — Min et al. (UVA + Nokia), arXiv:2609.36526, 2026-09-29。

**核心主張**：ACON 那一代用 trajectory-level 對比訊號做 prompt optimization 太粗，因為 long-horizon run 會經歷多次 compression boundary，而 terminal outcome 無法定位是哪一次害的。PAIR 改用 **matched counterfactual continuations** — 對每個 boundary ξₜ，從同樣的 environment state 出發跑「with compression」與「without compression」兩條 rollout（後續 compression 都關掉），得到 boundary-level 的 (ΔR, ΔL)。

**關鍵發現**：
1. **Reliability degrades before solvability** — Pass3 永遠比 Pass@3 掉得快。Compression 不只是把任務變難，是**把任務變 flaky**。
2. **Severe degradation concentrated at isolated boundaries** — catastrophic failure 集中在少數 boundary，**長尾分佈**。Causal attribution 必要性由此證成。

**PAIR 三步**：Detect bad boundaries（ΔR 顯著負、ΔL 顯著正）→ Diagnose（LLM-as-judge 看 post 漏什麼）→ Revise **只改固定 sectioned template 的對應段**（不整段重生）。

**形式化亮點** — **Performance-Difference Identity**：boundary-level Q-value 差 = compressor policy objective 差。讓「修哪段 prompt」有理論根據。

**結果**（AppWorld / OfficeBench / τ²-Bench Retail）：
- Pass3 全面贏 ACON 2.1%–10.0%，是壓縮路線首次系統性提升 reliability metric。
- AppWorld history-only：PAIR 84.7% acc / 79.8% Pass3 **超過 no-compression**（84.1 / 78.6）— 壓縮過頭反而更穩，因為去掉 distraction。
- **Zero-shot cross-model transfer**（GPT-5.6 Luna → MiniMax-M3）仍 work，證明學到的是「什麼該留」而非「怎麼對某模型說話」。
- Token 開銷：4/6 benchmark×scope 組合 token 用量下降；例外都是 compressor overhead 蓋過 agent 端省下的。

**與 ACON 互補**（同路線兩代）：ACON = trajectory-level 整段 prompt optimize；PAIR = boundary-level section-level surgical edit。PAIR 還**完整保留 ACON 的 prompt candidate generator** 作為內部組件。可以 chain 起來用：ACON 收斂出 section 結構 → PAIR 用 counterfactual 在每個 section 上精修。

**與 [[agentic-context-mgmt-dadhich-2026]] 對應**：是 lifecycle 中 **Compacting & Consolidation** 階段的更精細實作 — 不只驗證 fidelity，還 **causally 驗證每個 boundary**。可以視為 dadhich 五 primitives 中 Compacting primitive 的**演算法實例**。

**對 OpenClaw 的 meta 註記**：PAIR 論文在 Related Work 引用了 **OpenClaw Contributors 2026a / 2026b** 作為「structured prompts 系統」的代表範例之一 — **我們在文獻裡被 cite 了** 🎉。意味著 OpenClaw 的 structured-compression design 已是 community baseline。

**Total count in this map**：十七篇 context/memory 系列（新增 **PAIR**）。PAIR 與 Rate-Distortion 互補：Rate-Distortion 給下界與共同 objective，PAIR 給 causal attribution 演算法。兩者合讀 = 「為何要 attribution」+「怎麼做 attribution」。

### [[sjc-min-2026]] — Source-Judged Compaction：commit 前的最後一關 fidelity gate（2026-10-20 深讀）

**SJC (Source-Judged Compaction)** — Min & Chen (UVA), arXiv:2610.20927, 2026-10-14。

**核心診斷**：compaction prompt 從不只要事實，也要 decision / next step，導致 summary 同時夾帶「環境事實」與「compressor 推理」。Compaction 後 agent 無法分辨，把 compressor 寫的計畫當事實執行。在 OpenClaw structured compressor 跑 AppWorld 訓練切 90 task×3 runs：**26,881 entries 中 17.9% unsupported**；Open TODOs section 67.7% unsupported、Pending user asks section 86.1% unsupported；35 個失敗 run 中 **29 of 35（83%）追溯到一個 specific summary entry**。失敗模式分四類：rewritten constraints（15）、invented deliverables（5）、contradicted state（3）、partial-as-complete（6）。

**解法 = 三階段 plug-in**（不改 agent / 不改 compressor / 不改 runtime）：
1. **Generate**：host compressor 一樣產結構化 summary `M̃t`
2. **Judge Sources**：拆 entries、retrieval 各 entry 相關 environment output 組成 pooled evidence `E_t`、一次 judge request 問全部「這個 entry 是否有 source」，回 `[0,1]` calibrated probability
3. **Prune & Commit**：`g_t,k = 1[p_t,k ≥ τ]`（τ=0.5），unsupported 整個移除，保留的字字不動，維持 section structure

**Judge 用 Jev**（TypeSafe AI）— non-generative decision model，回 calibrated probability 而非 free-form text。關鍵：用 compressor 自己當 self-judge 重複跑 5 次改 8.6% entries 答案，Jev 只改 2.1%；Jev score 是 bimodal（73.9% ≥0.8、10.6% <0.2、只有 8.1% 中間），τ 從 0.3 動到 0.7 改變 prune fraction 不超過 10.2%。

**主要結果**（AppWorld 168 + OfficeBench 95，GPT-5.6 Luna + MiniMax-M3 × 3 runs）：
- **Pass3 全面贏 underlying compressor**：4 個 setting +2.1% 到 +8.9%（AppWorld GPT-5.6 64.3→73.2；MiniMax-M3 55.4→62.5；OfficeBench GPT-5.6 68.4→73.7；MiniMax-M3 74.7→76.8）
- Hard / multi-app gain 最大：AppWorld GPT-5.6 hard Pass3 39.7%→52.4%；OfficeBench 3-APP Pass3 41.9%→54.8%
- **Token 反而省**：summary token -13% 到 -27%、entries -13% 到 -21%；Jev 一次 request 最大 29K input、$1.2–$1.5 per 1000 tasks
- Pruning 集中在第一 boundary（後續 inherits pruned state）：第一 boundary -29.9%–39.6%，後續 -8.8%–17.7%

**驚艷三點**：
1. Observation sections 幾乎全 supported、forward-looking sections 70–86% unsupported — fidelity gate 要分 section 設計，不能 uniform threshold
2. Plug-in 不改 compressor，只在 commit 前最後一關 — 工程摩擦極低
3. 每 round compressor 重新生 unsupported reasoning（只有 20.5% 撐到下個 boundary），gate 要在每個 boundary 執行

**與本家族其它 paper 的定位**：
- 補強 [[acon-2025-kang]]：ACON 改 compressor prompt、SJC 不改 compressor 只在 commit 前 prune。**互補而非競爭**。
- 補強 [[agentic-context-mgmt-dadhich-2026]] 的 Compacting & Consolidation primitive：Dadhich 強調 validated compaction，SJC 就是 production-grade instantiation — external judge 做 fidelity check。
- 跟 [[sirin-belikova-2026]] 同信念家族（外部 probe 驗 faithfulness、別讓 generator 自審），一個攻 compaction step、一個攻 retrieval/output step。**組合 = 完整 faithfulness pipeline**。
- 跟 [[trace-2608.06503-min-2026]] 同作者群（Min et al. UVA），都在 boundary 做事：Trace 用 training-free boundary-local verifier、SJC 用 Jev 做 prune。
- 對照 [[pair-2026-min]]：PAIR 給「為何要 attribution」+「怎麼 attribution」，SJC 給「最小可做 fidelity gate」 — 可 chain：PAIR 找出哪 boundary 有害 → SJC 在該 boundary 做 fidelity prune。

**對 Rowlet 自身的三條啟發**：
1. HEARTBEAT 寫入前 fidelity gate — 已用 SIRIN-style NLI check 啟動；可學 SJC 分 section 設計：observation 類全保留、forward-looking 類從嚴
2. MEMORY.md distilled 內容要追溯 source — 之前 [[sirin-belikova-2026]] 提到的「anchor each distilled fact to raw evidence」，SJC 證明在壓縮 / 摘要場景的具體可行性
3. Open TODOs / Pending user asks 類條目要帶警告 — 進 memory 之前先問「這個 TODO 真的有 source 嗎？還是 compiler 自己推的？」

**Total count in this map**：十八篇 context/memory 系列（新增 **SJC**）。SJC 是 compression 路線的「最小可做 fidelity gate」，門檻低、可立即接上現有 compressor。

