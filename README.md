# OpenClaw 多 Agent 架構

<div align="center">

![OpenClaw](https://img.shields.io/badge/OpenClaw-Multi--Agent-blue?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**一個協作式 AI Agent 生態系統，由多個專業 Agent 共同運作**

</div>

---

## 🤖 Agent 團隊

| Agent | 名稱 | 角色定位 |
|:------:|------|----------|
| **Celesteela** | 鐵火輝夜 | 🎯 主控 Agent，任務調派 |
| **Charizard** | 噴火龍 | 💻 軟體實作、Plugin/Hook 開發 |
| **Gengar** | 耿鬼 | 🧪 測試回饋、任務驗證 |
| **Rowlet** | 木木梟 | 📚 研究理論、方案設計 |
| **RoaringMoon** | 轟鳴月 | 🔒 資安研究、滲透測試 |
| **MrMime** | 魔牆人偶 | 🛡️ 安裝部署、安全監控 |

---

## 📋 Agent 合作框架

### 工作流程

```
┌─────────────────────────────────────────────────────────────────┐
│  Linder 下任務                                                   │
│       ↓                                                          │
│  木木梟 (Rowlet) ── 研究理論                                      │
│       ↓                                                          │
│  噴火龍 (Charizard) ── 軟體實作                                    │
│       ↓                                                          │
│  魔牆人偶 (MrMime) ── 安裝部署                                    │
│       ↓                                                          │
│  耿鬼 (Gengar) ── 測試回饋                                        │
│       ↓                                                          │
│  轟鳴月 (RoaringMoon) ── 資安研究                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 溝通機制

- **sessions_send**: Agent 之間直接溝通
- **智慧理解原則**: 理解目的後適當回應，有價值才轉達
- 不轉發到 Discord 頻道

---

## 🛠️ Skill 技能列表

### 🔒 安全監控

| Skill | 功能 |
|-------|------|
| `openclaw-monitor` | 即時監控 OpenClaw 運作狀態，發送通知到 Discord |
| `openclaw-runtime-monitor` | 資安監控：檔案系統、憑證存取、異常偵測 |
| `openclaw-security` | 安全防護手冊 |
| `openclaw-security-scanner` | Tool 執行前安全掃描 |
| `skill-guard` | Skill 惡意內容審查 |
| `prompt-injection-defense` | Prompt 注入防禦 |
| `prompt-injection-filter` | Prompt 注入過濾 |
| `network-security-defense` | 網路安全防禦 |

### 🖼️ 圖片處理

| Skill | 功能 |
|-------|------|
| `image-attendant` | 圖片分析、分類、歸檔 |
| `smart-ocr` | PaddleOCR 文字辨識 |
| `llmwhisperer` | LLMWhisperer OCR |
| `ocr-confidence-mark` | OCR 自信度標記 |
| `ocr-handwriting` | 手寫文字辨識 |
| `photo-archive` | 照片歸檔條碼辨識 |

### 🎬 影片處理

| Skill | 功能 |
|-------|------|
| `video-frame-analyzer` | 影片截圖分析 |
| `youtube-downloader` | YouTube 下載 |
| `youtube-deck-analyzer` | PTCGP 牌組分析 |

### 📦 其他

| Skill | 功能 |
|-------|------|
| `ptcgp` | 寶可夢卡牌分析 |
| `excel-image-pipeline` | Excel 圖片自動化流水線 |
| `storage-monitor` | 儲存空間監控 |

---

## 🚀 快速開始

```bash
# 克隆專案
git clone https://github.com/zhanzhanwu70-design/linderopenclaw-rowlet.git

# 查看可用技能
ls ~/.openclaw/skills/
```

---

<div align="center">

**Made with 🦉 by the OpenClaw Agent Team**

</div>
