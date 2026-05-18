import { Resvg } from '@resvg/resvg-js';
import fs from 'fs';

const fontPath = '/home/node/.openclaw/workspace-rowlet/.fonts/NotoSansCJKtc-Regular.otf';
const fontData = fs.readFileSync(fontPath);

console.log('Font size:', fontData.length, 'bytes');
console.log('Font first bytes:', fontData.slice(0,4).toString('hex'));

async function render(name, svgContent) {
  const escaped = svgContent.replace(/&(?!amp;|lt;|gt;|quot;|apos;|#)/g, '&amp;');
  
  // Try with font as buffer
  const r1 = new Resvg(escaped, {
    fontFiles: [fontData.buffer],
    loadSystemFonts: false,
    fitTo: { mode: 'width', value: 1600 },
    background: 'white',
  });
  const p1 = r1.render().asPng();
  
  // Try with font as Uint8Array
  const r2 = new Resvg(escaped, {
    fontFiles: [new Uint8Array(fontData)],
    loadSystemFonts: false,
    fitTo: { mode: 'width', value: 1600 },
    background: 'white',
  });
  const p2 = r2.render().asPng();
  
  console.log(`${name}: buffer=${p1.length}B uint8=${p2.length}B`);
  
  fs.writeFileSync(`${name}-buf.png`, p1);
  fs.writeFileSync(`${name}-uint8.png`, p2);
}

const svg1 = fs.readFileSync('01-uutagent-overview.svg', 'utf8');
const svg2 = fs.readFileSync('02-uutagent-4phases.svg', 'utf8');
const svg3 = fs.readFileSync('03-uutagent-verify-learning.svg', 'utf8');

await render('01', svg1);
await render('02', svg2);
await render('03', svg3);
