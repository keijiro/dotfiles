#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
root_dir="${1:-.}"
package_dir=$("$script_dir/detect_package_dir.sh" "$root_dir")

for name in README.md CHANGELOG.md LICENSE; do
  source_path="$root_dir/$name"
  target_path="$package_dir/$name"

  if [ ! -f "$source_path" ]; then
    echo "Missing root file: $source_path" >&2
    exit 1
  fi

  cp "$source_path" "$target_path"
  printf 'Synced %s -> %s\n' "$source_path" "$target_path"
done
