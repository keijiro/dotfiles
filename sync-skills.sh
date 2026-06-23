#!/usr/bin/env bash
#
# sync-skills.sh
#
# Synchronizes symlinks for the skills stored in this repository into the
# skill directories used by each AI agent (Claude Code, Codex, ...).
#
# For every skill directory in this repository (a sub-directory containing a
# SKILL.md file), a symlink is created in each target directory.  Symlinks that
# point back into this repository but no longer correspond to an existing skill
# are removed.  Anything else in the target directories (real files, unrelated
# symlinks, the Codex ".system" directory, ...) is left untouched.

set -euo pipefail

# Absolute path to the directory that holds this script (= the repository root).
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# Skills source directory.
SKILLS_DIR="$REPO_DIR"/skills

# Target directories the skills get linked into.
TARGET_DIRS=(
    "$HOME/.claude/skills"
    "$HOME/.codex/skills"
)

# Collect the names of the skills in this repository (directories with SKILL.md).
skills=()
for dir in "$SKILLS_DIR"/*/; do
    [ -f "${dir}SKILL.md" ] || continue
    skills+=("$(basename "$dir")")
done

# Resolve a symlink's target to an absolute path (handles relative targets).
resolve_link() {
    local link="$1" target
    target="$(readlink "$link")"
    case "$target" in
        /*) printf '%s\n' "$target" ;;
        *)  printf '%s\n' "$(cd "$(dirname "$link")" && cd "$(dirname "$target")" && pwd -P)/$(basename "$target")" ;;
    esac
}

# Is the given skill name present in this repository?
is_known_skill() {
    local name="$1" s
    for s in "${skills[@]:-}"; do
        [ "$s" = "$name" ] && return 0
    done
    return 1
}

for target_dir in "${TARGET_DIRS[@]}"; do
    mkdir -p "$target_dir"

    # --- Add / fix symlinks for every skill in the repository. ---
    for name in "${skills[@]:-}"; do
        src="$SKILLS_DIR/$name"
        link="$target_dir/$name"

        if [ -L "$link" ]; then
            # Already a symlink: re-point it if it does not match.
            if [ "$(resolve_link "$link")" = "$src" ]; then
                continue
            fi
            rm "$link"
        elif [ -e "$link" ]; then
            # A real file/directory occupies the name: do not clobber it.
            echo "skip: $link exists and is not a symlink" >&2
            continue
        fi

        ln -s "$src" "$link"
        echo "link: $link -> $src"
    done

    # --- Remove stale symlinks that point into this repository. ---
    for link in "$target_dir"/*; do
        [ -L "$link" ] || continue
        resolved="$(resolve_link "$link")"
        # Only consider symlinks that point inside this repository.
        case "$resolved" in
            "$SKILLS_DIR"/*) ;;
            *) continue ;;
        esac
        name="$(basename "$link")"
        if ! is_known_skill "$name"; then
            rm "$link"
            echo "unlink: $link"
        fi
    done
done

echo "Done."
