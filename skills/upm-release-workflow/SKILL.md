---
name: upm-release-workflow
description: Maintain and release a Unity UPM package repository that follows the `Packages/jp.keijiro.*` layout. Use when updating the `Unreleased` section in `CHANGELOG.md`, preparing a new package release, generating `package.json` `_upm.changelog` metadata, syncing root/package documentation files, packing a signed tarball with `upm`, creating a GitHub release, or checking release readiness. Keep npm publishing as a manual user step.
---

# UPM Release Workflow

Use this skill for routine maintenance and release work on a Unity UPM package repository.

## Start Here

- Find the package directory with `scripts/detect_package_dir.sh`.
- Confirm the repository root contains `README.md`, `CHANGELOG.md`, and `LICENSE`.
- Confirm the package directory contains synchronized copies of those files.
- Read [references/workflow.md](references/workflow.md) before changing release metadata or creating a GitHub release.

## Route the Request

Use one of these paths.

### Update the changelog

- Review commits since the previous release.
- Update or create the `Unreleased` section in the root `CHANGELOG.md`.
- Preserve any manual notes that are still accurate.
- Sync the package copy of `CHANGELOG.md`.

### Prepare a package release

- Bump the package version in `Packages/.../package.json`.
- Rename the `Unreleased` heading in `CHANGELOG.md` to the new version and today's date.
- Generate `_upm.changelog` from the newest released changelog section with `scripts/render_upm_changelog.py`.
- Sync `README.md`, `CHANGELOG.md`, and `LICENSE` into the package directory with `scripts/sync_package_docs.sh`.
- Commit the changes and create a git tag for the version.

### Release the package

- Pack the package tarball into the repository root with `scripts/pack_package.sh`.
- The script reads `UPM_SERVICE_ACCOUNT_KEY_ID`, `UPM_SERVICE_ACCOUNT_KEY_SECRET`, and `UPM_SERVICE_ACCOUNT_ORG_ID` from macOS Keychain and invokes `upm pack`.
- Confirm the generated `[package-name]-[version].tgz` tarball exists in the repository root.
- Push commits and tags before creating the GitHub release.
- Build release notes from the latest `CHANGELOG.md` version section, omitting the section heading.
- Confirm the release title with the user in the form `[version]: [title]`.
- Create the GitHub release with `gh`.
- Instruct the user to run `npm publish` manually after the GitHub release is ready.

## Guardrails

- Keep root/package copies of `README.md`, `CHANGELOG.md`, and `LICENSE` synchronized.
- Do not invent release notes. Derive them from `CHANGELOG.md` and commit history.
- Do not publish to npm from the agent.
- Stop for user input when Keychain credentials are missing, `upm pack` fails, or a release title is required.

## Resources

- [references/workflow.md](references/workflow.md): Detailed workflow rules and release expectations.
- `scripts/detect_package_dir.sh`: Print the package directory under `Packages/jp.keijiro.*`.
- `scripts/pack_package.sh`: Pack the package tarball with `upm` using macOS Keychain credentials.
- `scripts/render_upm_changelog.py`: Convert the newest released changelog section into Unity Rich Text for `_upm.changelog`.
- `scripts/sync_package_docs.sh`: Copy root documentation files into the package directory.
