#!/usr/bin/env python3
"""Mark every skill pinned in skills-lock.json as `name-only` in Claude Code settings.

Merges `"<name>": "name-only"` into `skillOverrides`, preserving other settings
and any override the user already set to a different value.
"""

import argparse
import json
import subprocess
import sys
from pathlib import Path


def project_root() -> Path:
    try:
        out = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            capture_output=True, text=True, check=True,
        )
        return Path(out.stdout.strip())
    except (subprocess.CalledProcessError, FileNotFoundError):
        return Path.cwd()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--lock", default="skills-lock.json",
                        help="lock file to read skill names from")
    parser.add_argument("--settings", default=".claude/settings.local.json",
                        help="settings file to merge overrides into")
    parser.add_argument("--mode", default="name-only",
                        choices=["name-only", "user-invocable-only", "off"],
                        help="override value to apply")
    args = parser.parse_args()

    root = project_root()
    lock_path = root / args.lock
    settings_path = root / args.settings

    if not lock_path.exists():
        print(f"error: {lock_path} not found; install the skills first",
              file=sys.stderr)
        return 1

    lock = json.loads(lock_path.read_text())
    names = sorted(lock.get("skills", {}))
    if not names:
        print(f"error: no skills listed in {lock_path}", file=sys.stderr)
        return 1

    if settings_path.exists():
        settings = json.loads(settings_path.read_text())
    else:
        settings = {}
        settings_path.parent.mkdir(parents=True, exist_ok=True)

    overrides = settings.setdefault("skillOverrides", {})
    if not isinstance(overrides, dict):
        print(f"error: skillOverrides in {settings_path} is not an object",
              file=sys.stderr)
        return 1

    added, kept = [], []
    for name in names:
        existing = overrides.get(name)
        if existing == args.mode:
            continue
        if existing is not None:
            kept.append((name, existing))
            continue
        overrides[name] = args.mode
        added.append(name)

    settings_path.write_text(json.dumps(settings, indent=2) + "\n")

    print(f"{settings_path}: {len(added)} skill(s) set to {args.mode}, "
          f"{len(names) - len(added) - len(kept)} already set")
    for name, existing in kept:
        print(f"  left alone: {name} (already {existing!r})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
