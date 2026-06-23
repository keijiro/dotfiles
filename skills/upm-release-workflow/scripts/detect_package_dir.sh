#!/bin/sh
set -eu

root_dir="${1:-.}"
packages_dir="$root_dir/Packages"

if [ ! -d "$packages_dir" ]; then
  echo "Packages directory not found: $packages_dir" >&2
  exit 1
fi

matches=$(find "$packages_dir" -mindepth 1 -maxdepth 1 -type d -name 'jp.keijiro.*' | sort)

count=$(printf '%s\n' "$matches" | sed '/^$/d' | wc -l | tr -d ' ')

if [ "$count" -eq 0 ]; then
  echo "No package directory matching jp.keijiro.* found under $packages_dir" >&2
  exit 1
fi

if [ "$count" -gt 1 ]; then
  echo "Multiple package directories found under $packages_dir:" >&2
  printf '%s\n' "$matches" >&2
  exit 1
fi

printf '%s\n' "$matches"
