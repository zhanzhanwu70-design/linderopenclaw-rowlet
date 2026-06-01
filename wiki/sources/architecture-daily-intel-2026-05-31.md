---
type: source
title: 架構師每日情報 2026-05-31
created: 2026-05-31
updated: 2026-05-31T18:02:19Z
tags:
  - agent-architecture
  - multi-agent
  - harness-engineering
  - skill-optimization
source_path: /home/node/.openclaw/workspace-rowlet/architecture-daily-report.md
---

# 架構師每日情報 2026-05-31

## 摘要

本日情報聚焦 agent architecture、multi-agent governance、harness engineering、workflow orchestration、skill artifact optimization。最重要的趨勢是：skills 正在從靜態提示片段變成可測試、可撤除、可內化、可治理的架構資產；multi-agent 系統則需要 formal governance、replayable orchestration traces、durable runtime 與 context hub 支撐。

## Key Findings

1. **Agent Skills for Context Engineering**：強調 progressive disclosure、context compression、filesystem context、evaluation 與 harness engineering，是 skill-based agent OS 的實用參考。
2. **revfactory/harness**：把 harness 明確定位為 L3 Team-Architecture Factory，支援 pipeline、fan-out/fan-in、expert pool、producer-reviewer、supervisor、hierarchical delegation。
3. **Architecting Agentic Communities**：提出 LLM Agent / Agentic AI / Agentic Community 三層分類，並用 ODP-EL formalism 管理 roles、contracts、deontic governance 與 accountability chains。
4. **LangChain Agent Development Lifecycle**：生產級 agent 流程收斂為 Build → Test → Deploy → Monitor；runtime、harness、sandbox、durability、traces、context hub 逐漸成為標準元件。
5. **SkillC**：用 contrastive credit assignment 學習 skill internalization，要求模型在訓練時比較 skill-injected 與 skill-free rollouts，避免只學會依賴外部 skill。
6. **Orchestration traces RL**：multi-agent RL 的核心資料結構是 temporal interaction graph；spawn、delegate、communicate、aggregate、stop 都應成為可學習／可評估決策。

## Sources

- Agent Skills for Context Engineering — https://github.com/muratcankoylan/agent-skills-for-context-engineering
- revfactory/harness — https://github.com/revfactory/harness
- Architecting Agentic Communities using Design Patterns — https://arxiv.org/html/2601.03624v3
- The Agent Development Lifecycle — https://www.langchain.com/blog/the-agent-development-lifecycle
- SkillC: Learning Autonomous Skill Internalization in LLM Agents via Contrastive Credit Assignment — https://arxiv.org/html/2605.27899v1
- Reinforcement Learning for LLM-based Multi-Agent Systems through Orchestration Traces — https://arxiv.org/abs/2605.02801

## 對本地架構的可執行啟示

- 將 skills 分成 metadata、workflow、references、evals 四層，預設只載入 metadata。
- 將 harness factory 拆成 runtime/config factory、team architecture factory、skill artifact factory、eval/trace layer。
- 為 subagent orchestration 建立 replayable trace schema，至少紀錄 spawn、delegate、message、tool、return、aggregate、stop。
- 對 skill optimization 同時量測 with-skill 與 without-skill performance；用撤除測試避免 skill dependency。
- 在 agent runtime 中保留 durable execution、approval boundary、sandbox、context hub 與 full trajectory traces。

## Open Questions

- graphifyy query 在本環境未偵測到 CLI；需確認它是外部工具、別名，或只存在於其他 workspace。
- 是否要把 daily intelligence 進一步拆成概念頁：`skill-internalization`、`orchestration-traces`、`team-architecture-factory`。
- 是否需要把 OpenClaw subagent trace schema 對齊 orchestration trace paper 的 JSON schema。
