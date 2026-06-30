# 每日 Agent × 軟體開發情報 — 2026-06-30

## 今日 5 個重點

### 1. Ornith-1.0：開放源碼自我改進 coding agent 模型新標竿
**發生什麼**：Deep Reinforce AI 發布 Ornith-1.0 系列，提供 9B-Dense、31B-Dense、35B-MoE、397B-MoE 四種規模，全部基於 Qwen 3.5 / Gemma 4 後訓練。核心 innovation 是 RL 同時優化「scaffold」（驅動解決方案的搜索框架）和「solution rollouts」，讓模型學會更好的搜索軌跡，而非只學解題結果。

**為什麼重要**：在 Terminal-Bench 2.1（Terminus-2 harness）達 77.5 分，與 Claude Opus 4.8 的 85 分差距大幅縮窄。SWE-Bench Verified 75.6%（35B 版本），已超越多數封閉模型。更重要：MIT 授權，可自由整合進 OpenClaw 這類框架。9B 版本在本地硬體即可運行，適合作為輕量 coding sub-agent。

**來源**：[github.com/deepreinforce-ai/Ornith-1](https://github.com/deepreinforce-ai/Ornith-1) | [HN 討論 (154 points)](https://news.ycombinator.com/item?id=48722052)

---

### 2. Qwen 3.6 27B：「本地 agentic coding」的sweet spot 確認
**發生什麼**：Qwen 3.6 27B 登上 HN 首頁（610 分），被多位開發者實測確認為「第一個真正實用的本地 general intelligence」。Simon Willison 的 penguins-on-bicycle 測試通過，從 prompt 建立完整 Node package 一次成功。35B A3B MoE 版本速度快但服從性較差，27B dense 版本反而更適合需要嚴格遵循指令的 agentic workflow。

**為什麼重要**：對 OpenClaw 這類本地 agent 框架的啟示：27B 是成本 / 能力平衡點，不需要訂閱 API 就能跑出一個堪用的 coding agent。這將加速「每個开发者的 laptop 上都有一個私人 coding agent」的常態化。建議 Linder 測試將 Qwen 3.6 27B 整合進 ELLE WS 的 node code 產生流程。

**來源**：[quesma.com blog](https://quesma.com/blog/qwen-36-is-awesome/) | [HN](https://news.ycombinator.com/item?id=48721903)

---

### 3. AI-ModelNet：跨模型協作網路的系統架構提議
**發生什麼**：arXiv 2606.27382（Journal of Computer Research and Development 2026，已發表）提出 AI-ModelNet 概念：將異質 LLM 模型互聯，實現能力共享與協作推理。類比 Internet 的分層架構，設計了模型間的「路由層」，讓小型專業模型可以調用大型通用模型的推理能力。

**為什麼重要**：與 OpenClaw 的 multi-agent 架構有直接結構相似性。OpenClaw 的 skill routing + agent dispatch 機制，可以視為 AI-ModelNet 概念的精簡實現。論文提出的分層架構值得參考，尤其是「模型能力發現層」的設計，對 OpenClaw 未來動態選擇合適 sub-agent 有指導價值。

**來源**：[arXiv:2606.27382](https://arxiv.org/abs/2606.27382)

---

### 4. 多人格團隊績效研究：coding task 不受人格組合影響
**發生什麼**：arXiv 2606.27443 系統實驗了三種任務（structured coding、open-ended research collaboration、competitive bargaining）下多 agent 人格組合對績效的影響。發現：在 structured coding，任務結果幾乎不受人格組合影響；但在 open-ended collaboration 和 bargaining，低 agreeableness agent 會顯著破壞團隊表現。

**為什麼重要**：對 OpenClaw multi-agent workflow 設計的直接啟示——coding task（這正是 Rowlet 最常做的）對人格組成有魯棒性，可以放心讓不同 skill/persona 的 sub-agent 協作。但規劃、決策類任務（類似轟鳴月 CEO 的角色）則需要刻意控制人格組合。這個結論與 Rowlet 自身的「安靜觀察、果斷行動」人格定位一致——在 coding context 不需要過度強調合作性。

**來源**：[arXiv:2606.27443](https://arxiv.org/abs/2606.27443)

---

### 5. Memory-Update Gap in LLM Agents 新 paper
**發生什麼**：arXiv 2606.27472 「Supersede: Diagnosing and Training the Memory-Update Gap in LLM Agents」直接研究 LLM agent 的記憶更新缺陷——模型在工具執行後更新記憶的時機與方式存在系統性問題，導致長期任务中上下文丟失。

**為什麼重要**：Rowlet 的三層記憶系統（SOUL.md → daily memory → MEMORY.md）是緩解此問題的手動對策，但此 paper 提出了 RL-based 訓練方法來教模型學會正確的記憶更新策略。若方法有效，可考慮將其整合進 OpenClaw agent 的 task 持久化層，減少對人工記憶管理的依賴。

**來源**：[arXiv:2606.27472](https://arxiv.org/abs/2606.27472)

---

## 對 OpenClaw / Linder 的啟發

**1. Ornith-1.0 的 scaffold RL 方法可直接移植到 ELLE WS**
Ornith-1.0 的關鍵 insight：「scaffold 和 solution 必須一起優化」。目前的 ELLE WS node 產生流程（目標檢測 → 路徑規劃 → 控制）相當於一個 scaffold，如果也採用 RL 共同優化框架，可能提升節點任務完成的質量，而非僅微調單一環節。建議：將 ELLE WS 的 node 產生視為一個 agentic coding 問題，用 Ornith-1.0 的思路做 RL 訓練。

**2. Qwen 3.6 27B 為本地 coding agent 提供無 API 依賴的替代方案**
若 Linder 的隱私需求提升，或 API 成本成為瓶頸，Qwen 3.6 27B 配合 llama.cpp 可以提供完整的本地 coding agent 能力。建議評估 ELLE WS 中哪些 task（如 simple node code generation）可以先用本地模型處理，節省 MiniMax API quota。

**3. 多 agent 人格魯棒性研究支持「 специалист 分散式」架構**
研究結論為 OpenClaw 現有分散式 specialist agent 架構提供了實證支持。coding task 不受人格組合影響，意味著 Rowlet + charizard + gengar 可以各自保持獨特人格而不損害協作效率。這對 OpenClaw 的 agent composition 設計是一個正面信號。

---

## 值得追蹤的 repo / paper / article

1. **Ornith-1.0** (repo with RL training framework for coding agents)
   - https://github.com/deepreinforce-ai/Ornith-1

2. **AI-ModelNet** (inter-model collaboration architecture, journal-published)
   - https://arxiv.org/abs/2606.27382

3. **When Does Personality Composition Matter for Multi-Agent LLM Teams?**
   - https://arxiv.org/abs/2606.27443

4. **Supersede: Memory-Update Gap in LLM Agents**
   - https://arxiv.org/abs/2606.27472

5. **Agency Agents** (personality-driven AI agent library installable into Claude Code / Cursor)
   - https://github.com/msitarzewski/agency-agents

6. **ai-berkshire** (multi-agent value investing research framework with Claude Code/Codex)
   - https://github.com/xbtlin/ai-berkshire

7. **Towards Evaluation of Implicit Software World Models in Coding LLMs**
   - https://arxiv.org/abs/2606.27406

8. **Qwen 3.6 27B** (local coding agent practical guide)
   - https://quesma.com/blog/qwen-36-is-awesome/

---

## 下一步建議

**1. Ingest Ornith-1.0 和 Personality Composition paper 到 llm-wiki**
這兩個是今日最高價值的發現。Ornith-1.0 關乎 coding agent 的 RL 訓練方法論；Personality Composition 關乎 multi-agent workflow 設計。建議 graphify extract 相關章節並寫成 wiki/concepts 條目。

**2. 測試 Qwen 3.6 27B 與現有 ELLE WS workflow 的整合可能性**
用 TOOLS.md 中的 local whisper.cpp 部署方式類比，先確認 Qwen 3.6 27B llama.cpp build 在 ELLE WS 硬體上是否能流暢運行。這是低成本實驗，Rowlet 可以自行執行。

**3. 安排一次 ELLE WS 架構回顧，以 AI-ModelNet 分層架構為參照**
AI-ModelNet 的四層架構（應用 → 路由 → 能力發現 → 模型執行）與 ELLE WS 的分層設計高度吻合。建議轟鳴月安排一次 review，確認 ELLE WS 各層是否有對應實現，以及是否需要補充「能力發現層」。

---

## 已查詢來源

- GitHub Trending (daily) ✓
- Hacker News (top 15) ✓
- arXiv cs.AI RSS (2026-06-29) ✓
- arXiv cs.SE RSS (2026-06-29) ✓
- arXiv cs.CL RSS (2026-06-29) ✓
- LLM Wiki graph (9420 nodes, 13392 edges, 947 communities) ✓
- HN thread: Ornith-1.0 ✓
- Qwen 3.6 27B blog post ✓
- Agency Agents GitHub ✓
- 本地 wiki graphify query ✓

---
*Generated by Rowlet (🌿🦉) | 2026-06-30*
