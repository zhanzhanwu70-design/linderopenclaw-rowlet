---
title: "Raw Sources List"
category: reference
tags: [sources, references]
created: 2026-05-07
modified: 2026-05-26
sources: []
---

# Raw Sources List - 原始來源總目錄

## 核心概念來源

| 來源 | 描述 | 納入日期 |
|------|------|----------|
| [Karpathy LLM Wiki Gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) | LLM Wiki 核心概念，Karpathy 提出 | 2026-05-07 |
| [在生产环境中Vibe Coding - 机器之心](https://www.youtube.com/watch?v=95HaTK1raP0) | Anthropic Agent 主管的 4 條黃金法則 | 待補 |

---

## Agent Framework 來源

| 來源 | 描述 | 納入日期 |
|------|------|----------|
| [Claude Code vs OpenAI Codex Comparison](https://www.mindstudio.ai/blog/claude-code-vs-openai-codex-comparison) | 兩大 Agent 框架對比 | 2026-05-07 |
| [Codex vs Claude Code - Builder.io](https://www.builder.io/blog/codex-vs-claude-code) | 實務層面深度對比 | 待補 |
| [AI Coding Agents Benchmark - Render](https://render.com/blog/ai-coding-agents-benchmark) | 2025 年主流 Agent 基準測試 | 待補 |

---

## 工具與生態

| 來源 | 描述 | 納入日期 |
|------|------|----------|
| [Obsidian](https://obsidian.md/) | Wiki 瀏覽與編輯工具 | 2026-05-07 |
| [qmd](https://github.com/tobi/qmd) | 本地 Markdown 搜尋引擎 | 2026-05-07 |
| [Marp](https://marp.app/) | Markdown 簡報生成工具 | 2026-05-07 |
| [LangGraph](https://langchain-ai.github.io/langgraph/) | Agent 工作流框架 | 待補 |

---

## 待納入來源

- [ ] 更多 Agent Framework 比較
- [ ] Harness Engineering 相關論文
- [ ] Vibe Coding 延伸閱讀
- [ ] OpenClaw / NemoClaw 官方文檔

---

## 如何新增來源

1. 將來源放入 `/raw/` 目錄
2. 執行 Ingest workflow
3. 由 LLM 進行摘要與整合
4. 更新本 index

---

_tags: [sources, references]_

## Context & Memory 管理來源

| 來源 | 描述 | 納入日期 |
|------|------|----------|
| [ContextWeaver (Wu et al., 2026)](wiki/sources/contextweaver-wu-2026.md) | Agent Context 管理：Dependency Graph + Validation Layer，針對 Tool-use 多步推理任務 | 2026-05-26 |
