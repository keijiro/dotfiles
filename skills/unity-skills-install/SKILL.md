---
name: unity-skills-install
description: Installs the keijiro/unity-skills collection with `npx skills`. Use when asked to add or update the Unity skills in a project.
allowed-tools:
  - Bash
---

# Install Unity skills

Installs every skill from `github.com/keijiro/unity-skills` (31 at present) as
project-level skills, shared by Claude Code and every agent that reads the
agent-neutral `.agents/skills/` directory (Codex, Cursor, Copilot, Gemini CLI,
...).

`npx skills` keeps the files in `.agents/skills/<name>/` and points
`.claude/skills/<name>` at them with a symlink, so both trees stay in sync from
a single install.

## 1. Check the target

Work at the repository root (`git rev-parse --show-toplevel`), or the current
directory outside a git repo.

`npx skills` writes to `skills-lock.json`, `.agents/skills/`, and
`.claude/skills/`. Inspect all three first:

```bash
ls -d skills-lock.json .agents/skills .claude/skills 2>/dev/null
git ls-files --error-unmatch skills-lock.json .agents/skills .claude/skills 2>/dev/null
```

If any path exists, **stop and ask the user**: update, leave alone, or
reinstall. Show what is there first — those directories may hold hand-written
skills that are unrecoverable once overwritten.

## 2. Install

```bash
npx -y skills add keijiro/unity-skills --skill '*' --agent claude-code universal -y
```

`universal` is the agent entry for `.agents/skills/`, and `claude-code` adds the
`.claude/skills/` symlinks. Pin both; `--all` expands to `--agent '*'` and
scatters copies into every other agent's directory.

Each skill lands in `.agents/skills/<name>/`, is linked from
`.claude/skills/<name>`, and is pinned by source and content hash in
`skills-lock.json`. `npx -y skills experimental_install` restores that set
later, but it only refills `.agents/skills/`; re-run the command above to
recreate the `.claude/skills/` symlinks.

## 3. Ignore the artifacts

```bash
scripts/update_gitignore.sh
```

Adds `/skills-lock.json`, `/.agents/skills/`, `/.claude/skills/`, and
`/.claude/settings.local.json` (written in step 4). Paths git already ignores
are skipped via `git check-ignore`, so re-running is safe.

Leave out any path step 1 found **already tracked** — a `.gitignore` entry does
not untrack a file. Ask whether to `git rm --cached` it first.

## 4. Mark the skills `name-only` (Claude Code only)

Other agents have no `skillOverrides` setting; skip this step silently when the
user only wants the `.agents/skills/` install.

```bash
scripts/set_name_only.py
```

Merges `"<name>": "name-only"` into `skillOverrides` in
`.claude/settings.local.json` for every skill in the lock file, keeping other
settings and any override the user set to a different value. `name-only` lists a
skill by name without its description, keeping 31 descriptions out of context
while leaving the skills invocable.

Local scope is deliberate: the skills are gitignored, so overrides in the shared
`settings.json` would reach teammates as dead entries. Pass
`--settings .claude/settings.json` if the user wants them shared.

## 5. Report

Give the skill count, both install directories, the ignored paths, and the
settings file. Overrides apply next session; `/skills` shows the current state.

## Resources

- `scripts/update_gitignore.sh`: Ignore the lock file, `.agents/skills/`, `.claude/skills/`, and `.claude/settings.local.json`.
- `scripts/set_name_only.py`: Set `name-only` overrides for every locked skill.
