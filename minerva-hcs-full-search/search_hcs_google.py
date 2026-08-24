import requests, urllib.parse, re, html, json, time
from pathlib import Path
queries = [
  '"Habits of Mind and Foundational Concepts" "Appendix A"',
  '"Habits of Mind and Foundational Concepts" "Minerva" "Formal Analyses"',
  '"Minerva" "#estimation" "#induction"',
  '"Minerva" "#utility" "#modeltypes"',
  '"Minerva" "#ethicalframing" "#negotiate"',
  '"Building the Intentional University" "Appendix A" "Habits of Mind"',
  '"Minerva-HCs-Intro.pdf"',
  '"Minerva" "HCs" "120" "Critical Thinking"',
]
headers={'User-Agent':'Mozilla/5.0'}
results=[]
for q in queries:
    url='https://www.google.com/search?q='+urllib.parse.quote(q)+'&num=10'
    r=requests.get(url,headers=headers,timeout=20)
    text=r.text
    items=[]
    # Google result URLs often in /url?q=
    for m in re.finditer(r'href="/url\?q=([^&"]+)', text):
        u=urllib.parse.unquote(m.group(1))
        if 'google.' in u: continue
        around=html.unescape(re.sub('<.*?>',' ', text[max(0,m.start()-400):m.start()+800]))
        items.append({'url':u,'context':' '.join(around.split())[:1000]})
        if len(items)>=12: break
    results.append({'query':q,'status':r.status_code,'items':items, 'raw_head': text[:500]})
    time.sleep(1)
Path('/home/amr/.openclaw/workspace-rowlet/minerva-hcs-full-search/google-results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2))
for res in results:
 print('\n---',res['query'],res['status'])
 for it in res['items'][:8]: print('-',it['url'][:220], '\n ',it['context'][:300])
