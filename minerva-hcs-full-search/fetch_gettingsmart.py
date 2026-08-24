import requests, re, html
from pathlib import Path
out=Path('/home/amr/llm-wiki/raw/references/minerva-hcs-full-list-search-2026-06-13')
out.mkdir(parents=True, exist_ok=True)
url='https://www.gettingsmart.com/2018/01/05/minerva-the-intentional-university/'
r=requests.get(url,headers={'User-Agent':'Mozilla/5.0'},timeout=30)
r.raise_for_status()
(out/'getting-smart-minerva-intentional-university.html').write_text(r.text,encoding='utf-8')
text=re.sub(r'<script.*?</script>|<style.*?</style>', ' ', r.text, flags=re.S|re.I)
text=re.sub(r'<[^>]+>', ' ', text)
text=html.unescape(text)
text='\n'.join(line.strip() for line in text.splitlines() if line.strip())
(out/'getting-smart-minerva-intentional-university.txt').write_text(text,encoding='utf-8')
print('saved', len(r.text), len(text))
idx=text.find('Thinking Critically')
print(text[idx:idx+4000])
