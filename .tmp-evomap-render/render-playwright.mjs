import { chromium } from 'playwright';
import fs from 'fs';

async function renderSVG(svgPath, outPath) {
  const svg = fs.readFileSync(svgPath, 'utf8');
  
  const html = `<!DOCTYPE html>
<html>
<head>
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body { background: white; }
svg { max-width: 100%; height: auto; display: block; }
</style>
</head>
<body>
${svg}
</body>
</html>`;

  const browser = await chromium.launch({ headless: true, args: ['--no-sandbox'] });
  const page = await browser.newPage({ viewport: { width: 1600, height: 900 } });
  await page.setContent(html, { waitUntil: 'networkidle' });
  await page.waitForTimeout(1000);
  
  const screenshot = await page.screenshot({ type: 'png', clip: { x: 0, y: 0, width: 1600, height: 900 } });
  await browser.close();
  
  fs.writeFileSync(outPath, screenshot);
  console.log(`Rendered: ${outPath} (${screenshot.length} bytes)`);
  return screenshot.length;
}

const svg1 = '01-uutagent-overview.svg';
const svg2 = '02-uutagent-4phases.svg';
const svg3 = '03-uutagent-verify-learning.svg';

await renderSVG(svg1, 'pw-01.png');
await renderSVG(svg2, 'pw-02.png');
await renderSVG(svg3, 'pw-03.png');
