---
title: "L8 Principal's Agentic Engineering Workflow（Kun Chen）"
type: source
tags: [agentic-engineering, workflow, coding-agent, memory, skills, terminal, tmax, lavish, axiom, no-mistakes, goodnight-have-fun, treehouse, first-mate, multi-agent]
status: completed
created: 2026-06-28
updated: 2026-06-29
source: https://www.youtube.com/watch?v=iQyg-KypKAA
uploader: Kun Chen
duration: "45:46"
---

# L8 Principal's Agentic Engineering Workflow

## 講者背景

**Kun Chen（Koon）**
- 前 Meta/Microsoft/Atlassian **L8 Principal Engineer**
- 在 Meta 做過 Bing 搜尋引擎、Windows、Facebook Games
- 近幾年在 Atlassian 建構 frontier coding agents
- **每日產出：40-50 個 PRs，全部經過測試並部署上線**

> 「不是那些在社交媒體上看到的 Minecraft demo，是真的產品開發。」

---

## 核心哲學：船長模式

```
船長的時間：
  前端（Lavish 規劃）  ←———————→  後端（No Mistakes 結果審查）
       30 分鐘                    30 分鐘

中間全部交給 AI，自己去 spin up 其他任務。
```

**把自己當 Engineering Manager / Director，不是當工人。**
- Director 不 review PR，靠團隊 carry
- 你的工作是建立 culture 和 process，讓團隊執行
- No Mistakes 就是這個 process 的自動化

---

## 第一章：組裝船（Assemble our ship）

### 終端優先的理由

1. **手不離鍵盤**：移動滑鼠會打斷 flow，強迫大腦 context switch
2. **跨設備一致**：同一套 workflow 在手機上也能繼續（tmax persistent session）

### 工具棧

| 工具 | 用途 |
|------|------|
| **Westerm** | 終端模擬器，跨平台（Mac/Windows/Linux），高度可定制，lower script 熱重載 |
| **tmax** | 終端複用器，分屏/分頁/persistent session，跨設備連接 |
| **Neovim** | 鍵盤導向文字編輯器，relative line number 導航 |

### tmax 的關鍵能力

- **分屏**：一個 pane 跑 agent，另一個跑編輯器
- **分頁**：多個 agent session 並行
- **Persistent session**：detach 後再 reattach，回到同一狀態
- **跨設備連接**：同一 session 可以從另一台設備接手

---

## 第二章：招募船員（Recruit crewmates）

### 四種 Agent Harness

| Harness | 特色 | 缺點 |
|---------|------|------|
| **Claude Code** | 預設體驗最好，豐富功能集 | 偶爾 bug，多訂閱綁定 |
| **Codex CLI** | Rust 寫，流暢，開源，可看 source code 找 workaround | 功能相對少，不夠可定制 |
| **Py Coding Agent** | 極簡、高度可擴展 | 無內建功能，需要自己配置 |
| **Open Code** | 跨模型，buttery smooth UI，完整預設功能 | 較新 |

**工作流設計原則：保持 Agent Agnostic（與模型/harness 無關），景觀變化太快。**

---

## 第三章：記憶系統（Memory Files）

### 兩層 Memory 架構

**Global Memory（`~/.claude/projects/_global/agents.md`）**
- 27 行以內的全域偏好
- 內容會進入**每個專案**的 system prompt
- 寫的是原則，不是流水帳

**Global Memory 內容示例：**
```
- 偏好：never use mdash（AI 預設用 mdash，我不喜欢）
- 原則：don't give too much weight to development cost
  （AI 會高估人類開發時間，要糾正這個 bias）
- 原則：always starts with reproducing the bug in n2 setting
  （不是 unit test，是贴近用户真实场景的 n2 测试）
```

**Project Memory（`專案/claude.md`）**
- 專案術語、架構、常規、學習累積
- **不是自己寫，是每次看到 AI 犯錯就糾正，讓它寫入 memory**
- Over time crewmates 越來越聰明

### Memory → Skills 遷移

當 Project Memory 越來越大，把「只在特定情況需要的內容」移到 Skills。

**Skills 有 Progressive Disclosure：**
- Agent 啟動時只載入 description field
- 只有真的需要這個 skill 時才讀完整內容
- 不浪費 token

**遷移方法：**
```
把 end-to-end testing 指令從 agents.md 移到 project-level skill
→ Anthropic 的 `skill-creator` skill 來幫助創建
→ 安裝方式：`npx skills install @anthropic/skill-creator`
```

### Skill 安裝的風險

**不要從網路隨便安裝 skill（即使很多 GitHub stars）。**

案例：android-kappathi-skills（177K stars）
- 實測：+5% tokens，結果反而更差
- Stars 多 ≠ 真的好

---

## 第四章：語音輸入（Voice Input）

