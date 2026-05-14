import fs from 'fs';
import path from 'path';
import { Resvg } from '@resvg/resvg-js';
const srcDir = '/home/node/.openclaw/workspace/llm-wiki/raw/presentations/evomap';
const outDir = '/home/node/.openclaw/workspace/llm-wiki/raw/presentations/evomap/png';
const fontFile = '/home/node/.openclaw/workspace-rowlet/.fonts/NotoSansCJKtc-Regular.otf';
fs.mkdirSync(outDir, { recursive: true });
for (const name of fs.readdirSync(srcDir)) {
  if (!name.endsWith('.svg')) continue;
  let svg = fs.readFileSync(path.join(srcDir, name), 'utf8');
  svg = svg.replace(/&(?!amp;|lt;|gt;|quot;|apos;|#)/g, '&amp;');
  const resvg = new Resvg(svg, {
    fitTo: { mode: 'width', value: 1600 },
    background: 'white',
    font: { fontFiles: [fontFile], loadSystemFonts: false, defaultFontFamily: 'Noto Sans CJK TC' }
  });
  const pngData = resvg.render().asPng();
  fs.writeFileSync(path.join(outDir, name.replace(/\.svg$/, '.png')), pngData);
  console.log('rendered', name);
}
