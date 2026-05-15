#!/bin/bash
# Build script for Cloudflare Pages
# Generates index.html with the file tree baked in

shopt -s dotglob
mkdir -p dist
cd "$(dirname "$0")"

# Generate JSON tree using find + jq-like bash output
generate_json() {
    local dir="$1"
    local first=true
    printf '['
    for entry in "$dir"/*; do
        [ -e "$entry" ] || continue
        local name=$(basename "$entry")
        local rel_path="${entry#./}"
        case "$name" in
            .git|node_modules|dist|build.sh|index.html) continue ;;
        esac
        [ "$first" = true ] && first=false || printf ','
        if [ -d "$entry" ]; then
            printf '{"name":"%s","path":"%s","type":"dir","children":' "$name" "$rel_path"
            generate_json "$entry"
            printf '}'
        else
            printf '{"name":"%s","path":"%s","type":"file"}' "$name" "$rel_path"
        fi
    done
    printf ']'
}

TREE=$(generate_json ".")

cat > dist/index.html << 'HTMLEOF'
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
        .breadcrumb { color: #6c7086; margin-bottom: 16px; }
        .breadcrumb a { color: #89b4fa; }
    </style>
</head>
<body>
    <h1>dotfiles</h1>
    <p class="path">A simple index of my dotfiles.</p>
    <div class="breadcrumb" id="breadcrumb"></div>
    <ul id="file-list"></ul>
    <script>
        const REPO = 'mxagg/dotfiles';
        const BRANCH = 'main';
        const RAW = `https://raw.githubusercontent.com/${REPO}/${BRANCH}/`;
        const FILE_TREE = TREEPLACEMENT;

        function getPath() {
            return new URLSearchParams(window.location.search).get('path') || '';
        }
        function renderBreadcrumb(path) {
            const bc = document.getElementById('breadcrumb');
            if (!path) { bc.innerHTML = ''; return; }
            const parts = path.split('/');
            let html = '<a href="?">root</a>';
            let acc = '';
            for (const p of parts) {
                acc += (acc ? '/' : '') + p;
                html += ` / <a href="?path=${encodeURIComponent(acc)}">${p}</a>`;
            }
            bc.innerHTML = html;
        }
        function getEntries(path) {
            if (!path) return FILE_TREE;
            let cur = FILE_TREE;
            for (const p of path.split('/')) {
                const found = cur.find(e => e.name === p && e.type === 'dir');
                if (!found) return [];
                cur = found.children;
            }
            return cur;
        }
        function render() {
            const path = getPath();
            renderBreadcrumb(path);
            const entries = getEntries(path).sort((a, b) => {
                if (a.type === b.type) return a.name.localeCompare(b.name);
                return a.type === 'dir' ? -1 : 1;
            });
            const list = document.getElementById('file-list');
            list.innerHTML = '';
            for (const item of entries) {
                const li = document.createElement('li');
                const a = document.createElement('a');
                if (item.type === 'dir') {
                    li.className = 'dir';
                    a.href = `?path=${encodeURIComponent(item.path)}`;
                    a.textContent = item.name + '/';
                } else {
                    li.className = 'file';
                    a.href = RAW + item.path;
                    a.textContent = item.name;
                    a.target = '_blank';
                }
                li.appendChild(a);
                list.appendChild(li);
            }
        }
        render();
    </script>
</body>
</html>
HTMLEOF

# Now replace the placeholder with actual tree JSON
sed -i "s|TREEPLACEMENT|${TREE}|" dist/index.html

echo "Build complete: dist/index.html"
