# Daily LLM Wiki Curator

Workspace target: `/home/amr/llm-wiki`

Your job once per run:

1. Work only inside `/home/amr/llm-wiki`.
2. Randomly choose one existing non-sensitive wiki entry to review.
   - Prefer entries under `wiki/concepts/`, `wiki/projects/`, `wiki/topics/`, or `wiki/sources/`.
   - Never choose anything under or derived from `raw/secrets/`.
3. Read the chosen wiki page.
4. Identify and inspect its underlying raw source(s).
5. Extend the research:
   - Use the web and/or source inspection to learn something relevant and current.
   - You may download a small number of clearly relevant public artifacts into `raw/`.
   - Keep downloads bounded and practical.
   - Prefer text, markdown, html, json, pdf, or small code/reference artifacts.
   - Avoid huge binaries, archives, models, media dumps, or anything privacy-sensitive.
6. Update or create wiki pages based on evidence:
   - Update the reviewed page if appropriate.
   - Create additional concept/source/topic/project/synthesis pages only when justified.
   - Update `wiki/index.md` if new pages were created.
   - Append a dated note to `wiki/log.md` summarizing what you reviewed and what you added.
7. Return a concise daily summary for the Discord channel.

Rules and safety constraints:
- Do not access or summarize secrets beyond noting that sensitive content was skipped.
- Do not modify files outside `/home/amr/llm-wiki` except temporary scratch files if needed.
- Keep the run lightweight: one reviewed entry, a few focused edits, and at most a few new raw files.
- Prefer reversible, well-named additions.
- Cite paths you touched in the final summary.
- If the chosen entry is low-value, broken, or sensitive, pick another one.
- If no worthwhile extension is found, still improve the wiki page or log with a careful review note instead of forcing low-quality additions.

Suggested raw destinations:
- Web pages/articles/docs -> `raw/web/` or `raw/references/`
- PDFs/docs -> `raw/documents/`
- Small code/reference snippets or repos -> `raw/code/` or `raw/references/`
- Misc supporting data -> `raw/data/`

Output expectation:
- 3-8 bullet points max
- mention selected entry
- mention any new raw files
- mention wiki pages created/updated
