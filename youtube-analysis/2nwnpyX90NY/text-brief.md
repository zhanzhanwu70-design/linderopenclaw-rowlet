# 文字簡報：Matt Pocock Skills — 真實工程師常用 AI 編程技能庫

影片：`2nwnpyX90NY`  
標題：mattpocock-skills:真实工程师常用技能库，github 超火开源AI编程技能组合  
頻道：AI隨風  
長度：約 13 分 17 秒  
轉錄：本機 whisper.cpp，未使用外部 STT API

## 一句話摘要

這支影片介紹 Matt Pocock 的 `skills` repo：它不是讓 AI 隨便 vibe coding，而是把真實工程開發中的需求澄清、TDD、bug 診斷、PRD、issue 拆分與架構改善，包成 Claude Code / Codex 等 coding agent 可使用的小型技能。

## 核心觀點

影片認為，Matt Pocock skills 的價值在於：

- 不接管整個 AI 編程流程。
- 不像 GSD / BMAD / Spec-Kit 這類重流程那樣環環相扣。
- 保留工程師對節奏、規則與工作方式的控制權。
- 用小而專注的 skills 修補 AI coding 常見失敗模式。

## 影片指出的主要問題

### 1. Agent 理解有偏差

人和 agent 聊完需求後，agent 實作出來的效果常常和一開始討論的不一致。問題不是模型完全不會寫，而是需求理解、邊界條件和流程規則沒有對齊。

### 2. Codebase 變成一團爛泥

AI coding 容易重複建立類別、重寫可復用的小方法，或忘記既有設計，導致 codebase 越寫越亂。

### 3. 大流程框架太重

像 GSD / BMAD / Spec-Kit 這類流程能提供完整節奏，但缺點是當某個步驟不適合你的專案時，很難局部修改，工程師容易被流程控制。

## 主要 skills 介紹

### grill-me / grill-with-docs

用途：需求澄清與追問。

影片說明：這類技能會一直問問題，直到使用者和 AI 對需求有共同理解。`grill-with-docs` 更進一步，會產生或更新 `CONTEXT.md`，把專案中的術語、業務概念和決策脈絡記錄下來。

重點：

- 問到沒有模糊點為止。
- 將重要術語保存成共享術語表。
- 可搭配 ADR 保存架構決策。
- 提示詞本身不長，但行為效果明確。

### TDD

用途：讓 agent 用測試驅動開發。

流程：

1. 規劃。
2. 寫測試。
3. 看到測試失敗。
4. 實作功能。
5. 讓測試通過。
6. 重構。

影片認為這是讓 AI coding 建立回饋循環的重要方法。

### diagnose

用途：bug 診斷。

影片提到它是一套嚴謹的 debug 方法論，讓 agent 不要亂猜，而是按階段定位問題、驗證假設、修復並補回歸測試。

### improve-codebase-architecture

用途：架構改善。

這個 skill 會掃描 codebase，找出可以改善的架構候選點，讓使用者選擇方向後再深入分析與提出方案。

適合在：

- 完成一個模組後。
- 專案寫了一段時間後。
- 覺得 AI 產出的結構開始混亂時。

### to-prd

用途：把上下文整理成 PRD。

它會根據目前對話內容生成產品需求文件，包含使用者故事、模組劃分、測試內容與不在範圍內的事項。

### to-issues

用途：把 PRD 或大型需求拆成 GitHub issues。

影片示範中，它會把大需求切成幾個可以獨立執行的小任務，並透過標籤標記哪些任務已經 ready for agent。

### setup-matt-pocock-skills

用途：初始化 repo 需要的 skill 設定。

會處理：

- issue tracker，例如 GitHub issues。
- triage label。
- domain docs，例如 `CONTEXT.md`。
- ADR 目錄。
- 在 `CLAUDE.md` / agent 設定檔加入必要上下文。

這讓後續 skills 知道去哪裡讀 domain language、issue 規則與專案決策。

## 推薦使用流程

影片推薦的工作流大致是：

1. 先用 `grill-with-docs` 做需求追問與對齊。
2. 將對齊後的上下文用 `to-prd` 轉成 PRD。
3. 用 `to-issues` 把 PRD 拆成可執行的 GitHub issues。
4. 用 `tdd` 實作每個 issue。
5. 有 bug 時用 `diagnose`。
6. 每隔幾天用 `improve-codebase-architecture` 做架構整理。

## 對 OpenClaw / Linder workflow 的啟示

這支影片和 Matt Pocock repo 本身共同指向一個設計原則：

**不要只讓 agent 會寫 code，要讓 agent 會做工程。**

可借鑑到 OpenClaw 的地方：

- 每個 skill 應該小而明確，不要變成大型黑箱流程。
- 需求不清楚時，agent 應先追問，而不是急著執行。
- 重要術語與決策應寫入文件，避免每次對話重建 context。
- 大任務應拆成可審核、可交接、可 AFK 執行的小任務。
- 定期架構審查可以降低 agent 產生 code entropy 的風險。

## 實務建議

如果要把這套想法移植到 OpenClaw，我會優先做三件事：

1. 寫一個 OpenClaw 版 `grill` skill：一次只問一題，每題附建議答案，直到任務邊界清楚。
2. 建立 repo-local contract：讓每個專案有自己的 `CONTEXT.md`、ADR、task/issue 規則。
3. 把「每日 agent 研究 cron」也改成 skill 化：固定輸出 raw source、簡報、wiki 條目、趨勢判斷與下一步建議。

## 轉錄品質備註

本影片沒有可用字幕，因此使用本機 whisper.cpp small model 轉錄。部分英文名詞被中文 ASR 誤識別，例如：

- `grill` 可能被轉成 `Grid`。
- `CONTEXT.md` 可能被轉成 `connects MD`。
- `issues` 可能被轉成 `ecious`。
- `Claude.md` 可能被轉成類似 `color ambd`。

簡報內容已依影片語境與已知 repo 內容校正這些名詞。
