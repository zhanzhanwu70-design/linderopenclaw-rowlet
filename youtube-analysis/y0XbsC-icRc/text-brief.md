# 文字簡報：我不寫 Prompt 了、我寫 Loop — Loop Engineering

影片：`y0XbsC-icRc`  
標題：我不寫 Prompt 了、我寫 Loop : Prompt Engineering  
頻道：Jim AI Notebook  
日期：2026-06-10  
長度：約 9 分 04 秒  
轉錄：本機 whisper.cpp，未使用外部 STT API

## 一句話摘要

影片主張 2026 年工程師的重要升級不是「寫更好的 prompt」，而是設計能持續運作、能自我觸發、能分工、能驗證、能交付的 **Loop Engineering**：工程師從直接跟單一 AI 對話，轉向設計 AI agent 工作系統。

## 核心引言

影片引用 Boris Cherny / Addy Osmani 脈絡：

> 我不再 prompt Claude；我寫 loop，讓 loop 自己 prompt Claude。我的工作是寫 loop。

重點不是「不寫 prompt」，而是角色轉換：

- 舊模式：人是 prompt operator，手動驅動 AI。
- 新模式：人是 loop designer，設計 AI 如何持續工作、回報、修正與交付。

## 四個根本轉換

### 1. 從事件到流程

Prompt 是一次性事件：你打一段，AI 回一次。  
Loop 是長期流程：今天跑一次，明天再跑，持續追蹤任務狀態。

### 2. 從執行到設計

Prompt 時代，人親手推每一步。  
Loop 時代，人設計規則、觸發條件、檢查機制與交付路徑。

### 3. 從一對一到一對多

Prompt 是人對單一 AI。  
Loop 是人管理多個 agents：triage、implementer、verifier、reviewer、reporter 各司其職。

### 4. 從在線到持續工作

Prompt 需要人在線。  
Loop 可以靠 cron / automation / hook 在人離線時繼續跑。

## Prompt vs Loop

影片的比喻：

- Prompt 模式：像廚師在廚房，AI 是助手；你不在，菜就停。
- Loop 模式：像設計工廠；你設計流程、分工與品管，工廠可持續產出。

對工程師的差異：

- Prompt：賣時間。
- Loop：賣設計。
- Prompt：人的在線時間是天花板。
- Loop：流程設計是放大器。

## 一個典型 Loop 長相

影片描述的範例：

1. 早上 cron 觸發 triage agent。
2. Agent 掃描：昨天 CI 失敗、open GitHub issues、過去 24 小時新 commits。
3. 每個問題寫入 board / memory。
4. Loop 為每個項目開獨立 Git worktree。
5. 每個 worktree 派兩個 subagents：
   - Implementer：寫修復。
   - Verifier：對照 spec、skills、測試做 review。
6. Verifier 通過後，自動開 PR、連 Linear ticket、通知 Slack、跑 CI。
7. 人醒來後 review 結果，而不是手動推每一步。

## 五個基礎積木

### 1. Automation / cron / hook

Loop 的心跳。沒有自動觸發，就只是一次性的 agent run。

### 2. Worktree

讓多個 agent 平行處理不同任務，避免互相踩 code。

### 3. Skills / project memory

保存專案規範、domain language、工作流程與檢查規則，避免每次重新教 agent。

### 4. Plugins / connectors / MCP

讓 agent 能接 GitHub、Linear、Slack、staging API、CI、文件系統等外部工具。

### 5. Subagents

分工與品管。Implementer 寫，Verifier 查，避免「自己寫、自己審」造成盲點。

## 三個主要風險

### 1. 驗證盲區

無人監督的 loop 可能穩定產出錯誤。自動化不是免審查。

### 2. 理解爆炸

Agent 產出速度可能超過人理解速度。幾天後 codebase 可能變成黑盒。

### 3. 認知投降

人如果只按 approve，不再理解系統，就從工程師變成橡皮圖章。

## 影片的價值判斷

影片最重要的提醒是：

> Build a loop, but build it like someone who intends to stay the engineer.

也就是：建 loop，但要以「仍然想當工程師」的方式建，不是以「只想跳過理解」的方式建。

好的 loop 應該放大工程師理解；壞的 loop 會讓工程師放棄理解。

## 對 OpenClaw 的啟示

這支影片其實非常貼 OpenClaw：

- heartbeat / cron = automation 心跳
- task queue / shared memory = loop memory
- sessions_send / subagents = agent 分工
- skills = 專案知識與流程封裝
- AGENTS.md / HEARTBEAT.md = agent operating contract
- llm-wiki = durable knowledge layer

所以 OpenClaw 的正確方向不是「每次問 AI 一題」，而是逐步建立：

```text
trigger → triage → task split → agent execution → verification → artifact → review → memory update
```

這也呼應 Linder 之前的判斷：

1. 先用 OpenClaw 做能力驗證。
2. 找出高 ROI use case。
3. 再補 governance / sandbox / approval gate。

## 實作建議

如果把 Loop Engineering 落到 OpenClaw，我會優先做：

1. **Daily research loop**：cron 觸發 → 搜尋 agent/news/software trend → 寫 raw → 寫 wiki → 回報摘要。
2. **Code issue loop**：掃 GitHub issue / CI failure → 建 task → 子 agent 修 → verifier 檢查 → human review。
3. **Knowledge loop**：YouTube / repo / web article → raw ingest → wiki source → synthesis → graph refresh。
4. **Governance loop**：每個 loop 都有 cost cap、approval gate、artifact path、rollback / stop rule。

## 轉錄品質備註

本影片沒有可用字幕，因此使用本機 whisper.cpp small model 轉錄。部分專有名詞可能被誤識別，例如：

- Addy Osmani
- Boris Cherny
- Claude Code
- cron
- triage
- worktree
- skills
- connectors
- subagents

簡報內容已依影片語境與外部來源摘要校正主要名詞。
