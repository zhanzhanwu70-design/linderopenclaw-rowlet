---
title: "OpenClaw 系統架構圖"
type: concept
tags: [openclaw, architecture, gateway, websocket, rpc, plugin, multi-agent, channel, session, model-provider]
status: completed
created: 2026-07-03
updated: 2026-07-03
source_image: raw/images/openclaw-architecture-diagram.png
---

# OpenClaw 系統架構

## 圖例

| 顏色 | 角色 |
|------|------|
| 🟧 橘色 | User / External（使用者 / 外部系統） |
| 🟦 淺藍 | CLI / Entry（命令列介面與進入點） |
| 🟩 綠色 | Gateway / Server（通訊閘道與伺服器） |
| 🟪 紫色 | Execution / Runtime（執行階段 / 插件擴充） |
| 🟦 深藍底 | Platform / Docs（平台與文件） |

| 線型 | 意義 |
|------|------|
| ➡️ 實線 | Sync Flow / Call（同步流程呼叫） |
| ⤳ 虛線 | Async / Event（非同步事件） |
| ⤏ 點虛線 | Plugin Integration（插件整合介面） |

---

## 分層架構

### 第一層：User / Operator（使用者）

- 人類操作員或自動化腳本
- 唯一入口：`Terminal / Shell`
- 透過 shell 啟動 `openclaw` 指令

### 第二層：Entry & Bootstrap（進入與啟動層）

```
openclaw.mjs（JS Launcher）
    ├── 檢查 Node 版本
    ├── 編譯快取
    ├── 啟用幫助快速路徑
    └── 載入 dist/entry.js
         ↓
src/entry.ts（TS Runtime Entry）
    ├── Profile 容器化
    ├── 強制 No color 模式
    ├── Respawn（如有必要）
    └── 呼叫 runCli() 進入 CLI 主體
```

### 第三層：CLI Core（命令列核心）

| 檔案 | 功能 |
|------|------|
| `run-main.ts` | CLI Runner 主入口 |
| `builder.ts` | CLI Builder，組裝指令 |
| `register-commands.ts` | 註冊所有子指令 |
| `fast-path.ts` | 快速處理 help/version |
| `help.ts` | 幫助中繼資料 |

**Commands：**
- `agent` → Agent 管理
- `status` → 系統狀態
- `tasks` → 任務管理
- `gateway` → Gateway 控制

**關鍵節點：** `call.ts`（Gateway Client）是 CLI 與 Gateway 之間的 RPC 客戶端

### 第四層：Gateway（WebSocket Server）

#### Server Core
| 元件 | 功能 |
|------|------|
| WebSocket Server | 連線管理與身份驗證 |
| RPC Router | 把 RPC 方法路由到對應處理器 |
| State & Events | 廣播 / 訂閱狀態變化 |

#### Server Methods
| 模組 | 用途 |
|------|------|
| `chat.ts` | 聊天方法 |
| `session.ts` | 會話管理 |
| `node.ts` | 節點操作 |
| `control-ui.ts` | 控制 UI 介接 |
| `state.ts` | 狀態方法 |

### 第五層：External Channels / Platforms

Gateway 對接的第三方訊息平台：
- **WhatsApp** 📱
- **Telegram** ✈️
- **Slack** 💬
- **Discord** 🎮

### 第六層：Agents / Sessions / Channels（執行三柱）

#### Agents
- `agent-command.ts` → Agent 指令處理器
- `attempt-execution.ts` → 執行單次推理嘗試
- `model-fallback.ts` → 當主模型失敗時切換備援模型

#### Sessions
- Session Store（DB / Files / Memory）
- 提供 Transcripts（對話記錄）

#### Channels
- Conversation / Session Mapping
- Allowlist & Gating（白名單與權限控管）

### 第七層：Model Provider / Agent Harness

支援多家 LLM Providers：
- OpenAI 🤖
- Anthropic 🧠
- Ollama 🦙（本地）
- 本地其他模型

### 第八層：Tools / Skills / Resources

提供 Agent 可調用的能力：
- 🔧 **MCP**（Model Context Protocol）
- 🌐 **Browser**（瀏覽器操作）
- 💻 **Shell**（命令執行）
- 📂 **Files**（檔案系統）
- 🔍 **Search / RAG**（檢索增強生成）

### 第九層：Plugins & Extensions（插件擴充層）

#### Plugin System (Core)
- Discovery（自動發現）
- Manifest（清單）
- Lifecycle（生命週期）
- Runtime Loading（執行期載入）
- CLI Command Registration（CLI 指令註冊）

#### Extensions
| 插件類型 | 用途 |
|----------|------|
| **Provider Plugins** | 模型提供者 |
| **Channel Plugins** | 訊息通道 |
| **Memory Plugins** | 記憶 / RAG |
| **Diagnostics Plugins** | 日誌 / 指標 |
| **Tool Plugins** | 工具整合 |

### 第十層：Apps / Shared Packages / Docs

#### Apps (Platform)
- Web UI / Dashboard（網頁儀表板）
- Control Panel（控制台）

#### Shared Packages
| 套件 | 內容 |
|------|------|
| Gateway Protocol | RPC / WS 協議 |
| Terminal Core | Terminal 抽象 |
| Normalization Core | 資料正規化 |

#### Documentation
- `docs/`（Mintlify）
- Developer & Operator Docs

---

## 數據流向

### 路徑 1：本地使用者操作
```
User → Shell → openclaw.mjs → entry.ts → CLI Core
     → call.ts → Gateway (WebSocket) → Server Methods
     → Agents → Model Provider → Tools → 回傳
```

### 路徑 2：外部平台訊息
```
WhatsApp/Telegram/Slack/Discord → Channel Adapters
     → Session Store → Agent → Model + Tools
     → 寫回 Session → 透過 Channel 回覆平台
```

### 路徑 3：狀態事件廣播
```
Agent / Session / Channel 變更 → State & Events
     → 廣播給所有訂閱者（WebSocket Clients）
```

### 路徑 4：插件掛載
```
Plugin System 同時整合：
  CLI 註冊 ↔ Gateway 路由 ↔ Agents 能力
  ↔ Channels 通道 ↔ Tools 工具
```

---

## 設計亮點

1. **多端入口**：CLI、Web UI、外部平台 全部匯入 Gateway 統一處理
2. **WebSocket + RPC**：低延遲雙向通訊，適合即時對話與狀態推送
3. **插件化架構**：Provider、Channel、Tool、Memory、Diagnostics 全部可熱插拔
4. **會話 / 通道 / 代理 三分離**：職責清晰，便於水平擴展
5. **模型回退機制**：避免單一模型故障造成服務中斷
6. **共享套件層**：確保所有上層模組使用一致的協議、終端與資料格式

---

## 核心定位

這是一個 **以 Gateway 為核心、以插件為擴充、以多通道為入口、以 LLM 為大腦** 的現代 AI Agent 平台架構。

- **Gateway = 系統中樞**：所有流量都經過它
- **Plugin System = 擴充骨幹**：所有模組可熱插拔
- **Agent / Session / Channel 三柱 = 執行單元**：各自專注自己的職責
