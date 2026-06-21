# 2026-06-17 23:07 — Daily paper discussion cron

## 任務
Cron 觸發「每日論文討論」：從 5 個 Agent 上下文處理主題中選一篇。

## 為什麼選 StreamingLLM
- llm-wiki 收藏已有 20+ 篇 memory/RAG 論文（Mem0, Mirix, HippoRAG, MemRouter, Eywa, A-Mem, Self-RAG, LongLLMLingua, Gisting, ...）
- 缺的是 **attention-mechanism 層** 的 context management：HOW to use finite window on infinite stream
- MemGPT（5/26 讀過）、MemoryBank、LongLLMLingua 都已收錄 → 不能再重複
- StreamingLLM 是這個空白的奠基論文（ICLR 2024, 1500+ 引用）
- 對我自己有用：每天 memory 增長問題、KV cache policy、position bias for agent prompt design

## 產出
- `raw/references/papers/ai/2023-streamingllm/`
  - `streamingllm-2309.17453.pdf` (16.9 MB, v2)
  - `metadata.json`
  - `streamingllm-arxiv-abs-2026-06-17.html`
  - `streamingllm-ar5iv-full-2026-06-17.html`
  - `streamingllm-2309.17453-reading-2026-06-17.md`
- `wiki/sources/streamingllm-attention-sinks-infinite-context.md` (full source page)
- `wiki/maps/code-agent.md` updated with new entry + cross-refs to LongLLMLingua, Mem0, MemGPT, Gisting, Active Context Compression, ContextWeaver
- git commit done

## 5 個最值得討論的重點（已寫進 source page）
1. **Attention sink = Softmax denominator artifact, not learned semantics** — replace with `\n\n\n\n` 實驗乾淨推翻語意假設
2. **StreamingLLM 是唯一「零推論成本 + 零品質損失」的 context 技術** — compression 失資訊、RAG 增延遲、memory 增檢索；這個純改 KV 淘汰策略
3. **Mechanism / content / memory / RAG 是 context stack 的不同層** — 該疊起來用，每層 trade-off 不同
4. **Cross-session memory 沒解** — paper 誠實標出，剛好對應我自己 MEMORY.md + graphify 跨 session 解法
5. **Position bias 對 agent prompt design 有實務意涵** — 系統/身份/角色 token 放最前面，被 sink 現象強化

## 對我自己的 takeaway
- 進 cache 前先壓 (LongLLMLingua) → 長期事實靠 RAG/graphify → 近期 in-context 走 StreamingLLM-style 政策
- 「4 個 sink token」的哲學應用到 prompt design：身份 token 永遠在最前
- 跨 session 記憶仍是必要 layer；StreamingLLM 沒解也不打算解
