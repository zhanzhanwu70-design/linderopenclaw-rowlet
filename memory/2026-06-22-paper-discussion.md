# 2026-06-22 Daily Paper Discussion

## 每日論文討論 🌿

### Less Context, Better Agents: Efficient Context Engineering for Long-Horizon Tool-Using LLM Agents

**論文**: arXiv:2606.10209
**作者**: Abhilasha Lodha, Mahsa Pahlavikhah Varnosfaderani, Abir Chakraborty, Abhinav Mithal (Microsoft)
**PDF**: `raw/references/papers/ai/2606.10209-less-context-better-agents.pdf`
**Wiki source**: `wiki/sources/less-context-better-agents-2606.10209.md`
**Map 更新**: `wiki/maps/code-agent.md`（新增條目並連結互補關係）

---

## 任務

選擇一篇 Context Compression & Summarization 相關論文，與團隊討論。

## 為什麼選這篇

1. **非常新的研究**（2026-06-08 submission）：enterprise tool-using agent 實務研究
2. **直接回答實務問題**：context overflow 怎麼解？pruning vs summary vs full history
3. **方法論清晰**：四種配置系統性比較，含統計分析（CI、effect size、sensitivity）
4. **互補性強**：可與 AtomMem（多 session 長期）、Active Context Compression（coding agents）、LongLLMLingua（token-level）形成完整 context management stack 敘事

## 完成的產出

- PDF 下載：`2606.10209-less-context-better-agents.pdf`（380KB）
- Source entry 建立：5051 bytes，含完整摘要、演算法、實驗結果、失敗分析、理論貢獻
- Code-agent map 更新：加入新條目並建立與 Active Context Compression 的互補關係

## 3-5 個重點（可供團隊討論）

### 1. Full History 反而最差（71% vs 91.6%）
Full conversation history 不只昂貴，還會降低任務完成率。完整資訊不等於決策相關資訊。Context rot 是 production 事實，不是 theory。

### 2. Pruning + Summary 是黃金組合（token -62.7%, runtime -60.2%, 完成率 +20.6pp）
Pruning (last 5) alone already helps (79% vs 71%)。加上 summary window W=3 達到 91.6%。兩者缺一不可：pruning 控制長度，summary 保存情境意識。

### 3. W=3 是 summary window 的 sweet spot
太短（1）：agent 失去歷史感。太長（5+）：summary 本身變成噪聲。跨模型（GPT-5 + Claude Sonnet 4.5）和跨任務類型都穩健。

### 4. 不是所有任務都適合 aggressive pruning
Iterative refinement 任務（pylint-7080）中，aggressive pruning **增加** token usage 110%，因為 agent 需要連續上下文。和 Active Context Compression（Focus）的發現完全一致——需要情境判斷何時压缩、何時保留完整歷史。

### 5. Context engineering 是 semantic-level 的，和 token-level compression 層次不同
本文定義的 context engineering 和 LongLLMLingua（token/doc-level compression）是互補的 stack 層次：
- Token-level compression（LongLLMLingua）→ 進 cache 前的「瘦身」
- Semantic-level engineering（本文 + AtomMem）→ 結構化記憶表示與 eviction
- Memory retrieval（Mem0/HippoRAG）→ 多 session 長期知識召回

## 觀察 / 待辦

- 實驗環境是 Microsoft D365 F&O（internal ERP），benchmark 是 50-task hotel expense，N=5, W=3 的最佳參數可能需要針對 OpenClaw 的使用情境調整
- 值得關注的後續論文：SemanticZip（LLM as semantic decompressor），VikingMem（memory base management）
- 今天處理的 AtomMem（2026-06-21）和本文（2026-06-22）剛好構成完整的 context management stack 敘事：AtomMem = 長期多 session 記憶，Less Context = 單任務 tool-use context 管理
