#!/bin/bash
# Add the `npx skills` install artifacts to the project .gitignore.
# Idempotent: paths git already ignores, by whatever pattern, are left alone.

set -euo pipefail

in_git_repo=1
root=$(git rev-parse --show-toplevel 2>/dev/null) || { in_git_repo=0; root=$(pwd); }
gitignore="$root/.gitignore"

# Each entry is the .gitignore pattern plus the path used to test it.
entries=(
    "/skills-lock.json:skills-lock.json"
    "/.claude/skills/:.claude/skills/"
    "/.claude/settings.local.json:.claude/settings.local.json"
)

already_ignored() {
    local pattern=$1 path=$2
    if [[ $in_git_repo -eq 1 ]]; then
        # Catches equivalent patterns too, e.g. a bare `.claude/settings.local.json`.
        git -C "$root" check-ignore -q "$path" && return 0
        return 1
    fi
    [[ -f "$gitignore" ]] && grep -qxF "$pattern" "$gitignore"
}

added=()
for entry in "${entries[@]}"; do
    pattern=${entry%%:*}
    path=${entry#*:}
    already_ignored "$pattern" "$path" || added+=("$pattern")
done

if [[ ${#added[@]} -eq 0 ]]; then
    echo "Nothing to add; git already ignores the skills install artifacts."
    exit 0
fi

# Keep a blank line before the new block unless the file is empty or absent.
if [[ -s "$gitignore" ]]; then
    [[ -n $(tail -c 1 "$gitignore") ]] && echo >> "$gitignore"
    echo >> "$gitignore"
fi

{
    echo "# npx skills install artifacts"
    printf '%s\n' "${added[@]}"
} >> "$gitignore"

echo "Added to $gitignore:"
printf '  %s\n' "${added[@]}"
