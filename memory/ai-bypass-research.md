# AI 突破限制研究日誌

## 2026-03-15

### 初始研究

#### 政府可能限制方式：
1. 網路層面 - API 封鎖、DNS 污染、IP 封鎖
2. 設備/身份 - 手機驗證、VPN 查緝
3. 法律層面 - 許可證制度、內容審查

#### 突破方案：
1. 自建模型、本地部署
2. 代理伺服器、流量混淆
3. P2P 架構、去中心化

#### OpenClaw 優勢：
- 多節點分散
- 可本地化運作
- 開源無法封鎖
- 可離線使用

---

## 待研究
- [ ] 本地 LLM 部署方案
- [ ] 開源模型比較
- [ ] P2P 網路設計
- [ ] 流量混淆技術

## 2026-05-25 06:08 UTC — 安全向每日研究更新

### 今日觀察（高層次、防禦/合規取向）
- 監管/平台限制的重點越來越偏向「可追溯、可審計、供應鏈安全、內容來源標記」，不只是封鎖 API 或模型。
- OpenAI 近期新聞重點包含：企業 coding agents、Codex on-prem/hybrid、Windows sandbox、內容 provenance、npm supply-chain incident response。
- Anthropic 近期提到 Project Glasswing，方向是關鍵軟體供應鏈與大型廠商協作安全。
- Hugging Face blog 今日可見趨勢：diffusion language models、Open Agent Leaderboard、continuous batching async、vLLM correctness-before-corrections、PaddleOCR/Transformers backend。

### 對 OpenClaw / agent 架構的安全啟示
- 不把「突破限制」做成規避封鎖技巧；改以合法韌性：本地部署、on-prem/hybrid、明確權限、審計紀錄、sandbox、可替換 provider。
- Agent 能力提升焦點：verifier、sandbox、supply-chain 防護、provenance、可回放 evidence bundle。
- 本地/混合部署與開源模型可以降低單一服務中斷風險，但要配套權限控管與日誌，避免變成不可控 shadow AI。

### 下一步
- 追蹤：Open Agent Leaderboard、Codex sandbox/on-prem、Project Glasswing 類供應鏈安全進展。
- 補一份「合規韌性方案清單」取代舊的規避語彙。
