import requests, urllib.parse, re, html, json, time
from pathlib import Path
queries = [
  'Habits of Mind and Foundational Concepts Minerva Appendix A',
  'Minerva HCs Critical Thinking Creative Thinking Effective Communication Effective Interaction',
  'Minerva HCs 120 habits of mind foundational concepts',
  'Building the Intentional University Appendix A Habits of Mind Foundational Concepts',
]
headers={'User-Agent':'Mozilla/5.0'}
results=[]
for q in queries:
    url='https://search.brave.com/search?q='+urllib.parse.quote(q)
    r=requests.get(url,headers=headers,timeout=20)
    text=r.text
    items=[]
    for m in re.finditer(r'<a[^>]+href="(https?://[^"]+)"[^>]*>(.*?)</a>', text, re.S):
        t=html.unescape(re.sub('<.*?>',' ',m.group(2))).strip()
        u=html.unescape(m.group(1))
        if not t or any(x in u for x in ['brave.com','javascript']): continue
        around=html.unescape(re.sub('<.*?>',' ', text[max(0,m.start()-300):m.end()+700]))
        items.append({'title':t[:300], 'url':u, 'context':' '.join(around.split())[:1000]})
        if len(items)>=15: break
    results.append({'query':q,'status':r.status_code,'items':items,'head':text[:500]})
    time.sleep(3)
Path('/home/node/.openclaw/workspace-rowlet/minerva-hcs-full-search/brave-results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2))
for res in results:
 print('\n---',res['query'],res['status'])
 for it in res['items'][:10]: print('-',it['title'][:160], '\n ',it['url'][:240], '\n ',it['context'][:260])
