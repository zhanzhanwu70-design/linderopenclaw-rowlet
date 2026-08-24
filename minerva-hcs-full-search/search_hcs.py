import requests, urllib.parse, re, html, json, time
from pathlib import Path
queries = [
  '"Habits of Mind and Foundational Concepts" "Appendix A"',
  '"Habits of Mind and Foundational Concepts" "Minerva" "#"',
  '"Minerva" "#estimation" "#induction"',
  '"Minerva" "#utility" "#modeltypes"',
  '"Minerva" "#ethicalframing" "#negotiate"',
  '"Building the Intentional University" "Appendix A" "#estimation"',
  '"Building the Intentional University" "#constraints"',
  '"Minerva" "foundational concepts" "#composition"',
  '"Minerva" "Habits of Mind" "payoff matrices"',
  '"Minerva" "HCs" "Formal Analyses" "Empirical Analyses"',
  '"Minerva" "HCs" "Multimodal Communications" "Complex Systems"',
  '"Minerva" "HCs" "120"',
]
results=[]
headers={'User-Agent':'Mozilla/5.0'}
for q in queries:
    print('QUERY', q, flush=True)
    url='https://search.yahoo.com/search?p='+urllib.parse.quote(q)
    try:
        r=requests.get(url,headers=headers,timeout=20)
        text=r.text
        items=[]
        for m in re.finditer(r'<a[^>]+href="(https?://[^"]+)"[^>]*>(.*?)</a>', text, re.S):
            t=html.unescape(re.sub('<.*?>',' ',m.group(2))).strip()
            h=html.unescape(m.group(1))
            if not t: continue
            if any(x in h for x in ['yahoo.com','javascript']): continue
            around=html.unescape(re.sub('<.*?>',' ',text[max(0,m.start()-300):m.end()+500]))
            items.append({'title':t[:300], 'url':h, 'context':' '.join(around.split())[:900]})
            if len(items)>=12: break
        results.append({'query':q,'status':r.status_code,'items':items})
    except Exception as e:
        results.append({'query':q,'error':repr(e)})
    time.sleep(1)
out=Path('/home/amr/.openclaw/workspace-rowlet/minerva-hcs-full-search/search-results.json')
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(json.dumps(results,ensure_ascii=False,indent=2), encoding='utf-8')
for res in results:
    print('\n---',res['query'],res.get('status'),res.get('error',''))
    for it in res.get('items',[])[:5]:
        print('-', it['title'][:220])
        print(' ', it['url'][:240])
        print('  ', it['context'][:240])
