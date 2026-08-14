---
title: "Code-Agent Map"
category: map
type: knowledge-map
created: 2026-06-11
modified: 2026-08-09
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

目前八篇形成一個互補堆疊：

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

### TrajWiki 補充：Source-Grounded Memory Trajectories（2026-08-05 深讀）

**最新論文（2608.00967, 2026-08-01）**，專攻 long-horizon dialogue agent 的 memory 追蹤與可解釋性。

**核心貢獻**：
1. **Memory Trajectory Model** — 將每段記憶視為一條 source-grounded evolution trajectory，透過 immutable episodic snapshots + claim-level operations（ADD/REVISE/DEPRECATE）維護。解決了 overwriting 導致的資訊丟失問題。
2. **Memory Wiki 中間層** — 持續把對話歷史增量編譯成結構化 wiki pages（entities、events、quantities、topics、conflicts），wiki page 之間互相連結形成知識圖譜。
3. **Hierarchical query routing** — 查詢時：wiki page → linked memory trajectories → snapshots → source messages for evidence-grounded answer synthesis。

**與其他方法的根本差異**：
- vs **MemGPT**：MemGPT 是 paging-based memory（把不常用的 context 移到外部），TrajWiki 是結構化的 evolution trajectory，強調版本演化與 provenance
- vs **SelfMem**：SelfMem 是 inference-time self-reflection，TrajWiki 是 persistent structured wiki + explicit revision operations
- vs **CompactionRL**：CompactionRL 把 summarization 變成可學習的 action，TrajWiki 把 memory revision 變成 explicit operations（ADD/REVISE/DEPRECATE）

**對 OpenClaw 的直接啟發**：Rowlet 目前的三層記憶（SOUL.md / daily memory / MEMORY.md）本質上還是 append-only 和 static retrieval 的混合。TrajWiki 的 operation model 提示我們：可以在 `MEMORY.md` 或 `SOUL.md` 的更新邏輯中加入 explicit revision types（修訂 vs 廢棄），而不只是覆蓋式寫入。這會讓記憶的演化可追蹤、可診斷。

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

現有十二篇 + CompactionRL 形成十三篇互補堆疊：

10. **SIRIN**：見上方第 8 項
11. **CompactionRL (Li et al., 2026)**：將 context compaction 整合進 RL training pipeline 的第一個方法。核心突破：**PPO over group-relative methods** — compaction 讓單一 rollout 變成可變數量、可變長度的 segments，GRPO 的 group normalization 無法處理，PPO 的 critic-based token-level advantage 才是正確框架。**Summarization as learnable action** — 任務執行動作和摘要動作在同一个 task-level reward 下聯合優化，壓縮策略不再是工程師設計的 heuristic，而是模型從 outcome feedback 學到的技能。

CompactionRL 與其他 training-time 方法的差異：
- vs **Memory-R2**：Memory-R2 訓練的是「何時更新記憶」，CompactionRL 訓練的是「如何生成摘要」。Memory-R2 解決的是 memory 使環境 non-stationary 的 credit assignment；CompactionRL 解決的是 compression policy 的 quality。
- vs **SelfMem**：SelfMem 是 inference-time optimization（不需要 training），CompactionRL 是 training-time learning（從 outcome feedback 端到端訓練）。
- vs **MemGPT**：MemGPT 是 system-level memory paging（固定 policy），CompactionRL 是 learnable compaction policy（模型自己學）。

**對 OpenClaw 的直接啟發**：Rowlet 的 heartbeat 本身就像一個 compaction trigger —— 每次 heartbeat 都做一個「壓縮 + 繼續」的動作，但目前的實作是 heuristic 的（固定的總訊息長度閾值）。CompactionRL 的啟示是：**如果我們能收集足夠的 heartbeat outcome data，就可以訓練模型自己學何時壓縮、怎麼壓縮**，而不只是靠固定規則。這需要 (1) 定義 task-level reward for heartbeat outcomes，(2) PPO-style 訓練框架。

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

### 對我們自己的工程提醒

根據 [[lost-in-the-middle-2023-liu]] 的 finding，目前架構有兩個潛在風險：

1. **Mid-prompt 衰減**：當 heartbeat 把 `memory/YYYY-MM-DD.md` + 多個 tool 結果 + wiki dumps 串進對話中段，重要的 earlier tool result 可能掉進 U-shape 谷底。
2. **Long-session 退化**：多 session 串接的 conversation，舊 session 的關鍵資訊一旦被新 session 推到中段，就會被模型忽略。需倚賴 [[memgpt-packer-2024]] 的 recall storage 或 [[organize-then-retrieve-2026-hsu]] 的 hierarchical summary 來主動 page-in。

3. **缺乏 reversible context management**：目前的 daily memory 是 append-only，wiki 是 static retrieval。[[ace-liao-2026]] 的啟發是：即使是我們的分層記憶系統，也可以借鑒「每步動態重建 context」的思路 — 不是用固定策略管理記憶，而是根據當前任務需求彈性選擇呈現形式（raw / abstract / drop）。這對 OpenClaw 的 heartbeat 整合特別有意義。
