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

## 3. Recluster and regenerate the report

```bash
cd /home/amr/llm-wiki && PYTHONPATH=/home/amr/llm-wiki/raw/code/graphify:/home/amr/llm-wiki/.venv-graphify/Lib/site-packages python3 -m graphify cluster-only .
```

The run ends with `Done — N communities. GRAPH_REPORT.md and graph.json updated.`

The `PYTHONPATH` is required: the `graphify` entry point on PATH and `python3 -m graphify` inside `~/.openclaw/skills/graphify` are the installer wrapper, whose `cluster-only` subcommand does not exist. The real package lives at `/home/amr/llm-wiki/raw/code/graphify`, and the venv's editable install still points at a Windows path, so the local repo copy must be on `PYTHONPATH`. `networkx` is pure Python and importable from the venv's `Lib/site-packages` on Linux.

## 4. Verify the new pages are not orphans

```bash
python3 scripts/check_graph_links.py "Page Title" "Another Title"
```

Every listed title must print `ok` with at least 1 incoming wiki_link. `MISSING` means no node carries that title; `ORPHAN` means the node exists but nothing links to it — go back to step 1, add the backlinks, then repeat from step 2.

Also confirm `graphify-out/GRAPH_REPORT.md` shows the current date and the expected node/edge totals.

## 5. Log the change

Append a dated entry to `/home/amr/llm-wiki/wiki/log.md` naming the raw artifacts, the wiki files added, and the final node/edge/community counts.

## Environment notes

- `graphify-out/` is read-only (`dr-x---r-x`) — do not try to write backup copies there.
- `graphify cluster-only` skips `graph.html` once the graph passes 5000 nodes; that is expected, not a failure.
