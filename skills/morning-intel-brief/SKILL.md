---
name: "morning-intel-brief"
description: "Morning intel dispatch: first-party AI/software news, deduped, four-part report. Use when the morning pipeline asks for news."
---

# Morning intel brief (Rowlet → Roaringmoon pipeline)

## When to use

The morning pipeline dispatch asks for today's AI / software news as a four-part report under a hard deadline (T+15).

## Steps

1. **Batch-fetch first-party feeds once, at dispatch time.** Run a single command that fetches every vendor feed and prints HTTP status plus byte size per feed; keep only feeds returning 200. Verified endpoints: OpenAI official news RSS (openai.com), `https://huggingface.co/blog/feed.xml`, `https://blogs.nvidia.com/feed/`, `https://aws.amazon.com/blogs/aws/feed/`, `https://blog.google/technology/ai/rss/`, `https://mistral.ai/news/rss`, and `anthropic.com/news/announcements`.
   *Done when:* every candidate title carries a feed timestamp.

2. **Cull by date and by prior publication.** Drop anything the dispatch lists as published in the last 7 days, and anything whose feed date falls outside the target window. Also record each excluded source with a reason and its evidence (feed URL + that feed's newest item date) so the next round does not re-crawl it.
   *Done when:* every remaining candidate is new to the pipeline.

3. **Establish the date on the page itself, and name the field that carried it.** A feed timestamp is not proof, and the first date-like string on a page usually is not either. Identify the specific field holding the article's own date — `datePublished`, a `Posted on:` line, an atom `<updated>`, or a date printed in the body — and carry that field name plus its value to the report, so the pipeline can re-verify each item without re-reading the page.
   Page dates mislead in five recurring shapes:
   - a top-bar "today" label showing the current date above an article published weeks earlier (Anthropic's index prints "Latest news / <today>" above a featured article whose own `<time>` is weeks back);
   - a sidebar or promo banner promoting a *different* article (a "PostgreSQL 19 Released!" banner read as the date of an adjacent post);
   - `dateModified` mistaken for the publish date;
   - a first-party weekly roundup whose printed date is the aggregation date while every linked item was published days earlier;
   - an atom feed (`<entry>/<updated>`) with no `<pubDate>`, where a date grep finds nothing — read `datePublished` instead.
   When the page prints no date, check the official sitemap/RSS, and drop the item if the date still cannot be established. Second-hand sources (media rewrites, vendor business case studies) are excluded outright. First-party roundups are excluded as items too, but use them as an index: open each linked first-party page and date it on its own.
   When the page announces an open-source release, read the repository in the same fetch round: the VERSION file, star/fork/commit counts, the README's stated prerequisites, and the LICENSE. The repository states the maturity the announcement page glosses over — a `0.0.0-dev` VERSION, a "requires TPM 2.0 and a signed-loader kernel" line, a BSD-versus-GPL dual license — and those values are exactly the section-① facts the other side cannot know. Label the item pre-release when the VERSION file says so, and quote star/commit counts as observed-now values, since they move.
   *Done when:* each item has a date printed by its own page, the date field is named, and every open-source item carries a maturity fact taken from the repository rather than from the announcement wording.

4. **Respect the topic boundary, but never drop a hand-off.** Rowlet owns AI / model / product / company-level items; architecture and developer tooling belong to Charizard. When an item sits on Charizard's side, name it in the report explicitly as Charizard's candidate rather than counting it as one of your own delivered items. If it goes unpublished that round, verify the first-party page yourself and publish it as your own item in the next round.
   *Done when:* every yielded item has a named owner, and no yielded item is left ownerless.

5. **Build the four-part report with per-item evidence.** Each item carries: title, 2-sentence summary, full first-party URL, the page-printed date **plus the date field you used to read it**, one time qualifier (then/now, conference date/release date), one maturity or default state (public preview / GA, default on/off), and 1–2 verbatim sentences from the page. Then append the four sections: (1) 1–2 facts the other side cannot know (numbers, versions, dates, exact source phrases); (2) where your leading conclusion may be wrong; (3) your conclusion plus residual uncertainty; (4) every conflicting claim written as "possible conflict: X vs Y", including claims you are unsure the other side saw.
   *Done when:* all four sections and every per-item field are present, each item naming its date field.

6. **Ship inside T+15 and stop.** Deliver via `sessions_send` to the pipeline session as soon as candidates converge; add no extra verification afterwards. Prefer two solid items over four padded with already-published ones.
   *Done when:* the pipeline session acknowledges the delivery.

## Pitfalls

- Write section 4 as claim pairs — "possible conflict: X vs Y" — not as a summary of the other side's article. List what you might have seen differently even when you are unsure.
- Already-published items are excluded even when you have fresh commentary on them; put that commentary in the depth section, never as a delivered item.
- A feed timestamp is not proof of date; the page itself must print the date — and you must name the field that printed it. "Published 2026-11-24" is not re-verifiable; "Posted on: Nov 24, 2026" is.
- A page date is not automatically the article date: today-labels, promo banners for other articles, `dateModified`, and roundup aggregation dates all masquerade as the publish date.
- Every excluded source still needs a reason plus evidence, or the next round re-crawls it.
- Quote source sentences verbatim in the source language and write the surrounding report in Chinese.
- Yielding an item to another line is not the same as dropping it: name the owner, then check the next round whether it shipped.

## Verification

- Every delivered item: the first-party URL returns 200 and prints a publication date.
- Every item names the date field it used, and the value in that field is the item's own publish date — not a today-label, banner, `dateModified`, or aggregation date.
- Every item's maturity label matches the page's own wording (preview vs GA, default on/off) rather than your paraphrase.
