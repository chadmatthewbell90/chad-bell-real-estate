#!/bin/bash
# ============================================================
# Publish the current working copy to the staging site:
#   https://chadmatthewbell90.github.io/chad-bell-real-estate-staging/
#   (repo: github.com/chadmatthewbell90/chad-bell-real-estate-staging,
#    GitHub Pages on, deploying from the main branch root)
#
# The live site is not touched. The staging copy is made safe:
#   - Google Tag Manager snippets removed, if any are ever added
#   - noindex meta + robots.txt (kept out of Google)
#   - "Staging preview" badge on every page
#   - no CNAME; 404.html <base href> pointed at the staging path
#
# Usage (from the repo root):  scripts/deploy-staging.sh
# ============================================================
set -euo pipefail

STAGING_OWNER="chadmatthewbell90"
STAGING_NAME="chad-bell-real-estate-staging"
STAGING_REPO="https://github.com/${STAGING_OWNER}/${STAGING_NAME}.git"
STAGING_URL="https://${STAGING_OWNER}.github.io/${STAGING_NAME}/"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$(mktemp -d)"
trap 'rm -rf "$BUILD"' EXIT

if ! git ls-remote "$STAGING_REPO" >/dev/null 2>&1; then
  echo "Staging repo $STAGING_REPO not found or not accessible."
  echo "Create it (empty, public) on GitHub, add your account as a collaborator, then rerun."
  exit 1
fi

# Copy the site (everything except git data, scripts and any live CNAME)
rsync -a --exclude '.git' --exclude 'scripts' --exclude 'CNAME' "$ROOT/" "$BUILD/"

printf 'User-agent: *\nDisallow: /\n' > "$BUILD/robots.txt"

python3 - "$BUILD" "/${STAGING_NAME}/" <<'EOF'
import pathlib, re, sys
build, base_path = pathlib.Path(sys.argv[1]), sys.argv[2]

head_extra = '  <meta name="robots" content="noindex, nofollow" />\n'
badge = '''  <div style="position:fixed;top:calc(var(--nav-h) + 8px);right:12px;z-index:2000;background:#D4A84F;color:#0A1A24;font:600 12px/1 Inter,system-ui,sans-serif;letter-spacing:.08em;text-transform:uppercase;padding:6px 12px;border-radius:50px;box-shadow:0 2px 8px rgba(0,0,0,.2);pointer-events:none">Staging preview</div>
'''

for page in sorted(build.rglob('*.html')):
    s = page.read_text()
    s, n1 = re.subn(r'[ \t]*<!-- Google Tag Manager -->.*?<!-- End Google Tag Manager -->\n', '', s, flags=re.S)
    s, n2 = re.subn(r'[ \t]*<!-- Google Tag Manager \(noscript\) -->.*?<!-- End Google Tag Manager \(noscript\) -->\n', '', s, flags=re.S)
    if n1 > 1 or n2 > 1 or n1 != n2:
        sys.exit(f'{page.name}: expected at most one GTM snippet and matching noscript block, found {n1} and {n2}; staging not published')
    s = re.sub(r'<meta name="robots"[^>]*>\n?', '', s)
    s = s.replace('<meta charset="UTF-8" />', '<meta charset="UTF-8" />\n' + head_extra, 1)
    s = re.sub(r'<base href="[^"]*" />', f'<base href="{base_path}" />', s)
    s = re.sub(r'(<body[^>]*>\n)', r'\1' + badge, s, count=1)
    if 'googletagmanager.com/gtm.js' in s or 'noindex' not in s or 'Staging preview' not in s:
        sys.exit(f'{page.name}: staging transform incomplete; staging not published')
    page.write_text(s)
    print(f'  {page.relative_to(build)}: ' + ('GTM removed, ' if n1 else '') + 'noindex + badge added')
EOF

SOURCE_COMMIT="$(git -C "$ROOT" rev-parse --short HEAD)"
DIRTY=""; git -C "$ROOT" diff --quiet HEAD || DIRTY=" + uncommitted changes"

cd "$BUILD"
git init -q -b main
git add -A
git -c user.name="$(git -C "$ROOT" config user.name || echo staging)" \
    -c user.email="$(git -C "$ROOT" config user.email || echo staging@localhost)" \
    commit -q -m "Staging build from ${SOURCE_COMMIT}${DIRTY}"
git push -q --force "$STAGING_REPO" main
echo "Published to $STAGING_URL (from ${SOURCE_COMMIT}${DIRTY})"
