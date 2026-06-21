# 架構師每日情報 2026-06-20

## 本日重點發現

### 1. Skill-MAS：突破性的 Meta-Skill 進化框架
**LLM Multi-Agent System 的第三條路**

提出了一個關鍵突破：將「經驗保留」與「參數更新」解耦，透過可進化的 Meta-Skill 架構來解決現有方法的兩難：
- **推理時 MAS**：使用 frozen frontier LLMs 但無法從過去經驗學習
- **訓練時 MAS**：透過梯度更新內化經驗，但受限於小模型能力上限

Skill-MAS 的解決方案：
1. Multi-Trajectory Rollout：在當前 Meta-Skill 下對每個任務採樣行為分佈
2. Selective Reflection：適應性選擇優先任務，應用階層式對比分析，將系統經驗蒸餾為可推廣的策略級原則

**意義**：這與 OpenClaw 的 skill 概念高度相關，可能是未來 skill 自動進化的參考架構。

📎 [arXiv:2606.18837](https://arxiv.org/abs/2606.18837)

---

### 2. NORA：Harness Engineering 的典範研究
**專為空間數據科學設計的自主研究代理**

NORA (Night Owl Research Agent) 提出了 **harness engineering** 的正式概念，證明「領域專門化的 harness 工程」能顯著提升研究輸出品質。

核心組件：
- 21 個領域專門化 workflow skills
- 9 個專業子代理
- 自訂 MCP 伺服器

關鍵的 harness 設計原則：
- Lifecycle hooks
- Safety gates
- Generator-evaluator 分離
- Human-in-the-loop
- State persistence

**意義**：對於 OpenClaw 的 skill 框架設計有直接參考價值，特別是關於如何確保可靠性和可重複性的工程實踐。

📎 [arXiv:2605.02092](https://arxiv.org/abs/2605.02092)

---

### 3. LLM Agent 通訊協議的技術分類學
**首個全面的 Agent 間通訊協議分類**

隨著多代理系統的發展，通訊協議的標準化變得至關重要。這篇論文提供了：
- Agent 通訊協議的技術分類
- 協議設計的關鍵維度分析
- 跨系統互通性的挑戰與解決方案

**意義**：對於 OpenClaw 多代理協作框架的協議設計有重要參考價值。

📎 [arXiv (Submitted 17 June, 2026)](https://arxiv.org/search/?searchtype=all&query=LLM+agent+communication+protocol+taxonomy+2026)

---

### 4. Rollout Strategies for LLM RL 綜合調查
**強化學習中 rollout 策略的完整分類**

這篇 survey 覆蓋了 LLM 強化學習中的四種核心策略：
1. **Generate**：生成策略
2. **Filter**：過濾策略
3. **Control**：控制策略
4. **Replay**：回放策略

對於 skill/prompt 優化有直接影響：了解 rollout 策略的優缺點有助於設計更有效的 RL-based prompt 優化系統。

📎 [arXiv (Submitted 7 April, 2026)](https://arxiv.org/search/?searchtype=all&query=rollout+strategy+LLM+reinforcement+learning+survey+2026)

---

### 5. MCP 生態系統的快速成熟
**Model Context Protocol 的多項新研究**

本月出現多個 MCP 相關研究：
- **MCP-Atlas**：大規模真實 MCP 伺服器的工具使用能力基準
- **ProvenanceGuard**：MCP 代理的來源感知事實驗證
- **MCP-Persona**：透過環境模擬評估 LLM 代理在現實應用中的表現
- **ComplexMCP**：動態、相互依賴、大規模工具沙箱中的 LLM 代理評估

**意義**：MCP 作為 OpenClaw 的工具接口標準，這些研究提供了重要的性能評估和安全參考。

---

## 詳細內容

### Topic 1: Agent Architecture / Skill Systems

**Skill-MAS: Evolving Meta-Skill for Automatic Multi-Agent Systems**
- Authors: Hehai Lin, Qi Yang, Chengwei Qin
- Submitted: 17 June 2026
- 核心創新：將高層編排能力概念化為可進化的 Meta-Skill，透過封閉優化迴圈（Multi-Trajectory Rollout + Selective Reflection）實現經驗保留
- 實驗：在四個複雜基準和四種不同 LLM 上驗證，展現優異的性能提升和跨任務/模型的轉移能力

**Superpowers Framework** (已存在于 wiki)
- 強調「技能觸發自動化」的 agentic 軟體開發方法論
- 支援多種 coding agent（Claude Code, OpenAI Codex, Cursor, etc.）

### Topic 2: Multi-Agent Architecture

**EARS: Explanatory Abstention for Reliable Sub-Agent Modeling**
- 大規模企業設置中，集中式多代理系統的 coordinator 將用戶請求委派給輕量級、領域專業化的子代理
- 提出可解釋的拒絕機制，提高系統可靠性

**CAPRA: Scaling Feedback on Software Architecture Deliverables**
- 多代理 LLM 系統，用於軟體架構交付物的自動評估
- 填補了軟體工程教育中自動化架構審查的空白

### Topic 3: Harness Engineering / Workflow Orchestration

**CAX-Agent: A Lightweight Agent Harness for Reliable APDL Automation**
- 針對 MAPDL 有限元素模擬的可靠性挑戰
- 核心：結構化執行控制、工具封裝、故障恢復

**DynAMO: Dynamic Asset Management Orchestration**
- 透過拓撲多代理調度實現動態資產管理編排
- submitted: 14 June 2026

### Topic 4: Skill Artifact Optimization / RL

**On Effectiveness and Efficiency of Agentic Tool-calling and RL Training**
- 研究 tool-calling 與 RL 訓練的有效性和效率
-  Submitted: 28 May 2026

**Generate, Filter, Control, Replay: Survey of Rollout Strategies for LLM RL**
- 21 位作者的大型 survey
- 系統化分類 LLM RL 中的 rollout 策略

---

## 額外觀察

1. **ArXiv 論文爆發**：2026年6月的多代理和 agent 架構論文數量明顯增加，特別是涉及 Meta-Skill、harness engineering、和 MCP 協議的研究

2. **領域專門化趨勢**：越來越多的研究強調領域專門化的 agent 和 harness設計，而非通用解決方案

3. **安全研究興起**：隨著 agent 系統部署增加，安全性研究（MCP poisoning、ADR、Prompt injection）也在快速增長

4. **OpenClaw 相關性**：本機制收集的論文與 OpenClaw 架構高度相關：
   - Skill-MAS → skill 自動進化
   - NORA → harness engineering 最佳實踐
   - MCP-Atlas/ProvenanceGuard → MCP 工具介面安全性
   - EARS/CAPRA → 多代理協作與審查

---

## 執行狀態

- **任務完成時間**：2026-06-20 18:28 UTC
- **主要資訊來源**：arXiv e-print repository
- **搜尋關鍵詞**：agent architecture, multi-agent LLM, harness engineering, workflow orchestration, RL prompt optimization, MCP
- **報告產出**：
  - 主報告：`~/workspace-rowlet/architecture-daily-report.md`
  - Wiki 更新：`~/workspace-rowlet/wiki/sources/architecture-daily-2026-06-20.md`
