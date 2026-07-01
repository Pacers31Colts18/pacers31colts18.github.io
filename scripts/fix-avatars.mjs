/**
 * fix-avatars.mjs
 * Replaces the old theme-colored backgrounds (red / cyan) in the
 * avatar PNGs with the Gruvbox palette equivalents.
 *
 * Usage: node scripts/fix-avatars.mjs
 */

import { PNG } from 'pngjs';
import { readFile, writeFile } from 'fs/promises';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');

// Gruvbox target backgrounds
const DARK_BG  = [0x32, 0x30, 0x2f]; // #32302f — dark-soft (card bg)
const LIGHT_BG = [0xf2, 0xe5, 0xbc]; // #f2e5bc — light-soft (card bg)

function replaceBackground(data, width, height, detect, target) {
  let replaced = 0;
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const i = (width * y + x) << 2;
      const r = data[i], g = data[i + 1], b = data[i + 2];

      if (detect(r, g, b)) {
        data[i]     = target[0];
        data[i + 1] = target[1];
        data[i + 2] = target[2];
        data[i + 3] = 255;
        replaced++;
      }
    }
  }
  return replaced;
}

async function fixAvatar(filename, detect, target) {
  const path = join(ROOT, 'static', 'img', filename);
  const src  = await readFile(path);
  const png  = PNG.sync.read(src);
  const n    = replaceBackground(png.data, png.width, png.height, detect, target);
  await writeFile(path, PNG.sync.write(png));
  console.log(`  ${filename} — ${n} pixels replaced`);
}

// Red background (#FF0000 ±40): avatar-dark.png
const isRed  = (r, g, b) => r > 180 && g < 90 && b < 90;
// Cyan background (#00FFFF ±40): avatar-light.png
const isCyan = (r, g, b) => r < 90 && g > 180 && b > 180;

console.log('Fixing avatar backgrounds…');
await fixAvatar('avatar-dark.png',  isRed,  DARK_BG);
await fixAvatar('avatar-light.png', isCyan, LIGHT_BG);
console.log('Done.');
