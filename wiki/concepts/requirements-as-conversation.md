---
title: "Requirements as Conversation — AI 參與需求定義"
type: concept
tags: [requirements, planning, agentic-engineering, brainstorming, openspec, prototype, SDLC, vibe-coding]
status: completed
created: 2026-07-02
updated: 2026-07-02
source: The New SDLC With Vibe Coding (Addy Osmani / Google)
---

# Requirements as Conversation

## 核心概念

傳統 SDLC 的問題：**需求（Requirements）和實作（Implementation）之間的鴻溝最大**。

把商業需求轉換成技術規格一直是手動的、易錯的過程，造成 stakeholder 想要什麼和工程師建什麼之間的永久落差。

## AI 時代的新模式

Modern AI tools 可以直接參與需求精煉：

| 傳統模式 | AI 時代模式 |
|---------|------------|
| 需求文件 → 規格文件（手動傳遞）| 自然語言描述 → 互動原型（AI 生成）|
| 工程師自己拆 user story | AI 從 product brief 生成 user story |
| 人類自己想到 edge case | AI 識別人類忽略的 edge case |
| API 文件手工寫 | 從自然語言描述生成 API schema |
| 需求審查漫長來回 | **conversation** 直接產生規格 + 初始實作 |

## 關鍵轉變

> Requirements stop being a document handed off between teams.
> They become **a conversation between humans and AI** that produces specification and initial implementation simultaneously.

**需求不再是跨團隊交接的文件，而是人類和 AI 的對話，同時產生規格和初始實作。**

## 具體能力

1. **User Story 生成**：從 product brief 自動生成
2. **Edge Case 識別**：AI 預先發現人類易忽略的極限情況
3. **API Schema 產生**：自然語言描述 → OpenAPI/JSON Schema
4. **互動原型生成**：從規格文件直接產生可操作的 prototype
5. **規格 + 實作同步**：需求對話結束時，prototype 已出來

## 與現有工具的對應

| 這段描述的能力 | OpenClaw 可能對應 |
|--------------|-----------------|
| User Story 生成 | brainstorming skill |
| Edge Case 識別 | review / audit skill |
| API Schema 產生 | openspec skill |
| 互動原型生成 | Canvas / Lavish |
| 對話式規格 | Claude Code / Codex 的自然語言規劃 |

## 在 Vibe Coding → Agentic Engineering 光譜中的位置

這個能力跨越整個光譜：
- **Vibe Coding 端**：AI 幫你快速 prototyping，但規格模糊
- **Agentic Engineering 端**：需求變成持續的 AI 對話，直到規格 stable + 可部署的 prototype

## 與 Kun Chen Workflow 的關係

Kun Chen 的 **Lavish Editor** 正是這個概念的實作：
- AI 生成 HTML artifact 視覺化規劃
- 人可以在上面 annotation / comment / 點擊決策
- 回饋傳回 AI → 持續對話直到共識

**不是文件來回，而是持續的視覺化對話。**

## 與 OpenSpec / Brainstorming 的關係

可能是指：
- `openspec` — 從自然語言生成規格文件的 skill
- `brainstorming` — 需求探索階段的對話式 skill
- `claude-code` / `codex` — 原生支援從描述到 prototype

## Source

- The New SDLC With Vibe Coding (Addy Osmani, Google)
- URL: https://addyosmani.com/blog/new-sdlc-vibe-coding/
