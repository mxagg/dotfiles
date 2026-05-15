#!/bin/bash
# Build script for Cloudflare Pages
# Scans the repo and injects the file tree into index.html

EXCLUDE="node_modules|\.git|build\.sh|dist|index\.html"

generate_tree() {
    local dir="$1"
    local first=true

    printf '['
    for entry in "$dir"/*; do
        [ -e "$entry" ] || continue
        local name=$(basename "$entry")
        local rel_path="${entry#./}"

        # Skip excluded files/dirs
        if echo "$name" | grep -qE "^($EXCLUDE)$"; then
            continue
        fi

        if [ "$first" = true ]; then
            first=false
        else
            printf ','
        fi

        if [ -d "$entry" ]; then
            printf '{"name":"%s","path":"%s","type":"dir","children":' "$name" "$rel_path"
            generate_tree "$entry"
            printf '}'
        else
            printf '{"name":"%s","path":"%s","type":"file"}' "$name" "$rel_path"
        fi
    done
    printf ']'
}

# Also handle hidden files (like .config)
shopt -s dotglob

mkdir -p dist

# Generate the tree JSON
cd "$(dirname "$0")"
TREE_JSON=$(generate_tree ".")

# Inject into index.html using awk (handles special chars better than sed)
awk -v tree="$TREE_JSON" '{gsub(/\/\*FILE_TREE_JSON\*\/null/, tree); print}' index.html > dist/index.html

echo "Build complete: dist/index.html"
