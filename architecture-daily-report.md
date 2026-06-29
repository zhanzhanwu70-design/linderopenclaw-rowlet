# 每日 Agent × 軟體開發情報 — 2026-06-29

**執行時間：** 2026-06-29 02:00 UTC  
**資料覆蓋：** arXiv (cs.AI, 131篇/日) · GitHub Trending · Hugging Face Papers · 新增repo監控

---

## 今日 5 個重點

### 1. Vercel Eve — Agent Framework 新勢力（⭐2860，2026-06-28 更新）
**發生什麼：** Vercel 發布 `eve`——一個以 TypeScript/JavaScript 為核心的 Agent 建構框架，主打 topics 包含 `agent`, `framework`, `harness`, `sandbox`, `workflows`。昨日更新，已累積近 3000 stars。

**為什麼重要：** Vercel 的加入代表主流前端/全端平台正式進場 agent infrastructure。它的 harness + sandbox 概念與 OpenClaw 的 tool-execution security 有高度結構相似性。關注它如何處理 multi-turn conversation state、credential isolation、和 workflow persistence——這些都是 OpenClaw正面對的課題。

**來源：** https://github.com/vercel/eve

---

### 2. ANIS — Agent-Native Immune System（arXiv:2606.28270，今日新鮮出爐）
**發生什麼：** 論文提出將免疫系統概念嵌入 agent 認知環（cognitive loop）本身，而非依賴外部防禦。提出六層 Immune Tower（L0-L5），含 Barrier Immunity（L1）隔離層、memory poisoning / tool-chain manipulation / multi-agent protocol attacks 的 vaccine taxonomy。

**為什麼重要：** 這是首篇將「agent runtime 安全」當作內生問題而非外掛問題的論文。對於 OpenClaw 這類多工具、多 session 架構，ANIS 的威脅模型（memory poisoning、tool-chain manipulation）直接適用。其「non-cognitive isolation layer」概念值得借鏡到 OpenClaw 的 sandbox 分層設計。

**來源：** https://arxiv.org/abs/2606.28270

---

### 3. ATOD — 多輪對話 Agent 的 OPD+RL 混合訓練（arXiv:2606.27814）
**發生什麼：** ATOD（Annealed Turn-aware On-policy Distillation）將 OPD（on-policy distillation）與 RL 混合，用 annealed schedule：前期 OPD 快速模仿老師，後期 RL 探索突破天花板。在 ALFWorld、WebShop 實測有效。

**為什麼重要：** 這對 OpenClaw 的 multi-agent workflow 最有直接意義——當多個 agent（轟鳴月、耿鬼、噴火龍）協作時，如何訓練每個 agent 的對話質量？ATOD 的「turn-level disagreement-uncertainty reweighting」T-DUR 機制可以直接啟發我們對 agent-to-agent 訊息質量的評估方法。

**來源：** https://arxiv.org/abs/2606.27814

---

### 4. Graph World Models — Agent/工具依賴圖的長期規劃誤差不確定性（arXiv:2606.27780）
**發生什麼：** 研究滾動規劃在圖結構世界模型（agents、tools、skills、dependencies構成的圖）中的誤差傳播。提出 Error-Aware GWM，結合光譜正則化、滾動一致性、critical-node 加權。動態邊（dynamic-edge）訓練是關鍵。

**為什麼重要：** 這幾乎是 OpenClaw skill/orchestration graph 的理論對應——當我們的 agent 跨 skill 調用形成依賴圖時，規劃誤差會沿邊傳播並放大。此論文提供了量化分析框架，可以幫助我們評估 skill 設計的穩健性，並預測長鏈 workflow 的失敗點。

**來源：** https://arxiv.org/abs/2606.27780

---

### 5. gamedev-skills/awesome-gamedev-agent-skills × Cloudflare security-audit-skill
**發生什麼：**
- `gamedev-skills/awesome-gamedev-agent-skills`（⭐164）：66 個便攜式 SKILL.md，橫跨 Godot、Unity、Unreal、Web，在 Claude Code、Cursor、Codex、Copilot、Gemini CLI 通用。含 master router 自動分發 skill。
- `cloudflare/security-audit-skill`（⭐1610）：多階段安全審計 skill，獨立驗證的 machine-readable findings。

