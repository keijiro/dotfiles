# Migration Steps for the Unity Package Release Workflow

This manual describes the migration steps required to update the Unity package
release workflow so it works with the signing feature introduced in Unity 6.3.

## Step 1: Add CHANGELOG.md

Create `CHANGELOG.md` in the repository root based on the current workflow
reference.

- Remove any placeholders.
- Append entries for the two most recent versions.
- Derive these versions from the latest two releases on GitHub.
- Summarize the release details using release notes and git commit logs.

Useful command:

```bash
gh release list --limit 2
```

## Step 2: Update package.json

Update `package.json` inside `Packages/jp.keijiro.(package-id)` using the
current workflow reference as the target shape.

- Reorder the fields to match the reference style.
- Add missing fields such as `changelogUrl`.
- Derive URLs from the git remote.
- Remove obsolete entries such as `keywords` and `unityRelease`.
- Add an empty changelog entry inside the `_upm` element.

Keep `_upm.changelog` empty during migration. It will be generated when
preparing the next release.

## Step 3: Copy CHANGELOG.md

Copy the root `CHANGELOG.md` into the package directory.

## Step 4: Ignore the Tarball

Add `/*.tgz` to `.gitignore`.

## Step 5: Remove .github

Delete the `.github` directory because GitHub Actions are no longer required.

## Step 6: Finish Up

Ask the user to perform the following actions:

- Open the project in the Unity Editor to generate `.meta` files.
- Commit and push every change if there are no issues.
