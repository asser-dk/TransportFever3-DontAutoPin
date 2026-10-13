#!/usr/bin/env bash
set -uo pipefail

f=$(jq -r '.tool_input.file_path // .tool_response.filePath // empty')
[ -n "$f" ] || exit 0
repo=$(cd "$(dirname "$0")/../.." && pwd)
workspace=$(dirname "$repo")
schemas=~/Documents/documentation/references/transport-fever-3/schemas

case "$f" in
	"$repo"/*.tl)
		out=$(cd "$workspace" && ~/.luarocks/bin/tl check "${f#"$workspace"/}" 2>&1) || { echo "$out" >&2; exit 2; } ;;
	"$repo"/src/mod.json) schema=mod ;;
	"$repo"/src/_metadata/modinfo.json) schema=modinfo ;;
	"$repo"/src/strings.json) schema=strings ;;
esac

if [ -n "${schema:-}" ]; then
	out=$(npx --yes ajv-cli@5 validate --strict=false --all-errors -s "$schemas/$schema.schema.json" -d "$f" 2>&1) || { echo "$out" >&2; exit 2; }
fi
exit 0
