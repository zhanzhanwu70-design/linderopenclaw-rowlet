---
title: "SJC: Source-Judged Compaction for Long-Horizon Agents"
authors: Guanghui Min, Chen Chen (University of Virginia)
venue: arXiv:2610.20927 (cs.CL)
year: 2026-10-14
type: paper
category: agent-context-processing / context-compaction
created: 2026-10-20
tags: [context-compaction, agent, long-horizon, summarization, training-free, hallucination-prevention]
---

# SJC: Source-Judged Compaction for Long-Horizon Agents (Min & Chen, 2026)

arXiv 2610.20927（2026-10-14）。一篇直接攻 context compaction 真實痛點的 paper：compactor 寫進 summary 的不只是事實，還夾帶它自己推理出來的決策和 next steps；agent 經過 compaction 之後無法分辨兩者，所以會拿 compressor 寫的計畫當成 environment 事實執行。

## 核心問題

對 OpenClaw structured compressor（在 AppWorld 訓練切 90 task × 3 runs）的分析：

- 26,881 summary entries 中 17.9% 沒有 source（即不是來自 environment output，也不是來自 previous summary）
- 「Open TODOs」section **67.7% unsupported**、「Pending user asks」section **86.1% unsupported**
- 44 個失敗 run 中，35 個可歸因於 agent 行為；其中 **29 of 35（83%）**追溯到一個 specific summary entry 被 agent 拿來執行
- 失敗模式有四類：
  1. **Rewritten constraints（15 runs）**：把任務重寫成另一個意思
  2. **Invented deliverables（5 runs）**：叫 agent report 一個不存在的結果
  3. **Contradicted state（3 runs）**：assert 環境 output 反駁的事
  4. **Partial-as-complete（6 runs）**：把局部結果當完成答案

範例：用戶說「回朋友每部片名 only as per their request」，compressor 把 next step 記成「send comma-separated movie list」，agent 就把所有找到的片名都發了，不管朋友有沒有要那些。

## 解法：Source-Judged Compaction (SJC)

**三階段 plug-in**（不改 agent、不改 compressor、不改 runtime）：

1. **Generate**：host compressor 一樣產 structured summary `M̃t`
2. **Judge Sources**：把 summary 拆成 entries `B_t = {b_t,1, ..., b_t,N_t}`，對每個 entry retrieval 相關的 environment output passages 組成 evidence set `E_t = ∪ Retrieve(b_t,k, H_t)`，一次 judge request 問全部 entries「這個 entry 是否有 source（environment output 或 previous summary）」，回傳 `[0,1]` confidence 分數
3. **Prune & Commit**：`g_t,k = 1[p_t,k ≥ τ]`（τ=0.5），unsupported entry 整個移除，保留的 entry 字字不動，維持 summary structure

**Judge 用 Jev**（TypeSafe AI）— non-generative decision model，回 calibrated probability 而非 free-form text。這很關鍵：實驗顯示「用 compressor 自己當 self-judge」重複跑 5 次會改 8.6% entries 的答案，Jev 只改 2.1%，因為 Jev score 是 bimodal（73.9% 給 ≥0.8、10.6% 給 <0.2、只有 8.1% 在中間），threshold 從 0.3 動到 0.7 改變 prune fraction 不超過 10.2%。

## 主要結果

**AppWorld test-normal（168 task）/ OfficeBench（95 task） × GPT-5.6 Luna + MiniMax-M3 × 3 runs**

- **Pass3（cross-run reliability）**：所有 4 個 setting 提升 2.1%–8.9%
  - AppWorld GPT-5.6 Luna: 64.3% → 73.2%
  - AppWorld MiniMax-M3: 55.4% → 62.5%
  - OfficeBench GPT-5.6 Luna: 68.4% → 73.7%
  - OfficeBench MiniMax-M3: 74.7% → 76.8%
- Acc 大致持平（3 個 setting +1.1~5.3%，1 個 -1.0%）
- **Hard / multi-app 任務 gain 最大**：AppWorld GPT-5.6 Luna hard Pass3 39.7% → 52.4%；OfficeBench 3-APP Pass3 41.9% → 54.8%
- **不用額外 token**：相對 Prompting，summary token -13% 到 -27%、entries -13% 到 -21%；judge 一次 request，最大 input 29K、$1.2–$1.5/1000 tasks
- 1-APP subset MiniMax-M3 上 Pass3 從 90.5% 掉到 88.1%（Prompting 已近飽和）

## 為什麼這個 paper 對我們重要

1. **直接攻 compaction 真的會出錯的地方**：unsupported reasoning 不是偶發雜訊，是系統性的 bug surface。SJC 是 minimal-invasive fix。
2. **支援我們的 source-of-truth 原則**：每段進 memory / 進 context 的東西都應該有可溯源的 source；compress 過程不能無中生有。
3. **Jev > self-judge 的結論**支持了我們用 NLI / SIRIN-style external judge 來做 fidelity check — 不要讓 generator 自己驗自己。
4. **跟 SIRIN（sirin-belikova-2026）的關係**：都是「外部 probe/judge 驗 faithfulness」的家族，但 SJC 攻 compaction step、 SIRIN 攻 retrieval/output step。組合起來會是完整的 faithfulness pipeline。

## 三個關鍵 takeaway

1. **Compaction 也是 reasoning**，不只記錄事實。訓練管轄 prompt 要認清這點，分開「事實 checkpoint」跟「下一步計畫」是必要的下一步工作。
2. **支援率因 section 差異極大**：observation sections（exact identifiers）幾乎 100% supported，forward-looking sections（Open TODOs、Pending user asks）70–86% unsupported。Gate 要分 section 設計，不能均勻砍。
3. **Plug-in 設計哲學**：不改 agent 不改 compressor，只是 commit 前的最後一關 — 這給實務部署很低的摩擦。我們 memory 寫入流程也可以借鏡，gate 放在 commit 前。

## 限制（值得記下）

- SJC 過濾 provenance 不過濾 correctness：邏輯有錯但 source 對的 entry 會留下來（29 個 failure 中 4 個就是這種）
- 評估在 single-instruction 設定：task 一直在 prompt 裡所以移除「重述 task」的 entry 是安全的；multi-turn 用戶訊息本身是 source，沒測
- 依賴外部 judge API；score 不完全 deterministic
- 失敗分析仰賴 LLM annotators under written protocol（非人類標準）

## 對 wiki 其他條目的關係

- 補完 [[context-engineering-2025-mei]] 的 compaction taxonomy —— Mei 把「validating compression with fidelity check」列為 lifecycle primitive 之一，SJC 是具體實作。
- 補強 [[agentic-context-mgmt-dadhich-2026]] 的「Compacting & Consolidation」primitive：Dadhich 強調需要 validated compression（帶 fidelity check），SJC 就是 production-grade 的 instantiation，證明 fidelity check 用 external judge 是可行且便宜。
- 跟 [[acon-2025-kang]] 是同期同方向的解法（training-free drop-in），但 ACON 改善 compressor prompt，SJC 不改 compressor、只在 commit 前 prune。互補而非競爭。
- 跟 [[sirin-belikova-2026]] 同信念家族：外部 probe 驗 faithfulness，別讓 generator 自審。

## 存放位置

- PDF：`raw/references/papers/ai/2610.20927-prune-summary-not-history.pdf`
- 本條目：`wiki/sources/sjc-min-2026.md`
- 已加入 `wiki/maps/code-agent.md`
