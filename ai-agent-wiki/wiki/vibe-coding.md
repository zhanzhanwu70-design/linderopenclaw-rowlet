---
title: "Vibe Coding"
category: methodology
tags: [vibe-coding, methodology, ai-coding]
created: 2026-05-07
modified: 2026-05-07
sources: ["https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f"]
---

# Vibe Coding - AI 輔助開發的新方式

## 一句話定義

**跟著感覺走，讓 AI 幫你寫 code，你只負責 review 和提需求。**

---

## 傳統開發 vs Vibe Coding

### 傳統開發
```
人類工程師
  → 自己寫 code
  → 自己測試
  → 自己 debug
  → 自己部署
全程手動，耗時費力
```

### Vibe Coding
```
人類（導師/審查者）
  → 告訴 AI 目標
  → AI 生成 code
  → 人類 review
  → AI 根據 feedback 修正
  → 持續來回直到完成
```

---

## Karpathy 的四條黃金法則

根據 Anthropic Programming Agent 主管的分享：

### 法則 1：Agent 要能「停不下來」，但人類要能隨時介入

- AI 自動生成過程不要中斷
- 人類要能隨時檢查、終止、修改

### 法則 2：好的 Agent 需要「安全邊界」

```
什麼可以動，什麼不能動
  → 有嚴格的紅線
  → 不會執行危險操作
```

### 法則 3：把任務拆到「Agent 擅長的顆粒度」

```
壞的做法：給一個超大任務
好的做法：給小步驟多輪互動

小步驟 → 多輪來回 → 品質更穩
```

### 法則 4：需要完整的 Observability

- 人類能看到 Agent 做到哪
- 出了問題要知道從哪裡修

---

## Vibe Coding 的適用場景

| 場景 | 適合程度 | 說明 |
|------|----------|------|
| 簡單 script | ⭐⭐⭐⭐⭐ | 最適合，AI 可快速完成 |
| 原型開發 | ⭐⭐⭐⭐ | 快速驗證想法 |
| 程式碼重構 | ⭐⭐⭐ | AI 幫你理解並重寫 |
| 大型系統 | ⭐⭐ | 需要更嚴格的控制 |
| 核心系統 / 安全 | ⭐ | 不建議，容易出錯 |

---

## Vibe Coding 的工作流

```
1. 給目標
   「我想要一個能處理 CSV 的 script」

2. AI 生成
   AI 根據目標生成 code

3. Review
   人類檢查輸出的 code

4. Feedback
   「這裡不太對，應該改成...」

5. AI 修正
   根據 feedback 調整

6. 重複直到滿意
```

---

## Vibe Coding 的限制

| 限制 | 說明 |
|------|------|
| **Code Quality** | AI 寫的 code 可能有安全問題 |
| **複雜架構** | 大型系統需要更嚴格把關 |
| **Debug** | 錯誤難以追踪到根因 |
| **測試覆蓋** | 可能漏掉 edge case |

---

## Vibe Coding 與 LLM Wiki 的結合

LLM Wiki 讓 Vibe Coding 更強：

```
你的 Vibe Coding session
        ↓
有價值的結論存進 wiki
        ↓
下次不需要重新理解
        ↓
知識持續累積
```

---

## 與 Harness Engineering 的關係

| Harness 模組 | 對 Vibe Coding 的幫助 |
|-------------|---------------------|
| 提示詞工程 | 怎麼給 AI 指令最有效 |
| 工作流管理 | 複雜任務怎麼拆解 |
| 監控系統 | 追蹤 AI 生成了什麼 |
| 自動修復 | AI 自己修正錯誤 |

---

## 總結

> Vibe Coding 不是無腦地用 AI 寫 code
> 而是有紀律地使用 AI 的輔助開發方式

**核心原則**：
1. 你管方向，AI 管執行
2. 小步驟多來回，不要一次給太多
3. 持續 review，不要完全放手
4. 有價值的結論記錄下來

---

## 相關頁面

- [[karpathy-llm-wiki]] — 與 wiki 系統的整合
- [[agent-frameworks]] — 各 framework 的 vibe coding 能力
- [[harness-engineering]] — 支撐 vibe coding 的四大工程

---

_tags: [vibe-coding, methodology, ai-coding]_
