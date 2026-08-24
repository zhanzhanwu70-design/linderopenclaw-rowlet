---
type: source
title: 架構師每日情報 2026-06-01
created: 2026-06-01
updated: 2026-06-01T18:03:00Z
tags:
  - agent-architecture
  - multi-agent
  - harness-engineering
  - skill-optimization
source_path: /home/amr/.openclaw/workspace-rowlet/architecture-daily-report.md
mirrors:
  - /home/node/workspace-rowlet/architecture-daily-report.md
---

# 架構師每日情報 2026-06-01

## 摘要

本日情報聚焦 self-evolving agent skills、skill artifact optimization、skill internalization RL、agent harness infrastructure 與研究索引 taxonomy。最重要的趨勢是：skill 正在從靜態 prompt / 文件，轉化為可訓練、可驗證、可記憶、可轉移、可撤除測試的長期架構資產；harness engineering 則正在形成固定分層，包括 context、tools、memory、permissions、orchestration、observability、eval 與 human approval boundary。

## Key Findings

1. **SkillOpt**：將 skill 文件當成 frozen agent 的外部可訓練狀態，使用 scored rollouts、bounded edits、held-out validation gate、rejected-edit buffer 與 slow/meta update 進行穩定優化。
2. **MUSE-Autoskill**：提出 creation / memory / management / evaluation / refinement 的 skill lifecycle，加入 skill-level memory、unit tests、runtime feedback 與 cross-agent transfer。
3. **SkillC**：用 paired skill-injected / skill-free rollouts 做 contrastive credit assignment，讓 RL 區分「依賴 skill」與「真正內化 skill」。
4. **OpenHarness**：將 agent harness 明確拆成 tool-use、skills、memory、multi-agent coordination、permissions、hooks、cost tracking、subagent lifecycle 等基礎能力。
5. **awesome-harness-engineering / VoltAgent papers**：curated index 已成為架構 taxonomy，可用於檢查本地 agent stack 是否缺少 eval、trace、permission、orchestration、memory lifecycle 或 skill governance。

## Sources

- SkillOpt: Executive Strategy for Self-Evolving Agent Skills — https://arxiv.org/abs/2605.23904
- MUSE-Autoskill: Self-Evolving Agents via Skill Creation, Memory, Management, and Evaluation — https://arxiv.org/abs/2605.27366
- SkillC: Learning Autonomous Skill Internalization in LLM Agents via Contrastive Credit Assignment — https://arxiv.org/abs/2605.27899
- OpenHarness — https://github.com/HKUDS/OpenHarness
- awesome-harness-engineering — https://github.com/ai-boost/awesome-harness-engineering
- VoltAgent awesome-ai-agent-papers — https://github.com/VoltAgent/awesome-ai-agent-papers

## 對本地架構的可執行啟示

- 為每個 skill 加入生命週期欄位：created_by、last_used、success_cases、failure_cases、unit_tests、eval_score、accepted_edits、rejected_edits。
- 建立 skill eval split：train rollouts 用於生成修改，held-out tasks 用於接受／拒絕修改。
- 對 skill optimization 同時測量 with-skill、without-skill、degraded-skill，避免只強化外部 skill 依賴。
- 把 harness capability matrix 固定化：context delivery、tool schemas、permissions、memory、task runner、subagents、observability、eval、human approval。
- 將 trajectory trace 保存為可 replay artifact，未來可用於 eval dataset、skill refinement、orchestration RL 與 incident audit。

## Open Questions

- 是否要把本日內容拆成獨立概念頁：`skillopt`、`skill-lifecycle`、`skill-internalization`、`agent-harness-capability-matrix`。
- OpenClaw skill metadata 是否應加入 machine-readable eval schema，而不是只靠 SKILL.md prose。
- `graphifyy query` 在本環境未偵測到 CLI；需確認它是其他 workspace 的別名、MCP 工具，或尚未安裝。
