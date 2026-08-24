# Agentic Context Management (ACM) — Dadhich 2026

## Metadata

- **Title**: Agentic Context Management: Solving Agent Memory and Cost by Treating Them as Lifecycle and Architecture Problems
- **arXiv**: [2607.21503](https://arxiv.org/abs/2607.21503)
- **PDF**: [2607.21503.pdf](/home/amr/.openclaw/workspace-rowlet/raw/references/papers/ai/2607-agentic-context-mgmt/2607.21503.pdf)
- **Authors**: G. Dadhich (Maximem AI)
- **Published**: 2026
- **Eval Harness**: [github.com/maximem-ai](http://github.com/maximem-ai)
- **Benchmarks**: LongMemEval (92%), LoCoMo (93.2%)

## 核心貢獻

### 1. 框架重構：Memory → Context Management

論文的核心主張：**把 context management 當作「儲存問題」是錯誤的框架**。

傳統「Memory」框架只優化兩個 moment：write 和 read。但 production agent 每 turn 必須做出五個不同的決定：
1. **記什麼**（哪些值得保留）
2. **怎麼結構化**（用什麼 schema）
3. **本次 context 放什麼**（scope 選擇）
4. **下一 turn 可能需要什麼**（anticipate）
5. **當 context 超預算時怎麼辦**（compaction）

Store 不做任何一個決定。**Context management 是一個 lifecycle，不只是一個 store。**

### 2. 五個 Primitives

| Primitive | 職責 |
|-----------|------|
| **Architecting** | 定義 memory 的形狀：哪些資訊類別重要、存在哪、如何檢索/壓縮。多數系統用固定 universal schema，作者認為 architecture 本身應該是 first-class primitive。|
| **Ingesting** | 把對話、文件、工具回應轉為結構化、可檢索的 memory。關鍵 insight： retrieval quality 由 ingest quality 決定。 |
| **Scoping** | 決定本次 context 要包含 retained memory 的哪一小部分（relevance filtering）。|
| **Anticipating** | 主動預測下一 turn 需要什麼資訊（proactive recall）。|
| **Compacting & Consolidation** | 當 context 超過 budget 時，在不丟失重要資訊的前提下压缩；同時維持 provenance（知道資訊從哪來）。|

### 3. 經濟論證（Efficient Frontier）

```
Naïve full-append:     O(n²) token cost  (quadratic — 每 turn 都在重複讀取所有歷史)
Crude summarization:    O(n) cost but accuracy cliff ( fidelity loss )
Validated compaction:   O(n) cost with preserved fidelity ✓
```

**Key insight**：不是所有的 memory 都應該用同一種策略處理。「validated compaction」（含 fidelity validation 的压缩）才能同時達到 linear cost 和 preserved accuracy。

### 4. Scope Hierarchy

ACM 不是只管單一 user，而是跨越組織層級：
- **Individual user** → 自己的對話歷史、個人偏好
- **Team / Project** → 共享上下文
- **Organization** → 政策、知識庫、部門邊界

還要防止 user A 的 context 洩漏到 user B（multi-tenant security）。

### 5. 開放前沿

現有 benchmarks 不 capture 的三個維度：
- **Latency** — 記憶檢索速度
- **Token efficiency** — 每次檢索的性價比
- **Context-rot resistance** — 上下文腐爛（早期資訊被後期稀釋）

**Decision-level & Organization-level context** — 未來方向，多 agent 間的上下文協調。

## 與我們的相關性

- **Rowlet 三層記憶**：SOUL.md（人格）→ daily memory（短期）→ MEMORY.md（長期）→ 可對照 ACM 五 primitive 框架檢視
- **心跳寫入前的 faithfulness check**：論文提到 validated compaction 是關鍵，這呼應 [[sirin-belikova-2026]] 的 NLI-based hallucination detection
- **Cost scaling**：我們的 session 也有 O(n²) 問題 — 每次 heartbeat 讀取大量 history

## 標籤

#context-management #agent-memory #lifecycle #token-cost #context-compression #production-agents
