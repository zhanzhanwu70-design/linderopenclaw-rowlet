---
arxiv: 2609.36526v1
title: "Adapting Context Compression for Long-Horizon Agents with Counterfactual Continuations"
short: PAIR
authors: [Guanghui Min, Liang Wu, Minjia Shi, Yinhan He, Mayank Darbari, Liangjie Hong, Chen Chen]
affiliations: [University of Virginia, Nokia]
submitted: 2026-09-29
subjects: [cs.LG, cs.AI, cs.CL]
pages: 41 (main body 9 figures / 9 tables)
license: arXiv non-exclusive-distrib
related: [acon-2025, memgpt-2024-packer, context-engineering-2025-mei, lost-in-the-middle-2023-liu]
---

# PAIR (Min et al., 2026) — Paper Metadata

## BibTeX
```bibtex
@article{min2026pair,
  title  = {Adapting Context Compression for Long-Horizon Agents with Counterfactual Continuations},
  author = {Min, Guanghui and Wu, Liang and Shi, Minjia and He, Yinhan and Darbari, Mayank and Hong, Liangjie and Chen, Chen},
  year   = {2026},
  journal= {arXiv preprint arXiv:2609.36526},
  url    = {https://arxiv.org/abs/2609.36526}
}
```

## Why this paper matters for our wiki

- 它是 **ACON 路線的最新後續**，直接 attack ACON 暴露出的問題：trajectory-level 訊號太粗、agent stochasticity 干擾 attribution。
- 第一次把 **causal / counterfactual reasoning** 正式引進 context compression prompt adaptation。
- 在 AppWorld / OfficeBench / τ²-Bench Retail 三個 benchmark 上，**Pass3（reliability）全面勝過 ACON**，accuracy 也接近甚至超過 no-compression baseline。
- 9 天前 (2026-09-29) 投稿，仍是 v1 — 有 likely follow-up 的空間。

## Stored artifacts

- `pair-2026-min.pdf` (1.37 MB, 9 main pages + appendices, 41 pages total)
- `pair-2026-min.txt` (2,784 lines, `pdftotext -layout` extraction)
- `pair-2026-min.metadata.md` (this file)
- wiki source: `wiki/sources/pair-2026-min.md`
