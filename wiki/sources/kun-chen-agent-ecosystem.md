---
title: "Kun Chen Agent Ecosystem（kunchenguid）"
type: source
tags: [agentic-engineering, kun-chen, ecosystem, firstmate, treehouse, no-mistakes, gnhf, lavish, axi, open-super-whisper, wezterm, tmux, neovim, worktree, multi-agent]
status: completed
created: 2026-06-30
updated: 2026-06-30
source: https://linktr.ee/kunchenguid
uploader: Kun Chen (kunchenguid)
---

# Kun Chen Agent Ecosystem

## Source
- LinkTree: https://linktr.ee/kunchenguid
- All tools maintained by **Kun Chen（kunchenguid）**

## 工具清單

| 工具 | 用途 | 安裝方式 |
|------|------|---------|
| [WezTerm](https://wezterm.org/) | 終端模擬器 | 跨平台，比 macOS Terminal 更強 |
| [tmux](https://github.com/tmux/tmux/wiki) | 終端複用器 | session 管理、分屏、跨設備 |
| [Neovim](https://neovim.io/) | 文字編輯 | 鍵盤導向編輯器 |
| [npx skills CLI](https://github.com/vercel-labs/skills) | Skill 安裝工具 | `npx skills add ...` |
| [OpenSuperWhisper](https://github.com/starmel/OpenSuperWhisper) | 語音輸入 | macOS 本地 Whisper 轉文字 |
| [AXI](https://axi.md/) | 工具設計原則 | 10 原則讓 CLI 對 agent 高效 |
| [Lavish](https://github.com/kunchenguid/lavish) | 視覺化規劃 | HTML artifact 協作介面 |
| [No Mistakes](https://github.com/kunchenguid/no-mistakes) | PR pipeline | 自動 review/test/push/PR |
| [GNHF](https://github.com/kunchenguid/gnhf) | 長時任務 | 睡覺時 autonomous iteration |
| [Treehouse](https://github.com/kunchenguid/treehouse) | Work tree 管理 | 池化 reuse，保留 build cache |
| [First Mate](https://github.com/kunchenguid/firstmate) | Agent 協調者 | 船長只跟 first mate 說話 |

---

## 整體架構

```
你（船長 / Captain）
    ↓
First Mate（第一副手 / 協調者 agent）
    ↓
├─ Treehouse（work tree 池管理器）
├─ tmux（終端 session 管理）
├─ Coding Agent（Claude Code / Codex / Open Code）
├─ No Mistakes（PR pipeline 自動化）
├─ GNHF（睡覺時 autonomous iteration）
└─ Lavish（視覺化規劃 artifact）
```

---

## 各工具詳解

### 1. AXI（Agent eXperience Interface）
**官網：https://axi.md**

**核心：10 個設計原則讓 CLI 工具對 agent 高效**

實測數據（Chrome DevTools 基準）：
| 工具 | 平均成本 | 平均耗時 |
|------|---------|---------|
| chrome-devtools-mcp | $0.120 | 36.2s |
| chrome-devtools-axi | **$0.074** | **21.5s** |
| agent-browser | $0.088 | 24.6s |

**為何差異這麼大：**
- CLI 輸出格式影響 agent 解析效率
- JSON vs 人類可讀格式的取捨
- 操作組合（combined operations）減少 round-trip

**Official AXIs：**
| AXI | 領域 | 說明 |
|-----|------|------|
| [gh-axi](https://github.com/kunchenguid/gh-axi) | GitHub | Issues/PRs/workflow/runs/releases |
| [chrome-devtools-axi](https://github.com/kunchenguid/chrome-devtools-axi) | 瀏覽器自動化 | Navigate/click/fill/extract |
| [lavish-axi](https://github.com/kunchenguid/lavish-axi) | 人機協作 | HTML artifact annotation |

**安裝：**
```bash
npx skills add kunchenguid/axi
```

---

### 2. Lavish（HTML Artifact 協作）
**GitHub：https://github.com/kunchenguid/lavish**

**核心：讓 agent 生成的 HTML 成為互動式規劃介面**

```
Agent 生成 HTML artifact（如產品規劃、技術架構圖）
    ↓
Lavish 在瀏覽器打開
    ↓
你可以在元素上 annotation / comment / 點擊決策
    ↓
回饋傳回 agent 處理
```

**特色：**
- Local only，零雲依賴
- 支援 element annotation + text selection comment
- Battery included（內建多種視覺化範本）

**安裝：**
```bash
npx skills add kunchenguid/lavish-axi --skill lavish
```

---

### 3. No Mistakes（PR Pipeline）
**GitHub：https://github.com/kunchenguid/no-mistakes**
**文件：https://kunchenguid.github.io/no-mistakes/**

**核心：git push 到 no-mistakes，自動跑完整 pipeline**

```bash
$ git checkout my-branch
$ git push no-mistakes
    ↓
┌──────────────────────────────────────────────┐
│ disposable worktree — your work stays put    │
│ review → test → docs → lint → push → PR → CI│
└──────────────────────────────────────────────┘
    ↓ every check green
clean PR, opened for you
```

**Pipeline 階段：**
1. **review** — 分析改動的意圖
2. **test** — 跑測試
3. **docs** — 更新文件
4. **lint** — 程式碼風格檢查
5. **push** — 推到 remote
6. **PR** — 自動開 PR
7. **CI** — 監控 CI 結果，自動修失敗

**特色：**
- Non-blocking（隔離 worktree，不阻斷當前工作）
- Agent-agnostic（支援 Claude/Codex/Rovo/OpenCode/Copilot/ACP）
- 機械性錯誤自動修復，意圖相關問題上報
- 全部 green 才推到 origin

**安裝：**
```bash
curl -fsSL https://raw.githubusercontent.com/kunchenguid/no-mistakes/main/docs/install.sh | sh
```

---

### 4. GNHF（Good Night, Have Fun）
**GitHub：https://github.com/kunchenguid/gnhf**
**npm：https://www.npmjs.com/package/gnhf**

**核心：睡前告訴 agent 任務，它會 autonomous iteration 到你醒來**

```bash
# 基本用法
$ gnhf "reduce complexity of the codebase without changing functionality"

# 帶限制
$ gnhf "reduce complexity" --max-iterations 10 --max-tokens 5000000

# 多個 agent 同時跑（用 worktree）
$ gnhf --worktree "implement feature X" &
$ gnhf --worktree "add tests for module Y" &
$ gnhf --worktree "refactor the API layer" &

# 當前 branch 直接跑
$ gnhf --current-branch
```

**特色：**
- 每個 iteration 小步 commit，失敗 rollback（除了 commit 失敗的修復保留）
- Live terminal title 顯示 token/iteration/commit 進度
- 醒來看到 branch 充滿乾淨的 commits + log + 運行報告
- Agent-agnostic（支援 Claude Code, Codex, Rovo Dev, OpenCode, GitHub Copilot CLI, Pi, ACP）

**Exit summary 包含：**
- Elapsed time
- Branch name
- Iterations count
- Token totals
- Branch diff stats
- Local notes/log paths
- Review commands

---

### 5. Treehouse（Work Tree 池）
**GitHub：https://github.com/kunchenguid/treehouse**

**核心：管理 pool of reusable git worktrees**

```bash
$ cd myproject  # 開始在你的 repo
$ treehouse     # 拿到一個 worktree，自動 pool 管理
🌳 Entered worktree at ~/.treehouse/myproject-a1b2c3/1/myproject

# 在隔離環境跑 agent
$ exit  # 釋放 worktree 回 pool，build cache 保留
🌳 Terminated lingering processes: opencode (pid 12345)
🌳 Worktree returned to pool.
```

**特色：**
- Instant isolation（零等待 clone）
- Worktree 保留在 pool，dependency + build cache 不丟
- 下一個 agent 可以立馬 reuse
- 衝突自動檢測，agent 不會互相踩踏
- 支援 macOS/Linux/Windows/Nix/Go

**安裝：**
```bash
# macOS / Linux
curl -fsSL https://kunchenguid.github.io/treehouse/install.sh | sh

# Windows (PowerShell)
irm https://kunchenguid.github.io/treehouse/install.ps1 | iex

# Go
go install github.com/kunchenguid/treehouse@latest
```

---

### 6. First Mate（Agent 協調者）
**GitHub：https://github.com/kunchenguid/firstmate**

**核心：船長只跟 first mate 說話，它管整個船員團隊**

```
船長：跟 first mate 說「幫我做三件事」
    ↓
First Mate：
  ├─ 開 tmux 視窗 x3
  ├─ 每個視窗配一個 Treehouse worktree
  ├─ 調度 coding agent 並行工作
  ├─ 監控每個 agent 進展
  ├─ 處理 merge conflict
  ├─ 呼叫 No Mistakes 驗證每個 change
  └─ 回報結果給船長
```

**Two task shapes：**
| 類型 | 用途 | 交付物 |
|------|------|--------|
| **Ship** | 交付程式碼變更 | PR |
| **Scout** | 調研/規劃/重現/審計 | 調查報告 |

**Optional secondmates：**
- 領域專家 supervisor（如專門管 test 的 secondmate）
- 隔離的 firstmate home，有自己的 FM_HOME/state/projects
- 由 primary firstmate 版本控制管理

**特色：**
- Zero-token supervision（bash watcher，不耗 token）
- Event-driven（ sleeping on the fleet，事件觸發才 wake）
- Agent-agnostic（任何 coding agent 都可以變成 firstmate）
- 不是 CLI，是目錄 + AGENTS.md + skills + scripts

**安裝：**
```bash
# 把任何 agent 變成 firstmate
git clone https://github.com/kunchenguid/firstmate.git
```

---

### 7. OpenSuperWhisper
**GitHub：https://github.com/starmel/OpenSuperWhisper**

**核心：macOS 本地語音轉文字，Whisper 模型**

**特色：**
- Real-time 錄音 + 轉錄
- 兩個引擎：Whisper + Parakeet
- Global keyboard shortcuts（可設單鍵或組合鍵）
- Hold-to-record 模式（按住錄，鬆開停）
- 支援多種麥克風（內建/外接/Bluetooth/iPhone Continuity）
- 亞洲語言 autocorrect（日/中/韓）
- Streaming transcription

**安裝：**
```bash
brew update
brew install opensuperwhisper
```

---

### 8. WezTerm
**官網：https://wezterm.org/**

**核心：跨平台終端模擬器，Lua 配置**

**特色：**
- Cross-platform（macOS/Linux/Windows）
- 高度可定制（Lua 配置文件）
- Lower script 熱重載
- GPU 加速渲染
- 內建多路複用（類似 tmux 但更整合）

---

### 9. Neovim
**官網：https://neovim.io/**

**核心：鍵盤導向文字編輯器**

**特色：**
- Relative line number 導航
- Extensible（plugins/API）
- 適合與 tmux/WezTerm 整合

---

## 完整工作流示例

### 場景：睡覺前交代任務

```bash
# 1. 告訴 first mate
$ firstmate "implement user auth, add tests for API layer, and investigate memory leak"

# 2. First mate 自動：
#    - 開 3 個 tmux 視窗
#    - 每個配 treehouse worktree
#    - 並行調度 3 個 coding agent

# 3. 你去睡覺，GNHF 在背景 autonomous iteration

# 4. 醒來：
#    - No Mistakes 已跑完每個 PR
#    - First mate 回報結果
```

### 場景：白天工作

```bash
# 1. 在 WezTerm + tmux 環境工作

# 2. 需要規劃 → Lavish
$ npx -y lavish-axi  # agent 生成 HTML artifact，瀏覽器打開

# 3. 做完功能 → No Mistakes
$ git push no-mistakes
# 自動 review/test/docs/lint/push/PR

# 4. 需要長時迭代 → GNHF
$ gnhf "improve test coverage" --max-tokens 5000000
```

---

## 與 OpenClaw 的對應

| Kun Chen 生態 | OpenClaw 現有 | 差距 |
|--------------|--------------|------|
| First Mate | sessions_send / subagent | **需要實作**：協調多個 agent 並行 |
| Treehouse | Multiple sessions | **需要實作**：worktree pool 管理 |
| GNHF | Cron job | **部分具備**：長時任務追蹤 |
| No Mistakes | Hook + Task Flow | **需要實作**：adversarial review pipeline |
| Lavish | Canvas / diagram-maker | **部分具備**：視覺化 artifact |
| AXI | Tool design standards | **需要建立**：工具 benchmark 文化 |
| OpenSuperWhisper | Local whisper.cpp | ✅ 已具備 |
| WezTerm / tmux | Terminal 多視窗 | ✅ 看你設定 |

---

## 移植到 OpenClaw 的優先順序

**第一波（立即可用）：**
1. ✅ OpenSuperWhisper → 已有 local whisper.cpp
2. ✅ WezTerm/tmux → 看你硬體
3. ⚡ AXI 原則 → 建立工具 benchmark 文化

**第二波（需要 skill 封裝）：**
4. Lavish → 寫一個 skill 讓 agent 知道如何用
5. No Mistakes → 用 Hook + Task Flow 實作類似 pipeline
6. GNHF → Cron job + Task Flow 實作長時迭代

**第三波（需要架構調整）：**
7. Treehouse → 類似 OpenClaw 的 workspace isolation
8. First Mate → sessions_send + fleet management |

---

## Related Wiki Entries

- `wiki/sources/l8-principal-agentic-engineering-workflow-kun-chen.md` — Kun Chen L8 Workflow 逐字稿整理
- `wiki/concepts/prompt-optimization-methods-lecture.md` — Prompt Optimization 方法論
