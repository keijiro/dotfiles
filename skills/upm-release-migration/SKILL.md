---
name: upm-release-migration
description: Migrate an existing Unity UPM package repository to the newer release workflow used for Unity 6.3 signing support. Use when a repository lacks the new root/package `CHANGELOG.md` copies, needs `package.json` field cleanup such as `changelogUrl` and `_upm.changelog`, or still contains obsolete GitHub Actions release automation.
---

# UPM Release Migration

Use this skill to migrate an existing UPM repository to the current release workflow.

## Start Here

- Find the package directory under `Packages/jp.keijiro.*`.
- Inspect the repository root, `package.json`, `.gitignore`, and `.github`.
- Read [references/migration.md](references/migration.md) before making changes.

## Migration Steps

- Create `CHANGELOG.md` in the repository root.
- Populate the changelog with the latest two GitHub releases, using release notes and commit history.
- Update `Packages/jp.keijiro.(package-id)/package.json` to the new layout and field set.
- Reorder fields to match the current reference style.
- Add `changelogUrl` and any other missing URLs derived from the git remote.
- Remove obsolete fields such as `keywords` and `unityRelease`.
- Add `_upm.changelog` with an empty string.
- Copy the root `CHANGELOG.md` into the package directory.
- Add `/*.tgz` to `.gitignore`.
- Remove the `.github` directory.

## Finish

- Ask the user to open the project in the Unity Editor to generate `.meta` files.
- Ask the user to review, commit, and push the migration if everything looks correct.

## Guardrails

- Derive changelog content from real releases and commits.
- Do not leave placeholder text in `CHANGELOG.md`.
- Keep the new root/package changelog copies identical.

## Resources

- [references/migration.md](references/migration.md): Detailed migration checklist and repository expectations.
