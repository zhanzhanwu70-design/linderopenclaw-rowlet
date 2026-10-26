#!/usr/bin/env python3
"""Report incoming wikilink edges for named llm-wiki pages.

Usage: python3 check_graph_links.py "Page Title" ["Another Title"]
Exit code 1 when a title is missing from the graph or has no incoming wikilink.
"""
import json
import sys
from pathlib import Path

GRAPH = Path("/home/amr/llm-wiki/graphify-out/graph.json")


def main() -> int:
    labels = sys.argv[1:]
    if not labels:
        print("usage: check_graph_links.py <title> [<title> ...]", file=sys.stderr)
        return 2

    graph = json.loads(GRAPH.read_text(encoding="utf-8"))
    nodes = graph.get("nodes") or []
    edges = graph.get("edges") or graph.get("links") or []

    by_label = {}
    for node in nodes:
        label = (node.get("label") or node.get("norm_label") or "").lower()
        if label:
            by_label.setdefault(label, node.get("id"))

    communities = {n.get("community") for n in nodes if n.get("community") is not None}
    print(
        f"nodes={len(nodes)} edges={len(edges)} communities={len(communities)}"
    )

    rc = 0
    for label in labels:
        node_id = by_label.get(label.lower())
        if node_id is None:
            print(f"MISSING  {label} — no graph node carries that title")
            rc = 1
            continue
        incoming = sum(
            1
            for e in edges
            if e.get("relation") == "wiki_link" and e.get("target") == node_id
        )
        if incoming:
            print(f"ok       {label} — {incoming} incoming wiki_link")
        else:
            print(f"ORPHAN   {label} — 0 incoming wiki_link")
            rc = 1
    return rc


if __name__ == "__main__":
    raise SystemExit(main())
