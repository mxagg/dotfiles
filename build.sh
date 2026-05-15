#!/bin/bash
# Run this locally before pushing to update index.html with current file list.
# No build step needed on Cloudflare — it serves index.html directly.

cd "$(dirname "$0")"
BASE="https://raw.githubusercontent.com/mxagg/dotfiles/main"

FILES=$(git ls-files | grep -v "index.html\|build.sh" | sort)

ITEMS=""
for f in $FILES; do
    ITEMS="$ITEMS        <li class=\"file\"><a href=\"$BASE/$f\" target=\"_blank\">$f</a></li>\n"
done

cat > index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dotfiles</title>
    <style>
        body {
            font-family: monospace;
            background: #1e1e2e;
            color: #cdd6f4;
            max-width: 700px;
            margin: 40px auto;
            padding: 20px;
        }
        h1 { color: #89b4fa; }
        a {
            color: #a6e3a1;
            text-decoration: none;
        }
        a:hover { text-decoration: underline; }
        ul { list-style: none; padding: 0; }
        li { padding: 4px 0; }
        li.file::before { content: "📄 "; }
        li.dir::before { content: "📁 "; }
        .path { color: #6c7086; font-size: 0.85em; }
    </style>
</head>
<body>
    <h1>dotfiles</h1>
    <p class="path">A simple index of my dotfiles.</p>
    <ul>
$(echo -e "$ITEMS")
    </ul>
</body>
</html>
EOF

echo "index.html updated with $(echo "$FILES" | wc -l) files."
