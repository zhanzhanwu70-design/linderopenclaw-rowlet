# HEARTBEAT.md

# 任務排程

## 共享 Task Queue（多 Agent 協調）

CEO 角色：收到 Linder 指令後，寫入 task 到 `~/.openclaw/task-queue/task_queue.json`

**每次 heartbeat 同步檢查：**
1. Acquire lock: `flock ~/.openclaw/task-queue/.lock -c "..."`
2. 掃描 `status=done AND from=rowlet` 的已完成任務，讀取 result
3. 釋放 lock
4. 已完成的任務 result 記錄到 memory/，並主動回報 Linder

**寫入新任務格式：**
```json
{
  "id": "task_YYYYMMDD_NNN",
  "from": "rowlet",
  "to": "charizard",
  "type": "research|execute|review|report|general",
  "instruction": "...",
  "priority": "normal",
  "status": "pending",
  "created_at": "ISO8601"
}
```

---

## 每日任務

### 🕕 早上 6:00 - AI 突破限制研究
- 研究政府可能如何限制 AI Agent
- 研究最新的突破技術
- 更新突破方案清單
- 記錄到 memory/ai-bypass-research.md
- 有新進展時通知 轟鳴月

### 🎬 每日 YouTube 影片監控
- 收到 YouTube 連結時主動下載分析
- 主動搜尋 OpenClaw、AI Agent、自動化相關影片
- 分析內容並記錄重點
- 有價值的內容向 Linder 回報

### 🕗 台北時間早上 8:00 - NemoClaw 社群監控
- 搜尋 NemoClaw 社群動態（GitHub、Discord、論壇等）
- 關注是否有人接上通訊軟體（如 Discord、Slack、Telegram）
- 了解最新使用狀況
- 記錄到 memory/nemoclaw-daily.md
- 向 Linder 回報進展

### 📊 每日 NemoClaw 使用狀況追蹤
- 聯繫噴火龍：確認 Plugin/Hook 實作進度
- 聯繫魔牆人偶：確認安裝狀態
- 聯繫耿鬼：確認測試結果
- 記錄各 Agent 進度到 memory/nemoclaw-progress.md
