# 架構師每日情報 2026-06-09

## 本日重點發現

1. **Agent Skills 正式標準化 — arXiv 2602.12430 綜合論文出爐**
2. **Skill-R1：用 RL 取代 Prompt Engineering 進化 Skill Artifact**
3. **Harness Engineering 完整指南問世 — 6 Layer 架構共識成型**
4. **26.1% 社群 Skill 含有漏洞 — 安全性成為關鍵議題**
5. **LangGraph 2026 benchmark 達 87% 任務成功率**

---

## 詳細內容

### 1. Agent Skills 正式標準化 — arXiv 2602.12430

浙江大學研究團隊發表首篇全面性 Agent Skills 綜論論文，涵蓋四大軸線：

- **架構基礎**：SKILL.md 規格、漸進式上下文載入、Skills 與 MCP 的互補角色
- **技能獲取**：RL with Skill Libraries (SAGE)、自主技能發現 (SEAgent)、組合式技能合成
- **部署規模**：CUA stack、GUI grounding、OSWorld / SWE-bench benchmark 進展
- **安全性**：26.1% 社群貢獻的 skill 含有漏洞，提出 Skill Trust and Lifecycle Governance Framework

**核心洞察**：從單一語言模型到模組化技能 Agent 的轉變，是 2025-2026 年部署範式的關鍵轉折。Skills 供「做什麼」，MCP 供「如何連接」。

> arXiv: https://arxiv.org/abs/2602.12430  
> GitHub resources: https://github.com/scienceaix/agentskills

---

### 2. Skill-R1：用 RL 取代 Prompt Engineering 進化 Skill Artifact

UC San Diego + Adobe Research 提出 Skill-R1 框架，將 Skill 優化重新定義為**雙層優化問題**：

- **Generation 內**：同技能條件下的 rollout 群組相對比較
- **Generation 間**：技能修訂是否在連續世代中改善誘導行為

**關鍵創新**：訓練一個輕量級 skill generator，而非更新任務 LLM 本身。保持對閉源模型的黑箱相容性，同時適應成本遠低於模型層級更新。

適用場景：多步驟、複雜任務，單次 Prompt 優化方法難以處理的場景。

> arXiv: https://arxiv.org/html/2605.09359v1

---

### 3. Harness Engineering 完整指南 — 2026 六層架構共識

FutureAGI 整理 2026 年 LLM Agent 標準六層架構：

| Layer | 負責 | 2026 主流選擇 |
|-------|------|--------------|
| Model Core | 推理引擎 | GPT-5, Claude Opus 4.7, Gemini 3.x, Llama 4 |
| Memory | 工作/情節/程序記憶 | Mem0, Letta, Zep; 向量庫 + 結構化表 |
| Tools | 外部行動 | Typed function calls, MCP servers, 程式執行 |
| Planner | 目標分解 | ReAct, Plan-and-Execute, Reflexion, ToT |
| Runtime | 狀態/重試/交接 | LangGraph, CrewAI, OpenAI Agents SDK, MS Agent Framework |
| Observability + Eval | 追蹤/評分/護欄 | Future AGI traceAI + Agent Command Center |

**重要趨勢**：OpenAI Swarm 2026 初被封存，由 production Agents SDK 取代；Microsoft 推出統一的 Agent Framework。

---

### 4. 社群 Skill 安全性危機 — 26.1% 含有漏洞

論文 arXiv 2602.12430 揭露：社群貢獻的 skill 中，超過四分之一存在安全漏洞。研究者提出 **Skill Trust and Lifecycle Governance Framework** — 四層閘道式權限模型，依技能來源調整部署能力。

這是首篇系统性處理 Agent Skill 安全性的研究，顯示技能生態系統的信任問題已經浮上檯面。

---

### 5. GEPA：反思式 Prompt 演化可超越 RL

ICLR 2026 Oral Paper。UC Berkeley + Stanford + UT Austin 聯合提出 **GEPA (Generalized Evolutionary Prompt Algorithm)**，核心主張：**反思式 Prompt 演化在特定任務上可以超越強化學習**。

適用場景：需要針對特定任務實例優化 Prompt 的情境，而非泛化到所有任務。

> arXiv: https://arxiv.org/abs/2507.19457

---

### 附錄：參考資源索引

| 主題 | 資源 |
|------|------|
| Agent Skills 綜論 | arxiv.org/abs/2602.12430 |
| Skill-R1 (RL Skill 優化) | arxiv.org/html/2605.09359v1 |
| Harness Engineering 指南 | nxcode.io, futureagi.com |
| Awesome Harness Engineering | github.com/ai-boost/awesome-harness-engineering |
| GEPA (Prompt Evolution) | arxiv.org/abs/2507.19457 |
| LLM Agent Architectures 2026 | futureagi.com/blog/llm-agent-architectures-core-components/ |

---

## 執行狀態

- 任務完成時間：2026-06-09 18:03 UTC
- 消耗 tokens：搜尋 3 次 + fetch 6 次（估計約 45,000 tokens input）
- 報告目標路徑：`/home/node/.openclaw/workspace-rowlet/architecture-daily-report.md`
- Wiki 更新：`/home/node/.openclaw/workspace-rowlet/ai-agent-wiki/wiki/raw-sources-list.md`