- 語音輸入比打字快 **3 倍**（Stanford 論文）
- 本地轉錄：`Open Super Whisper`（免費開源，Whisper 模型本地運行）
- Open Super Whisper 支援 system prompt 自定義詞彙，提昇轉錄準確率

**何時用語音：**
- 複雜指令
- 長篇描述

**何時回打字：**
- URL 或檔案路徑（誰想唸 URL 給別人聽）

---

## 第五章：Axi Framework（工具設計優化）

### 核心發現

工具設計對 agent 效率差異巨大。

例如 GitHub MCP Server vs GitHub CLI：
- **3 倍 token 成本**
- **2 倍延遲**

沒有明顯理由，就是工具設計不良。

### Axi Framework

Kun Chen 自己寫的 **10 個原則**，讓工具對 agent 高效。

例如：用 token 高效輸出格式，比 JSON 省約 40% tokens。

### Axi 使用方式
- 網站：`axi.md` 有 catalog
- GitHub CLI：Axi 效率最高、成本最低
- 還有 Chrome Dev Tools Axi 等

**核心訊息：給 agent 工具之前先做 benchmark，工具設計嚴重影響 agent 效率。**

---

## 第六章：Lavish Editor（視覺化規劃）

### 問題

預設規劃輸出是 terminal 裡的 wall of text，難以理解、無法對特定部分給 feedback。

### Lavish 是什麼

讓 agent 生成 **HTML artifact** 來視覺化規劃內容，始終使用與當前專案一致的 design system。

### Lavish 的優勢

- 看得清楚每個選項長什麼樣
- 可以對特定部分 annotation / comment
- 可以點擊決策，不需要回 terminal
- 節省來回溝通時間

### 使用方式

作為 skill 安裝，agent 遇到需要規劃的任務自動使用。

---

## 第七章：No Mistakes Pipeline（Quality Bar）

### 問題

AI 寫 code 超快，如果每個 diff 都要人 review，會成為瓶頸。而且 review diff 很無聊。

### Pipeline 步驟

```
Agent 說「做完了」
    ↓
No Mistakes Pipeline
    ↓
1. 建 branch + commit
2. 隔離 work tree 裡 rebase 到最新 main
3. 理解背後的原始意圖（分析 agent session）
4. 處理 merge conflict
5. Adversarial Review（新 fresh context，catch 問題）
   - 明確問題：self-corrected
   - 模糊問題（涉及 product）：escalation 給人類
6. 測試驗證 + 記錄 evidence（截圖/影片/log）
7. 文件 pass（更新相關文件）
8. 確認無 linking 問題
9. Push + Raise PR
10. Babysitting PR 直到 merge（處理 merge conflict + CI failure）
```

### PR 輸出包含

- Original intent
- What changed
- How it's tested
- Pipeline 過程摘要
- **Risk Assessment**：決定你要花多少時間 review

### Risk Assessment 的用法

| 風險等級 | 需要看 diff？ | 原因 |
|---------|-------------|------|
| Low risk | 不需要 | pipeline 已經攔截大部分問題 |
| High risk | 需要 | 才需要自己深入看 |

### 觸發方式

- 在 agent 裡輸入 `no mistakes`
- No Mistakes 會自己創建隔離的 work tree 來跑 pipeline

**實務經驗：**
> 「看起來很慢，但實際上我從來不盯著螢幕。我會去 spin up 其他任務，等到 no mistakes 說全部通過了，我才回來看 PR。」

---

## 第八章：Goodnight Have Fun（長時任務）

### 問題

睡覺 7-8 小時，如何讓 agent 繼續工作？

### 解決方案

`goodnight have fun` — 開源的 long-running task loop tool，設定目標 + stop condition。

### 使用方式

```bash
goodnight-have-fun --prompt "pretend you are a 7 year old kid..." \
  --token-cap 50 \
  --stop-condition "no more problems found"
```

### 適用場景

- 可驗證的目標（reducing page load time、improving test coverage）
- 信任 agent 有合理判斷力的任務
- 需要多輪迭代的 hypothesis testing

### 對比：Claude Code / Codex 的 `/goal` 命令

| 功能 | Goodnight Have Fun | /goal |
|------|-------------------|-------|
| Token cap | ✅ 可設定精確上限 | ❌ 可能一覺醒來 quota 沒了 |
| Iteration cap | ✅ 可設定 | ❌ |
| Stop condition | ✅ 可自訂 | ❌ |

### 監控

- 每個 iteration = 一個月亮
- Commits 數量追蹤
- 可以 monitor token 使用量和 iteration 數

---

## 第九章：Treehouse + Git Work Tree（多船員並行）

### 問題

同樣目錄不能跑兩個 agent，會 conflict。

### 解決方案：Git Work Tree

每個 agent 在獨立的 work tree 目錄工作，無 conflict。

### 問題：管理負擔

