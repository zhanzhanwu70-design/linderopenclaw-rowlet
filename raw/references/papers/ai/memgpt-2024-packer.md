# MemGPT: Towards LLMs as Operating Systems

## Metadata

| Field | Value |
|-------|-------|
| **arXiv ID** | 2310.08560v2 |
| **Title** | MemGPT: Towards LLMs as Operating Systems |
| **Authors** | Charles Packer, Sarah Wooders, Kevin Lin, Vivian Fang, Shishir G. Patil, Ion Stoica, Joseph E. Gonzalez |
| **Submitted** | 12 October 2023 |
| **Updated** | 12 February 2024 |
| **Subjects** | Artificial Intelligence (cs.AI) |
| **URL** | https://arxiv.org/abs/2310.08560 |
| **PDF** | https://arxiv.org/pdf/2310.08560 |
| **DOI** | https://doi.org/10.48550/arXiv.2310.08560 |
| **Code / Data** | https://research.memgpt.ai |

## Abstract

Large language models are constrained by finite context windows, which limits long conversations and large-document analysis. MemGPT proposes **virtual context management**, inspired by operating-system virtual memory: an LLM agent treats the prompt/context window as scarce “main memory” and moves information between in-context memory and external storage through tool/function calls. The system uses a memory hierarchy, self-directed reads/writes, memory-pressure warnings, recursive summaries, paginated retrieval, and event/interrupt-style control flow to create the illusion of a larger usable context. The paper evaluates MemGPT on multi-session chat and document analysis tasks, showing improved long-term consistency, engagement, and multi-hop retrieval compared with fixed-context baselines.

## PDF Storage Path

`/home/node/.openclaw/workspace-rowlet/raw/references/papers/ai/memgpt-2024-packer.pdf`

(arXiv PDF — publicly available via arXiv open access)

## Notes

- Filed under: Long-term Memory for Agents / Context Window Management / Conversation History Handling / RAG for Agents
- Domain tag: `code-agent`
- Central mechanism: split memory into main context, working context, FIFO message queue, recall storage, and archival storage.
- Key engineering idea: the LLM is not merely given retrieved snippets; it is given functions to manage its own context and decide when to retrieve, store, or yield.
- Important evaluation results:
  - Deep Memory Retrieval on Multi-Session Chat: MemGPT improves GPT-4 accuracy from 32.1% to 92.5%, and GPT-4 Turbo from 35.3% to 93.4%.
  - Document QA: performance is designed to be robust as context length grows because relevant material is paged in instead of blindly stuffed into the prompt.
  - Nested key-value retrieval: MemGPT demonstrates multi-hop lookup behavior by chaining function calls across external memory.
- Practical limitation / open question: memory management quality depends heavily on the base model’s ability to decide when to store, retrieve, and continue function chaining.
