---
name: jj
description: Operational style guide for Jujutsu (jj) VCS. Use when working with version control in a project that has a .jj directory.
trigger: A .jj directory exists in the project root and VCS operations are needed.
allowed-tools:
  - Bash
---

# jj Operational Style

This skill covers workflow conventions, not basic usage. Apply these rules whenever
performing version control operations in a jj repository.

## Describe before you work

Before modifying the working copy, set the intent on the current change:

```bash
jj describe -m "Brief description of what this change will do"
```

This makes the change's purpose visible immediately, rather than describing it
after the fact.

## New after completing work

Create a new change when a unit of work is finished. Before running `jj new`,
review the current description and update it if the actual work diverged from
the original intent:

```bash
jj describe -m "Revised description if needed"
jj new
```

Do this at natural boundaries: a feature is complete, a bug is fixed, a refactor
is self-contained. Do not let unrelated work accumulate in a single change.

## Push only on explicit instruction

`jj git push` publishes changes to a shared remote. It is categorically different
from local operations like `describe`, `new`, `squash`, or `rebase`. Do **not**
push unless the user explicitly asks for it.

## Git-specific operations (tags, etc.)

When a git-native operation is needed (e.g. `git tag`) and git colocation is not
active, temporarily enable it:

```bash
# Enable colocation and switch to main so git commands work as expected
jj git colocation enable
git switch main

# Perform the git operation
git tag v1.2.3
git push origin v1.2.3

# Restore
jj git colocation disable
```

After the git work is done, disable colocation so the repository returns to its
normal state.
