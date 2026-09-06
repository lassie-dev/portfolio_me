# Lassie — portfolio

A single-page portfolio for a senior full-stack engineer. No build step in the
usual sense, no dependencies, no framework — one static HTML file that loads two
fonts from Google Fonts and does everything else itself.

## Editing content

Everything personal lives in **one place**: the `DATA` object near the top of the
`<script>` block in `content.html`.

```js
var DATA = {
  lede:       "...",                       // hero paragraph, limited inline <b> allowed
  facts:      [ { k, v, sub } ],           // the four-column strip under the hero
  cases:      [ { title, role, context,
                  problem, approach[],     // approach entries allow inline <b>
                  outcome[{v,k}], tags[],
                  links?[{label,url}],     // optional: live site, repository
                  private? } ],            // optional: "Client work, not public"
  caps:       [ { name, sub, desc, tags[] } ],
  principles: [ { name, desc } ],
  stack:      [ { group, core[], rest[] } ],  // core[] renders highlighted
  links:      [ { where, what, url, copy? } ] // copy: click copies instead of navigating
};
```

Nothing else in the file needs to change to keep the site current.

### Claims and figures

Every claim on the page is qualitative on purpose — it describes how a system
was built, not how much it improved. That keeps the site honest while no
measured figures are on hand.

When you do have numbers you can cite, swap them into the `outcome` entries
(`{ v, k }` — `v` is the figure, `k` the caption beneath it). If you want to
stage one before you have the real value, write it as `((X%))`: the build prints
a warning listing every such token still present, so a placeholder cannot reach
production unnoticed.

### Linking to work

Each case study can carry `links` (a live site, a repository) and a `private`
note where the work cannot be shown. Both are optional — a case declaring
neither renders no link row at all, which is the current state. Uncomment the
slots already present in each case and fill them in:

```js
links: [{ label: "Live site",  url: "https://..." },
        { label: "Repository", url: "https://github.com/..." }],
private: "Client work, not public",
```

Only ever link to work you actually built. A borrowed URL is trivial for a
client to check — WHOIS, the Wayback Machine, or one question about a technical
decision on the page — and it discredits every honest claim next to it. Where a
project is under NDA or offline, use `private` and let the written case study
carry the weight; a described system with no link reads as discretion, while a
link to someone else's site reads as fraud.

## Building

`content.html` is the source. `index.html` is generated from it:

```powershell
powershell -ExecutionPolicy Bypass -File build.ps1
```

The build lifts `<title>` and the font `<link>` tags into a proper `<head>`,
adds meta/Open Graph tags and the favicon, warns about unfilled placeholders,
and writes `index.html`.

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

Push the repository and import it on [vercel.com/new](https://vercel.com/new).
Framework preset: **Other**. Leave the build command empty and the output
directory as the root. Every push to the default branch redeploys.

### Custom domain

Vercel project → **Settings → Domains → Add**, then point your registrar at the
records Vercel shows you.

## Notes

- **Theme.** The page follows the visitor's light/dark setting, and the button in
  the header cycles system → light → dark. The choice is stored in
  `localStorage` behind a `try/catch`, so it degrades cleanly in private windows
  or when site data is blocked.
- **Both palettes are defined explicitly.** Light tokens sit on bare `:root`;
  dark is redefined under `@media (prefers-color-scheme:dark)` guarded with
  `:root:not([data-theme="light"])`, and again under `:root[data-theme="dark"]`
  so the toggle wins in both directions.
- **Reveal-on-scroll** is added by JavaScript, not by the markup, so the page is
  fully readable with scripting disabled. It is skipped entirely for anyone with
  `prefers-reduced-motion` set.
- **The email row copies instead of navigating** when the Clipboard API is
  available, and falls back to the `mailto:` link when it is not, or when the
  visitor holds Ctrl/Cmd.
- **Scroll spy** marks the current section in the header. Section anchors and
  `scroll-padding-top` keep headings clear of the sticky bar.
- Contact details in `DATA.links` are public once deployed.
