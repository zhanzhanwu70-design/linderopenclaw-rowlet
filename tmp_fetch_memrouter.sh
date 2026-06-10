#!/usr/bin/env bash
set -euo pipefail
ROOT=/home/node/.openclaw/workspace/llm-wiki
DIR="$ROOT/raw/references/papers/ai/memrouter-memory-as-embedding-routing-2605.00356"
mkdir -p "$DIR"
python3 - <<'PY'
import json, urllib.request, pathlib
root=pathlib.Path('/home/node/.openclaw/workspace/llm-wiki/raw/references/papers/ai/memrouter-memory-as-embedding-routing-2605.00356')
meta={
  'arxiv_id':'2605.00356v1',
  'title':'MemRouter: Memory-as-Embedding Routing for Long-Term Conversational Agents',
  'authors':['Tianyu Hu','Weikai Lin','Weizhi Zhang','Jing Ma','Song Wang'],
  'published':'2026-05-01T02:33:50Z',
  'updated':'2026-05-01T02:33:50Z',
  'categories':['cs.CL','cs.AI'],
  'abstract':'Long-term conversational agents must decide which turns to store in external memory, yet recent systems rely on autoregressive LLM generation at every turn to make that decision. We present MemRouter, a write-side memory router that decouples memory admission from the downstream answer backbone and replaces per-turn memory-management decoding with an embedding-based routing policy. MemRouter encodes each turn together with recent context, projects the resulting embeddings through a frozen LLM backbone, and predicts whether the turn should be stored using lightweight classification heads while training only 12M parameters. Under a controlled matched-harness comparison on LoCoMo, where the retrieval pipeline, answer prompts, and QA backbone (Qwen2.5-7B) are held identical, MemRouter outperforms an LLM-based memory manager on every question category (overall F1 52.0 vs 45.6, non-overlapping 95% CIs) while reducing memory-management p50 latency from 970ms to 58ms. Descriptive factorial averaging further shows that learned admission improves mean F1 by +10.3 over random storage, category-specific prompting adds +5.2 over a generic prompt, and retrieval contributes +0.7. These results suggest that write-side memory admission can be learned by a small supervised router, while answer generation remains a separate downstream component in long-horizon conversational QA.',
  'abs_url':'https://arxiv.org/abs/2605.00356v1',
  'pdf_url':'https://arxiv.org/pdf/2605.00356v1',
  'source':'arXiv API snapshot fetched 2026-06-09'
}
(root/'metadata.json').write_text(json.dumps(meta, ensure_ascii=False, indent=2), encoding='utf-8')
urllib.request.urlretrieve(meta['pdf_url'], root/'memrouter-2605.00356v1.pdf')
urllib.request.urlretrieve('https://export.arxiv.org/api/query?id_list=2605.00356', root/'arxiv-api.xml')
PY
if command -v pdftotext >/dev/null 2>&1; then
  pdftotext -layout "$DIR/memrouter-2605.00356v1.pdf" "$DIR/memrouter-2605.00356v1.txt"
else
  printf 'pdftotext not available; PDF saved but text extraction blocked.\n' > "$DIR/EXTRACT_TEXT_BLOCKED.txt"
fi
ls -lh "$DIR"
