---
name: unity-create-project
description: Use when creating a new minimal Unity project.
allowed-tools:
  - Bash
---

# New bare minimum project

Use this when asked to create an empty project.

The `unity` CLI recognizes a directory as a Unity project when it contains the following:

- An `Assets` directory
- A `ProjectSettings/ProjectVersion.txt` file (may be empty)

```bash
mkdir -p MyProject/Assets MyProject/ProjectSettings
touch MyProject/ProjectSettings/ProjectVersion.txt
```

# New project from a minimal template

The `github.com/keijiro/UnityProjectTemplate` repository provides the following minimal templates as subdirectories:

- AIA-URP3D: Minimal 3D URP project with the AI Assistant package.
- URP-UITK: Minimal 3D URP project with the UI Toolkit package.
- URP: Minimal 3D URP project.

Use one of these templates when asked to create a new Unity project that fits one of these categories. To instantiate a template, clone the repository into a temporary directory, move the desired subdirectory to the destination, then delete the temporary directory.

```bash
tmp=$(mktemp -d)
git clone --depth 1 https://github.com/keijiro/UnityProjectTemplate "$tmp"
mv "$tmp/URP" MyProject
rm -rf "$tmp"
```
