---
title: "The best AI agents are simpler than you think - Sierra agents interview"
type: source
tags: [sierra, langchain, customer-experience-agents, voice-agents, ghostwriter, agent-harness, multi-model, pci-compliance, outcome-based-pricing]
status: completed
created: 2026-06-28
updated: 2026-06-28
source: https://youtu.be/uCKhOmth2ms
uploader: LangChain
duration: "1:27:25"
---

# The best AI agents are simpler than you think

## Summary
LangChain  podcast 訪談 Sierra 產品長 Zach Renaud-Wedeen，解析 Sierra 如何構建企業級客戶體驗代理平台。核心主題：為何最好的 AI agent 比想像的更簡單、Sierra 的 Analyze/Build/Release 工作流、多模型並行架構、語音代理的特殊設計。

## Sierra 公司背景

- **定位**：企業客戶體驗代理平台（Customer Experience Agent Platform）
- **客戶**：Fortune 20 大部分企業、40-50% Fortune 50/100
- **定價**：Outcome-based pricing（按結果收費，如銷售佣金）
- **願景**：不只是客服，而是客戶生命週期全階段的 engagement 平台

## 三階段工作流：Analyze / Build / Release

### Analyze（分析）
- **Explorer Agent**：類似 ChatGPT Deep Research，針對客戶對話數據的長期研究
- **Reports**：對話數據報表
- **Monitors**：持續監控對話品質

### Build（構建）
- **Ghostwriter**：AI agent 構建工具，類似 Codex / Claude Code
- **Journeys**：自然語言標準作業程序（不是 code，是 SOP）
- **Variables**：變量管理

### Release（發布）
- 協作流程
- Change management
- 治理程序（governance）

### 循環
```
日常流程：Analyze → Build → Release
Ghostwriter 會主動根據 insights 建議改進，閉環 feedback
```

## 語音代理的特殊架構

### 平行思考、傾聽、說話
Sierra agent 的核心突破：**同時**進行這三件事**（parallelize thinking, listening, talking）**。

```
傳統架構：傾聽 → 思考 → 回應（串行）
Sierra 架構：三件事同時並行（並行）
```

### 多模型協作
- 單一對話 turn 可能調用 10-15 個不同的模型
- 有時分類（classifying）和回應（responding）同時發生
- 設計關鍵：**信任模型輸出**，不強制串行化

## 支付隔離架構

### PCI 合規問題
> "We have isolated infrastructure where payment info doesn't go to an external large language model because none of the LLM providers are PCI certified in that way"

- 支付資訊必須隔離
- 不能送進外部 LLM（沒有 PCI 認證）
- 需要獨立的基礎設施層

## 與傳統 Agent Harness 的差異

| 維度 | 標準 Harness（如 Codex）| Sierra 架構 |
|------|------------------------|------------|
| 工具調用 | 單一 agent 串行 | 多模型並行 |
| 語音處理 | 不支援 | 原生支援 parallel thinking |
| 支付安全 | 無特殊設計 | 隔離基礎設施 |
| 工作流 | Code-centric | Natural language SOP |
| 目標用戶 | 工程師 | 業務人員（no-code）|

## 為何「更簡單」

訪談的核心論點：
1. **No-code agent building**：不需要寫 code，用自然語言描述 SOP
2. **Materialize to file systems**：讓 coding agent 能在檔案系統層級工作
3. **Trust the model**：不要過度干預模型輸出，讓架構自然呈現

## 與 Kun Chen Workflow 的比較

| 維度 | Kun Chen（船長模式）| Sierra |
|------|-------------------|--------|
| 核心哲學 | 人當船長，AI 當船員 | 平台讓業務人員也能建 agent |
| 工具 | 大量自建工具（No Mistakes 等）| Ghostwriter + Journeys |
| 語音 | 不支援 | 原生語音并行架構 |
| 目標用戶 | 工程師 | 企業業務人員 |
| 規模 | 個人/小團隊 | Fortune 20 企業級 |

---

## Transcription
全文 4068 行：`raw/video/2026-06-28-uCKhOmth2ms/audio.txt`

## Raw Files
- `raw/video/2026-06-28-uCKhOmth2ms/audio.webm`（94.5 MB）
- `raw/video/2026-06-28-uCKhOmth2ms/audio.wav`（164 MB）
- `raw/video/2026-06-28-uCKhOmth2ms/audio.txt`（4068 行）

## References
- Sierra: https://sierrasecurity.com/
- LangChain Podcast: https://blog.langchain.dev/