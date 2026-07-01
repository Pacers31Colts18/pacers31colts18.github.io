# joeloveless.com

Personal blog built with [Docusaurus 3.9](https://docusaurus.io/). Gruvbox dark theme, IBM Plex Mono font, blog-only (no docs).

## Setup

```bash
npm install
```

## Local Development

```bash
npm start
```

Starts the dev server at `http://localhost:3000`. Most changes hot-reload without a restart.

## Writing a New Post

1. Create a folder under `blog/` named `YYYY-MM-DD-post-slug/`
2. Add an `index.md` inside it with frontmatter:

```markdown
---
title: Your Post Title
date: YYYY-MM-DD
description: One-sentence summary shown on the card grid.
tags:
  - Intune
  - PowerShell
---

Post content here...
```

3. Run the OG image generator (see below)
4. Commit and push — GitHub Actions deploys to GitHub Pages automatically

## OG / Social Card Images

Images are auto-generated from post frontmatter using Satori. They appear as the social preview card when a post is shared on social media (Twitter, LinkedIn, Bluesky, etc.).

**Generate images for new posts only:**

```bash
npm run og
```

**Regenerate all images** (e.g. after changing the design):

```bash
npm run og -- --force
```

Output goes to `static/img/og/{slug}.png`. The script also updates the `image:` frontmatter field in each post so Docusaurus picks it up automatically.

The design: dark Gruvbox background, three horizontal color stripes (amber `#d79921`, aqua `#8ec07c`, red `#cc241d`) centered vertically, post title above the stripes, site name upper-left, date lower-right.

## Build

```bash
npm run build
```

Generates the static site into the `build/` directory.

## Project Structure

```
blog/                  Blog posts (YYYY-MM-DD-slug/index.md)
src/
  components/
    HomeBlogList.js    Homepage post grid with client-side pagination
  css/
    custom.css         Gruvbox theme variables and global styles
  pages/
    index.js           Homepage (profile card + blog grid)
static/
  img/
    og/                Auto-generated OG images (gitignored or committed)
scripts/
  generate-og-images.mjs   OG image generator (Satori + resvg)
docusaurus.config.js   Site config (title, navbar, footer, blog settings)
```

## Key Design Decisions

- **6 posts per page** on both the homepage and `/blog` archive
- **Right sidebar** on individual blog posts (recent posts list)
- **Blog post headers** styled as a bordered card matching the profile card
- **OG images** are for social sharing only — not embedded inline in posts
- **IBM Plex Mono** loaded via Google Fonts (stylesheet) and `@fontsource` (OG image generation)
