# Workflow Instructions for Agents

## Project Structure

The `Packages` directory contains the primary UPM package developed in the
repository. Its name follows the `jp.keijiro.[package-name]` pattern.

The repository root contains `README.md`, `CHANGELOG.md`, and `LICENSE`.
Equivalent files exist inside the package, so keep them synchronized whenever
you update the root-level documents.

## Updating the Changelog

Updating the changelog means bringing the `[Unreleased]` section of
`CHANGELOG.md` up to date.

- Review git commits made since the previous release.
- Append the relevant changes to `[Unreleased]`.
- Preserve useful manual notes that are already present.
- Add the `[Unreleased]` section if it is missing.

## Preparing a Package Release

Preparing a package release means refreshing the UPM package data inside the
`Packages` directory so it is ready for a new version.

Perform the following tasks:

- Bump the `version` field in `package.json`.
- Update the `_upm` element in `package.json` as described below.
- Change the `[Unreleased]` heading in `CHANGELOG.md` to the new version and
  today's date.
- Commit the changes and create a git tag for the new version number.

## `_upm` in package.json

The `_upm` element in `package.json` contains only the `changelog` entry.

- Copy the latest released version section from `CHANGELOG.md` into that entry.
- Remove the section heading that contains the version number and date.
- Convert the content to Unity Rich Text.
- Use `<b>` tags for headings and `<br>` for line breaks.
- Insert an extra `<br>` before every heading after the first one.

## Releasing the Package

Releasing the package means packing the signed tarball with the `upm` CLI and
publishing it as the new version.

Perform the following tasks:

- Run `scripts/pack_package.sh` to create the `[package-name]-[version].tgz`
  tarball in the repository root.
- The script retrieves `UPM_SERVICE_ACCOUNT_KEY_ID`,
  `UPM_SERVICE_ACCOUNT_KEY_SECRET`, and `UPM_SERVICE_ACCOUNT_ORG_ID` from macOS
  Keychain with `security find-generic-password`.
- If Keychain credentials are missing or `upm pack` fails, stop and report the
  error.
- Push commits and tags to the remote repository before creating the release.
- Use `gh` to create a GitHub release.
- Copy the latest `CHANGELOG.md` version section into the release notes,
  omitting the section title.
- Use a heredoc for release notes when they contain line breaks.
- Make the release title a concise summary in the form `[version]: [title]`.
- Confirm the title with the user before finalizing the release.
- Instruct the user to use `npm` to publish the tarball.
