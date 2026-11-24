#!/bin/bash

set -euo pipefail

repository_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repository_root"

if [[ -z "${DEVELOPER_DIR:-}" ]]; then
  if [[ -d /Applications/Xcode_26.6.app/Contents/Developer ]]; then
    export DEVELOPER_DIR=/Applications/Xcode_26.6.app/Contents/Developer
  else
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
  fi
fi

mkdir -p .build

xcrun docc convert ObjectTracking.docc \
  --output-path .build/site \
  --fallback-display-name ObjectTrackingWithRCP \
  --fallback-bundle-identifier com.madebyrsh.ObjectTrackingWithRCP \
  --fallback-default-module-kind Application \
  --hosting-base-path /2026TechMap_tutorial \
  --transform-for-static-hosting \
  --warnings-as-errors

cp scripts/docc-root-redirect.html .build/site/index.html

# Reuse the exact assets bundled with the app; don't maintain a second copy in source.
example_assets=ObjectTrackingWithRCP/Packages/RealityKitContent/Sources/RealityKitContent/RealityKitContent.rkassets
download_dir=.build/site/downloads
mkdir -p "$download_dir"
cp "$example_assets/TreasureChest.usdz" "$example_assets/TreasureChest.referenceobject" "$download_dir/"
zip -q -X -j "$download_dir/TreasureChest-example.zip" \
  "$download_dir/TreasureChest.usdz" "$download_dir/TreasureChest.referenceobject"


