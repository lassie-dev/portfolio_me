# Lassie's Letter

A single-page portfolio. No build step, no dependencies, no framework — one static
HTML file that loads two fonts from Google Fonts and does everything else itself.

## Editing content

Everything personal lives in **one place**: the `DATA` object near the top of the
`<script>` block in `content.html`.

```js
var DATA = {
  about:     [ "paragraph", "paragraph" ],
  preview:   true,          // set to false once the repos below are real
  repos:     [ { name, desc, url, lang, color, stars, updated } ],
  languages: [ { name, pct, color } ],   // pct should sum to ~100
  links:     [ { where, what, url } ]
};
```

Nothing else in the file needs to change to keep the site current.

`preview: true` shows a dashed "Preview entries" chip above the work list. Delete
that line (or set it to `false`) once the entries are your real repositories.

## Building

`content.html` is the source. `index.html` is generated from it:

```powershell
powershell -ExecutionPolicy Bypass -File build.ps1
```

The build lifts `<title>` and the font `<link>` tags into a proper `<head>`,
adds meta/Open Graph tags and the favicon, and writes `index.html`.

**Run this after every edit to `content.html`** — Vercel deploys `index.html`,
not `content.html`.

## Deploying to Vercel

`vercel.json` is already set up: static hosting, clean URLs, and sensible
security headers. No framework preset is needed — Vercel serves `index.html`
from the project root.

### Option A — CLI (fastest, no Git required)

```powershell
npm i -g vercel
vercel login
vercel          # preview deployment
vercel --prod   # production
```

Answer the setup prompts with the defaults; when it asks for the output
directory, accept the root.

### Option B — Git

```powershell
git init
git add .
git commit -m "Portfolio site"
git branch -M main
git remote add origin https://github.com/<your-username>/<repo>.git
git push -u origin main
```

Then on [vercel.com/new](https://vercel.com/new), import the repository.
Framework preset: **Other**. Leave the build command empty and the output
directory as the root. Every push to `main` redeploys.

### Custom domain

Vercel project → **Settings → Domains → Add**, then point your registrar at the
records Vercel shows you.

## Notes

- The page is theme-aware: it follows the visitor's light/dark setting, and both
  palettes are defined explicitly.
- The drifting petals are a `<canvas>` and are disabled for anyone with
  `prefers-reduced-motion` set — they get a single static scatter instead.
- The language garland is generated as inline SVG from `DATA.languages`; the
  bloom radius scales with the square root of the percentage so the areas, not
  the widths, stay proportional.
- Contact details in `DATA.links` are public once deployed.
