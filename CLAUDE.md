# Chad Bell Real Estate website

Static one-page site for Chad Bell, estate agent at Acutts Bluff (The Bluff, Durban). Its only job is to get **homeowners who want to sell** to contact Chad for a valuation. It is not a listings site: never add property listings, search, or buyer-focused content.

Live at https://chadmatthewbell90.github.io/chad-bell-real-estate/ (no custom domain yet). The people working on it are not developers: explain git, deploys and DNS in plain terms.

## Workflow

- **Default: commit and push every finished, verified change to `main` without asking.** GitHub Pages publishes it in about a minute. Keep each change in its own commit so it can be reverted on its own. Don't build preview pages unless asked.
- **Staging:** when asked to "put it on staging", "preview" or "show me first", make the change, run `scripts/deploy-staging.sh`, and send the staging URL it prints. Push to `main` only after they say "push it live". The staging repo (`chadmatthewbell90/chad-bell-real-estate-staging`) has to exist with Pages switched on before the script works; it tells you if it doesn't.
- **Undo:** "revert the last change" means `git revert` the relevant commit and push.
- `git pull` before making changes; more than one person pushes to this repo.
- The repo belongs to **chadmatthewbell90**; Cameron (`cameronferreira`) is a collaborator with push access but not admin, so Pages, domain and repo settings have to be changed from Chad's account.

## Copy voice

- First person, as Chad: "I", "me", "my" (e.g. "I visit your home"). Headings and buttons may address the seller directly ("Get my free valuation"). Use "Chad" in the third person only in the nav label "Why Chad", page titles, meta, alt text and JSON-LD.
- Audience is serious sellers on The Bluff and surrounding Durban South suburbs. Lead with what sets Chad apart: social media marketing, 16 years' experience, Best Listing Agent nationwide (current holder, most recently 2025), Acutts Bluff management team.
- No promises of sale prices or selling times, and no made-up numbers: no invented sales counts, follower counts, reviews or testimonials. Add those only when Chad supplies real ones.
- South African English (valuation, suburb, transfer, conveyancer, bond).

## Structure

- `index.html`: the whole site, in sections: hero, marquee, stats, statement, `#why`, `#marketing`, `#award`, `#process`, `#areas`, `#faq`, `#valuation` (form + contact).
- `privacy.html` (served at `/privacy`; link to `privacy`, not `privacy.html`), `404.html`.
- `css/style.css`: design tokens at the top, plus the mobile alignment rules in its header comment.
- **Look: boho coastal town** (owner's direction, 2026-11-24). The Bluff is a beach suburb, so keep it sunny and earthy: cream/sand backgrounds, terracotta (`--clay`) for buttons and accent words, sun mustard, sea-glass, and ocean teal for the dark sections. Motifs: the arched window onto an animated beach scene in the hero, wave dividers (`.wave-top`, painted in the section's own colour), swaying palm-frond shadows, the sunburst award seal, dashed lines, Caveat handwritten notes. Don't drift back to dark/tech styling.
- Fonts: Fraunces with the SOFT axis (headings; italic for `<em>` accent words), DM Sans (body), Caveat (short handwritten notes and the signature only).
- `js/main.js`: all motion (word-split hero heading, scroll reveals, scroll-lit statement, count-ups, parallax, magnetic buttons, phone tilt, process line) and the valuation form. Every effect is off under `prefers-reduced-motion`.
- **All paths are relative** (`css/style.css`, `privacy`, `#valuation`) because the site lives under the `/chad-bell-real-estate/` sub-path. `404.html` is the exception: it uses `<base href="/chad-bell-real-estate/">` because GitHub serves it at any depth.
- `scripts/deploy-staging.sh` publishes the staging copy. `_config.yml` keeps `scripts/` and this file off the live site.
- Images: `favicon-48.png`, `favicon-192.png`, `apple-touch-icon.png` (CB monogram) and `og-image.jpg` (1200×630 share image) were generated from HTML; there are no photos of Chad yet.

## Valuation form

No server: on submit, `js/main.js` builds a WhatsApp message from the fields and opens `wa.me/27845206603`. Nothing is stored or sent until the visitor presses send in WhatsApp. The privacy policy describes exactly this; update it if the form ever posts somewhere else (e.g. an email form service).

## Contact details (from Chad's public Acutts profile)

- Phone / WhatsApp 084 520 6603 (`+27845206603`), email chadbell@acutts.co.za
- Facebook https://www.facebook.com/Chadbellacuttsbluff
- PPRA FFC 1157352 (in the footer; property practitioners must show it)

## Connecting a custom domain later

1. Add a `CNAME` file containing the domain (e.g. `www.example.co.za`) and push.
2. In Chad's account: repo Settings → Pages → Custom domain, then tick Enforce HTTPS once the certificate is issued.
3. DNS: `www` CNAME → `chadmatthewbell90.github.io`; apex A records → 185.199.108.153, 185.199.109.153, 185.199.110.153, 185.199.111.153.
4. Find and replace `https://chadmatthewbell90.github.io/chad-bell-real-estate/` with the new address (canonical, Open Graph, JSON-LD, `robots.txt`, `sitemap.xml`), and change the `<base href>` in `404.html` to `/`.
5. Note that `chadbellrealestate.co.za` already exists as an older site; check who controls it before choosing a domain.

## Tracking

None yet: no Google Tag Manager, GA4, cookie banner or booking widget. When tracking is added, put GTM in `<head>` wrapped in `<!-- Google Tag Manager -->` … `<!-- End Google Tag Manager -->` (and the noscript in matching comments) so the staging script can strip it, add a cookie notice, and update the privacy policy's "Cookies and tracking" section.

## Gotchas

- The hero heading is split into words by JS. The `<em>` phrase (with its hand-drawn squiggle SVG) is animated as one unit on purpose: splitting inside it would break the squiggle and any `background-clip: text` effect.
- Sections that need horizontal clipping use `overflow-x: clip`, not `overflow: hidden`, so the wave divider above them stays visible.
- Headless Chrome won't make a window narrower than about 500px. To check the 390px mobile layout, screenshot a wrapper page with the site in a 390px-wide iframe.
