---
name: "llm-wiki-graph-sync"
description: "Sync llm-wiki pages into the graphify graph. Use after writing wiki sources/concepts/people. Produces graph nodes, wikilink edges, fresh GRAPH_REPORT.md."
---

# llm-wiki Graph Sync

Keep `/home/amr/llm-wiki/wiki/` pages and `graphify-out/graph.json` consistent so every new page is reachable through graph queries instead of sitting as an orphan.

## 1. Author pages with resolvable wikilinks

- Put each new page under `wiki/sources/`, `wiki/concepts/`, `wiki/people/`, or `wiki/topics/` with frontmatter keys `type`, `title`, `created`, `updated`, `tags`.
- A page with no incoming `[[wikilink]]` is an orphan in the graph. When adding one source page, also add the concept, person, and topic pages it introduces, and link them back to each other with `[[concepts/<name>]]`, `[[people/<name>]]`, `[[topics/<name>]]`.
- A wikilink resolves by vault path, by bare filename, or by exact page title. Linking `[[集中力量辦大事]]` and `[[concepts/集中力量辦大事]]` both work.

## 2. Append the wiki pages to the graph

```bash
cd /home/amr/llm-wiki && python3 tools/add-wiki-pages-to-graphify.py
```

This rewrites `graphify-out/graph.json` deterministically: one `wiki_<sha256[:16]>` node per page plus one `wiki_link` edge per wikilink found in page text. The run ends with `PASS: Added N wiki page nodes and M wiki links`.

Use the Python tool, not `tools/add-wiki-pages-to-graphify.ps1` — no PowerShell on this host.

## 3. Recluster and regenerate the report — only with a verified rollback

`cluster-only` rebuilds the graph from the extraction cache, so it **drops the `wiki_link` edges that step 2 added**. Measured on 2026-11-21: total edges **24,521 → 20,463** and `wiki_link` **16,347 → 12,289** (about 4,000 wiki links gone), the output key changed from `edges` to `links`, and `graph.html` was deleted. The run still reports success, so treat the graph as damaged until you check it.

Back up first, into `/tmp` and not into `graphify-out/`:

```bash
cd /home/amr/llm-wiki
cp graphify-out/graph.json /tmp/graph.json.bak
cp graphify-out/GRAPH_REPORT.md /tmp/GRAPH_REPORT.bak.md
```

Then run:

```bash
cd /home/amr/llm-wiki && PYTHONPATH=/home/amr/llm-wiki/raw/code/graphify python3 -m graphify cluster-only . --no-viz
```

The `PYTHONPATH` is required: the `graphify` entry point on PATH and `python3 -m graphify` inside `~/.openclaw/skills/graphify` are the installer wrapper, whose `cluster-only` subcommand does not exist. The real package lives at `/home/amr/llm-wiki/raw/code/graphify`, and the venv's editable install still points at a Windows path, so the local repo copy must be on `PYTHONPATH`.

`networkx` is not reliably importable from `.venv-graphify/Lib/site-packages` on this host. If the run dies on the import, `python3 -m pip install --user networkx` is enough — it is pure Python and needs no root.

After the run, compare edge counts. If `wiki_link` dropped, restore the backup and skip this step:

```bash
cp /tmp/graph.json.bak graphify-out/graph.json
cp /tmp/GRAPH_REPORT.bak.md graphify-out/GRAPH_REPORT.md
```

**For wiki page sync, step 2 alone is sufficient** — the Python linker already writes the nodes and edges. Run `cluster-only` only when you have a reason to recluster, and repeat step 2 afterwards if you do. A `GRAPH_REPORT.md` that lags `graph.json` is a known, acceptable state; a `graph.json` missing thousands of `wiki_link` edges is not.

## 4. Verify the new pages are not orphans

```bash
python3 scripts/check_graph_links.py "Page Title" "Another Title"
```

Every listed title must print `ok` with at least 1 incoming wiki_link. `MISSING` means no node carries that title; `ORPHAN` means the node exists but nothing links to it — go back to step 1, add the backlinks, then repeat from step 2.

Pages that only link *to* each other still have 0 incoming edges, because their edges are outgoing. Give every new page at least one incoming edge by putting a `[[<page-name>]]` wikilink for it in `wiki/index.md` — index wikilinks are `wiki_link` edges and count as incoming. After editing the index, repeat step 2.

When `scripts/check_graph_links.py` is unavailable, count incoming `wiki_link` edges per new page directly from the graph:

```bash
cd /home/amr/llm-wiki && python3 - <<'PY'
import json
paths = ["concepts/foo", "sources/bar"]          # replace with the new pages' wiki paths
g = json.load(open("graphify-out/graph.json"))
node_path = {n["id"]: n.get("wiki_path", "") for n in g["nodes"]}
incoming = {p: 0 for p in paths}
for e in g.get("edges", []):
    if e.get("relation") != "wiki_link":
        continue
    wp = node_path.get(e.get("target"), "")
    if wp in incoming:
        incoming[wp] += 1
for p, c in incoming.items():
    print(f"{c:>3} incoming  {p}")
PY
```

Count against the graph step 2 wrote — a recluster in step 3 drops `wiki_link` edges entirely, so the count would be zero for every page. A page that still shows 0 incoming edges is an orphan: add its `wiki/index.md` wikilink and repeat step 2.

Also confirm `graphify-out/GRAPH_REPORT.md` shows the current date and the expected node/edge totals.

## 5. Log the change

Append a dated entry to `/home/amr/llm-wiki/wiki/log.md` naming the raw artifacts, the wiki files added, and the final node/edge/community counts.

## Environment notes

- `graphify-out/` is read-only (`dr-x---r-x`) — do not try to write backup copies there.
- `graphify cluster-only` skips `graph.html` once the graph passes 5000 nodes; that is expected, not a failure.