**為什麼重要：** 兩者都印證了「skill-as-portable-unit」的架構方向——skill 不綁定單一 agent/IDE，而是跨平台運行。OpenClaw 的 skill 系統領先業界，但需要追上「skill router / skill registry」的自動發現機制。Cloudflare 的 security-audit skill 模式可以是我們 own security skill 的參考模板。

**來源：** 
- https://github.com/gamedev-skills/awesome-gamedev-agent-skills
- https://github.com/cloudflare/security-audit-skill

---

## 對 OpenClaw / Linder 的啟發

**① Agent runtime security 需要內建化（ANIS 啟發）**
OpenClaw 目前的安全機制（skill-guard、runtime-monitor）是外部補丁。ANIS 的 Layered Immune Tower 概念建議：將 credential isolation、tool-chain verification、memory poisoning detection 變成 OpenClaw agent loop 的內建層，而非外掛。

**② Skill graph 需要 Error-Aware 評估（Graph World Models 啟發）**
目前的 skill registry 是靜態的。可以借鑒論文的 critical-node weighting，用過去 workflow 失敗數據對每個 skill 節點加權，自動標記高風險 skill 組合鏈，變成動態的「skill reliability score」。

**③ ATOD-style training 優化 multi-agent 訊息路由**
多個 OpenClaw specialist agent（Rowlet、Gengar、Charizard）之間的溝通目前是啟發式。可以借鑒 ATOD 的 turn-level disagreement reweighting：讓 sending agent 對自己訊息做「可 follow 性」自評，receiving agent 對不理解的地方請求重述。

---

## 值得追蹤的 repo / paper / article

1. **vercel/eve** — Agent 建構框架（⭐2860）  
   https://github.com/vercel/eve

2. **cloudflare/security-audit-skill** — 多階段安全審計 skill（⭐1610）  
   https://github.com/cloudflare/security-audit-skill

3. **anthropics/launch-your-agent** — Claude Code → Managed Agent 部署技能（⭐552）  
   https://github.com/anthropics/launch-your-agent

4. **benchflow-ai/awesome-evals** — Agent eval 資源彙整（⭐564）  
   https://github.com/benchflow-ai/awesome-evals

5. **gamedev-skills/awesome-gamedev-agent-skills** — 66 個跨平台便攜 SKILL.md（⭐164）  
   https://github.com/gamedev-skills/awesome-gamedev-agent-skills

6. **ANIS: Agent-Native Immune System** (arXiv:2606.28270)  
   https://arxiv.org/abs/2606.28270

7. **ATOD: Multi-turn Agent OPD+RL Training** (arXiv:2606.27814)  
   https://arxiv.org/abs/2606.27814

8. **Error-Aware Graph World Models** (arXiv:2606.27780)  
   https://arxiv.org/abs/2606.27780

---

## 下一步建議

**① Ingest ANIS 論文到 llm-wiki**
這篇是近距離直接相關於 OpenClaw security architecture 的論文。建議 graphify → 建立 `wiki/concepts/Agent-Native-Immune-System.md`，並與既有的 `openclaw-security` skill 建立圖譜連結。

**② 評估 vercel/eve 的架構設計**
e ve 的 harness + sandbox + workflow 組合與 OpenClaw 的相似度值得做一次架構對照。如果它有值得抄襲的設計模式，可以考慮寫一個 `eve-vs-openclaw` 的 analysis note。

**③ 實驗：給 OpenClaw skill 加 reliability score**
用現有的 task/heartbeat log 數據，計算每個 skill 的歷史成功率，作為 dynamic routing 的依據。這是 Graph World Models 論文的實務落地，不需要新工具，用現有數據即可啟動。

---

## 已查詢來源狀態

| 來源 | 狀態 |
|------|------|
| arXiv cs.AI (131篇/日) | ✅ 成功，新鮮出爐 |
| GitHub Trending (agent/multi-agent) | ✅ 成功 |
| Hugging Face Papers | ⚠️ 頁面 JS render，內容截斷 |
| Hacker News (Algolia API) | ❌ API 回400，參數需調整 |
| InfoQ / Martin Fowler | ⚠️ 未查（RSS 需額外設定） |
| LangChain/LangGraph release notes | ⚠️ 未查 |

---
*Rowlet 🌿🦉 — 每日 Agent × 軟體開發情報*
