# H-MEM: Hierarchical Memory for LLM Agents — Sun & Zeng 2025

## Metadata

- **Title**: Hierarchical Memory for High-Efficiency Long-Term Reasoning in LLM Agents
- **arXiv**: [2507.22925](https://arxiv.org/abs/2507.22925)
- **PDF**: `raw/references/papers/ai/hmem-llm-agents-2025.pdf`
- **Authors**: Haoran Sun, Shengzhi Zeng
- **Published**: July 2025 (arXiv v1)
- **Dataset**: LoCoMo (5 task settings)
- **Baseline comparisons**: 5 baselines evaluated

## 核心貢獻

### 1. 四層記憶階層架構

H-MEM 將記憶組織為四層，模擬人類認知記憶的結構：

| Layer | 抽象層級 | 類比 |
|-------|----------|------|
| **Domain Layer** | 最高 | 章（section）|
| **Category Layer** | 次高 | 節（subsection）|
| **Memory Trace Layer** | 次低 | 小節（subsubsection）|
| **Episode Layer** | 最低 | 內容（content）+ 用戶 profile |

上三層作為漸進式索引，最底層儲存實際的事件內容與用戶資訊。

### 2. Positional Index Encoding（位置索引編碼）

每層的 memory vector 都嵌入一個**位置索引編碼**，指向其在下一層中語義相關的子記憶。這使得：
- 檢索時不需要對所有記憶做 exhaustive similarity search
- 只需沿著上層語義引導的 index 逐層向下搜尋
- 大幅減少無關資訊的參與，降低計算成本

### 3. 與現有方法的對比

論文批評現有方法的問題：

- **MemoryBank（向量檢索）**：記憶 entry 增加時，向量檢索複雜度急劇上升
- **A-MEM（Zettelkasten 網絡）**：結構複雜，維護和更新節點關係的一致性/準確性有挑戰
- **MemGPT（OS-style 分層）**：外部記憶依賴 RAG 模型，在大規模資訊處理時準確度和效率有取捨

### 4. 記憶更新機制

H-MEM 設計了一個「更科學」的記憶更新機制，適應人類複雜的心理變化。這意味著：
- 不是簡單的 append 或 fixed-threshold summarization
- 而是動態評估記憶的衰退與重要性

## 關鍵設計啟發

### 層級路由 vs 全域向量搜索

傳統方法：query 向量與所有記憶計算相似度，選 top-k
H-MEM：query 在上層開始，沿 index 逐層向下，只在相關分支計算

→ **這個設計對我們的 LLM Wiki 有直接參考價值**：目前的 graphify query 是全域搜索，可以考慮加入 topic → category → concept 的分層路由。

### 提取模型的角色

每輪 user-LLM 互動後，會呼叫一個專門的 memory extraction model 來分析對話，將資訊結構化寫入四層記憶。

→ **對我們三層記憶系統的啟發**：每次 heartbeat 可以有意識地「提取」值得升級到 MEMORY.md 的資訊，而非被動累積。

## 與其他論文的關聯

- **Dadhich ACM (2607.21503)**：H-MEM 的四層結構呼應了 ACM 的「五個 Primitives」，但 H-MEM 專注於記憶的**結構化組織**，ACM 強調的是**整個 lifecycle 的决策框架**
- **MemGPT**：H-MEM 受到 MemGPT 的分層架構啟發，但用 positional index 取代了向量檢索
- **MemoryBank**：H-MEM 直接解決了 MemoryBank 向量檢索複雜度膨脹的問題

## 值得討論的問題

1. **四層是否足夠？** 人類認知記憶遠比四層複雜，是否需要更多抽象層級？
2. **Index accuracy 的脆弱性**：如果上層索引選錯分支，會導致整條檢索路徑失敗。如何保證 index 的 reliability？
3. **計算節省 vs 召回率**：逐層路由節省計算，但是否犧牲了 recall？論文只在 LoCoMo 評估，泛化性待驗證。
4. **記憶更新的觸發時機**：何時觸發記憶整合/壓縮？論文的「科學更新機制」具體細節仍需深入閱讀。
5. **對 OpenClaw Agent 的實用性**：三層（SOUL/daily/MEMORY）vs 四層，是否有一個最佳粒度？
