# SIRIN: A Unified Toolkit for Detecting Contextual Hallucinations in RAG and Memory-Grounded LLM Systems

## Metadata

| Field | Value |
|-------|-------|
| **Title** | SIRIN: A Unified Toolkit for Detecting Contextual Hallucinations in Retrieval-Augmented and Memory-Grounded LLM Systems |
| **Authors** | Julia Belikova, Rauf Parchiev, Mikhail Filimonov, Konstantin Polev, Andrey Savchenko, Maksim Makarenko |
| **Affiliation** | Sber AI Lab |
| **arXiv** | 2608.00033 |
| **Submitted** | 20 July 2026 |
| **Subjects** | cs.AI |
| **URL** | https://arxiv.org/abs/2608.00033 |
| **PDF** | raw/references/papers/ai/sirin-2026-belikova.pdf |
| **Code** | https://github.com/sb-ai-lab/SIRIN |
| **Demo** | https://hf.co/spaces/parchiev/SIRIN |
| **HTML** | https://arxiv.org/html/2608.00033v1 |
| **Domain** | Context Processing / RAG / Hallucination Detection |

## Abstract (as published)

SIRIN (Semantic Inconsistency Recognition and Inspection Nexus) is a unified toolkit and interactive web UI for detecting contextual hallucinations (fluent, plausible responses unsupported by the provided evidence) in retrieval-augmented, agentic, and memory-grounded LLM systems. SIRIN unifies three detector paradigms (representation probing, uncertainty estimation, and judge-style verification) and the complementary task of pre-generation query answerability under one interface, configuration system, and evaluation pipeline, supporting response- and span-level inspection in both white-box and black-box settings. The web UI enables live analysis of user-supplied context-query-answer triples through hallucination scores, unsupported-span highlighting, and side-by-side detector comparison, with a lightweight plug-in design for adding new detectors. We demonstrate SIRIN on hallucination detection, query answerability, and as a faithfulness gate within long-term memory systems.

## Three Detector Families

1. **Representation Probing (white-box)**: Train lightweight classifiers over frozen LLM hidden states, attention maps, token probabilities. Examples: Lookback Lens, token-level span prediction.
2. **Uncertainty Estimation (black-box)**: Score generations by model's own confidence — perplexity, semantic uncertainty, attention-aware estimators (RAUQ), entropy-based methods.
3. **Judge-style Verification (black-box)**: Use a second model (encoder, decoder, or API-based) for NLI-style / alignment-style factuality checks. LLM-as-judge verification.

## Key Capabilities

- Unified interface: same report schema `(s, ŷ, E)` where s ∈ [0,1] calibrated score, ŷ = predicted label, E = evidence (span scores, uncertainty values, judge rationales)
- Two complementary tasks: **contextual hallucination detection** (post-gen faithfulness check) + **query answerability** (pre-gen sufficiency check)
- Span-level localization: unsupported spans highlighted on answer text
- Plug-in architecture for adding new detectors
- Integration as faithfulness gate in long-term memory systems (demonstrated with SimpleMem)

## Comparison with Existing Toolkits

| Toolkit | Probe | Judge | UE | Answerability | Span | UI |
|---------|-------|-------|----|-------|------|----|
| LM-Polygraph | ~ | ✗ | ✓ | ✗ | ~ | ~ |
| RAGAS | ✗ | ✓ | ✗ | ~ | ~ | ✗ |
| DeepEval | ✗ | ✓ | ✗ | ~ | ~ | ✗ |
| UpTrain | ✗ | ✓ | ✗ | ✓ | ~ | ✓ |
| TruLens | ✗ | ✓ | ✗ | ~ | ~ | ✓ |
| LettuceDetect | ✗ | ✓ | ✗ | ✗ | ✓ | ✓ |
| **SIRIN** | **✓** | **✓** | **✓** | **✓** | **✓** | **✓** |

## Why This Matters for Context Processing

Contextual hallucination is the failure mode where the model is fluent and plausible but not grounded in the provided context. In RAG + agent memory systems, this compounds over multiple retrieval-summarize-store cycles. The paper explicitly calls out: "Such failures are especially consequential in deployed RAG systems and in agentic pipelines, where models repeatedly retrieve, summarize, store, and update declarative or procedural memory over long-term interaction."

## Research Gap Addressed

No existing toolkit unifies all three detector families under a single interface. SIRIN treats this as an **infrastructure problem**, not a single-detector problem.
