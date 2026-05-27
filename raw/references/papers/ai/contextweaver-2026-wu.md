# ContextWeaver: Selective and Dependency-Structured Memory Construction for LLM Agents

## Metadata

| Field | Value |
|-------|-------|
| **arXiv ID** | 2604.23069 |
| **Title** | ContextWeaver: Selective and Dependency-Structured Memory Construction for LLM Agents |
| **Authors** | Yating Wu, Yuhao Zhang, Sayan Ghosh, Sourya Basu, Anoop Deoras, Jun Huan, Gaurav Gupta |
| **Submitted** | 24 April 2026 |
| **Subjects** | Computation and Language (cs.CL) |
| **URL** | https://arxiv.org/abs/2604.23069 |
| **PDF** | https://arxiv.org/pdf/2604.23069 |
| **HTML** | https://arxiv.org/html/2604.23069v1 |
| **DOI** | https://doi.org/10.48550/arXiv. 2604.23069 |

## Abstract

Large language model (LLM) agents often struggle in long-context interactions. As the agent accumulates more interaction history, context management approaches such as sliding window and prompt compression may omit earlier structured information that later steps rely on. Recent retrieval-based memory systems surface relevant content but still overlook the causal and logical structure needed for multi-step reasoning. We introduce ContextWeaver, a selective and dependency-structured memory framework that organizes an agent's interaction trace into a graph of reasoning steps and selects the relevant context for future actions. Unlike prior context management approaches, ContextWeaver supports: (1) dependency-based construction and traversal that link each step to the earlier steps it relies on; (2) compact dependency summarization that condenses root-to-step reasoning paths into reusable units; and (3) a lightweight validation layer that incorporates execution feedback. On the SWE-Bench Verified and Lite benchmarks, ContextWeaver improves performance over a sliding-window baseline in pass@1, while reducing reasoning steps and token usage. Our observations suggest that modeling logical dependencies provides a stable and scalable memory mechanism for LLM agents that use tools.

## PDF Storage Path

`/home/node/.openclaw/workspace-rowlet/raw/references/papers/ai/contextweaver-2026-wu.pdf`

(arXiv PDF — publicly available via arXiv open access)

## Notes

- Filed under: Context Window Management / Long-term Memory for Agents
- Domain tag: `code-agent`
- Aims to solve the problem where sliding window / prompt compression drop critical earlier dependency information during multi-step agentic tasks
- Key insight: treat agent interaction trace as a graph of reasoning steps, not just a sequence of messages
- Three核心功能: dependency-based construction, compact summarization, validation layer
- Benchmark: SWE-Bench Verified & Lite (realistic software engineering tasks)
- Result: better pass@1 with fewer reasoning steps & less token usage
