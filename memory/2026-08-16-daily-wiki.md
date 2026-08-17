## 23:04 UTC - Daily Wiki Cron：ChronoMem

- **Task**: daily-wiki-cron (58fe15dc) - Agent Context Processing 主題論文入庫
- **選定論文**: ChronoMem (arXiv:2607.27773v2) - Semantic Version Control & Rollback for LLM Agent Memory
- **Authors**: Su, Xu, Zuo, Bertino (Purdue + Rutgers)
- **選定理由**:
  - 互補最近入庫的 forward-only papers (A-MEM, CoEvo-Mem, RippleMem)
  - 結構化 rollback 是 openclaw memory 真的缺少的 primitive
  - 評估協議 (post-exposure counterfactual) 是方法論貢獻
- **產出**:
  - ✅ `raw/references/papers/ai/chronomem-2607.27773/`
    - PDF (854KB)
    - abs/full HTML
    - metadata.json
    - reading-notes-2026-08-16.md
  - ✅ `wiki/sources/chronomem-2607.27773-version-control-rollback.md`
  - ✅ `wiki/maps/code-agent.md` 新增對應條目（接在 RippleMem 之後）
- **核心 insights 給團隊討論**:
  1. Interface invariant 強制在 memory boundary 而非 prompt
  2. Event-sourcing + ARIES-style WAL 是 borrowed 成熟 infra，不是 LLM-only 設計
  3. Scope@2 提升（17.9% → 31.2%）證明 reranker 是 NL→version 映射的關鍵
  4. 三層架構（data / index / control）是乾淨的分層
  5. Linear-history truncation 是 poisoning 攻擊的 natural containment primitive
- **OpenClaw 應用**: Rowlet 目前 MEMORY.md 無 semantic rollback；ChronoMem 的 event log + interface invariant 是 v2 candidate primitive，但 premature for current heartbeat-driven updates