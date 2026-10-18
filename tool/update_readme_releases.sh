#!/usr/bin/env bash
# Rewrites the block between the "releases" markers in README.md with one row
# per release (newest first): an icon and a direct link to that release's APK.
# Needs the GitHub CLI (GH_TOKEN) and GITHUB_REPOSITORY; run by the Build workflow.
set -euo pipefail

repo="${GITHUB_REPOSITORY:?}"
icon="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"
limit=20

table=$(gh api "repos/$repo/releases?per_page=$limit" --jq '
  .[] | select(.draft | not) | . as $r
  | ($r.assets[] | select(.name | endswith(".apk"))) as $a
  | "| [<img src=\"'"$icon"'\" width=\"40\" alt=\"APK\">](\($a.browser_download_url)) | [**\($r.name)**](\($r.html_url)) | \($r.published_at[:10]) | [\($a.name)](\($a.browser_download_url)) |"')

block="<!-- releases:start -->
| | Release | Date | Download |
|---|---|---|---|
${table}
<!-- releases:end -->"

python3 - "$block" <<'PY'
import re, sys
block = sys.argv[1]
text = open("README.md", encoding="utf-8").read()
new, n = re.subn(r"<!-- releases:start -->.*?<!-- releases:end -->", lambda _: block, text, flags=re.S)
if n != 1:
    sys.exit("releases markers not found in README.md")
open("README.md", "w", encoding="utf-8").write(new)
PY
