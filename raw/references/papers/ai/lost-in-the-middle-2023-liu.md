# Lost in the Middle: How Language Models Use Long Contexts

## Metadata

| Field | Value |
|-------|-------|
| **arXiv ID** | 2307.03172v3 |
| **Title** | Lost in the Middle: How Language Models Use Long Contexts |
| **Authors** | Nelson F. Liu, Kevin Lin, John Hewitt, Ashwin Paranjape, Michele Bevilacqua, Fabio Petroni, Percy Liang |
| **Affiliations** | Stanford University; UC Berkeley; Samaya AI |
| **Submitted** | 6 July 2023 (v1) |
| **Updated** | 20 November 2023 (v3) |
| **Published** | Transactions of the Association for Computational Linguistics (TACL), 2023 |
| **Subjects** | Computation and Language (cs.CL) |
| **URL** | https://arxiv.org/abs/2307.03172 |
| **PDF** | https://arxiv.org/pdf/2307.03172 |
| **DOI** | https://doi.org/10.48550/arXiv.2307.03172 |
| **Length** | 18 pages, 16 figures |

## Abstract

While recent language models have the ability to take long contexts as input, relatively little is known about how well they use longer context. We analyze the performance of language models on two tasks that require identifying relevant information in their input contexts: multi-document question answering and key-value retrieval. We find that performance can degrade significantly when changing the position of relevant information, indicating that current language models do not robustly make use of information in long input contexts. In particular, we observe that performance is often highest when relevant information occurs at the **beginning or end** of the input context, and significantly degrades when models must access relevant information **in the middle** of long contexts, even for explicitly long-context models. Our analysis provides a better understanding of how language models use their input context and provides new evaluation protocols for future long-context language models.

## PDF Storage Path

`/home/node/.openclaw/workspace-rowlet/raw/references/papers/ai/lost-in-the-middle-2023-liu.pdf`

(arXiv PDF — publicly available via arXiv open access)

## Models Evaluated

- **Open**: MPT-30B-Instruct, LongChat-13B (16K context)
- **Closed**: OpenAI GPT-3.5-Turbo, Anthropic Claude-1.3

## Tasks

1. **Multi-document question answering (QA)** — passage + distractor documents + question
2. **Key-value retrieval (KVR)** — synthetic JSON KV pairs, model must retrieve the value for a given key

## Key Empirical Findings

- **U-shaped performance curve** as relevant information moves from start → middle → end of context
- **Primacy bias** — info at the beginning is well utilized
- **Recency bias** — info at the end is well utilized
- **Middle collapse** — info in the middle is significantly underutilized, even for models explicitly trained for long context (LongChat-13B/16K)
- Effect is **robust across model families** and **worsens with longer input contexts** (more distractor documents)
- Closed models (GPT-3.5, Claude) are **not immune** to the effect
- For closed models, performance also depends on **total input length**: very long inputs degrade even end-of-context retrieval

## Notes

- Filed under: Context Window Management / Selective Context Inclusion / Long-context Evaluation
- Domain tag: `code-agent`
- Central finding: a larger context window does **not** equal better long-context use
- This is the foundational empirical paper behind almost every "RAG > stuffing context" or "MemGPT-style paging" argument
- Implication for agents: if you must use long context, **place critical information at the edges**; for true long-horizon work, retrieve or page in relevant pieces rather than blindly stuffing
