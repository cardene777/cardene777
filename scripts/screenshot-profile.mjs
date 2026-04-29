// Screenshot docs/index.html and write assets/profile-terminal.png.
// Used both locally and from GitHub Actions to refresh the README image.
import { chromium } from 'playwright';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { mkdir } from 'node:fs/promises';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, '..');

const target = process.env.SCREENSHOT_URL ??
  `file://${path.join(repoRoot, 'docs', 'index.html')}`;
const outDir = path.join(repoRoot, 'assets');
const outFile = path.join(outDir, 'profile-terminal.png');

await mkdir(outDir, { recursive: true });

const browser = await chromium.launch();
const context = await browser.newContext({
  viewport: { width: 980, height: 1400 },
  deviceScaleFactor: 2,
});
const page = await context.newPage();
await page.goto(target, { waitUntil: 'networkidle', timeout: 60_000 });
await page.waitForTimeout(3000);

const body = await page.$('body');
await body.screenshot({
  path: outFile,
  omitBackground: false,
});

await browser.close();

console.log(`Wrote ${outFile}`);