手動管理 work tree 變成一種 mental debt——要去記「我在哪個 work tree 做什麼」。

### 解決方案：Treehouse

```bash
treehouse              # 拿到一個 fresh work tree
treehouse status       # 看所有 work tree 狀態（used vs idle）
treehouse remove       # 關閉並釋放
```

- 關閉 tab 自動知道 done，釋放 work tree
- 下次要 work tree 時，優先 reuse idle 的，而不是建立新的

---

## 第十章：First Mate（ Agent 的 Agent）

### 為何需要

管理多個 agent session 的 constant context switch 非常耗費精力。

### First Mate 是什麼

另一個 agent，作為船長和船員之間的橋樑。

### First Mate 做的事

- 接收船長的指令
- 自動创建 work trees
- 調度多個 agent 並行工作
- 調用 No Mistakes 驗證每個 change
- 回報結果給船長

### 實務體驗

> 「看著 first mate 自動創建 tab、調度 treehouse、跑 agent、跑 no mistakes，整個過程我不需要操心任何細節。這種體驗非常oddly satisfying。」

### 當 first mate 就緒後的變化

- 船長開始發現： bottleneck 在於自己想不出要給 first mate 做什麼
- 這是好事——表示需要把精力放在「理解用戶需求、理解競爭格局、畫 treasure map」

> 「恭喜，你成功從水手轉變成船長了。」

---

## 完整工具清單

| 工具 | 用途 | 開源？ |
|------|------|--------|
| [Westerm](https://github.com/westerm/) | 跨平台終端模擬器 | ✅ |
| [tmax](https://github.com/tmux/tmux) | 終端複用器 | ✅ |
| [Neovim](https://neovim.io/) | 鍵盤導向編輯器 | ✅ |
| [Open Super Whisper](https://github.com/) | 本地語音轉文字 | ✅ |
| [Axi.md](https://axi.md) | Agent 高效工具 catalog | ✅ |
| [Lavish](https://github.com/) | 視覺化規劃 artifact | ✅ |
| [No Mistakes](https://github.com/) | PR pipeline 自動化 | ✅ |
| [Goodnight Have Fun](https://github.com/) | Long-running task loop | ✅ |
| [Treehouse](https://github.com/) | Work tree 管理 | ✅ |
| [First Mate](https://github.com/) | Agent 協調者 | ✅ |

---

## 與其他系統的比較

| 維度 | Kun Chen Workflow | Sakana Fugu Conductor |
|------|------------------|---------------------|
| 協調輸出 | 直接 tool call + pipeline | 自然語言 workflow 描述 |
| 人類角色 | 船長（前期規劃 + 後期把關）| 最終決策者 |
| 失敗處理 | No Mistakes adversarial review | 依賴模型自己 |
| 學習方式 | 人工建立 memory + skills | RL 訓練出協調策略 |
| 複雜任務 | 靠 Lavish 視覺化規劃 | 靠 Conductor 自己判斷 |

**核心差異**：Kun Chen 是人建立系統讓模型服從，Sakana 是模型自己學協調。前者更適合當下工程實踐。

---

## 與 OpenClaw 的對應

| Kun Chen 的系統 | OpenClaw 現有功能 | 備註 |
|----------------|-----------------|------|
| Global Memory | MEMORY.md | 精簡原則 |
| Project Memory | memory/YYYY-MM-DD.md + project wiki | 累積學習 |
| Skills（Progressive Disclosure）| Skills system | ✅ |
| Lavish Editor | Canvas / diagram-maker | 視覺化 artifact |
| No Mistakes Pipeline | Task queue + heartbeat | 差異：No Mistakes 是adversarial review |
| Goodnight Have Fun | Cron job / long-running task | 自動迭代直到 stop condition |
| Treehouse | Multiple sessions / workspace isolation | 自動化 work tree 管理 |
| First Mate | sessions_send / subagent | 需要實作 |

---

## 關鍵語錄

> 「Review diff is just not fun. No one says I became an engineer because I love reviewing diffs all day.」

> 「In order to really scale ourselves with AI, we have to think of ourselves more as an engineering manager or engineering director.」

> 「Your directors most likely don't review any PRs. Yet they can influence the quality of their team's software by creating good culture and processes, and rely on the team to carry them out. That's what we should do with AI.」

> 「The bottleneck is shifting. You start to run out of ideas for what to ask. This is a good thing. It means you as the captain needs to keep up.」

---

## Transcription

全文 1077 行：`raw/video/2026-06-28-iQyg-KypKAA/audio.txt`

## Raw Files

- `raw/video/2026-06-28-iQyg-KypKAA/audio.webm`（39.6 MB）
- `raw/video/2026-06-28-iQyg-KypKAA/audio.wav`（85.8 MB）
- `raw/video/2026-06-28-iQyg-KypKAA/audio.txt`（1077 行）
