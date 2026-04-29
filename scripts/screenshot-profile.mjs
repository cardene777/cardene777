// Record docs/index.html as a webm video then convert to MP4 (and a small GIF fallback).
// Used both locally and from GitHub Actions to refresh the README artifacts.
import { chromium } from 'playwright';
import { fileURLToPath } from 'node:url';
import { execSync } from 'node:child_process';
import path from 'node:path';
import { mkdir, rm, readdir } from 'node:fs/promises';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, '..');

const target = process.env.SCREENSHOT_URL ??
  `file://${path.join(repoRoot, 'docs', 'index.html')}`;
const outDir = path.join(repoRoot, 'assets');
const gifFile = path.join(outDir, 'profile-terminal.gif');
const mp4File = path.join(outDir, 'profile-terminal.mp4');
const recordDir = path.join(repoRoot, '.tmp-record');
const RECORD_MS = Number(process.env.RECORD_MS ?? 8000);
const FPS = Number(process.env.GIF_FPS ?? 10);
const WIDTH = Number(process.env.GIF_WIDTH ?? 720);

await mkdir(outDir, { recursive: true });
await rm(recordDir, { recursive: true, force: true });
await mkdir(recordDir, { recursive: true });

const browser = await chromium.launch();
const context = await browser.newContext({
  viewport: { width: WIDTH, height: 1400 },
  recordVideo: { dir: recordDir, size: { width: WIDTH, height: 1400 } },
});
const page = await context.newPage();
await page.goto(target, { waitUntil: 'networkidle', timeout: 60_000 });

const fullHeight = await page.evaluate(() => document.body.scrollHeight);
console.log(`Full page height: ${fullHeight}px`);

await page.waitForTimeout(2000);

const scrollSteps = 12;
const stepDelay = Math.max(200, Math.floor((RECORD_MS - 4000) / scrollSteps));
for (let i = 1; i <= scrollSteps; i++) {
  const scrollTo = Math.floor((fullHeight * i) / scrollSteps);
  await page.evaluate((y) => window.scrollTo({ top: y, behavior: 'smooth' }), scrollTo);
  await page.waitForTimeout(stepDelay);
}

await page.waitForTimeout(2000);

await page.close();
await context.close();
await browser.close();

const files = (await readdir(recordDir)).filter((f) => f.endsWith('.webm'));
if (files.length === 0) throw new Error('No video recorded');
const videoFile = path.join(recordDir, files[0]);
console.log(`Recorded video: ${videoFile}`);

execSync(
  `ffmpeg -y -i "${videoFile}" -vf "scale=${WIDTH}:-2:flags=lanczos,fps=24" -c:v libx264 -pix_fmt yuv420p -movflags +faststart -crf 28 -preset slow "${mp4File}"`,
  { stdio: 'inherit' },
);

const palette = path.join(recordDir, 'palette.png');
execSync(
  `ffmpeg -y -i "${videoFile}" -vf "fps=${FPS},scale=${WIDTH}:-1:flags=lanczos,palettegen=stats_mode=diff" "${palette}"`,
  { stdio: 'inherit' },
);
execSync(
  `ffmpeg -y -i "${videoFile}" -i "${palette}" -lavfi "fps=${FPS},scale=${WIDTH}:-1:flags=lanczos [x]; [x][1:v] paletteuse=dither=bayer:bayer_scale=5" "${gifFile}"`,
  { stdio: 'inherit' },
);

await rm(recordDir, { recursive: true, force: true });

console.log(`Wrote ${gifFile}`);
console.log(`Wrote ${mp4File}`);
