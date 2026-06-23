#!/usr/bin/env python3

import argparse
import re
import sys
from pathlib import Path


VERSION_HEADING_RE = re.compile(r"^## \[(?!Unreleased\])(.+?)\]\s*-\s*(.+)$")
SUBHEADING_RE = re.compile(r"^###\s+(.+?)\s*$")


def load_section(text: str) -> str:
    lines = text.splitlines()
    start = None
    end = len(lines)

    for index, line in enumerate(lines):
        if VERSION_HEADING_RE.match(line):
            start = index + 1
            break

    if start is None:
        raise ValueError("No released changelog section found.")

    for index in range(start, len(lines)):
        if lines[index].startswith("## "):
            end = index
            break

    return "\n".join(lines[start:end]).strip()


def render_rich_text(section: str) -> str:
    output = []
    heading_count = 0
    pending_blank = False
    last_kind = None

    for raw_line in section.splitlines():
        line = raw_line.rstrip()

        if not line:
            pending_blank = True
            continue

        heading = SUBHEADING_RE.match(line)
        if heading:
            if heading_count > 0:
                output.append("<br>")
            output.append(f"<b>{heading.group(1)}</b><br>")
            heading_count += 1
            pending_blank = False
            last_kind = "heading"
            continue

        if pending_blank and last_kind == "body":
            output.append("<br>")

        escaped = (
            line.replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
        )
        output.append(f"{escaped}<br>")
        pending_blank = False
        last_kind = "body"

    return "".join(output).removesuffix("<br>")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Render the newest released CHANGELOG section as Unity Rich Text."
    )
    parser.add_argument("changelog", nargs="?", default="CHANGELOG.md")
    args = parser.parse_args()

    changelog_path = Path(args.changelog)
    if not changelog_path.is_file():
        print(f"CHANGELOG not found: {changelog_path}", file=sys.stderr)
        return 1

    try:
        section = load_section(changelog_path.read_text(encoding="utf-8"))
        print(render_rich_text(section))
        return 0
    except ValueError as exc:
        print(str(exc), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
