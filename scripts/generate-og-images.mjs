/**
 * generate-og-images.mjs
 *
 * Generates Gruvbox-styled 1200×630 OG images for every blog post and
 * updates the `image:` frontmatter field so Docusaurus picks them up for
 * social sharing.
 *
 * Usage:
 *   npm run og            — skip posts whose PNG already exists
 *   npm run og -- --force — regenerate all posts
 */

import satori from 'satori';
import { Resvg } from '@resvg/resvg-js';
import { readFile, writeFile, mkdir, readdir } from 'fs/promises';
import { existsSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { createElement as h } from 'react';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT     = join(__dirname, '..');
const BLOG_DIR = join(ROOT, 'blog');
const OUT_DIR  = join(ROOT, 'static', 'img', 'og');
const FONT_DIR = join(ROOT, 'node_modules/@fontsource/ibm-plex-mono/files');

// ── Gruvbox dark palette ──────────────────────────────────────────────────────
const G = {
  bg:      '#1d2021',
  fg:      '#ebdbb2',
  muted:   '#a89984',
  yellow:  '#d79921',
  aqua:    '#8ec07c',
  card:    '#3c3836',
};

// ── Font loading (from @fontsource/ibm-plex-mono in node_modules) ────────────
async function loadFonts() {
  const [regular, semiBold] = await Promise.all([
    readFile(join(FONT_DIR, 'ibm-plex-mono-latin-400-normal.woff')),
    readFile(join(FONT_DIR, 'ibm-plex-mono-latin-600-normal.woff')),
  ]);
  return [
    { name: 'IBM Plex Mono', data: regular,  weight: 400, style: 'normal' },
    { name: 'IBM Plex Mono', data: semiBold, weight: 600, style: 'normal' },
  ];
}

// ── Frontmatter parser ────────────────────────────────────────────────────────
function parseFrontmatter(src) {
  const m = src.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  if (!m) return {};

  const block = m[1];
  const out = {};

  // Scalar fields (title, date, image, slug …)
  for (const line of block.split(/\r?\n/)) {
    const kv = line.match(/^(\w[\w-]*):\s*(.*)$/);
    if (kv) out[kv[1]] = kv[2].trim().replace(/^['"]|['"]$/g, '');
  }

  // Tags as YAML sequence (  - value) or inline ([a, b])
  const seq = block.match(/^tags:\s*\r?\n((?:[ \t]+[-•]\s*.+\r?\n?)+)/m);
  if (seq) {
    out.tags = seq[1]
      .split(/\r?\n/)
      .map(l => l.replace(/^[ \t]+[-•]\s*/, '').replace(/^['"]|['"]$/g, '').trim())
      .filter(Boolean);
  } else {
    const inl = block.match(/^tags:\s*\[([^\]]*)\]/m);
    if (inl) out.tags = inl[1].split(',').map(t => t.trim().replace(/^['"]|['"]$/g, ''));
  }

  if (!Array.isArray(out.tags)) out.tags = [];
  return out;
}

// ── OG image — Gruvbox lines, title above lines, site + date corners ─────────
async function buildPng(title, date, tags, fonts) {
  // Colors from custom.css: amber (dark primary), aqua (dark footer), red (light header)
  const LINES = ['#d79921', '#8ec07c', '#cc241d'];
  const LINE_H = 36;
  const TOTAL_H = LINES.length * LINE_H; // 108px
  const LINES_TOP = Math.round((630 - TOTAL_H) / 2); // 261

  const fontSize = title.length > 50 ? 46 : title.length > 30 ? 56 : 66;

  const dateStr = date
    ? new Date(date).toLocaleDateString('en-US', {
        month: 'long', day: 'numeric', year: 'numeric', timeZone: 'UTC',
      })
    : '';

  const root = h('div', {
    style: {
      display: 'flex',
      position: 'relative',
      width: '1200px', height: '630px',
      background: '#282828',
      fontFamily: '"IBM Plex Mono"',
    }
  },
    // Site name — upper left
    h('div', {
      style: {
        position: 'absolute', top: 48, left: 64,
        display: 'flex',
        color: G.muted, fontSize: 18, letterSpacing: '0.06em',
      }
    }, 'joeloveless.com'),

    // Title — centered horizontally, bottom edge flush with top of first line
    h('div', {
      style: {
        position: 'absolute',
        left: 80, right: 80,
        bottom: 630 - LINES_TOP, // bottom of element = top of first line
        display: 'flex',
        justifyContent: 'center',
      }
    },
      h('div', {
        style: {
          display: 'flex',
          color: G.fg, fontSize, fontWeight: 600,
          lineHeight: 1.3, textAlign: 'center',
        }
      }, title)
    ),

    // Lines — vertically centered
    h('div', {
      style: {
        position: 'absolute',
        top: LINES_TOP, left: 0,
        display: 'flex', flexDirection: 'column',
        width: '1200px',
      }
    }, ...LINES.map(color =>
      h('div', { style: { width: '1200px', height: LINE_H, background: color } })
    )),

    // Date — bottom right
    dateStr ? h('div', {
      style: {
        position: 'absolute', bottom: 48, right: 64,
        display: 'flex',
        color: G.muted, fontSize: 18,
      }
    }, dateStr) : null,
  );

  const svg = await satori(root, { width: 1200, height: 630, fonts });
  return new Resvg(svg).render().asPng();
}

// ── Blog post discovery ───────────────────────────────────────────────────────
async function* findPosts(dir) {
  const entries = await readdir(dir, { withFileTypes: true });
  for (const e of entries) {
    const full = join(dir, e.name);
    if (e.isDirectory()) {
      for (const name of ['index.mdx', 'index.md']) {
        const p = join(full, name);
        if (existsSync(p)) { yield { file: p, slug: e.name }; break; }
      }
    } else if (/\.mdx?$/.test(e.name)) {
      yield { file: full, slug: e.name.replace(/\.mdx?$/, '') };
    }
  }
}

// ── Main ──────────────────────────────────────────────────────────────────────
async function main() {
  const force = process.argv.includes('--force');

  console.log('Loading fonts…');
  const fonts = await loadFonts();

  await mkdir(OUT_DIR, { recursive: true });

  let generated = 0, skipped = 0, failed = 0;

  for await (const { file, slug } of findPosts(BLOG_DIR)) {
    const outFile = join(OUT_DIR, `${slug}.png`);
    const imgPath = `/img/og/${slug}.png`;

    if (!force && existsSync(outFile)) { skipped++; continue; }

    const src = await readFile(file, 'utf-8');
    const fm  = parseFrontmatter(src);
    const title = fm.title || slug;

    process.stdout.write(`  ${slug} … `);
    try {
      const png = await buildPng(title, fm.date, fm.tags, fonts);
      await writeFile(outFile, png);

      // Update image: field in frontmatter only (social sharing card)
      // Do NOT replace inline images in post bodies — the static PNG doesn't adapt to light/dark mode
      const updated = /^image:/m.test(src)
        ? src.replace(/^image:.*$/m, `image: ${imgPath}`)
        : src.replace(/^---/, `---\nimage: ${imgPath}`);

      await writeFile(file, updated, 'utf-8');

      console.log('ok');
      generated++;
    } catch (err) {
      console.log(`FAILED — ${err.message}`);
      failed++;
    }
  }

  console.log(`\n${generated} generated · ${skipped} skipped · ${failed} failed`);
}

main().catch(err => { console.error(err); process.exit(1); });
