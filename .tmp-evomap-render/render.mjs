import fs from 'fs';
import path from 'path';
import { Resvg } from '@resvg/resvg-js';
const srcDir = '/home/amr/llm-wiki/raw/presentations/evomap';
const outDir = '/home/amr/llm-wiki/raw/presentations/evomap/png';
fs.mkdirSync(outDir, { recursive: true });
for (const name of fs.readdirSync(srcDir)) {
  if (!name.endsWith('.svg')) continue;
  let svg = fs.readFileSync(path.join(srcDir, name), 'utf8');
  svg = svg.replace(/&(?!amp;|lt;|gt;|quot;|apos;|#)/g, '&amp;');
  const resvg = new Resvg(svg, { fitTo: { mode: 'width', value: 1600 }, background: 'white' });
  const pngData = resvg.render().asPng();
  fs.writeFileSync(path.join(outDir, name.replace(/\.svg$/, '.png')), pngData);
  console.log('rendered', name);
}