# Keep DocC's markup and behavior; only change the overview layout.
landing=.build/site/tutorials/objecttrackingtutorials/index.html
overview_style='<style>
.hero.hero.hero { max-width:calc(100% - 2rem); }
@media (max-width:420px) { .hero.hero.hero { width:calc(100% - 2rem); } }
.hero .copy-container.copy-container { width:100%; max-width:55rem; margin-inline:0; text-align:left; display:flex; flex-direction:column; align-items:flex-start; gap:.75rem; }
.hero .copy-container > .title, .hero .copy-container > .content { width:100%; min-width:0; }
.hero h1, .hero .copy-container p, .hero .copy-container li { word-break:keep-all; overflow-wrap:anywhere; }
.hero .copy-container h1 { margin-bottom:.25rem; }
.hero .copy-container > .content { display:grid; grid-template-columns:minmax(0, 1fr); }
.hero .copy-container > .content > :first-child { margin:0 0 clamp(1.5rem, 3vw, 2.25rem); line-height:1.7; text-wrap:pretty; }
.hero .copy-container > .content > :is(h2,h3) {
  margin:0; padding:1rem 1.25rem .65rem;
  border:1px solid var(--color-grid, #86868b); border-bottom:0; border-radius:12px 12px 0 0;
  font-size:1.27rem; font-weight:650; line-height:1.3;
}
.hero .copy-container > .content > ul {
  margin:0; padding:0 1.25rem 1.15rem 2.45rem;
  border:1px solid var(--color-grid, #86868b); border-top:0; border-radius:0 0 12px 12px;
  font-size:.95rem; line-height:1.7;
}
.hero .copy-container > .content > ul + :is(h2,h3), .hero .copy-container > .content > ul + p { margin-top:1rem; }
.hero .copy-container > .content > ul > li + li { margin-top:1rem; }
.hero .copy-container > .content > ul:nth-of-type(3) {
  list-style:none;
  padding-inline:1.25rem;
}
.hero .copy-container > .content > ul:nth-of-type(3) > li + li {
  padding-top:.85rem;
  border-top:1px solid color-mix(in srgb, currentColor 16%, transparent);
}
/* Keep the native DocC time and action in one vertical group. */
.hero .copy-container > .content > p:last-child,
.hero .copy-container > .duration-note {
  margin:clamp(1.25rem, 3vw, 1.85rem) 0 0;
  color:var(--color-secondary-label, #86868b); font-size:.9rem; line-height:1.5;
}
.hero .copy-container code { white-space:nowrap; }
@media (min-width:900px) {
  .hero .copy-container > .content { grid-template-columns:minmax(0, 1.2fr) minmax(0, 1fr); column-gap:1.25rem; }
  .hero .copy-container > .content > p { grid-column:1 / -1; }
  .hero .copy-container > .content > :is(h2,h3) { grid-row:2; }
  .hero .copy-container > .content > ul { grid-row:3; }
  .hero .copy-container > .content > ul + :is(h2,h3) { margin-top:0; }
  .hero .copy-container > .content > ul:first-of-type, .hero .copy-container > .content > :is(h2,h3):nth-child(2) { grid-column:1; }
  .hero .copy-container > .content > ul:nth-of-type(2), .hero .copy-container > .content > :is(h2,h3):nth-child(4) { grid-column:2; }
  .hero .copy-container > .content > h2:nth-of-type(3) { grid-area:4 / 1 / 5 / 3; margin-top:1.25rem; }
  .hero .copy-container > .content > ul:nth-of-type(3) {
    grid-area:5 / 1 / 6 / 3;
    display:grid;
    grid-template-columns:repeat(2,minmax(0,1fr));
    gap:1.25rem;
  }
  .hero .copy-container > .content > ul:nth-of-type(3) > li + li {
    margin:0;
    padding:0 0 0 1.25rem;
    border-top:0;
    border-inline-start:1px solid color-mix(in srgb, currentColor 16%, transparent);
  }
}
.hero .copy-container .meta.meta { justify-content:flex-start; margin:0; }
.hero .copy-container .button-cta.button-cta { margin:.15rem 0 0; }
.hero .copy-container > .meta.is-localized { margin-top:clamp(.6rem, 1.4vw, 1.15rem); }
.hero .copy-container > .duration-note { margin:0; }
.hero .copy-container > .duration-note + .button-cta.button-cta { margin-top:max(0px, calc(16px - .75rem)); }
.hero > .asset.asset { margin-top:clamp(2.75rem, 5vw, 4rem); }
.hero > .asset::after { content:"Reality Composer Pro에서 비행기 배치"; content:"Reality Composer Pro에서 비행기 배치" / ""; display:block; margin:.8rem 0 .5rem; font-size:.82rem; text-align:left; word-break:keep-all; }
.learning-path .content-sections-container .content-section + .content-section { margin-top:clamp(1.5rem, 3vw, 2.25rem); }
.learning-path .volume .chapter + .chapter { margin-top:clamp(.9rem, 2vw, 1.6rem); }
.learning-path .chapter :is(h2,h3,p) { word-break:keep-all; overflow-wrap:anywhere; text-wrap:pretty; }
.learning-path .chapter p { line-height:1.7; }
#resources { --resource-pad:clamp(1.2rem, 3.5vw, 2.75rem); }
#resources .volume-name, #resources .tile-group .tile {
  text-align:left;
  align-items:flex-start;
  padding:var(--resource-pad);
  min-width:0;
}
#resources .volume-name > .name { margin:0 0 1.2rem; text-align:left; }
#resources .volume-name > .content, #resources .tile-group .tile > .content {
  width:100%;
  max-width:62ch;
  margin:0;
  font-size:1.0625rem;
  line-height:1.75;
  text-align:left;
  word-break:keep-all;
  overflow-wrap:anywhere;
}
#resources .volume-name .content p { margin:0; line-height:1.8; }
#resources .volume-name .content strong { font-size:1.18rem; }
#resources .tile-group .tile .inline-code { white-space:nowrap; }
#resources .tile-group .tile .icon { display:none; }
#resources .tile-group .tile .title { margin:0 0 .55rem; font-size:1.25rem; }
#resources .tile-group .tile ul { margin:.7rem 0 0; padding:0; list-style:none; }
#resources .tile-group .tile a.link { display:none; }
</style>'
# Localize DocC's generated duration and move only the caveat, not the CTA.
overview_script=$(cat <<'HTML'
<script>
document.addEventListener("DOMContentLoaded", () => {
  const root = document.querySelector("#app") || document.body;
  function formatDuration() {
    const copy = root.querySelector(".hero .copy-container");
    const meta = copy?.querySelector(":scope > .meta");
    const time = meta?.querySelector(".time");
    const note = copy?.querySelector(":scope > .content > p:last-child");
    if (!time || meta.classList.contains("is-localized") ||
        !note?.textContent.trim().startsWith("Create ML 학습 대기 시간")) return;
    const parts = time.textContent.trim().match(/^(?:(\d+)\s*hr?s?\s*)?(?:(\d+)\s*mins?)?$/i);
    if (!parts || !(parts[1] || parts[2])) return;
    const label = [...meta.querySelectorAll("*")].find(node =>
      node.childElementCount === 0 && node.textContent.trim() === "Estimated Time"
    );
    const labelText = [...meta.childNodes].find(node =>
      node.nodeType === Node.TEXT_NODE && node.textContent.trim() === "Estimated Time"
    );
    if (label) label.hidden = true;
    else if (labelText) labelText.textContent = "";
    time.textContent = ["약", parts[1] && parts[1] + "시간", parts[2] && parts[2] + "분"].filter(Boolean).join(" ");
    meta.classList.add("is-localized");
    note.classList.add("duration-note");
    meta.after(note);
  }
  function localizeResources() {
    const resources = root.querySelector("#resources");
    if (!resources) return;
    const heading = resources.querySelector(".volume-name > .name");
    const sample = resources.querySelector(".tile .title");
    if (heading?.textContent.trim() === "Resources") heading.textContent = "실습 자료";
    for (const nav of root.querySelectorAll('a[href$="#resources"]')) {
      if (nav.textContent.trim() === "Resources") nav.textContent = "실습 자료";
    }
    if (sample?.textContent.trim() === "Sample Code") sample.textContent = "완성 예제 코드";
  }
  function customizeOverview() {
    formatDuration();
    localizeResources();
  }
  new MutationObserver(customizeOverview).observe(root, { childList: true, subtree: true });
  customizeOverview();
});
</script>
HTML
)
OVERVIEW_STYLE="$overview_style" OVERVIEW_SCRIPT="$overview_script" perl -0pe 's{</head>}{$ENV{OVERVIEW_STYLE}$ENV{OVERVIEW_SCRIPT}</head>}' "$landing" > "$landing.tmp"
mv "$landing.tmp" "$landing"

# Include the stylesheet at every tutorial entry so DocC navigation keeps it.
# The intro summary markup scopes the style to the reference object lesson.
cp scripts/reference-lesson.css .build/site/reference-lesson.css
reference_style_version=$(shasum -a 256 scripts/reference-lesson.css | cut -c 1-12)
cp scripts/tutorial-quiz.js .build/site/tutorial-quiz.js
quiz_script_version=$(shasum -a 256 scripts/tutorial-quiz.js | cut -c 1-12)
while IFS= read -r -d '' tutorial_page; do
  REFERENCE_STYLE_VERSION="$reference_style_version" QUIZ_SCRIPT_VERSION="$quiz_script_version" \
    perl -0pe 's{</head>}{<link rel="stylesheet" href="/2026TechMap_tutorial/reference-lesson.css?v=$ENV{REFERENCE_STYLE_VERSION}"><script defer src="/2026TechMap_tutorial/tutorial-quiz.js?v=$ENV{QUIZ_SCRIPT_VERSION}"></script></head>}' "$tutorial_page" > "$tutorial_page.tmp"
  mv "$tutorial_page.tmp" "$tutorial_page"
done < <(find .build/site/tutorials -name index.html -print0)

# Give revised diagrams new URLs so a cached SVG cannot mask a new build.
python3 - .build/site <<'PY'
import hashlib
import json
import shutil
import sys
from pathlib import Path
from urllib.parse import quote, unquote

site = Path(sys.argv[1])
versioned_urls = {}
for data_file in (site / "data").rglob("*.json"):
    data = json.loads(data_file.read_text(encoding="utf-8"))
    changed = False
    for ref in data.get("references", {}).values():
        if ref.get("type") != "image":
            continue
        for variant in ref.get("variants", []):
            url = variant.get("url", "")
            if not url.startswith("/images/") or not url.endswith(".svg"):
                continue
            if url not in versioned_urls:
                source = site / unquote(url.lstrip("/"))
                digest = hashlib.sha256(source.read_bytes()).hexdigest()[:12]
                versioned = source.with_name(f"{source.stem}-{digest}.svg")
                shutil.copyfile(source, versioned)
                versioned_urls[url] = "/" + quote(versioned.relative_to(site).as_posix(), safe="/")
            variant["url"] = versioned_urls[url]
            changed = True
    if changed:
        data_file.write_text(json.dumps(data, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
PY
