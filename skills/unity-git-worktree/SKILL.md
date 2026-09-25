---
name: unity-git-worktree
description: Use when creating a git worktree for a Unity project, or working in one that has no Library yet.
allowed-tools:
  - Bash
---

# Git worktree for a Unity project

`Library` is gitignored, so a fresh worktree has none, and Unity reimports the
whole project on first open — minutes of waiting for a tree that is a few files
different from one already imported. Seed the new worktree's `Library` from the
main worktree **before Unity opens there**.

## 1. Create the worktree

Create it however the task calls for (`git worktree add`, or a tool that makes
one). Do not open Unity in it yet.

If the worktree already exists — made earlier, or by a tool before this skill
came in — skip to step 2 as long as it has no `Library`. If Unity has already
built one there, the reimport is paid for and there is nothing left to do.

## 2. Clone the main worktree's Library

Run this from inside the new worktree:

```bash
cp -Rc "$(git rev-parse --path-format=absolute --git-common-dir)/../Library" Library
```

- **Let git name the source.** `--git-common-dir` is the main worktree's `.git`,
  so its parent is the main worktree wherever it is. Worktrees usually land
  beside `main`, but where the tool that made them chose to put them is not
  something to assume — do not use a relative path like `../main/Library`.
- **`-c` asks APFS for a copy-on-write clone** (`clonefile(2)`), so the copy
  costs neither the time nor the disk of a real one. The two `Library` folders
  share their blocks until Unity rewrites a file, and only what it rewrites is
  paid for. This needs both worktrees on the same APFS volume.

Check first that the new worktree has no `Library` yet; if one exists, `cp -R`
copies into it as `Library/Library` rather than replacing it. Ask before
removing an existing one.

## 3. Open Unity

Open the project in the new worktree as usual. Unity picks up the cloned
`Library` and only reimports what differs between the two trees.
