---
title: "OpenClaw 高級進階技巧：模型精選策略+記憶系統優化+深度搜索整合+Gateway崩潰自動修復"
type: source
tags: [openclaw, model-selection, memory-system, multi-agent, skill, gateway, auto-repair, deep-search]
status: completed
created: 2026-06-28
updated: 2026-06-28
source: https://youtu.be/7n9qbuzwS-U
uploader: AI超元域
duration: "11:00"
---

# OpenClaw 高級進階技巧

## Summary
春節期間高強度使用 OpenClaw 的經驗總結，包含四個主要技巧：模型精選策略、記憶系統重構、深度搜索整合、Gateway 崩潰自動修復。

## 1. 模型精選策略

### 三個保留的模型

| 模型 | 用途 | 原因 |
|------|------|------|
| **Claude Opus 4.6** | 複雜任務 | agentic 能力最強，勝過 Sonnet 4.6 |
| **GPT-5.2（Codex）** | 簡單任務 | 額度多，支援 think 命令調整思考級別 |
| **MiniMax M2.1** | 開源模型備選 | 響應快、退鍋能力強，與 OpenClaw 搭配佳 |

### 關鍵洞察
- Claude Sonnet 4.6 的 agentic 能力不如 Opus 4.6
- GPT-5.3 Codex 更適合編碼場景，不適合 OpenClaw 中的 agentic 任務
- `--think` 命令可以設置思考級別（預設關閉）

## 2. 記憶系統重構（Markdown → Topics 分類）

### 核心做法
將單一 `MEMORY.md`（15KB）拆分成 `memory/topics/` 資料夾（2.3KB core + 分類檔案）。

### Topics 分類方式
- `openclaw-config/` — 配置相關記憶
- `multi-agent/` — 多 Agent 協作相關記憶
- `browser-automation/` — 瀏覽器自動化相關記憶
- `skill-config/` — 技能配置相關記憶
- `node-config/` — 節點配置相關記憶
- `workflow-rules/` — 工作流規則相關記憶

### 效果
- **按需加載**：根據場景只加載相關的記憶文件
- **精準命中**：每個主題獨立膨脹，不會相互干擾
- **新知識追加**：新知識可以追加到對應主題檔

### 做法
只需告訴 OpenClaw：`按照主題來拆分 MEMORY.md`

## 3. 深度搜索整合（Skill + Coze CLI）

### 問題
OpenClaw 自帶搜索功能有限：
- `websearch` 需要 Brave API
- `webfetch` 只支援 URL 內容抓取

### 解法
寫了一個 Skill 整合 Coze 的深度搜索能力（Deep Research）。

### 決策樹

```
用戶輸入
    ↓
有 URL？→ 是 → webfetch 抓取
    ↓ 沒有
簡單事實查詢？→ 是 → Brave 搜索
    ↓ 複雜/多元需深度研究
→ Coze CLI 多輪搜索
```

### Coze CLI 的能力
- 多輪深度調研
- 給出核心結論
- 列出具體來源
- 生成完整調研報告

## 4. Gateway 崩潰自動修復

### 背景
OpenClaw Gateway 可能因為插件 Bug 導致異常退出且無法啟動。

### 自動修復流程

```
Gateway 崩潰
    ↓
systemd 觸發 unfailure
    ↓
啟動修復服務（腳本）
    ↓
自動讀取 Gateway 日誌
    ↓
調用 Claude Code 分析問題
    ↓（自動）
定位問題 → 修改配置/代碼 → 驗證 JSON 語法 → 重啟 Gateway
    ↓
8 秒後檢測是否正常運行
    ↓ 失敗
第二次修復（重複上述過程）
    ↓ 失敗（兩次後）
通知用戶人工介入
```

### 自動修復的問題類型
- OpenClaw JSON 語法錯誤
- 插件相關配置錯誤
- 端口衝突

### 效果
- 凌晨 Gateway 崩潰可以自動修復
- Claude Code 全自動分析日誌、定位問題、修改代碼、驗證語法、重啟

## 實用價值
- 模型選擇：省成本 + 效率最大化
- 記憶系統：讓記憶更精準、按需加載
- 深度搜索：彌補 OpenClaw 自帶搜索不足
- 自動修復：實現真正的 24/7 無人值守

## Transcription
全文：`raw/video/2026-06-28-7n9qbuzwS-U/audio.txt`

## Raw Files
- `raw/video/2026-06-28-7n9qbuzwS-U/audio.webm`（9.22 MB）
- `raw/video/2026-06-28-7n9qbuzwS-U/audio.wav`（20.2 MB）
- `raw/video/2026-06-28-7n9qbuzwS-U/audio.txt`
